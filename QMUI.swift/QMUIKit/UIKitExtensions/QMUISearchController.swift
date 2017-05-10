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
    func searchController(_ searchController: QMUISearchController, updateResultsFor searchString: String)
    
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

    open weak var searchResultsDelegate: QMUISearchControllerDelegate?

    private var searchController: UISearchController?

    /**
     * 在某个指定的UIViewController上创建一个与其绑定的searchController
     * @param viewController 要在哪个viewController上添加搜索功能
     */
    convenience init(contentsViewController _: UIViewController) {
        self.init(nibName: nil, bundle: nil)
    }

    open var searchBar: UISearchBar? { return nil }

    open var tableView: UITableView? {
        if let searchController = searchController {
            return (searchController.searchResultsController as? QMUICommonTableViewController)?.tableView
        }
        return nil
    }
    
    /// 在搜索文字为空时会展示的一个 view，通常用于实现“最近搜索”之类的功能。launchView 最终会被布局为撑满搜索框以下的所有空间。
    open var launchView: UIView? {
        didSet {
            if searchController != nil {
//                searchController.customDimmingView = launchView
            } else {
//                searchDisplayController.customDimmingView = launchView
            }
        }
    }

    /// 控制以无动画的形式进入/退出搜索状态
    open var isActive: Bool {
        return searchController?.isActive ?? false
    }
    
    /**
     *  控制进入/退出搜索状态
     *  @param active YES 表示进入搜索状态，NO 表示退出搜索状态
     *  @param animated 是否要以动画的形式展示状态切换
     */
    func setActive(_ active: Bool, animated: Bool) {
        if let searchController = searchController {
            searchController.isActive = active
        } else {
//            searchDisplayController?.setActive(active, animated: animated)
        }
    }
}
