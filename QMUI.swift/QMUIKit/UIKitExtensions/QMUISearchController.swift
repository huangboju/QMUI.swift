//
//  QMUISearchController.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/2/9.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

/**
 * 配合QMUISearchController使用的protocol，主要负责两件事情：
 *
 * <ol>
 * <li>响应用户的输入，在搜索框内的文字发生变化后被调用，可在<i>searchController:updateResultsForSearchString:</i>方法内更新搜索结果的数据集，在里面请自行调用<i>[searchController.tableView reloadData]</i></li>
 * <li>渲染最终用于显示搜索结果的UITableView的数据，该tableView的delegate、dataSource均在这里实现</li>
 * </ol>
 */
protocol QMUISearchControllerDelegate: UITableViewDataSource, UITableViewDelegate {
    /**
     * 搜索框文字发生变化时的回调，请自行调用 `[tableView reloadData]` 来更新界面。
     * @warning 搜索框文字为空（例如第一次点击搜索框进入搜索状态时，或者文字全被删掉了，或者点击搜索框的×）也会走进来，此时参数searchString为@""，这是为了和系统的UISearchController保持一致
     */
    func searchController(_ searchController: QMUISearchController, updateResultsFor searchString: String?)

    func willPresent(_ searchController: QMUISearchController)
    func didPresent(_ searchController: QMUISearchController)
    func willDismiss(_ searchController: QMUISearchController)
    func didDismiss(_ searchController: QMUISearchController)
    func search(_ controller: QMUISearchController, didLoadSearchResults tableView: UITableView)
    func search(_ Controller: QMUISearchController, willShow emptyView: QMUIEmptyView)
}

extension QMUISearchControllerDelegate {
    func willPresent(_: QMUISearchController) {}
    func didPresent(_: QMUISearchController) {}
    func willDismiss(_: QMUISearchController) {}
    func didDismiss(_: QMUISearchController) {}
    func search(_: QMUISearchController, didLoadSearchResults _: UITableView) {}
    func search(_: QMUISearchController, willShow _: QMUIEmptyView) {}
}

protocol QMUISearchResultsTableViewControllerDelegate: class {
    func didLoadTableViewInSearchResultsTableViewController(_ viewController: QMUISearchResultsTableViewController)
}

class QMUISearchResultsTableViewController: QMUICommonTableViewController {
    open weak var delegate: QMUISearchResultsTableViewControllerDelegate?

    override func initTableView() {
        super.initTableView()
        tableView.keyboardDismissMode = .onDrag
        delegate?.didLoadTableViewInSearchResultsTableViewController(self)
    }
}

