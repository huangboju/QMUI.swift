//
//  QMUICommonDefines.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/1/17.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

// MARK: - 变量-编译相关

// 判断当前是否debug编译模式
#if DEBUG
let IS_DEBUG = true
#else
let IS_DEBUG = false
#endif


// MARK: - Clang
// TODO:


// 设备类型
let IS_IPAD = QMUIHelper.isIPad
let IS_IPAD_PRO = QMUIHelper.isIPadPro
let IS_IPOD = QMUIHelper.isIPod
let IS_IPHONE = QMUIHelper.isIPhone
let IS_SIMULATOR = QMUIHelper.isSimulator

// 操作系统版本号
let IOS_VERSION = Double(UIDevice.current.systemVersion) ?? 0

// 是否横竖屏
// 用户界面横屏了才会返回true
let IS_LANDSCAPE = UIInterfaceOrientationIsLandscape(UIApplication.shared.statusBarOrientation)
// 无论支不支持横屏，只要设备横屏了，就会返回YES
let IS_DEVICE_LANDSCAPE = UIDeviceOrientationIsLandscape(UIDevice.current.orientation)


// 屏幕宽度，会根据横竖屏的变化而变化
let SCREEN_WIDTH = UIScreen.main.bounds.width

// 屏幕高度，会根据横竖屏的变化而变化
let SCREEN_HEIGHT = UIScreen.main.bounds.height

// 屏幕宽度，跟横竖屏无关
let DEVICE_WIDTH = IS_LANDSCAPE ? UIScreen.main.bounds.height : UIScreen.main.bounds.width

// 屏幕高度，跟横竖屏无关
let DEVICE_HEIGHT = IS_LANDSCAPE ? UIScreen.main.bounds.width : UIScreen.main.bounds.height

// 设备屏幕尺寸
let IS_55INCH_SCREEN = QMUIHelper.is55InchScreen
let IS_47INCH_SCREEN = QMUIHelper.is47InchScreen
let IS_40INCH_SCREEN = QMUIHelper.is40InchScreen
let IS_35INCH_SCREEN = QMUIHelper.is35InchScreen

// 是否Retina
let IS_RETINASCREEN = UIScreen.main.scale >= 2.0

// 是否支持动态字体
let IS_RESPOND_DYNAMICTYPE = UIApplication.instancesRespond(to: #selector(getter: UIApplication.preferredContentSizeCategory))

// MARK: - 变量-布局相关

// bounds && nativeBounds / scale && nativeScale
let ScreenBoundsSize = UIScreen.main.bounds.size
let ScreenNativeBoundsSize = IOS_VERSION >= 8.0 ? UIScreen.main.nativeBounds.size : ScreenBoundsSize
let ScreenScale = UIScreen.main.scale
let ScreenNativeScale = IOS_VERSION >= 8.0 ? UIScreen.main.nativeScale : ScreenScale
// 区分设备是否处于放大模式（iPhone 6及以上的设备支持放大模式）
let ScreenInDisplayZoomMode = ScreenNativeScale > ScreenScale

// 状态栏高度(来电等情况下，状态栏高度会发生变化，所以应该实时计算)
let StatusBarHeight = (IOS_VERSION >= 8.0 ? UIApplication.shared.statusBarFrame.height : (IS_LANDSCAPE ? UIApplication.shared.statusBarFrame.width : UIApplication.shared.statusBarFrame.height))

let PixelOne: CGFloat = 1



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
