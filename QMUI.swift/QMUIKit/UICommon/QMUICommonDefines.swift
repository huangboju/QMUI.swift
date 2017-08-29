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
let IOS_VERSION = (UIDevice.current.systemVersion as NSString).floatValue

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

let PixelOne = QMUIHelper.pixelOne

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
let UIDynamicFontMake: (CGFloat) -> UIFont = { UIFont.qmui_dynamicFont(withSize: $0, bold: false) }
let UIDynamicFontMakeWithLimit: (CGFloat, CGFloat, CGFloat) -> UIFont = { UIFont.qmui_dynamicFont(withSize: $0.0, upperLimitSize: $0.1, lowerLimitSize: $0.2, bold: false) }
let UIDynamicFontBoldMake: (CGFloat) -> UIFont = { UIFont.qmui_dynamicFont(withSize: $0, bold: true) }
let UIDynamicFontBoldMakeWithLimit: (CGFloat, CGFloat, CGFloat) -> UIFont = { UIFont.qmui_dynamicFont(withSize: $0.0, upperLimitSize: $0.1, lowerLimitSize: $0.2, bold: true) }


// MARK: - 数学计算

let AngleWithDegrees: (CGFloat) -> CGFloat = { .pi * $0 / 180.0 }


// MARK: - 动画
// TODO:
//let QMUIViewAnimationOptionsCurveOut (7<<16)
//let QMUIViewAnimationOptionsCurveIn (8<<16)


// MARK: - 其他
// TODO:
//#define QMUILog(...) [[QMUIHelper sharedInstance] printLogWithCalledFunction:__FUNCTION__ log:__VA_ARGS__]



/**
 *  基于指定的倍数，对传进来的 floatValue 进行像素取整。若指定倍数为0，则表示以当前设备的屏幕倍数为准。
 *
 *  例如传进来 “2.1”，在 2x 倍数下会返回 2.5（0.5pt 对应 1px），在 3x 倍数下会返回 2.333（0.333pt 对应 1px）。
 */

func flatSpecificScale(_ value: CGFloat, _ scale: CGFloat) -> CGFloat {
    let s = scale == 0 ? ScreenScale : scale
    return ceil(value * s) / s
}

/**
 *  基于当前设备的屏幕倍数，对传进来的 floatValue 进行像素取整。
 *
 *  注意如果在 Core Graphic 绘图里使用时，要注意当前画布的倍数是否和设备屏幕倍数一致，若不一致，不可使用 flat() 函数，而应该用 flatSpecificScale
 */

func flat(_ value: CGFloat) -> CGFloat {
    return flatSpecificScale(value, 0)
}

/**
 *  类似flat()，只不过 flat 是向上取整，而 floorInPixel 是向下取整
 */
func floorInPixel(_ value: CGFloat) -> CGFloat {
    let resultValue = floor(value * ScreenScale) / ScreenScale
    return resultValue
}

func between(_ minimumValue: CGFloat, _ value: CGFloat, _ maximumValue: CGFloat) -> Bool {
    return minimumValue < value && value < maximumValue
}

func betweenOrEqual(_ minimumValue: CGFloat, _ value: CGFloat, _ maximumValue: CGFloat) -> Bool {
    return minimumValue <= value && value <= maximumValue
}

func ReplaceMethod(_ _class: AnyClass, _ _originSelector: Selector, _ _newSelector: Selector) {
    let oriMethod = class_getInstanceMethod(_class, _originSelector)
    let newMethod = class_getInstanceMethod(_class, _newSelector)
    let isAddedMethod = class_addMethod(_class, _originSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))
    if (isAddedMethod) {
        class_replaceMethod(_class, _newSelector, method_getImplementation(oriMethod), method_getTypeEncoding(oriMethod))
    } else {
        method_exchangeImplementations(oriMethod, newMethod)
    }
}


// MARK: - CGFloat

/// 用于居中运算


extension CGFloat {
    func center(with child: CGFloat) -> CGFloat {
        return flat((self - child) / 2.0)
    }
}



// MARK: - CGPoint

/// 两个point相加

extension CGPoint {
    func union(_ point: CGPoint) -> CGPoint {
        return CGPoint(x: flat(x + point.x), y: flat(y + point.y))
    }
}

extension CGRect {
    /// 获取rect的center，包括rect本身的x/y偏移
    var center: CGPoint {
        return CGPoint(x: flat(midX), y: flat(midY))
    }

    /// 对CGRect的x/y、width/height都调用一次flat，以保证像素对齐
    var flatted: CGRect {
        return CGRect(x: flat(minX), y: flat(minY), width: flat(width), height: flat(height))
    }

    /// 为一个CGRect叠加scale计算
    func apply(scale: CGFloat) -> CGRect {
        return CGRect(x: minX * scale, y: minY * scale, width: width * scale, height: height * scale).flatted
    }
    
    /// 计算view的水平居中，传入父view和子view的frame，返回子view在水平居中时的x值
    func minXHorizontallyCenter(in parentRect: CGRect) -> CGFloat {
        return flat((parentRect.width - width) / 2.0)
    }
    
    /// 计算view的垂直居中，传入父view和子view的frame，返回子view在垂直居中时的y值
    func minYVerticallyCenter(in parentRect: CGRect) -> CGFloat {
        return flat((parentRect.height - height) / 2.0)
    }

