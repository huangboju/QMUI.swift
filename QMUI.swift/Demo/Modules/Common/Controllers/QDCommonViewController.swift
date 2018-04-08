//
//  QDCommonViewController.swift
//  QMUI.swift
//
//  Created by TonyHan on 2018/3/6.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

class QDCommonViewController: QMUICommonViewController, QDChangingThemeDelegate {

    override func didInitialized() {
        super.didInitialized()

        NotificationCenter.default.addObserver(self, selector: #selector(handleThemeChanged(_:)), name: Notification.QD.ThemeChanged, object: nil)
    }

    @objc private func handleThemeChanged(_ notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        if let beforeChanged = userInfo[QDThemeNameKey.beforeChanged] as? QDThemeProtocol, let afterChanged = userInfo[QDThemeNameKey.afterChanged] as? QDThemeProtocol {
            themeBeforeChanged(beforeChanged, afterChanged: afterChanged)
        }
    }
    
    func themeBeforeChanged(_ beforeChanged: QDThemeProtocol, afterChanged: QDThemeProtocol) {
    }
}
