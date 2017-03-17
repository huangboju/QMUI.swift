//
//  QMUITableViewProtocols.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/3/17.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

protocol qmui_UITableViewDataSource {
    func qmui_tableView(_ tableView: UITableView, cellWith identifier: String) -> UITableViewCell
}

extension qmui_UITableViewDataSource {
    func qmui_tableView(_ tableView: UITableView, cellWith identifier: String) -> UITableViewCell {
        return UITableViewCell()
    }
}

protocol QMUITableViewDelegate: UITableViewDelegate {

    /** 
     * 控制是否在列表顶部显示搜索框。在QMUICommonTableViewController里已经接管了searchBar的初始化工作，所以外部只需要控制“显示/隐藏”，不需要自己再初始化一次。
     */
    func shouldShowSearchBar(in tableView: QMUITableView) -> Bool

    /** 
     * 自定义要在<i>- (BOOL)touchesShouldCancelInContentView:(UIView *)view</i>内的逻辑<br/>
     * 若delegate不实现这个方法，则默认对所有UIControl返回NO（UIButton除外，它会返回YES），非UIControl返回YES。
     */
    func tableView(_ tableView: QMUITableView, touchesShouldCancelIn contentView: UIView) -> Bool
}

protocol QMUITableViewDataSource: UITableViewDataSource, qmui_UITableViewDataSource {}

// 为了解决可选
extension QMUITableViewDelegate {
    func shouldShowSearchBar(in tableView: QMUITableView) -> Bool {
        return false
    }

    func tableView(_ tableView: QMUITableView, touchesShouldCancelIn contentView: UIView) -> Bool {
        return false
    }
}
