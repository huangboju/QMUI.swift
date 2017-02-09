//
//  QMUIHelper.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/2/9.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

class QMUIHelper {
    
    //MARK: - UIApplication
    static func renderStatusBarStyleDark() {
        UIApplication.shared.statusBarStyle = .default
    }

    static func renderStatusBarStyleLight() {
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    static func dimmedApplicationWindow() {
        let window = UIApplication.shared.keyWindow
        window?.tintAdjustmentMode = .dimmed
        window?.tintColorDidChange()
    }
    
    static func resetDimmedApplicationWindow() {
        let window = UIApplication.shared.keyWindow
        window?.tintAdjustmentMode = .normal
        window?.tintColorDidChange()
    }
}
