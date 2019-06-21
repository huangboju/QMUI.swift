//
//  QMUINavigationButton.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/5/3.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

enum QMUINavigationButtonType {
    case normal // 普通导航栏文字按钮
    case bold // 导航栏加粗按钮
    case image // 图标按钮
    case back // 自定义返回按钮(可以同时带有title)
    case close // 自定义关闭按钮(只显示icon不带title)
}

enum QMUINavigationButtonPosition: Int {
    case none = -1 // 不处于navigationBar最左（右）边的按钮，则使用None。用None则不会在alignmentRectInsets里调整位置
    case left // 用于leftBarButtonItem，如果用于leftBarButtonItems，则只对最左边的item使用，其他item使用QMUINavigationButtonPositionNone
    case right // 用于rightBarButtonItem，如果用于rightBarButtonItems，则只对最右边的item使用，其他item使用QMUINavigationButtonPositionNone
}


/**
 *  QMUINavigationButton 有两部分组成：
 *  一部分是 UIBarButtonItem (QMUINavigationButton)，提供比系统更便捷的类方法来快速初始化一个 UIBarButtonItem，推荐首选这种方式（原则是能用系统的尽量用系统的，不满足才用自定义的）。
 *  另一部分就是 QMUINavigationButton，会提供一个按钮，作为 customView 给 UIBarButtonItem 使用，这种常用于自定义的返回按钮。
 *  对于第二种按钮，会尽量保证样式、布局看起来都和系统的 UIBarButtonItem 一致，所以内部做了许多 iOS 版本兼容的微调。
 */
class QMUINavigationButton: UIButton {
    
    /**
     *  获取当前按钮的`QMUINavigationButtonType`
     */
    private(set) var type: QMUINavigationButtonType = .normal
    
    fileprivate var buttonPosition: QMUINavigationButtonPosition = .none
    
    private var defaultHighlightedImage: UIImage? // 在 set normal image 时自动拿 normal image 加 alpha 作为 highlighted image
    
    private var defaultDisabledImage: UIImage? // 在 set normal image 时自动拿 normal image 加 alpha 作为 disabled image
    
    
    convenience init() {
        self.init(type: .normal)
    }
    
    /**
     *  导航栏按钮的初始化函数，指定的初始化方法
     *  @param type 按钮类型
     *  @param title 按钮的title
     */
    init(type: QMUINavigationButtonType, title: String?) {
        super.init(frame: .zero)
        self.type = type
        setTitle(title, for: .normal)
        renderButtonStyle()
        sizeToFit()
    }
    
    /**
     *  导航栏按钮的初始化函数
     *  @param type 按钮类型
     */
    convenience init(type: QMUINavigationButtonType) {
        self.init(type: type, title: nil)
    }
    
