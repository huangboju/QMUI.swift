//
//  UITableView+QMUI.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/3/17.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

extension UITableView {
    func qmui_styledAsQMUITableView() {
        backgroundColor = style == .plain ? TableViewBackgroundColor : TableViewGroupedBackgroundColor
        separatorColor = TableViewSeparatorColor
        tableFooterView = UIView() // 去掉尾部空cell
        backgroundView = UIView() // 设置一个空的backgroundView，去掉系统的，以使backgroundColor生效

        sectionIndexColor = TableSectionIndexColor
        sectionIndexTrackingBackgroundColor = TableSectionIndexTrackingBackgroundColor
        sectionIndexBackgroundColor = TableSectionIndexBackgroundColor
    }

    func qmui_clearsSelection() {
        guard let selectedIndexPaths = indexPathsForSelectedRows else { return }
        for indexPath in selectedIndexPaths {
            deselectRow(at: indexPath, animated: true)
        }
    }
}
