//
//  UIBarItem+QMUI.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/5/17.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import Foundation

extension UIBarItem {
    
    /// 获取 UIBarItem（UIBarButtonItem、UITabBarItem） 内部的 view，通常对于 navigationItem 而言，需要在设置了 navigationItem 后并且在 navigationBar 可见时（例如 viewDidAppear: 及之后）获取 UIBarButtonItem.qmui_view 才有值。
    /// 对于 UIBarButtonItem 和 UITabBarItem 而言，获取到的 view 均为 UIControl 的私有子类。
    weak var qmui_view: UIView? {
        return value(forKey: "view") as? UIView
    }
}
