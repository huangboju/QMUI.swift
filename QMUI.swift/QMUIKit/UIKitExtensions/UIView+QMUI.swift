//
//  UIView+QMUI.swift
//  QMUI.swift
//
//  Created by xnxin on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

public struct QMUIBorderViewPosition: OptionSet {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let none = QMUIBorderViewPosition(rawValue: 0)
    public static let top = QMUIBorderViewPosition(rawValue: 1 << 0)
    public static let left = QMUIBorderViewPosition(rawValue: 1 << 1)
    public static let bottom = QMUIBorderViewPosition(rawValue: 1 << 2)
    public static let right = QMUIBorderViewPosition(rawValue: 1 << 3)
}


extension UIView: SelfAware {
    private static let _onceToken = UUID().uuidString

    static func awake() {
        if #available(iOS 11, *) {
            DispatchQueue.once(token: _onceToken) {
                ReplaceMethod(self, #selector(safeAreaInsetsDidChange), #selector(qmui_safeAreaInsetsDidChange))
            }
        }
        DispatchQueue.once(token: _onceToken) {
            var selector = #selector((UIView.convert(_:to:)) as (UIView) -> (CGPoint, UIView?) -> CGPoint)
            var qmui_selector = #selector((UIView.qmui_convert(_:to:)) as (UIView) -> (CGPoint, UIView?) -> CGPoint)
            ReplaceMethod(self, selector, qmui_selector)
            
            selector = #selector((UIView.convert(_:from:)) as (UIView) -> (CGPoint, UIView?) -> CGPoint)
            qmui_selector = #selector((UIView.qmui_convert(_:from:)) as (UIView) -> (CGPoint, UIView?) -> CGPoint)
            ReplaceMethod(self, selector, qmui_selector)
            
            selector = #selector((UIView.convert(_:to:)) as (UIView) -> (CGRect, UIView?) -> CGRect)
            qmui_selector = #selector((UIView.qmui_convert(rect:to:)) as (UIView) -> (CGRect, UIView?) -> CGRect)
            ReplaceMethod(self, selector, qmui_selector)
            
            selector = #selector((UIView.convert(_:from:)) as (UIView) -> (CGRect, UIView?) -> CGRect)
            qmui_selector = #selector((UIView.qmui_convert(rect:from:)) as (UIView) -> (CGRect, UIView?) -> CGRect)
            ReplaceMethod(self, selector, qmui_selector)
        }
    }
    

    @objc open func qmui_safeAreaInsetsDidChange() {
        qmui_safeAreaInsetsDidChange()
        qmui_safeAreaInsetsBeforeChange = qmui_safeAreaInsets
    }

    @objc open func qmui_convert(_ point: CGPoint, to view: UIView?) -> CGPoint {
        alertConvertValue(view)
        return qmui_convert(point, to: view)
    }

    @objc open func qmui_convert(_ point: CGPoint, from view: UIView?) -> CGPoint {
        alertConvertValue(view)
        return qmui_convert(point, from: view)
    }
    
    @objc open func qmui_convert(rect: CGRect, to view: UIView?) -> CGRect {
        alertConvertValue(view)
        return qmui_convert(rect: rect, to: view)
    }
    
    @objc open func qmui_convert(rect: CGRect, from view: UIView?) -> CGRect {
        alertConvertValue(view)
        return qmui_convert(rect: rect, from: view)
    }
}

extension UIView {
    fileprivate struct Keys {
        static var safeAreaInsetsBeforeChange = "safeAreaInsetsBeforeChange"
        
        static var borderPosition = "borderPosition"
        static var borderWidth = "borderWidth"
        static var borderColor = "borderColor"
        static var dashPhase = "dashPhase"
        static var dashPattern = "dashPattern"
        static var borderLayer = "borderLayer"

        static var needsDifferentDebugColor = "needsDifferentDebugColor"
        static var shouldShowDebugColor = "shouldShowDebugColor"
        static var hasDebugColor = "hasDebugColor"
    }

    /**
     *  相当于 initWithFrame:CGRectMake(0, 0, size.width, size.height)
     */
    convenience init(size: CGSize) {
        self.init(frame: size.rect)
    }
    
