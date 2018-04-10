//
//  QDButtonViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/4/9.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

class QDButtonViewController: QDCommonListViewController {

    override func initDataSource() {
        dataSource = ["QMUIButton",
                      "QMUILinkButton",
                      "QMUIGhostButton",
                      "QMUIFillButton",
                      "QMUINavigationButton",
                      "QMUIToolbarButton"]
    }
    
    override func didSelectCell(_ title: String) {
        var viewController: UIViewController?
        if title == "QMUIButton" {
            viewController = QDNormalButtonViewController()
        }
        if title == "QMUILinkButton" {
            viewController = QDLinkButtonViewController()
        }
        if title == "QMUIGhostButton" {
            viewController = QDGhostButtonViewController()
        }
        if title == "QMUIFillButton" {
            viewController = QDFillButtonViewController()
        }
        if title == "QMUINavigationButton" {
            viewController = QDNavigationButtonViewController()
        }
        if title == "QMUIToolbarButton" {
            viewController = QDToolBarButtonViewController()
        }
        
        if let viewController = viewController {
            viewController.title = title
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }

    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            let viewController = QDButtonEdgeInsetsViewController()
            let navController = QDNavigationController(rootViewController: viewController)
            self.present(navController, animated: true, completion: nil)
        }
    }
}
