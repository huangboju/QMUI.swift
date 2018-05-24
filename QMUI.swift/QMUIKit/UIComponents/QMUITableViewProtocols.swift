//
//  QMUITableViewProtocols.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/3/17.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

@objc protocol QMUICellHeightCache_UITableViewDataSource {
    /// 搭配 QMUICellHeightCache 使用，对于 UITableView 而言如果要用 QMUICellHeightCache 那套高度计算方式，则必须实现这个方法
    @objc optional func qmui_tableView(_ tableView: UITableView, cellWithIdentifier identifier: String) -> UITableViewCell
}

@objc protocol QMUICellHeightKeyCache_UITableViewDelegate {
    @objc optional func qmui_tableView(_ tableView: UITableView, cacheKeyForRowAt indexPath: IndexPath) -> AnyObject
}

@objc protocol QMUITableViewDelegate: UITableViewDelegate, QMUICellHeightKeyCache_UITableViewDelegate {

    /**
     * 自定义要在<i>- (BOOL)touchesShouldCancelInContentView:(UIView *)view</i>内的逻辑<br/>
     * 若delegate不实现这个方法，则默认对所有UIControl返回NO（UIButton除外，它会返回YES），非UIControl返回YES。
     */
    @objc optional func tableView(_ tableView: QMUITableView, touchesShouldCancelIn contentView: UIView) -> Bool
}

protocol QMUITableViewDataSource: UITableViewDataSource, QMUICellHeightCache_UITableViewDataSource {}
