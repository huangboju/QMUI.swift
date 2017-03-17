//
//  QDCommonGridViewController.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/2/9.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

/**
 *  配合属性 `tableViewInitialContentInset` 使用，标志 `tableViewInitialContentInset` 是否有被修改过
 *  @see tableViewInitialContentInset
 */
let QMUICommonTableViewControllerInitialContentInsetNotSet = UIEdgeInsets(top: -1, left: -1, bottom: -1, right: -1)

let kSectionHeaderFooterLabelTag = 1024

/**
 *  可作为项目内所有 `UITableViewController` 的基类，注意是继承自 `QMUICommonViewController` 而不是 `UITableViewController`。
 *
 *  一般通过 `initWithStyle:` 方法初始化，对于要生成 `UITableViewStylePlain` 类型的列表，推荐使用 `init:` 方法。
 *
 *  提供的功能包括：
 *
 *  1. 集成 `QMUISearchController`，可通过在 `shouldShowSearchBarInTableView:` 里返回 `YES` 来快速为列表生成一个搜索框。
 *
 *  2. 通过属性 `tableViewInitialContentInset` 和 `tableViewInitialScrollIndicatorInsets` 来提供对界面初始状态下的列表 `contentInset`、`contentOffset` 的调整能力，一般在系统的 `automaticallyAdjustsScrollViewInsets` 属性无法满足需求时使用。
 *
 *  @warning 在 `QMUICommonTableViewController` 里的 emptyView 将会以 `tableFooterView` 的方式显示出来，所以如果你的界面拥有自己的 `tableFooterView`，则需要重写 `showEmptyView`、`hideEmptyView` 来处理你的 footerView 和 emptyView 的显隐冲突问题。
 *
 *  @see QMUISearchController
 */
class QMUICommonTableViewController: QMUICommonViewController {
    /// 获取当前的 `UITableViewStyle`
    private(set) var style: UITableViewStyle!
    
    /// 获取当前的 tableView
    private(set) var tableView: QMUITableView!
    
    private var hasHideTableHeaderViewInitial = false
    private var hasSetInitialContentInset = false

    /**
     *  列表使用自定义的contentInset，不使用系统默认计算的，默认为QMUICommonTableViewControllerInitialContentInsetNotSet。<br/>
     *  当更改了这个值后，会把self.automaticallyAdjustsScrollViewInsets = NO
     */
    var tableViewInitialContentInset: UIEdgeInsets!
    
    /**
     *  是否需要让scrollIndicatorInsets与tableView.contentInsets区分开来，如果不设置，则与tableView.contentInset保持一致。
     *
     *  只有当更改了tableViewInitialContentInset后，这个属性才会生效。
     */
    var tableViewInitialScrollIndicatorInsets: UIEdgeInsets!
    
    convenience init() {
        self.init(style: .plain)
    }

    init(style: UITableViewStyle) {
        super.init(nibName: nil, bundle: nil)
        didInitialized(with: style)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        didInitialized(with: .plain)
    }

    func didInitialized(with style: UITableViewStyle) {
        self.style = style;
        tableViewInitialContentInset = QMUICommonTableViewControllerInitialContentInsetNotSet
        tableViewInitialScrollIndicatorInsets = QMUICommonTableViewControllerInitialContentInsetNotSet
    }
    
    deinit {
        tableView.delegate = nil
        tableView.dataSource = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = style == .plain ? TableViewBackgroundColor : TableViewGroupedBackgroundColor
    }
    
    override func initSubviews() {
        super.initSubviews()
        initTableView()
        initSearchController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.qmui_clearsSelection()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let shouldChangeTableViewFrame = view.bounds != tableView.frame
        if shouldChangeTableViewFrame {
            tableView.frame = view.bounds
        }

        if shouldAdjustTableViewContentInsetsInitially && !hasSetInitialContentInset {
            tableView.contentInset = tableViewInitialContentInset
            if shouldAdjustTableViewScrollIndicatorInsetsInitially {
                tableView.scrollIndicatorInsets = tableViewInitialScrollIndicatorInsets
            } else {
                // 默认和tableView.contentInset一致
                tableView.scrollIndicatorInsets = tableView.contentInset
            }
            [self.tableView qmui_scrollToTop];
            hasSetInitialContentInset = true
        }
        
        [self hideTableHeaderViewInitialIfCanWithAnimated:NO];
        
        layoutEmptyView()
    }

    var shouldAdjustTableViewContentInsetsInitially: Bool {
        return tableViewInitialContentInset != QMUICommonTableViewControllerInitialContentInsetNotSet
    }

    var shouldAdjustTableViewScrollIndicatorInsetsInitially: Bool {
        return tableViewInitialScrollIndicatorInsets != QMUICommonTableViewControllerInitialContentInsetNotSet
    }
}

// MARK: - QMUISubclassingHooks
extension QMUICommonTableViewController {
    /**
     *  初始化tableView，在initSubViews的时候被自动调用。
     *
     *  一般情况下，有关tableView的设置属性的代码都应该写在这里。
     */
    func initTableView() {}
    
    /**
     *  是否需要在第一次进入界面时将tableHeaderView隐藏（通过调整self.tableView.contentOffset实现）
     *
     *  默认为NO
     *
     *  @see QMUITableViewDelegate
     */
    var shouldHideTableHeaderViewInitial: Bool { return false }
}

extension QMUICommonTableViewController: QMUISearchControllerDelegate {
    /**
     *  获取当前的searchController，注意只有当 `shouldShowSearchBarInTableView:` 返回 `YES` 时才有用
     *
     *  默认为 `nil`
     *
     *  @see QMUITableViewDelegate
     */
    var searchController: QMUISearchController {
        return QMUISearchController()
    }
    
    /**
     *  获取当前的searchBar，注意只有当 `shouldShowSearchBarInTableView:` 返回 `YES` 时才有用
     *
     *  默认为 `nil`
     *
     *  @see QMUITableViewDelegate
     */
    var searchBar: UISearchBar {
        return UISearchBar()
    }

    /**
     *  是否应该在显示空界面时自动隐藏搜索框
     *
     *  默认为 `NO`
     */
    var shouldHideSearchBarWhenEmptyViewShowing: Bool { return false }
    
    /**
     *  初始化searchController和searchBar，在initSubViews的时候被自动调用。
     *
     *  会询问 `[self.tableView.delegate shouldShowSearchBarInTableView:]`，若返回 `YES`，则创建 searchBar 并将其以 `tableHeaderView` 的形式呈现在界面里；若返回 `NO`，则将 `tableHeaderView` 置为nil。
     *
     *  @warning `shouldShowSearchBarInTableView:` 默认返回 NO，需要 searchBar 的界面必须重写该方法并返回 `YES`
     */
    func initSearchController() {}
}
