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
    func qmui_tableView(_: UITableView, cellWith _: String) -> UITableViewCell {
        return UITableViewCell()
    }
}

protocol QMUITableViewDelegate: UITableViewDelegate {

    /**
     * 自定义要在<i>- (BOOL)touchesShouldCancelInContentView:(UIView *)view</i>内的逻辑<br/>
     * 若delegate不实现这个方法，则默认对所有UIControl返回NO（UIButton除外，它会返回YES），非UIControl返回YES。
     */
    func tableView(_ tableView: QMUITableView, touchesShouldCancelIn contentView: UIView) -> Bool
}

protocol QMUITableViewDataSource: UITableViewDataSource, qmui_UITableViewDataSource {}


extension QMUITableViewDelegate {
    func shouldShowSearchBar(in _: QMUITableView) -> Bool {
        return false
    }

    func tableView(_: QMUITableView, touchesShouldCancelIn _: UIView) -> Bool {
        return false
    }
}
