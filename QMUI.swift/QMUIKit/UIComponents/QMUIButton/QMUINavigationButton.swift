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
 *  QMUINavigationButton 是用于 UINavigationItem 的按钮，有两种使用方式：
 *  1. 利用类方法，快速生成所需的 UIBarButtonItem，其中大部分 UIBarButtonItem 均使用系统的 initWithBarButtonSystemItem 或 initWithImage 接口创建，仅有返回按钮利用了 customView 来创建 UIBarButtonItem。
 *  2. 利用 init 方法生成一个 QMUINavigationButton 实例，再通过类方法 + barButtonItemWithNavigationButton:position:target:action: 来生成一个对应的 UIBarButtonItem，此时 QMUINavigationButton 将作为 UIBarButtonItem 的 customView。
 *  若能满足需求，建议优先使用第 1 种方式。
 *  @note 关于 tintColor：UIBarButtonItem 如果使用了 customView，则需要修改 customView.tintColor，如果没使用 customView，则直接修改 UIBarButtonItem.tintColor。
 */
class QMUINavigationButton: UIButton {
    
    /**
     *  获取当前按钮的`QMUINavigationButtonType`
     */
    private(set) var type: QMUINavigationButtonType = .normal
    
    /**
     *  设置按钮是否用于UINavigationBar上的UIBarButtonItem。若为YES，则会参照系统的按钮布局去更改QMUINavigationButton的内容布局，若为NO，则内容布局与普通按钮没差别。默认为YES。
     */
    var useForBarButtonItem: Bool = true {
        didSet {
            if useForBarButtonItem == oldValue || type != .back { return }
            // 只针对返回按钮，调整箭头和title之间的间距
            // @warning 这些数值都是每个iOS版本核对过没问题的，如果修改则要检查要每个版本里与系统UIBarButtonItem的布局是否一致
            if useForBarButtonItem {
                let titleOffsetBaseOnSystem = UIOffset(horizontal: IOS_VERSION >= 11.0 ? 6 : 7, vertical: 0) // 经过这些数值的调整后，自定义返回按钮的位置才能和系统默认返回按钮的位置对准，而配置表里设置的值是在这个调整的基础上再调整
                let configurationOffset = NavBarBarBackButtonTitlePositionAdjustment
                titleEdgeInsets = UIEdgeInsets(
                    top: titleOffsetBaseOnSystem.vertical + configurationOffset.vertical,
                    left: titleOffsetBaseOnSystem.horizontal + configurationOffset.horizontal,
                    bottom: -titleOffsetBaseOnSystem.vertical - configurationOffset.vertical,
                    right: -titleOffsetBaseOnSystem.horizontal - configurationOffset.horizontal)
                contentEdgeInsets = UIEdgeInsetsMake(
                    IOS_VERSION >= 11.0 ? 0 : 1, // iOS 11 以前的自定义返回按钮要特地往下偏移一点才会和系统的一模一样
                    IOS_VERSION >= 11.0 ? -8 : 0, // iOS 11 使用了自定义按钮后整个按钮都会强制被往右边挪 8pt，所以这里要通过 contentEdgeInsets.left 偏移回来
                    0,
                    titleEdgeInsets.left) // 保证 button 有足够的宽度
            }
            // 由于contentEdgeInsets会影响frame的大小，所以更新数值后需要重新计算size
            sizeToFit()
        }
    }
    
