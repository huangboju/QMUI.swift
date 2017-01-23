//
//  QMUINavigationController.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/1/23.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

protocol QMUINavigationControllerDelegate {
    /// 是否需要将状态栏改为浅色文字，默认为宏StatusbarStyleLightInitially的值
    var shouldSetStatusBarStyleLight: Bool { get }
}
