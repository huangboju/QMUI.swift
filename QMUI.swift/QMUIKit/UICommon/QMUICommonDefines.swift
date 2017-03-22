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

// navigationBar相关frame
let NavigationBarHeight: CGFloat = IS_LANDSCAPE ? PreferredVarForDevices(44, 32, 32, 32) : 44

// toolBar的相关frame
let ToolBarHeight: CGFloat = (IS_LANDSCAPE ? PreferredVarForDevices(44, 32, 32, 32) : 44)

let TabBarHeight: CGFloat = 49

// 除去navigationBar和toolbar后的中间内容区域
func NavigationContentHeight(_ viewController: UIViewController) -> CGFloat {
    guard let nav = viewController.navigationController else {
        return viewController.view.frame.height - NavigationBarHeight - StatusBarHeight
    }
    let height = nav.isToolbarHidden ? 0 : nav.toolbar.frame.height
    return viewController.view.frame.height - NavigationBarHeight - StatusBarHeight - height
}

// 兼容controller.view的subView的top值在不同iOS版本下的差异
let NavigationContentTop = StatusBarHeight + NavigationBarHeight// 这是动态获取的
let NavigationContentStaticTop = 20 + NavigationBarHeight // 不动态从状态栏获取高度，避免来电模式下多算了20pt（来电模式下系统会把UIViewController.view的frame往下移动20pt）
func NavigationContentOriginY(_ y: CGFloat) -> CGFloat {
    return NavigationContentTop + y
}

let PixelOne: CGFloat = 1

// 获取最合适的适配值，默认以varFor55Inch为准，也即偏向大屏
func PreferredVarForDevices<T>(_ varFor55Inch: T, _ varFor47Inch: T, _ varFor40Inch: T, _ var4: T) -> T {
    return (IS_35INCH_SCREEN ? var4 : (IS_40INCH_SCREEN ? varFor40Inch : (IS_47INCH_SCREEN ? varFor47Inch : varFor55Inch)))
}

// 同上，加多一个iPad的参数
func PreferredVarForUniversalDevices<T>(varForPad: T, varFor55Inch: T, varFor47Inch: T, varFor40Inch: T, var4: T) -> T {
    return (IS_IPAD ? varForPad : (IS_55INCH_SCREEN ? varFor55Inch : (IS_47INCH_SCREEN ? varFor47Inch : (IS_40INCH_SCREEN ? varFor40Inch : var4))))
}


// 字体相关创建器，包括动态字体的支持
let UIFontMake: (CGFloat) -> UIFont = { UIFont.systemFont(ofSize: $0) }
// 斜体只对数字和字母有效，中文无效
let UIFontItalicMake: (CGFloat) -> UIFont = { UIFont.italicSystemFont(ofSize: $0) }
let UIFontBoldMake: (CGFloat) -> UIFont = { UIFont.boldSystemFont(ofSize: $0) }
let UIFontBoldWithFont: (UIFont) -> UIFont = { UIFont.boldSystemFont(ofSize: $0.pointSize) }
let UIFontLightMake: (CGFloat) -> UIFont = { UIFont.qmui_lightSystemFont(ofSize: $0) }
let UIFontLightWithFont: (UIFont) -> UIFont = { UIFont.qmui_lightSystemFont(ofSize: $0.pointSize) }
let UIDynamicFontMake: (CGFloat) -> UIFont = { UIFont.qmui_dynamicFont(with: $0, bold: false) }


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
