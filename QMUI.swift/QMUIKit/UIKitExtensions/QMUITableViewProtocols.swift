//
//  QMUITableViewProtocols.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/3/17.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

protocol qmui_UITableViewDataSource: class {
    func qmui_tableView(_ tableView: UITableView, cellWithIdentifier identifier: String) -> UITableViewCell
}

extension qmui_UITableViewDataSource {
    // TODO: 这里是不是回有BUG?
    // 在这个方法有用到func templateCell(forReuseIdentifier identifier: String) -> UITableViewCell
    func qmui_tableView(_: UITableView, cellWithIdentifier _: String) -> UITableViewCell {
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
