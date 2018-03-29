//
//  QDThemeManager.swift
//  QMUI.swift
//
//  Created by TonyHan on 2018/3/6.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import Foundation

extension Notification {
    public class QD {
        /// 当主题发生变化时，会发送这个通知
        public static let ThemeChanged = Notification.Name("Notification.QD.ThemeChanged")
    }
}

struct QDThemeNameKey {
    /// 主题发生改变前的值，类型为 NSObject<QDThemeProtocol>，可能为 NSNull
    static var beforeChanged = "QDThemeBeforeChangedName"
    /// 主题发生改变后的值，类型为 NSObject<QDThemeProtocol>，可能为 NSNull
    static var afterChanged  = "QDThemeAfterChangedName"
}

/**
 *  QMUI Demo 的皮肤管理器，当需要换肤时，请为 currentTheme 赋值；当需要获取当前皮肤时，可访问 currentTheme 属性。
 *  可通过监听 QDThemeChangedNotification 通知来捕获换肤事件，默认地，QDCommonViewController 及 QDCommonTableViewController 均已支持响应换肤，其响应方法是通过 QDChangingThemeDelegate 接口来实现的。
 */
class QDThemeManager {
    
    static let shared: QDThemeManager = {
        let instance = QDThemeManager()
        return instance
    } ()
    
    public var currentTheme: QDThemeProtocol! {
        willSet {
            
        }
        didSet {
            
        }
    }
    
    private init() {
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension QDThemeManager: QDChangingThemeDelegate {
    
    func themeBeforeChanged<T>(_ themeBeforeChanged: T, afterChanged: T) where T : QDThemeProtocol {
        // 主题发生变化，在这里更新全局 UI 控件的 appearance
//        QDCommonUI
    }
}