class QMUICustomSearchController: UISearchController {
    var customDimmingView: UIView? {
        didSet {
            if oldValue != customDimmingView {
                oldValue?.removeFromSuperview()
            }
            dimsBackgroundDuringPresentation = customDimmingView == nil
            if isViewLoaded {
                addCustomDimmingView()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addCustomDimmingView()
    }

    func addCustomDimmingView() {
        let superviewOfDimmingView = searchResultsController?.view.superview
        if let customDimmingView = customDimmingView, customDimmingView.superview != superviewOfDimmingView {
            superviewOfDimmingView?.insertSubview(customDimmingView, at: 0)
            layoutCustomDimmingView()
        }
    }

    func layoutCustomDimmingView() {
        var searchBarContainerView: UIView?
        for subview in view.subviews {
            if "\(subview.classForCoder)" == "_UISearchBarContainerView" {
                searchBarContainerView = subview
                break
            }
        }

        customDimmingView?.frame = customDimmingView!.superview!.bounds.insetEdges(UIEdgeInsets(top: (searchBarContainerView != nil ? searchBarContainerView!.frame.maxY : 0), left: 0, bottom: 0, right: 0))
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if customDimmingView != nil {
            UIView.animate(withDuration: CATransaction.animationDuration()) {
                self.layoutCustomDimmingView()
            }
        }
    }
}

/**
 * 在iOS8及以后会使用UISearchController实现。<br/>
 * 使用方法：
 * <ol>
 * <li>使用<i>initWithContentsViewController:</i>初始化</li>
 * <li>指定<i>searchResultsDelegate</i>属性并在其中实现<i>searchController:updateResultsForSearchString:</i>方法以更新搜索结果数据集</li>
 * <li>通过<i>searchBar</i>属性得到搜索框的引用并直接使用，例如 @code tableHeaderView = searchController.searchBar @endcode</li>
 * </ol>
 */
class QMUISearchController: QMUICommonViewController {

    open weak var searchResultsDelegate: QMUISearchControllerDelegate? {
        didSet {
            tableView?.dataSource = searchResultsDelegate
            tableView?.delegate = searchResultsDelegate
        }
    }

    private var searchController: QMUICustomSearchController?

    /**
     * 在某个指定的UIViewController上创建一个与其绑定的searchController
     * @param viewController 要在哪个viewController上添加搜索功能
     */
    convenience init(contentsViewController viewController: UIViewController) {
        self.init(nibName: nil, bundle: nil)

        // 将 definesPresentationContext 置为 YES 有两个作用：
        // 1、保证从搜索结果界面进入子界面后，顶部的searchBar不会依然停留在navigationBar上
        // 2、使搜索结果界面的tableView的contentInset.top正确适配searchBar
        viewController.definesPresentationContext = true

        let searchResultsViewController = QMUISearchResultsTableViewController()
        searchResultsViewController.delegate = self
        searchController = QMUICustomSearchController(searchResultsController: searchResultsViewController)
        searchController?.searchResultsUpdater = self
        searchController?.delegate = self
        searchBar = searchController?.searchBar
        if searchBar?.frame.isEmpty ?? true {
            // iOS8 下 searchBar.frame 默认是 CGRectZero，不 sizeToFit 就看不到了
            searchBar?.sizeToFit()
        }
        searchBar?.qmui_styledAsQMUISearchBar()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // 主动触发 loadView，如果不这么做，那么有可能直到 QMUISearchController 被销毁，这期间 self.searchController 都没有被触发 loadView，然后在 dealloc 时就会报错，提示尝试在释放 self.searchController 时触发了 self.searchController 的 loadView
        if #available(iOS 9.0, *) {
            searchController?.loadViewIfNeeded()
        }
    }

    open private(set) var searchBar: UISearchBar?

    open var tableView: UITableView? {
        if let searchController = searchController {
            return (searchController.searchResultsController as? QMUICommonTableViewController)?.tableView
        }
        return nil
    }

    /// 在搜索文字为空时会展示的一个 view，通常用于实现“最近搜索”之类的功能。launchView 最终会被布局为撑满搜索框以下的所有空间。
    open var launchView: UIView? {
        didSet {
            searchController?.customDimmingView = launchView
        }
    }

    /// 控制以无动画的形式进入/退出搜索状态
    open var isActive: Bool {
        set {
            setActive(newValue, animated: false)
        }
        get {
            return searchController?.isActive ?? false
        }
    }

    /**
     *  控制进入/退出搜索状态
     *  @param active YES 表示进入搜索状态，NO 表示退出搜索状态
     *  @param animated 是否要以动画的形式展示状态切换
     */
    open func setActive(_ active: Bool, animated _: Bool) {
        searchController?.isActive = active
    }

    /// 进入搜索状态时是否要把原界面的 navigationBar 推走，默认为 true
    var hidesNavigationBarDuringPresentation: Bool {
        set {
            searchController?.hidesNavigationBarDuringPresentation = newValue
        }
        get {
            return searchController?.hidesNavigationBarDuringPresentation ?? true
        }
    }

    // MARK: - QMUIEmptyView

    override func showEmptyView() {
        // 搜索框文字为空时，界面会显示遮罩，此时不需要显示emptyView了
        // 为什么加这个是因为当搜索框被点击时（进入搜索状态）会触发searchController:updateResultsForSearchString:，里面如果直接根据搜索结果为空来showEmptyView的话，就会导致在遮罩层上有emptyView出现，要么在那边showEmptyView之前判断一下searchBar.text.length，要么在showEmptyView里判断，为了方便，这里选择后者。
        if searchBar?.text?.isEmpty ?? true {
            return
        }

        super.showEmptyView()

        // 格式化样式，以适应当前项目的需求
        emptyView?.backgroundColor = TableViewBackgroundColor ?? UIColorWhite
        searchResultsDelegate?.search(self, willShow: emptyView!)

        if let searchController = searchController {
            let superview = searchController.searchResultsController?.view
            superview?.addSubview(emptyView!)
        } else {
            assert(false, "QMUISearchController无法为emptyView找到合适的superview")
        }

        layoutEmptyView()
    }
}

// MARK: - UISearchResultsUpdating
extension QMUISearchController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        searchResultsDelegate?.searchController(self, updateResultsFor: searchController.searchBar.text)
    }
}

// MARK: - QMUISearchResultsTableViewControllerDelegate
extension QMUISearchController: QMUISearchResultsTableViewControllerDelegate {
    func didLoadTableViewInSearchResultsTableViewController(_ viewController: QMUISearchResultsTableViewController) {
        searchResultsDelegate?.search(self, didLoadSearchResults: viewController.tableView)
    }
}

// MARK: - UISearchControllerDelegate
extension QMUISearchController: UISearchControllerDelegate {

    func willPresentSearchController(_: UISearchController) {
        searchResultsDelegate?.willPresent(self)
    }

    func didPresentSearchController(_: UISearchController) {
        searchResultsDelegate?.didPresent(self)
    }

    func willDismissSearchController(_: UISearchController) {
        searchResultsDelegate?.willDismiss(self)
    }

    func didDismissSearchController(_: UISearchController) {
        hideEmptyView()
        searchResultsDelegate?.didDismiss(self)
    }
}
