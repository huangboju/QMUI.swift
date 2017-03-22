//
//  QMUISearchController.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/2/9.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

/**
 * 兼容iOS7及以后的版本的searchController，在iOS7下会使用UISearchDisplayController实现，在iOS8及以后会使用UISearchController实现。<br/>
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

    var searchBar: UISearchBar? { return nil }

    var tableView: UITableView? {
        if let searchController = searchController {
            return (searchController.searchResultsController as? QMUICommonTableViewController)?.tableView
        }
        return nil
    }

    var active: Bool {
        return searchController?.isActive ?? false
    }
}
