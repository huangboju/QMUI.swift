//
//  QDTableViewCellViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/4/18.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

/// 展示 QMUITableViewCell 能力的 demo 列表
class QDTableViewCellViewController: QDCommonListViewController {

    override func initDataSource() {
        dataSource = ["通过 insets 系列属性调整间距",
                      "通过配置表修改 accessoryType 的样式",
                      "动态高度计算"]
    }
    
    override func didSelectCell(_ title: String) {
        tableView.qmui_clearsSelection()
        var viewController: UIViewController?
        if title == "通过 insets 系列属性调整间距" {
            viewController = QDTableViewCellInsetsViewController()
        } else if title == "通过配置表修改 accessoryType 的样式" {
            viewController = QDTableViewCellAccessoryTypeViewController()
        } else if title == "动态高度计算" {
            viewController = QDTableViewCellDynamicHeightViewController()
        }
        
        if let viewController = viewController {
            viewController.title = title
            navigationController?.pushViewController(viewController, animated: true)
        }
    }

}
