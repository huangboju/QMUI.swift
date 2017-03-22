//
//  QMUICommonDefines.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/1/17.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

// 是否横竖屏
// 用户界面横屏了才会返回true
let IS_LANDSCAPE = UIInterfaceOrientationIsLandscape(UIApplication.shared.statusBarOrientation)

// 屏幕宽度，会根据横竖屏的变化而变化
let SCREEN_WIDTH = UIScreen.main.bounds.width

// 屏幕高度，会根据横竖屏的变化而变化
let SCREEN_HEIGHT = UIScreen.main.bounds.height

// 屏幕宽度，跟横竖屏无关
let DEVICE_WIDTH = IS_LANDSCAPE ? UIScreen.main.bounds.height : UIScreen.main.bounds.width

// 屏幕高度，跟横竖屏无关
let DEVICE_HEIGHT = IS_LANDSCAPE ? UIScreen.main.bounds.width : UIScreen.main.bounds.height

let PixelOne: CGFloat = 1

// 是否支持动态字体
let IS_RESPOND_DYNAMICTYPE = UIApplication.instancesRespond(to: #selector(getter: UIApplication.preferredContentSizeCategory))

// 同上，加多一个iPad的参数

// MARK: - UIEdgeInsets

extension UIEdgeInsets {
    /// 获取UIEdgeInsets在水平方向上的值
    var horizontalValue: CGFloat {
        return self.left + self.right
    }

    /// 获取UIEdgeInsets在垂直方向上的值
    var verticalValue: CGFloat {
        return self.top + self.bottom
    }

    /// 将两个UIEdgeInsets合并为一个
    func concat(_ insets1: UIEdgeInsets, _ insets2: UIEdgeInsets) -> UIEdgeInsets {
        let top = insets1.top + insets2.top
        let left = insets1.left + insets2.left
        let bottom = insets1.bottom + insets2.bottom
        let right = insets1.right + insets2.right
        return UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    }
}

// MARK: - CGRect

extension CGRect {
    static func rect(with size: CGSize) -> CGRect {
        return CGRect(x: 0, y: 0, width: size.width, height: size.height)
    }
}
