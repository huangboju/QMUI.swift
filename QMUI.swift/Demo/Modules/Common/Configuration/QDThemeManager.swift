//
//  QDThemeManager.swift
//  QMUI.swift
//
//  Created by TonyHan on 2018/3/6.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import Foundation

public extension Notification {
    public class QD {
        /// 当主题发生变化时，会发送这个通知
        public static let ThemeChanged = Notification.Name("Notification.QD.ThemeChanged")
    }
}

/// 主题发生改变前的值，类型为 NSObject<QDThemeProtocol>，可能为 NSNull
public let QDThemeBeforeChangedName = "QDThemeBeforeChangedName"

/// 主题发生改变后的值，类型为 NSObject<QDThemeProtocol>，可能为 NSNull
public let QDThemeAfterChangedName = "QDThemeAfterChangedName"

class QDThemeManager {
    
    public var currentTheme: QDThemeProtocol? {
        willSet {
            
        }
        didSet {
            
        }
    }
    
    static let sharedInstance: QDThemeManager = {
        let instance = QDThemeManager()
        return instance
    } ()
    
    private init() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleThemeChanged(_:)), name: Notification.QD.ThemeChanged, object: nil)
    }
    
    @objc private func handleThemeChanged(_ notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        if let themeBeforeChanged = userInfo[QDThemeBeforeChangedName] as? QDThemeProtocol, let themeAfterChanged = userInfo[QDThemeAfterChangedName] as? QDThemeProtocol {
            //            themeBeforeChanged(themeBeforeChanged, afterChanged: themeAfterChanged)
        }
        
    }
    
    // MARK: QDChangingThemeDelegate
    func themeBeforeChanged <T:QDThemeProtocol> (_ beforeChanged: T, afterChanged: T) {
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
