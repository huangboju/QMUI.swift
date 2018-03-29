//
//  QDCommonViewController.swift
//  QMUI.swift
//
//  Created by TonyHan on 2018/3/6.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

class QDCommonViewController: QMUICommonViewController {

    override func didInitialized() {
        super.didInitialized()

        NotificationCenter.default.addObserver(self, selector: #selector(handleThemeChanged(_:)), name: Notification.QD.ThemeChanged, object: nil)
    }

    @objc private func handleThemeChanged(_ notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        if let themeBeforeChanged = userInfo[QDThemeNameKey.beforeChanged] as? QDThemeProtocol, let themeAfterChanged = userInfo[QDThemeNameKey.afterChanged] as? QDThemeProtocol {
//            themeBeforeChanged(themeBeforeChanged, afterChanged: themeAfterChanged)
        }
        
    }
    
    // MARK: QDChangingThemeDelegate
    func themeBeforeChanged <T:QDThemeProtocol> (_ beforeChanged: T, afterChanged: T) {
        
    }

}