    /**
     *  导航栏按钮的初始化函数
     *  @param image 按钮的image
     */
    convenience init(image: UIImage) {
        self.init(type: .image)
        setImage(image, for: .normal)
        // 系统在iOS8及以后的版本默认对image的UIBarButtonItem加了上下3、左右11的padding，所以这里统一一下
        contentEdgeInsets = UIEdgeInsets.init(top: 3, left: 11, bottom: 3, right: 11)
        sizeToFit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // 修复系统的UIBarButtonItem里的图片无法跟着tintColor走
    override func setImage(_ image: UIImage?, for state: UIControl.State) {
        if var image = image, self.image(for: state) != image {
            if image.renderingMode == .automatic {
                // 由于 QMUINavigationButton 是用于 UIBarButtonItem 的，所以默认的行为应该是尽量去跟随 tintColor，所以做了这个优化
                image = image.withRenderingMode(.alwaysTemplate)
            }
            
            if state == .normal {
                // 将 normal image 处理成对应的 highlighted image 和 disabled image
                defaultHighlightedImage = image.qmui_image(alpha: NavBarHighlightedAlpha)?.withRenderingMode(image.renderingMode)
                setImage(defaultHighlightedImage, for: .highlighted)
                
                defaultDisabledImage = image.qmui_image(alpha: NavBarDisabledAlpha)?.withRenderingMode(image.renderingMode)
                setImage(defaultDisabledImage, for: .disabled)
            } else {
                // 如果业务主动设置了非 normal 状态的 image，则把之前 QMUI 自动加上的两个 image 去掉，相当于认为业务希望完全控制这个按钮在所有 state 下的图片
                if image != defaultHighlightedImage && image != defaultDisabledImage {
                    if self.image(for: .highlighted) == defaultHighlightedImage && state != .highlighted {
                        setImage(nil, for: .highlighted)
                    }
                    if self.image(for: .disabled) == defaultDisabledImage && state != .disabled {
                        setImage(nil, for: .disabled)
                    }
                }
            }
            super.setImage(image, for: state)
        } else {
            super.setImage(image, for: state)
        }
    }
    
    // 自定义nav按钮，需要根据这个来修改title的三态颜色
    override func tintColorDidChange() {
        super.tintColorDidChange()
        
        setTitleColor(tintColor, for: .normal)
        setTitleColor(tintColor.withAlphaComponent(NavBarHighlightedAlpha), for: .highlighted)
        setTitleColor(tintColor.withAlphaComponent(NavBarDisabledAlpha), for: .disabled)
    }
    
    // 对按钮内容添加偏移，让UIBarButtonItem适配最新设备的系统行为，统一位置
    override var alignmentRectInsets: UIEdgeInsets {
        var insets = super.alignmentRectInsets
        
        if type == .normal || type == .bold {
            // 文字类型的按钮，分别对最左、最右那个按钮调整 inset（这里与 UINavigationItem(QMUINavigationButton) 里的 position 赋值配合使用）
            if #available(iOS 10, *) {
                
            } else {
                if buttonPosition == .left {
                    insets.left = 8
                } else if buttonPosition == .right {
                    insets.right = 8
                }
            }
            
            // 对于奇数大小的字号，不同 iOS 版本的偏移策略不同，统一一下
            if let titleLabel = titleLabel, titleLabel.font.pointSize / 2.0 > 0 {
                if #available(iOS 11, *) {
                    insets.top = PixelOne
                    insets.bottom = -PixelOne
                } else {
                    insets.top = -PixelOne
                    insets.bottom = PixelOne
                }
            }
        } else if type == .image {
            // 图片类型的按钮，分别对最左、最右那个按钮调整 inset（这里与 UINavigationItem(QMUINavigationButton) 里的 position 赋值配合使用）
            if buttonPosition == .left {
                insets.left = 11
            } else if buttonPosition == .right {
                insets.right = 11
            }
            
            insets.top = 1
        } else if type == .back {
            insets.top = PixelOne
            if #available(iOS 11, *) {
            } else {
                insets.left = 8
            }
        }
        
        return insets
    }
    
    private func renderButtonStyle() {
        if let font = NavBarButtonFont {
            titleLabel?.font = font
        }
        titleLabel?.backgroundColor = UIColorClear
        titleLabel?.lineBreakMode = .byTruncatingTail
        contentMode = .center
        contentHorizontalAlignment = .center
        contentVerticalAlignment = .center
        qmui_automaticallyAdjustTouchHighlightedInScrollView = true
        
        // 系统默认对 highlighted 和 disabled 的图片的表现是变身色，但 UIBarButtonItem 是 alpha，为了与 UIBarButtonItem  表现一致，这里禁用了 UIButton 默认的行为，然后通过重写 setImage:forState:，自动将 normal image 处理为对应的 highlighted image 和 disabled image
        adjustsImageWhenHighlighted = false
        adjustsImageWhenDisabled = false
        
        if #available(iOS 11, *) {
            translatesAutoresizingMaskIntoConstraints = false// 打开这个才能让 iOS 11 下的 alignmentRectInsets 生效
        }
        
        switch type {
        case .image:
            // 拓展宽度，以保证用 leftBarButtonItems/rightBarButtonItems 时，按钮与按钮之间间距与系统的保持一致
            contentEdgeInsets = UIEdgeInsets(top: 0, left: 11, bottom: 0, right: 11)
        case .bold:
            if let font = NavBarButtonFontBold{
                titleLabel?.font = font
            }
        case .back:
            // 配置表没有自定义的图片，则按照系统的返回按钮图片样式创建一张
            let backIndicatorImage = NavBarBackIndicatorImage ?? UIImage.qmui_image(shape: .navBack, size: CGSize(width: 13, height: 23), lineWidth: 3, tintColor: NavBarTintColor)!

            setImage(backIndicatorImage, for: .normal)
            setImage(backIndicatorImage.qmui_image(alpha: NavBarHighlightedAlpha), for: .highlighted)
            setImage(backIndicatorImage.qmui_image(alpha: NavBarDisabledAlpha), for: .disabled)
            
            contentHorizontalAlignment = .center
            
            // @warning 这些数值都是每个iOS版本核对过没问题的，如果修改则要检查要每个版本里与系统UIBarButtonItem的布局是否一致
            let titleOffsetBaseOnSystem = UIOffset(horizontal: IOS_VERSION >= 11.0 ? 6 : 7, vertical: 0) // 经过这些数值的调整后，自定义返回按钮的位置才能和系统默认返回按钮的位置对准，而配置表里设置的值是在这个调整的基础上再调整
            let configurationOffset = NavBarBarBackButtonTitlePositionAdjustment
            titleEdgeInsets = UIEdgeInsets(top: titleOffsetBaseOnSystem.vertical + configurationOffset.vertical, left: titleOffsetBaseOnSystem.horizontal + configurationOffset.horizontal, bottom: -titleOffsetBaseOnSystem.vertical - configurationOffset.vertical, right: -titleOffsetBaseOnSystem.horizontal - configurationOffset.horizontal)
            contentEdgeInsets = UIEdgeInsets(top: IOS_VERSION < 11.0 ? 1 : 0, left: 0, bottom: 0, right: titleEdgeInsets.left) // iOS 11 以前，y 值偏移一点
        default:
            break
        }
    }
}