    /// 在 iOS 11 及之后的版本，此属性将返回系统已有的 self.safeAreaInsets。在之前的版本此属性返回 UIEdgeInsetsZero
    public var qmui_safeAreaInsets: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return safeAreaInsets
        }
        return UIEdgeInsets.zero
    }
    
    /// 为了在 safeAreaInsetsDidChange 里得知变化前的 safeAreaInsets 值，增加了这个属性，注意这个属性仅在 `safeAreaInsetsDidChange` 的 super 调用前才有效。
    /// https://github.com/QMUI/QMUI_iOS/issues/253
    public var qmui_safeAreaInsetsBeforeChange: UIEdgeInsets {
        get {
            return (objc_getAssociatedObject(self, &Keys.safeAreaInsetsBeforeChange) as? UIEdgeInsets) ?? UIEdgeInsets.zero
        }
        set {
            objc_setAssociatedObject(self, &Keys.safeAreaInsetsBeforeChange, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    public func qmui_removeAllSubviews() {
        subviews.forEach { $0.removeFromSuperview() }
    }

    public static func qmui_animate(with animated: Bool, duration: TimeInterval, delay: TimeInterval, options: UIViewAnimationOptions, animations: @escaping () -> Void, completion: ((_ finish: Bool) -> Void)?) {
        if animated {
            UIView.animate(withDuration: duration, delay: delay, options: options, animations: animations, completion: completion)
        } else {
            animations()
            if let notNilCompletion = completion {
                notNilCompletion(true)
            }
        }
    }

    public static func qmui_animate(with animated: Bool, duration: TimeInterval, animations: @escaping () -> Void, completion: ((_ finish: Bool) -> Void)?) {
        if animated {
            UIView.animate(withDuration: duration, animations: animations, completion: completion)
        } else {
            animations()
            if let notNilCompletion = completion {
                notNilCompletion(true)
            }
        }
    }

    public static func qmui_animate(with animated: Bool, duration: TimeInterval, animations: @escaping () -> Void) {
        if animated {
            UIView.animate(withDuration: duration, animations: animations)
        } else {
            animations()
        }
    }
    
    private func hasSharedAncestorView(_ view: UIView?) -> Bool {
        if let view = view {
            var sharedAncestorView: UIView? = self
            while sharedAncestorView != nil && !view.isDescendant(of: sharedAncestorView!) {
                sharedAncestorView = sharedAncestorView?.superview
            }
            if sharedAncestorView != nil {
                return true
            }
        }
        return true
    }
    
    private func isUIKitPrivateView() -> Bool {
        // 系统有些东西本身也存在不合理，但我们不关心这种，所以过滤掉
        if self is UIWindow {
            return true
        }
        var isPrivate = false
        let classString = String(describing: type(of: self))
        let array = ["LayoutContainer", "NavigationItemButton", "NavigationItemView", "SelectionGrabber", "InputViewContent"]
        for string in array {
            if classString.hasPrefix("UI") || classString.hasPrefix("_UI") && classString.contains(string) {
                isPrivate = true
                break
            }
        }
        return isPrivate
    }
    
    private func alertConvertValue(_ view:UIView?) {
        if IS_DEBUG && isUIKitPrivateView() && !hasSharedAncestorView(view) {
            print("进行坐标系转换运算的 \(self) 和 \(String(describing: view)) 不存在共同的父 view，可能导致运算结果不准确（特别是在横屏状态下）")
        }
    }
}

// MARK: - QMUI_Runtime

extension UIView {
    /**
     *  判断当前类是否有重写某个指定的 UIView 的方法
     *  @param selector 要判断的方法
     *  @return YES 表示当前类重写了指定的方法，NO 表示没有重写，使用的是 UIView 默认的实现
     */
    public func qmui_hasOverrideUIKitMethod(_ selector: Selector) -> Bool {
        // 排序依照 Xcode Interface Builder 里的控件排序，但保证子类在父类前面
        var viewSuperclasses = [
            UILabel.self,
            UIButton.self,
            UISegmentedControl.self,
            UITextField.self,
            UISlider.self,
            UISwitch.self,
            UIActivityIndicatorView.self,
            UIProgressView.self,
            UIPageControl.self,
            UIStepper.self,
            UITableView.self,
            UITableViewCell.self,
            UIImageView.self,
            UICollectionView.self,
            UICollectionViewCell.self,
            UICollectionReusableView.self,
            UITextView.self,
            UIScrollView.self,
            UIDatePicker.self,
            UIPickerView.self,
            UIWebView.self,
            UIWindow.self,
            UINavigationBar.self,
            UIToolbar.self,
            UITabBar.self,
            UISearchBar.self,
            UIControl.self,
            UIView.self,
        ]
        if #available(iOS 9.0, *) {
            viewSuperclasses.append(UIStackView.self)
        }

        if NSClassFromString("UIVisualEffectView") != nil {
            viewSuperclasses.append(UIVisualEffectView.self)
        }

        for aClass in viewSuperclasses {
            if qmui_hasOverrideMethod(selector: selector, of: aClass) {
                return true
            }
        }

        return false
    }
}

// MARK: - QMUI_Debug

/**
 *  Debug UIView 的时候用，对某个 view 的 subviews 都添加一个半透明的背景色，方面查看 view 的布局情况
 */
extension UIView {
    /// TODO: - method swizzle

    /// 是否需要添加debug背景色，默认NO
    public var qmui_shouldShowDebugColor: Bool {
        set {
            objc_setAssociatedObject(self, &Keys.shouldShowDebugColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if newValue {
                setNeedsLayout()
            }
        }
        get {
            return (objc_getAssociatedObject(self, &Keys.shouldShowDebugColor) as? Bool) ?? false
        }
    }

    /// 是否每个view的背景色随机，如果不随机则统一使用半透明红色，默认NO
    public var qmui_needsDifferentDebugColor: Bool {
        set {
            objc_setAssociatedObject(self, &Keys.needsDifferentDebugColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if newValue {
                setNeedsLayout()
            }
        }
        get {
            return (objc_getAssociatedObject(self, &Keys.needsDifferentDebugColor) as? Bool) ?? false
        }
    }

    /// 标记一个view是否已经被添加了debug背景色，外部一般不使用
    public private(set) var qmui_hasDebugColor: Bool {
        set {
            objc_setAssociatedObject(self, &Keys.hasDebugColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return (objc_getAssociatedObject(self, &Keys.hasDebugColor) as? Bool) ?? false
        }
    }
}

// MARK: - QMUI_Border

/**
 *  UIView (QMUI_Border) 为 UIView 方便地显示某几个方向上的边框。
 *
 *  系统的默认实现里，要为 UIView 加边框一般是通过 view.layer 来实现，view.layer 会给四条边都加上边框，如果你只想为其中某几条加上边框就很麻烦，于是 UIView (QMUI_Border) 提供了 qmui_borderPosition 来解决这个问题。
 *  @warning 注意如果你需要为 UIView 四条边都加上边框，请使用系统默认的 view.layer 来实现，而不要用 UIView (QMUI_Border)，会浪费资源，这也是为什么 QMUIBorderViewPosition 不提供一个 QMUIBorderViewPositionAll 枚举值的原因。
 */
extension UIView {
    

    /// 设置边框类型，支持组合，例如：`borderType = QMUIBorderViewTypeTop|QMUIBorderViewTypeBottom`
    public var qmui_borderPosition: QMUIBorderViewPosition {
        set {
            objc_setAssociatedObject(self, &Keys.borderPosition, newValue, .OBJC_ASSOCIATION_RETAIN)
            setNeedsLayout()
        }
        get {
            return (objc_getAssociatedObject(self, &Keys.borderPosition) as? QMUIBorderViewPosition) ?? QMUIBorderViewPosition.none
        }
    }

    /// 边框的大小，默认为PixelOne
    @IBInspectable
    public var qmui_borderWidth: CGFloat {
        set {
            objc_setAssociatedObject(self, &Keys.borderWidth, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            setNeedsLayout()
        }
        get {
            return (objc_getAssociatedObject(self, &Keys.borderWidth) as? CGFloat) ?? 0
        }
    }

    /// 边框的颜色，默认为UIColorSeparator
    @IBInspectable
    public var qmui_borderColor: UIColor {
        set {
            objc_setAssociatedObject(self, &Keys.borderColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            setNeedsLayout()
        }
        get {
            return (objc_getAssociatedObject(self, &Keys.borderColor) as? UIColor) ?? UIColorWhite
        }
    }

    /// 虚线 : dashPhase默认是0，且当dashPattern设置了才有效
    public var qmui_dashPhase: CGFloat {
        set {
            objc_setAssociatedObject(self, &Keys.dashPhase, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            setNeedsLayout()
        }
        get {
            return (objc_getAssociatedObject(self, &Keys.dashPhase) as? CGFloat) ?? 0
        }
    }

    public var qmui_dashPattern: [NSNumber] {
        set {
            objc_setAssociatedObject(self, &Keys.dashPattern, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            setNeedsLayout()
        }
        get {
            return (objc_getAssociatedObject(self, &Keys.dashPattern) as? [NSNumber]) ?? []
        }
    }

    /// border的layer
    public private(set) var qmui_borderLayer: CAShapeLayer {
        set {
            objc_setAssociatedObject(self, &Keys.borderLayer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return (objc_getAssociatedObject(self, &Keys.borderLayer) as? CAShapeLayer) ?? CAShapeLayer()
        }
    }

    private func setDefaultStyle() {
        qmui_borderWidth = PixelOne
        qmui_borderColor = UIColorSeparator
    }
}

// MARK: - QMUI_Layout

/**
 *  对 view.frame 操作的简便封装，注意 view 与 view 之间互相计算时，需要保证处于同一个坐标系内。
 *  siwft 支持 view.minY 等属性，调用已经很方便，无需再实现 qmui_top 等
 */
extension UIView {
    /**
     * 设置view的width和height
     */
    public func qmui_set(width: CGFloat, height: CGFloat) {
        var frame = self.frame
        frame.size.height = height
        frame.size.width = width
        self.frame = frame
    }
    
    /**
     * 设置view的width
     */
    public func qmui_set(width: CGFloat) {
        var frame = self.frame
        frame.size.width = width
        self.frame = frame
    }
    
    /**
     * 设置view的height
     */
    public func qmui_set(height: CGFloat) {
        var frame = self.frame
        frame.size.height = height
        self.frame = frame
    }
    
    /**
     * 设置view的x和y
     */
    public func qmui_set(originX: CGFloat, originY: CGFloat) {
        var frame = self.frame
        frame.origin.x = originX
        frame.origin.y = originY
        self.frame = frame
    }
    
    /**
     * 设置view的x
     */
    public func qmui_set(originX: CGFloat) {
        var frame = self.frame
        frame.origin.x = originX
        self.frame = frame
    }
    
    /**
     * 设置view的y
     */
    public func qmui_set(originY: CGFloat) {
        var frame = self.frame
        frame.origin.y = originY
        self.frame = frame
    }
    
    /**
     * 获取当前view在superview内的水平居中时的minX
     */
    public var qmui_minXWhenCenterInSuperview: CGFloat {
        return superview?.bounds.width.center(with: frame.width) ?? 0
    }
    
    /**
     * 获取当前view在superview内的垂直居中时的minY
     */
    public var qmui_minYWhenCenterInSuperview: CGFloat {
        return superview?.bounds.height.center(with: frame.height) ?? 0
    }
}

// MARK: - QMUI_Snapshotting

/**
 *  方便地将某个 UIView 截图并转成一个 UIImage，注意如果这个 UIView 本身做了 transform，也不会在截图上反映出来，截图始终都是原始 UIView 的截图。
 */
extension UIView {
    public var qmui_snapshotLayerImage: UIImage? {
        return UIImage.qmui_image(view: self)
    }

    public func qmui_snapshotImage(_ afterScreenUpdates: Bool) -> UIImage? {
        return UIImage.qmui_image(view: self, afterScreenUpdates: afterScreenUpdates)
    }
}
