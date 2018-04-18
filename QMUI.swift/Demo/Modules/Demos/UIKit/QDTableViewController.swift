//
//  QDTableViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/4/18.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

/// QMUIKit 首页那个 tableView 的 demo 列表
class QDTableViewController: QDCommonListViewController {

    override func initDataSource() {
        dataSource = ["QMUITableViewCell",
                      "QMUITableViewHeaderFooterView"]
    }
    
    override func didSelectCell(_ title: String) {
        tableView.qmui_clearsSelection()
        var viewController: UIViewController?
        if title == "QMUITableViewCell" {
            viewController = QDTableViewCellViewController()
        } else if title == "QMUITableViewHeaderFooterView" {
            viewController = QDTableViewHeaderFooterViewController()
        }
        
        if let viewController = viewController {
            viewController.title = title
            navigationController?.pushViewController(viewController, animated: true)
        }
    }

}
