//
//  QDCollectionListViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/4/19.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

class QDCollectionListViewController: QDCommonListViewController {

    override func initDataSource() {
        super.initDataSource()
        
        dataSource = ["默认",
                      "缩放",
                      "旋转"]
    }
    
    override func didSelectCell(_ title: String) {
        var viewController: UIViewController?
        if title == "默认" {
            viewController = QDCollectionDemoViewController()
            if let viewController = viewController as? QDCollectionDemoViewController {
                viewController.collectionViewLayout.minimumLineSpacing = 20
            }
        } else if title == "缩放" {
            viewController = QDCollectionDemoViewController(style: .scale)
            if let viewController = viewController as? QDCollectionDemoViewController {
                viewController.collectionViewLayout.minimumLineSpacing = 0
            }
        } else if title == "旋转" {
            viewController = QDCollectionDemoViewController(style: .rotation)
            if let viewController = viewController as? QDCollectionDemoViewController {
                viewController.collectionViewLayout.minimumLineSpacing = 20
            }
        }
        
        if let viewController = viewController {
            viewController.title = title
            navigationController?.pushViewController(viewController, animated: true)
        }
    }

}
