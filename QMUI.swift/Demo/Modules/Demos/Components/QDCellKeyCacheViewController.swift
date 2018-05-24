//
//  QDCellKeyCacheViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/5/23.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

class QDCellKeyCacheViewController: QDCommonListViewController {

    override func initDataSource() {
        dataSource = ["QMUICellHeightKeyCache",
                      "QMUICellSizeKeyCache"]
    }
    
    override func didSelectCell(_ title: String) {
        tableView.qmui_clearsSelection()
        var viewController: UIViewController?
        if title == "QMUICellHeightKeyCache" {
            viewController = QDCellHeightKeyCacheViewController()
        } else if title == "QMUICellSizeKeyCache" {
            viewController = QDCellSizeKeyCacheViewController()
        }
        
        if let viewController = viewController {
            viewController.title = title
            navigationController?.pushViewController(viewController, animated: true)
        }
    }

}
