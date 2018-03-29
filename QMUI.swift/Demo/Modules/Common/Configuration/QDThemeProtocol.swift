//
//  QDThemeProtocol.swift
//  QMUI.swift
//
//  Created by TonyHan on 2018/3/6.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import Foundation

protocol QDThemeProtocol: QMUIConfigurationTemplateProtocol {
    
    var themeTintColor: UIColor { get }
    var themeListTextColor: UIColor { get }
    var themeCodeColor: UIColor { get }
    var themeGridItemTintColor: UIColor? { get }
    
    var themeName: String { get }
    
}

/// 所有能响应主题变化的对象均应实现这个协议，目前主要用于 QDCommonViewController 及 QDCommonTableViewController
protocol QDChangingThemeDelegate: class {
    
    func themeBeforeChanged(_ beforeChanged: QDThemeProtocol, afterChanged: QDThemeProtocol)
}
