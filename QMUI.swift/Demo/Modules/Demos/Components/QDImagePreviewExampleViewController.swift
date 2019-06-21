//
//  QDImagePreviewExampleViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/5/15.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

class QDImagePreviewExampleViewController: QDCommonListViewController {

    override func initDataSource() {
        super.initDataSource()
        
        
        dataSource = [String(describing: QMUIImagePreviewView.self),
                      String(describing: QMUIImagePreviewViewController.self)]
    }
    
    override func didSelectCell(_ title: String) {
        var viewController: UIViewController?
        if title == String(describing: QMUIImagePreviewView.self) {
            viewController = QDImagePreviewViewController1()
        } else if title == String(describing: QMUIImagePreviewViewController.self) {
            viewController = QDImagePreviewViewController2()
        }
        if let viewController = viewController {
            viewController.title = title
            navigationController?.pushViewController(viewController, animated: true)
        }
    }

}
