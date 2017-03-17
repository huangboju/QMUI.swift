//
//  QMUISearchControllerDelegate.swift
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
    func didDismiss(_ searchController:QMUISearchController)
    func search(_ controller: QMUISearchController, didLoadSearchResults tableView: UITableView)
    func search(_ Controller: QMUISearchController, willShow emptyView: QMUIEmptyView)
}

extension QMUISearchControllerDelegate {
    func willPresent(_ searchController: QMUISearchController) {}
    func didPresent(_ searchController: QMUISearchController) {}
    func willDismiss(_ searchController: QMUISearchController) {}
    func didDismiss(_ searchController:QMUISearchController) {}
    func search(_ controller: QMUISearchController, didLoadSearchResults tableView: UITableView) {}
    func search(_ Controller: QMUISearchController, willShow emptyView: QMUIEmptyView) {}
}
