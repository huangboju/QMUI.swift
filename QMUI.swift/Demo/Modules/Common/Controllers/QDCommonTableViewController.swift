//
//  QDCommonTableViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/4/4.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

class QDCommonTableViewController: QMUICommonTableViewController {
    
    override func didInitialized() {
        super.didInitialized()
        NotificationCenter.default.addObserver(self, selector: #selector(handleThemeChanged(_:)), name: Notification.QD.ThemeChanged, object: nil)
    }

    @objc func handleThemeChanged(_ notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        if let beforeChanged = userInfo[QDThemeNameKey.beforeChanged] as? QDThemeProtocol, let afterChanged = userInfo[QDThemeNameKey.afterChanged] as? QDThemeProtocol {
            themeBeforeChanged(beforeChanged, afterChanged: afterChanged)
        }
    }
}

extension QDCommonTableViewController: QDChangingThemeDelegate {
    func themeBeforeChanged(_ beforeChanged: QDThemeProtocol, afterChanged: QDThemeProtocol) {
        tableView.reloadData()
    }
}