extension UIBarButtonItem {
    
    static func item(button: QMUINavigationButton,
                     target: Any?,
                     action: Selector?) -> UIBarButtonItem {
        if let action = action {
            button.addTarget(target, action: action, for: .touchUpInside)
        }
        return UIBarButtonItem(customView: button)
    }
    
    static func item(image: UIImage?,
                     target: Any?,
                     action: Selector?) -> UIBarButtonItem {
        return UIBarButtonItem(image: image, style: .plain, target: target, action: action)
    }
    
    static func item(title: String?,
                     target: Any?,
                     action: Selector?) -> UIBarButtonItem {
        return UIBarButtonItem(title: title, style: .plain, target: target, action: action)
    }
    
    static func item(boldTitle: String?,
                     target: Any?,
                     action: Selector?) -> UIBarButtonItem {
        return UIBarButtonItem(title: boldTitle, style: .done, target: target, action: action)
    }
    
    static func backItem(target: Any?,
                         action: Selector?) -> UIBarButtonItem {
        var backTitle: String
        if NeedsBackBarButtonItemTitle {
            backTitle = "返回"; // 默认文字用返回
            if let viewController = target as? UIViewController {
                let previousViewController = viewController.qmui_previousViewController
                if let item = previousViewController?.navigationItem.backBarButtonItem {
                    // 如果前一个界面有主动设置返回按钮的文字，则取这个文字
                    backTitle = item.title ?? ""
                } else if let viewController = viewController as? QMUINavigationControllerAppearanceDelegate {
                    // 否则看是否有通过 QMUI 提供的接口来设置返回按钮的文字，有就用它的值
                    backTitle = viewController.backBarButtonItemTitle?(previousViewController) ?? ""
                } else if let title = previousViewController?.title {
                    // 否则取上一个界面的标题
                    backTitle = title
                }
            }
        } else {
            backTitle = " "
        }
        
        let button = QMUINavigationButton(type: .back, title: backTitle)
        if let action = action {
            button.addTarget(target, action: action, for: .touchUpInside)
        }
        let barButtonItem = UIBarButtonItem(customView: button)
        return barButtonItem
    }
    
    static func closeItem(target: Any?,
                         action: Selector?) -> UIBarButtonItem {
        let barButtonItem = UIBarButtonItem(image: NavBarCloseButtonImage, style: .plain, target: target, action: action)
        return barButtonItem
    }
    
    static func fixedSpaceItem(width: CGFloat) -> UIBarButtonItem {
        let item = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        item.width = width
        return item
    }
    
    static func flexibleSpaceItem() -> UIBarButtonItem {
        let item = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        return item
    }
}

extension UIBarButtonItem {
    
    /// 判断当前的 UIBarButtonItem 是否是 QMUINavigationButton
    fileprivate var qmui_isCustomizedBarButtonItem: Bool {
        guard let _ = customView as? QMUINavigationButton else {
            return false
        }
        return true
    }
    
    /// 判断当前的 UIBarButtonItem 是否是用 QMUINavigationButton 自定义返回按钮生成的
    fileprivate var qmui_isCustomizedBackBarButtonItem: Bool {
        guard let customView = customView as? QMUINavigationButton else {
            return false
        }
        let result = qmui_isCustomizedBarButtonItem && customView.type == .back
        return result
    }
    
