//
//  QDFontViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/4/24.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

class QDFontViewController: QDCommonGroupListViewController {

    override func initDataSource() {
        super.initDataSource()
        
        let od1 = QMUIOrderedDictionary(
            dictionaryLiteral:
            ("UIFontMake", ""),
            ("UIFontItalicMake", ""),
            ("UIFontBoldMake", ""),
            ("UIFontLightMake", ""))
        let od2 = QMUIOrderedDictionary(
            dictionaryLiteral:
            ("UIDynamicFontMake", ""),
            ("UIDynamicFontBoldMake", ""),
            ("UIDynamicFontLightMake", ""))
        dataSource = QMUIOrderedDictionary(
            dictionaryLiteral:
            ("默认", od1), ("动态字体", od2))
    }
    
    override func setupNavigationItems() {
        super.setupNavigationItems()
        title = "UIFont+QMUI"
    }
    
    override func contentSizeCategoryDidChanged(_ notification: Notification) {
        super.contentSizeCategoryDidChanged(notification)
        // QMUICommonTableViewController 默认会在这个方法里响应动态字体大小变化，并自动调用 [self.tableView reloadData]，所以使用者只需要保证在 cellForRow 里更新动态字体大小即可，不需要手动监听动态字体的变化。
    }
    
    // MARK: QMUITableViewDataSource, QMUITableViewDelegate
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.accessoryType = .none
        cell.selectionStyle = .none
        
        let key = keyName(at: indexPath)
        var font: UIFont?
        let pointSize: CGFloat = 15
        
        if key == "UIFontMake" {
            font = UIFontMake(pointSize)
        } else if key == "UIFontItalicMake" {
            font = UIFontItalicMake(pointSize)
        } else if key == "UIFontBoldMake" {
            font = UIFontBoldMake(pointSize)
        } else if key == "UIFontLightMake" {
            font = UIFontLightMake(pointSize)
        } else if key == "UIDynamicFontMake" {
            font = UIDynamicFontMake(pointSize)
        } else if key == "UIDynamicFontBoldMake" {
            font = UIDynamicFontBoldMake(pointSize)
        } else if key == "UIDynamicFontLightMake" {
            font = UIDynamicFontLightMake(pointSize)
        }
        
        cell.textLabel?.font = font
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 1 {
            let path = IS_SIMULATOR ? "设置-通用-辅助功能-Larger Text" : "设置-显示与亮度-文字大小"
            return "请到“\(path)”里修改文字大小再观察当前界面的变化"
        }
        return nil
    }
}