    private var buttonPosition: QMUINavigationButtonPosition = .none
    
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
        contentEdgeInsets = UIEdgeInsetsMake(3, 11, 3, 11)
        sizeToFit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // 修复系统的UIBarButtonItem里的图片无法跟着tintColor走
    override func setImage(_ image: UIImage?, for state: UIControlState) {
        var newImage = image
        if newImage != nil && newImage!.renderingMode == .automatic {
            // 由于 QMUINavigationButton 是用于 UIBarButtonItem 的，所以默认的行为应该是尽量去跟随 tintColor，所以做了这个优化
            newImage = newImage!.withRenderingMode(.alwaysTemplate)
        }
        
        super.setImage(newImage, for: state)
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
        
        if !useForBarButtonItem || buttonPosition == .none {
            return insets
        }
        
        if buttonPosition == .left {
            // 正值表示往左偏移
            if type == .image {
                insets = insets.setLeft(11)
            } else {
                insets = insets.setLeft(8)
            }
        } else if buttonPosition == .right  {
            // 正值表示往右偏移
            if type == .image {
                insets = insets.setRight(11)
            } else {
                insets = insets.setRight(8)
            }
        }
        
        let isBackOrImageType = type == .back || type == .image
        if isBackOrImageType {
            insets = insets.setTop(PixelOne)
        } else {
            insets = insets.setTop(1)
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
        adjustsImageWhenHighlighted = false
        adjustsImageWhenDisabled = false
        
        switch type {
        case .bold:
            if let font = NavBarButtonFontBold{
                titleLabel?.font = font
            }
        case .back:
            contentHorizontalAlignment = .left
            
            guard let backIndicatorImage = NavBarBackIndicatorImage else {
                print("NavBarBackIndicatorImage 为 nil，无法创建正确的 QMUINavigationButtonTypeBack 按钮")
                return
            }
            setImage(backIndicatorImage, for: .normal)
            setImage(backIndicatorImage.qmui_image(alpha: NavBarHighlightedAlpha), for: .highlighted)
            setImage(backIndicatorImage.qmui_image(alpha: NavBarDisabledAlpha), for: .disabled)
        default:
            break
        }
    }
    
    /**
     *  创建一个 type 为 QMUINavigationButtonTypeBack 的 button 并作为 customView 用于生成一个 UIBarButtonItem，返回按钮的图片由配置表里的宏 NavBarBackIndicatorImage 决定。
     *  @param target 按钮点击事件的接收者
     *  @param Selector 按钮点击事件的方法
     *  @param tintColor 按钮要显示的颜色，如果为 nil，则表示跟随当前 UINavigationBar 的 tintColor
     */
    static func backBarButtonItem(target: Any?, action: Selector?, tintColor: UIColor?) -> UIBarButtonItem? {
        var backTitle: String?
        if NeedsBackBarButtonItemTitle {
            backTitle = "返回" // 默认文字用返回
            if let viewController = target as? UIViewController {
                let previousViewController = viewController.qmui_previousViewController
                if let item = previousViewController?.navigationItem.backBarButtonItem {
                    // 如果前一个界面有
                    backTitle = item.title
                } else if previousViewController?.title != nil {
                    backTitle = previousViewController!.title
                }
            }
        } else {
            backTitle = " "
        }
        
        return systemBarButtonItem(.back, title: backTitle, tintColor: tintColor, position: .left, target: target, action: action)
    }
    
    /**
     *  创建一个 type 为 QMUINavigationButtonTypeBack 的 button 并作为 customView 用于生成一个 UIBarButtonItem，返回按钮的图片由配置表里的宏 NavBarBackIndicatorImage 决定，按钮颜色跟随 UINavigationBar 的 tintColor。
     *  @param target 按钮点击事件的接收者
     *  @param Selector 按钮点击事件的方法
     */
    static func backBarButtonItem(target: Any?, action: Selector?) -> UIBarButtonItem? {
        return backBarButtonItem(target: target, action: action, tintColor: nil)
    }
    
    /**
     *  创建一个以 “×” 为图标的关闭按钮，图片由配置表里的宏 NavBarCloseButtonImage 决定。
     *  @param target 按钮点击事件的接收者
     *  @param Selector 按钮点击事件的方法
     *  @param tintColor 按钮要显示的颜色，如果为 nil，则表示跟随当前 UINavigationBar 的 tintColor
     */
    static func closeBarButtonItem(target: Any?, action: Selector?, tintColor: UIColor?)
        -> UIBarButtonItem {
            let item = UIBarButtonItem(image: NavBarCloseButtonImage, style: .plain, target: target, action: action)
            item.tintColor = tintColor
            return item
    }
    
    /**
     *  创建一个以 “×” 为图标的关闭按钮，图片由配置表里的宏 NavBarCloseButtonImage 决定，图片颜色跟随 UINavigationBar.tintColor。
     *  @param target 按钮点击事件的接收者
     *  @param Selector 按钮点击事件的方法
     */
    static func closeBarButtonItem(target: Any?, action: Selector?)
        -> UIBarButtonItem {
            return closeBarButtonItem(target: target, action: action, tintColor: nil)
    }
    
    /**
     *  创建一个 UIBarButtonItem
     *  @param type 按钮的类型
     *  @param title 按钮的标题
     *  @param tintColor 按钮的颜色，如果为 nil，则表示跟随当前 UINavigationBar 的 tintColor
     *  @param position 按钮在 UINavigationBar 上的左右位置，如果某一边的按钮有多个，则只有最左边（最右边）的按钮需要设置为 QMUINavigationButtonPositionLeft（QMUINavigationButtonPositionRight），靠里的按钮使用 QMUINavigationButtonPositionNone 即可
     *  @param target 按钮点击事件的接收者
     *  @param Selector 按钮点击事件的方法
     */
    
    static func barButtonItem(type: QMUINavigationButtonType, title: String?, tintColor: UIColor?, position: QMUINavigationButtonPosition, target: Any?, action: Selector?) -> UIBarButtonItem? {
        let barButtonItem = systemBarButtonItem(type, title: title, tintColor: tintColor, position: position, target: target, action: action)
        return barButtonItem
    }
    
    /**
     *  创建一个 UIBarButtonItem
     *  @param type 按钮的类型
     *  @param title 按钮的标题
     *  @param position 按钮在 UINavigationBar 上的左右位置，如果某一边的按钮有多个，则只有最左边（最右边）的按钮需要设置为 QMUINavigationButtonPositionLeft（QMUINavigationButtonPositionRight），靠里的按钮使用 QMUINavigationButtonPositionNone 即可
     *  @param target 按钮点击事件的接收者
     *  @param Selector 按钮点击事件的方法
     */
    static func barButtonItem(type: QMUINavigationButtonType, title: String?, position: QMUINavigationButtonPosition, target: Any?, action: Selector?) -> UIBarButtonItem? {
        return barButtonItem(type: type, title: title, tintColor: nil, position: position, target: target, action: action)
    }
    
    /**
     *  将参数传进来的 button 作为 customView 用于生成一个 UIBarButtonItem。
     *  @param button 要作为 customView 的 QMUINavigationButton
     *  @param tintColor 按钮的颜色，如果为 nil，则表示跟随当前 UINavigationBar 的 tintColor
     *  @param position 按钮在 UINavigationBar 上的左右位置，如果某一边的按钮有多个，则只有最左边（最右边）的按钮需要设置为 QMUINavigationButtonPositionLeft（QMUINavigationButtonPositionRight），靠里的按钮使用 QMUINavigationButtonPositionNone 即可
     *  @param target 按钮点击事件的接收者
     *  @param Selector 按钮点击事件的方法
     *
     *  @note tintColor、position、target、Selector? 等参数不需要对 QMUINavigationButton 设置，通过参数传进来就可以了，就算设置了也会在这个方法里被覆盖。
     */
    static func barButtonItem(navigationButton: QMUINavigationButton, tintColor: UIColor?, position: QMUINavigationButtonPosition, target: Any?, action: Selector?) -> UIBarButtonItem? {
        if let target = target, let action = action {
            navigationButton.addTarget(target, action: action, for: .touchUpInside)
        }
        navigationButton.tintColor = tintColor
        navigationButton.buttonPosition = position
        let barButtonItem = UIBarButtonItem(customView: navigationButton)
        return barButtonItem
    }
    
    /**
     *  将参数传进来的 button 作为 customView 用于生成一个 UIBarButtonItem。
     *  @param button 要作为 customView 的 QMUINavigationButton
     *  @param position 按钮在 UINavigationBar 上的左右位置，如果某一边的按钮有多个，则只有最左边（最右边）的按钮需要设置为 QMUINavigationButtonPositionLeft（QMUINavigationButtonPositionRight），靠里的按钮使用 QMUINavigationButtonPositionNone 即可
     *  @param target 按钮点击事件的接收者
     *  @param Selector 按钮点击事件的方法
     *
     *  @note position、target、Selector? 等参数不需要对 QMUINavigationButton 设置，通过参数传进来就可以了，就算设置了也会在这个方法里被覆盖。
     */
    static func barButtonItem(navigationButton: QMUINavigationButton, position: QMUINavigationButtonPosition, target: Any?, action: Selector?) -> UIBarButtonItem? {
        return barButtonItem(navigationButton: navigationButton, tintColor: nil, position: position, target: target, action: action)
    }
    
    /**
     *  创建一个图片类型的 UIBarButtonItem
     *  @param image 按钮的图标
     *  @param tintColor 按钮的颜色，如果为 nil，则表示跟随当前 UINavigationBar 的 tintColor
     *  @param position 按钮在 UINavigationBar 上的左右位置，如果某一边的按钮有多个，则只有最左边（最右边）的按钮需要设置为 QMUINavigationButtonPositionLeft（QMUINavigationButtonPositionRight），靠里的按钮使用 QMUINavigationButtonPositionNone 即可
     *  @param target 按钮点击事件的接收者
     *  @param Selector 按钮点击事件的方法
     */
    static func barButtonItem(image: UIImage?, tintColor: UIColor?, position: QMUINavigationButtonPosition, target: Any?, action: Selector?) -> UIBarButtonItem? {
        let barButtonItem = UIBarButtonItem(image: image, style: .plain, target: target, action: action)
        barButtonItem.tintColor = tintColor
        return barButtonItem
    }
    
    /**
     *  创建一个图片类型的 UIBarButtonItem
     *  @param image 按钮的图标
     *  @param position 按钮在 UINavigationBar 上的左右位置，如果某一边的按钮有多个，则只有最左边（最右边）的按钮需要设置为 QMUINavigationButtonPositionLeft（QMUINavigationButtonPositionRight），靠里的按钮使用 QMUINavigationButtonPositionNone 即可
     *  @param target 按钮点击事件的接收者
     *  @param Selector 按钮点击事件的方法
     */
    static func barButtonItem(image: UIImage?, position: QMUINavigationButtonPosition, target: Any?, action: Selector?) -> UIBarButtonItem? {
        return barButtonItem(image: image, tintColor: nil, position: position, target: target, action: action)
    }
    
    static private func systemBarButtonItem(_ type: QMUINavigationButtonType, title: String?, tintColor: UIColor?, position: QMUINavigationButtonPosition, target: Any?, action: Selector?) -> UIBarButtonItem?  {
        
        switch type {
        case .back:
            // 因为有可能出现有箭头图片又有title的情况，所以这里不适合用barButtonItemWithImage:target:action:的那个接口
            let button = QMUINavigationButton(type: .back, title: title)
            button.buttonPosition = position
            if let action = action {
                button.addTarget(target, action: action, for: .touchUpInside)
            }
            button.tintColor = tintColor
            let barButtonItem = UIBarButtonItem(customView: button)
            return barButtonItem
        case .bold:
            let barButtonItem = UIBarButtonItem(title: title, style: .done, target: target, action: action)
            barButtonItem.tintColor = tintColor
            if let font = NavBarButtonFontBold {
                barButtonItem.setTitleTextAttributes([NSAttributedStringKey.font: font], for: .normal)
                
                if let tempAttributes = barButtonItem.titleTextAttributes(for: .normal) {
                    let attributes = Dictionary(uniqueKeysWithValues: tempAttributes.map {
                        key, value in (NSAttributedStringKey(key), value)
                    })
                    barButtonItem.setTitleTextAttributes(attributes, for: .highlighted)// iOS 11 如果不显式设置 highlighted 的样式，点击时字体会从加粗变成默认，导致抖动
                }
            }
            return barButtonItem
        case .image:
            // icon - 这种类型请通过barButtonItemWithImage:position:target:action:来定义
            return nil
        default:
            let barButtonItem = UIBarButtonItem(title: title, style: .plain, target: target, action: action)
            barButtonItem.tintColor = tintColor
            return barButtonItem
        }
    }
}