    /// 返回值：同一个坐标系内，想要layoutingRect和已布局完成的referenceRect保持垂直居中时，layoutingRect的originY
    func minYVerticallyCenter(layoutingRect: CGRect) -> CGFloat {
        return minY + minYVerticallyCenter(in: layoutingRect)
    }
    
    /// 返回值：同一个坐标系内，想要layoutingRect和已布局完成的referenceRect保持水平居中时，layoutingRect的originX
    func minXHorizontallyCenter(_ layoutingRect: CGRect) -> CGFloat {
        return minX + minXHorizontallyCenter(in: layoutingRect)
    }
    
    /// 为给定的rect往内部缩小insets的大小
    func insetEdges(_ insets: UIEdgeInsets) -> CGRect {
        let newX = minX + insets.left
        let newY = minY + insets.top
        let newWidth = width - insets.horizontalValue
        let newHeight = height - insets.verticalValue
        return CGRect(x: newX, y: newY, width: newWidth, height: newHeight)
    }

    mutating func float(top: CGFloat) -> CGRect {
        origin.y = top
        return self
    }

    mutating func float(bottom: CGFloat) -> CGRect {
        origin.y = bottom - height
        return self
    }
    
    mutating func float(right: CGFloat) -> CGRect {
        origin.x = right - width
        return self
    }
    
    mutating func float(left: CGFloat) -> CGRect {
        origin.x = left
        return self
    }
    
    /// 保持rect的左边缘不变，改变其宽度，使右边缘靠在right上
    mutating func limit(right: CGFloat) -> CGRect {
        size.width = right - minX
        return self
    }
    
    /// 保持rect右边缘不变，改变其宽度和origin.x，使其左边缘靠在left上。只适合那种右边缘不动的view
    /// 先改变origin.x，让其靠在offset上
    /// 再改变size.width，减少同样的宽度，以抵消改变origin.x带来的view移动，从而保证view的右边缘是不动的
    mutating func limit(left: CGFloat) -> CGRect {
        let subOffset = left - minX
        origin.x = left
        size.width -=  subOffset
        return self
    }
    
    /// 限制rect的宽度，超过最大宽度则截断，否则保持rect的宽度不变
    mutating func limit(maxWidth: CGFloat) -> CGRect {
        size.width = width > maxWidth ? maxWidth : width
        return self
    }

    mutating func setX(_ x: CGFloat) -> CGRect {
        origin.x = flat(x)
        return self
    }
    
    mutating func setY(_ y: CGFloat) -> CGRect {
        origin.y = flat(y)
        return self
    }

    @discardableResult
    mutating func setXY(_ x: CGFloat, _ y: CGFloat) -> CGRect {
        origin.x = flat(x)
        origin.y = flat(y)
        return self
    }

    @discardableResult
    mutating func setWidth(_ width: CGFloat) -> CGRect {
        size.width = flat(width)
        return self
    }

    mutating func setHeight(_ height: CGFloat) -> CGRect {
        size.height = flat(height)
        return self
    }
    
    
    mutating func setSize(size: CGSize) -> CGRect {
        self.size = size.flatted
        return self
    }
}

extension CGSize {
    /// 返回一个x/y为0的CGRect
    var rect: CGRect {
        return CGRect(origin: .zero, size: self)
    }

    var center: CGPoint {
        return CGPoint(x: flat(width / 2.0), y: flat(height / 2.0))
    }

    /// 判断一个size是否为空（宽或高为0）
    var isEmpty: Bool {
        return width <= 0 || height <= 0
    }

    /// 将一个CGSize像素对齐
    var flatted: CGSize {
        return CGSize(width: flat(width), height: flat(height))
    }

    /// 将一个 CGSize 以 pt 为单位向上取整
    var sizeCeil: CGSize {
        return CGSize(width: ceil(width), height: ceil(height))
    }

    /// 将一个 CGSize 以 pt 为单位向下取整
    var sizeFloor: CGSize {
        return CGSize(width: floor(width), height: floor(height))
    }

    static var max: CGSize {
        return CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
    }
}

/// 创建一个像素对齐的CGRect
let CGRectFlat: (CGFloat, CGFloat, CGFloat, CGFloat) -> CGRect = {
    return CGRect(x: flat($0.0), y: flat($0.1), width: flat($0.2), height: flat($0.3))
}


// MARK: - UIEdgeInsets

extension UIEdgeInsets {
    /// 获取UIEdgeInsets在水平方向上的值
    var horizontalValue: CGFloat {
        return left + right
    }

    /// 获取UIEdgeInsets在垂直方向上的值
    var verticalValue: CGFloat {
        return top + bottom
    }

    /// 将两个UIEdgeInsets合并为一个
    func concat(insets: UIEdgeInsets) -> UIEdgeInsets {
        let top = self.top + insets.top
        let left = self.left + insets.left
        let bottom = self.bottom + insets.bottom
        let right = self.right + insets.right
        return UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    }

    mutating func setTop(_ top: CGFloat) {
        self.top = flat(top)
    }

    mutating func setLeft(_ left: CGFloat) {
        self.left = flat(left)
    }

    mutating func setBottom(bottom: CGFloat) {
        self.bottom = flat(bottom)
    }

    mutating func setRight(_ right: CGFloat) {
        self.right = flat(right)
    }
}

// MARK: - CGRect

extension CGRect {
    static func rect(with size: CGSize) -> CGRect {
        return CGRect(x: 0, y: 0, width: size.width, height: size.height)
    }
}