    /// 获取内部的 QMUINavigationButton（如果有的话）
    fileprivate var qmui_navigationButton: QMUINavigationButton? {
        guard let customView = customView as? QMUINavigationButton else {
            return nil
        }
        return customView
    }
    
}

extension UINavigationItem: SelfAware2 {
    
    private static let _onceToken = UUID().uuidString

    static func awake2() {
        DispatchQueue.once(token: _onceToken) {
            let clazz = UINavigationItem.self

            ReplaceMethod(clazz, #selector(UINavigationItem.setLeftBarButton(_:animated:)), #selector(UINavigationItem.qmui_setLeftBarButton(_:animated:)))
            ReplaceMethod(clazz, #selector(UINavigationItem.setLeftBarButtonItems(_:animated:)), #selector(UINavigationItem.qmui_setLeftBarButtonItems(_:animated:)))
            ReplaceMethod(clazz, #selector(UINavigationItem.setRightBarButton(_:animated:)), #selector(UINavigationItem.qmui_setRightBarButton(_:animated:)))
            ReplaceMethod(clazz, #selector(UINavigationItem.setRightBarButtonItems(_:animated:)), #selector(UINavigationItem.qmui_setRightBarButtonItems(_:animated:)))
        }
    }
    
    @objc func qmui_setLeftBarButton(_ item: UIBarButtonItem, animated: Bool) {
        if detectSetItemsWhenPopping {
            tempLeftBarButtonItems = [item]
            return
        }
        
        qmui_setLeftBarButton(item, animated: animated)
        
        // 自动给 position 赋值
        item.qmui_navigationButton?.buttonPosition = .left
        // iOS 11，调整自定义返回按钮的位置 https://github.com/QMUI/QMUI_iOS/issues/279
        if #available(iOS 11, *) {
            guard let navigationBar = qmui_navigationBar else {
                return
            }
            navigationBar.qmui_customizingBackBarButtonItem = item.qmui_isCustomizedBackBarButtonItem
        }
    }
    
    @objc func qmui_setLeftBarButtonItems(_ items: [UIBarButtonItem], animated: Bool) {
        if detectSetItemsWhenPopping {
            tempLeftBarButtonItems = items
            return
        }
        
        qmui_setLeftBarButtonItems(items, animated: animated)
        // 自动给 position 赋值
        for (i, item) in items.enumerated() {
            if i == 0 {
                item.qmui_navigationButton?.buttonPosition = .left
            } else {
                item.qmui_navigationButton?.buttonPosition = .none
            }
        }
        
        // iOS 11，调整自定义返回按钮的位置 https://github.com/QMUI/QMUI_iOS/issues/279
        if #available(iOS 11, *) {
            guard let navigationBar = qmui_navigationBar else {
                return
            }
            var customizingBackBarButtonItem = false
            for item in items {
                if item.qmui_isCustomizedBackBarButtonItem {
                    customizingBackBarButtonItem = true
                    break
                }
            }
            navigationBar.qmui_customizingBackBarButtonItem = customizingBackBarButtonItem
        }
    }
    
    @objc func qmui_setRightBarButton(_ item: UIBarButtonItem, animated: Bool) {
        if detectSetItemsWhenPopping {
            tempRightBarButtonItems = [item]
            return
        }
        
        qmui_setRightBarButton(item, animated: animated)
        
        // 自动给 position 赋值
        item.qmui_navigationButton?.buttonPosition = .right
    }
    
    @objc func qmui_setRightBarButtonItems(_ items: [UIBarButtonItem], animated: Bool) {
        if detectSetItemsWhenPopping {
            tempRightBarButtonItems = items
            return
        }
        
        qmui_setRightBarButtonItems(items, animated: animated)
        // 自动给 position 赋值
        for (i, item) in items.enumerated() {
            if i == 0 {
                item.qmui_navigationButton?.buttonPosition = .right
            } else {
                item.qmui_navigationButton?.buttonPosition = .none
            }
        }
    }
    
    private struct Keys {
        static var tempLeftBarButtonItems = "tempLeftBarButtonItems"
        static var tempRightBarButtonItems = "tempRightBarButtonItems"
    }
    
    fileprivate var tempLeftBarButtonItems: [UIBarButtonItem]? {
        set {
            objc_setAssociatedObject(self, &Keys.tempLeftBarButtonItems, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &Keys.tempLeftBarButtonItems) as? [UIBarButtonItem]
        }
    }
    
    fileprivate var tempRightBarButtonItems: [UIBarButtonItem]? {
        set {
            objc_setAssociatedObject(self, &Keys.tempRightBarButtonItems, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &Keys.tempRightBarButtonItems) as? [UIBarButtonItem]
        }
    }
    
    // 监控是否在 iOS 10 及以下，手势返回的过程中，手势返回背后的那个界面修改了 navigationItem，这可能导致 bug：https://github.com/QMUI/QMUI_iOS/issues/302
    private var detectSetItemsWhenPopping: Bool {
        if #available(iOS 11, *) {
        } else {
            if let qmui_navigationBar = qmui_navigationBar, let navController = qmui_navigationBar.delegate as? UINavigationController {
                if navController.topViewController?.qmui_willAppearByInteractivePopGestureRecognizer ?? false && navController.topViewController?.qmui_navigationControllerPopGestureRecognizerChanging ?? false {
                    // 注意，判断条件里的 qmui_navigationControllerPopGestureRecognizerChanging 关键在于，它是在 viewWillAppear: 执行后才被置为 YES，而 QMUICommonViewController 是在 viewWillAppear: 里调用 setNavigationItems:，所以刚好过滤了这种场景。因为测试过，在 viewWillAppear: 里操作 items 是没问题的，但在那之后的操作就会有问题。
                    print("UINavigationItem (QMUINavigationButton) 拦截了一次可能产生顶部按钮混乱的操作，navigationController is \(navController), topViewController is \(String(describing: navController.topViewController))")
                    return true
                }
            }
        }
        return false
    }
    
    fileprivate weak var qmui_navigationBar: UINavigationBar? {
        // UINavigationItem 内部有个方法可以获取 navigationBar
        guard self.responds(to: #selector(getter: UINavigationController.navigationBar)) else {
            return nil
        }
        let result = perform(#selector(getter: UINavigationController.navigationBar)).takeRetainedValue() as? UINavigationBar
        return result
    }
}

extension UIViewController {
    @objc func navigationButton_viewDidAppear(_ animated: Bool) {
        navigationButton_viewDidAppear(animated)
        if let tempLeftBarButtonItems = navigationItem.tempLeftBarButtonItems {
            print("UIViewController (QMUINavigationButton) \(String(describing: type(of: self))) 在 viewDidAppear: 重新设置了 leftBarButtonItems: \(String(describing: navigationItem.tempLeftBarButtonItems))")
            navigationItem.leftBarButtonItems = tempLeftBarButtonItems
            navigationItem.tempLeftBarButtonItems = nil
        }
        if let tempRightBarButtonItems = navigationItem.tempRightBarButtonItems {
            print("UIViewController (QMUINavigationButton) \(String(describing: type(of: self))) 在 viewDidAppear: 重新设置了 rightBarButtonItems: \(String(describing: navigationItem.tempRightBarButtonItems))")
            navigationItem.rightBarButtonItems = tempRightBarButtonItems
            navigationItem.tempRightBarButtonItems = nil
        }
    }
}

extension UINavigationBar {
    
    /// 获取 navigationBar 内部的 contentView
    fileprivate weak var qmui_contentView: UIView? {
        for subview in subviews {
            if String(describing: type(of: subview)).contains("ContentView") {
                return subview
            }
        }
        return nil
    }
    
    private struct Keys {
        static var customizingBackBarButtonItem = "customizingBackBarButtonItem"
    }
    
    /// 判断当前的 UINavigationBar 的返回按钮是不是自定义的
    fileprivate var qmui_customizingBackBarButtonItem: Bool {
        set {
            objc_setAssociatedObject(self, &Keys.customizingBackBarButtonItem, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if #available(iOS 11, *) {
                if let contentView = qmui_contentView, contentView.safeAreaInsets.left == 0,  contentView.safeAreaInsets.right == 0 {
                    // TODO: molice iPhone X 横屏下，这段代码会导致 margins 不断变大，待解决，目前先屏蔽横屏的情况（也即 safeAreaInsets 左右不为0）
                    var layoutMargins = contentView.directionalLayoutMargins
                    let leadingMargin = max(0, layoutMargins.trailing - contentView.safeAreaInsets.right - (qmui_customizingBackBarButtonItem ? 8 : 0))
                    if layoutMargins.leading != leadingMargin {
                        layoutMargins.leading = leadingMargin
                        contentView.directionalLayoutMargins = layoutMargins
                    }
                }
            }
        }
        get {
            return objc_getAssociatedObject(self, &Keys.customizingBackBarButtonItem) as? Bool ?? false
        }
    }
}
