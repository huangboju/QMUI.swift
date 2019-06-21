//
//  QMUIConfiguration.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/1/17.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

/// 所有配置表都应该实现的 protocol
protocol QMUIConfigurationTemplateProtocol: NSObjectProtocol {
    
    init()
    
    /// 应用配置表的设置
    func applyConfigurationTemplate()
    
    /// 当返回 YES 时，启动 App 的时候 QMUIConfiguration 会自动应用这份配置表。但启动 App 时自动应用的配置表最多只允许一份，如果有多份则其他的会被忽略，需要在某些时机手动应用
    func shouldApplyTemplateAutomatically() -> Bool
    
}

/**
 *  维护项目全局 UI 配置的单例，通过业务项目自己的 QMUIConfigurationTemplate 来为这个单例赋值，而业务代码里则通过 QMUIConfigurationMacros.swift 文件里的宏来使用这些值。
 */
class QMUIConfiguration {
    
    static let shared: QMUIConfiguration = QMUIConfiguration()
    
    private init() {
        
        disabledColor = gray
        
        buttonHighlightedAlpha = controlHighlightedAlpha
        buttonDisabledAlpha = controlDisabledAlpha
        buttonTintColor = blue

        ghostButtonColorBlue = blue
        ghostButtonColorRed = red
        ghostButtonColorGreen = green
        ghostButtonColorGray = gray
        ghostButtonColorWhite = white

        fillButtonColorBlue = blue
        fillButtonColorRed = red
        fillButtonColorGreen = green
        fillButtonColorGray = gray
        fillButtonColorWhite = white

        navBarCloseButtonImage = UIImage.qmui_image(shape: .navClose, size: CGSize(width: 16, height: 16), tintColor: navBarTintColor)

        navBarAccessoryViewTypeDisclosureIndicatorImage = UIImage.qmui_image(shape: .triangle, size: CGSize(width: 8, height: 5), tintColor: navBarTintColor)?.qmui_image(orientation: .down)

        tabBarItemTitleColorSelected = tabBarTintColor

        toolBarTintColorHighlighted = toolBarTintColor?.withAlphaComponent(toolBarHighlightedAlpha)
        toolBarTintColorDisabled = toolBarTintColor?.withAlphaComponent(toolBarDisabledAlpha)

        searchBarPlaceholderColor = placeholderColor

        tableViewSeparatorColor = separatorColor
        tableViewCellBackgroundColor = white
        tableViewCellWarningBackgroundColor = yellow

        tableViewSectionHeaderTextColor = grayDarken
        tableViewSectionFooterTextColor = gray

        tableViewGroupedSectionHeaderTextColor = grayDarken
        tableViewGroupedSectionFooterTextColor = gray
        
    }
    
    // MARK: Global Color
    var clear = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
    var white = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    var black = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
    var gray = UIColor(r: 179, g: 179, b: 179)
    var grayDarken = UIColor(r: 163, g: 163, b: 163)
    var grayLighten = UIColor(r: 198, g: 198, b: 198)
    var red = UIColor(r: 250, g: 58, b: 58)
    var green = UIColor(r: 159, g: 214, b: 97)
    var blue = UIColor(r: 49, g: 189, b: 243)
    var yellow = UIColor(r: 255, g: 207, b: 71)
    
    var linkColor = UIColor(r: 56, g: 116, b: 171)
    var disabledColor: UIColor
    var backgroundColor: UIColor?
    var maskDarkColor = UIColor(r: 0, g: 0, b: 0, a: 0.35)
    var maskLightColor = UIColor(r: 255, g: 255, b: 255, a: 0.5)
    var separatorColor = UIColor(r: 222, g: 224, b: 226)
    var separatorDashedColor = UIColor(r: 17, g: 17, b: 17)
    var placeholderColor = UIColor(r: 196, g: 200, b: 208)
    
    var testColorRed = UIColor(r: 255, g: 0, b: 0, a: 0.3)
    var testColorGreen = UIColor(r: 0, g: 255, b: 0, a: 0.3)
    var testColorBlue = UIColor(r: 0, g: 0, b: 255, a: 0.3)

    // MARK: UIControl
    var controlHighlightedAlpha: CGFloat = 0.5
    var controlDisabledAlpha: CGFloat = 0.5
    
    // MARK: UIButton
    var buttonHighlightedAlpha: CGFloat = 0
    var buttonDisabledAlpha: CGFloat = 0
    var buttonTintColor: UIColor
    
    var ghostButtonColorBlue: UIColor
    var ghostButtonColorRed: UIColor
    var ghostButtonColorGreen: UIColor
    var ghostButtonColorGray: UIColor
    var ghostButtonColorWhite: UIColor
    var fillButtonColorBlue: UIColor
    var fillButtonColorRed: UIColor
    var fillButtonColorGreen: UIColor
    var fillButtonColorGray: UIColor
    var fillButtonColorWhite: UIColor
    
    // MARK: UITextField & UITextView
    var textFieldTintColor: UIColor?
    var textFieldTextInsets = UIEdgeInsets(top: 0, left: 7, bottom: 0, right: 7)
    
    // MARK: NavigationBar
    var navBarHighlightedAlpha: CGFloat = 0.2
    var navBarDisabledAlpha: CGFloat = 0.2
    var navBarButtonFont: UIFont? {
        didSet {
            // by molice 2017-08-04 只要用 appearence 的方式修改 UIBarButtonItem 的 font，就会导致界面切换时 UIBarButtonItem 抖动，系统的问题，所以暂时不修改 appearance。
        }
    }
    var navBarButtonFontBold: UIFont?
    var navBarBackgroundImage: UIImage? {
        didSet {
            guard let navBarBackgroundImage = navBarBackgroundImage else { return }
//            let appearance = UINavigationBar.appearance()
//            appearance.setBackgroundImage(navBarBackgroundImage, for: .default)
            QMUIHelper.visibleViewController?.navigationController?
                .navigationBar.setBackgroundImage(navBarBackgroundImage, for: .default)
        }
    }
    var navBarShadowImage: UIImage? {
        didSet {
            guard let navBarShadowImage = navBarShadowImage else { return }
//                let appearance = UINavigationBar.appearance()
//                appearance.shadowImage = navBarShadowImage
            QMUIHelper.visibleViewController?.navigationController?.navigationBar.shadowImage = navBarShadowImage
        }
    }
    var navBarBarTintColor: UIColor? {
        didSet {
            guard let navBarBarTintColor = navBarBarTintColor else { return }
//            UINavigationBar.appearance().barTintColor = navBarBarTintColor
            QMUIHelper.visibleViewController?.navigationController?.navigationBar.barTintColor = navBarBarTintColor
        }
    }
    var navBarTintColor: UIColor? {
        didSet {
            guard let navBarTintColor = navBarTintColor else { return }
//            print(QMUIHelper.visibleViewController ?? "")
            QMUIHelper.visibleViewController?.navigationController?.navigationBar.tintColor = navBarTintColor
        }
    }
    var navBarTitleColor: UIColor? {
        didSet {
            updateNavigationBarTitleAttributesIfNeeded()
        }
    }
    var navBarTitleFont: UIFont? {
        didSet {
            updateNavigationBarTitleAttributesIfNeeded()
        }
    }
    var navBarLargeTitleColor: UIColor? {
        didSet {
            updateNavigationBarLargeTitleTextAttributesIfNeeded()
        }
    }
    var navBarLargeTitleFont: UIFont? {
        didSet {
            updateNavigationBarLargeTitleTextAttributesIfNeeded()
        }
    }
    var navBarBackButtonTitlePositionAdjustment = UIOffset.zero {
        didSet {
            if UIOffset.zero != navBarBackButtonTitlePositionAdjustment {
                let backBarButtonItem = UIBarButtonItem.appearance()
                backBarButtonItem
                    .setBackButtonTitlePositionAdjustment(navBarBackButtonTitlePositionAdjustment,
                                                                       for: .default)
                QMUIHelper.visibleViewController?.navigationController?
                    .navigationItem.backBarButtonItem?.setBackButtonTitlePositionAdjustment(navBarBackButtonTitlePositionAdjustment, for: .default)
            }
        }
    }
    var navBarBackIndicatorImage: UIImage? {
        didSet {
            guard let _ = navBarBackIndicatorImage else { return }
            let navBarAppearance = UINavigationBar.appearance()
            let navigationBar = QMUIHelper.visibleViewController?.navigationController?.navigationBar
            // 返回按钮的图片frame是和系统默认的返回图片的大小一致的（13, 21），所以用自定义返回箭头时要保证图片大小与系统的箭头大小一样，否则无法对齐
            let systemBackIndicatorImageSize = CGSize(width: 13, height: 21)
            let customBackIndicatorImageSize = navBarBackIndicatorImage!.size
            if customBackIndicatorImageSize != systemBackIndicatorImageSize {
                let imageExtensionVerticalFloat = systemBackIndicatorImageSize.height.center(customBackIndicatorImageSize.height)
                navBarBackIndicatorImage = navBarBackIndicatorImage!.qmui_image(spacingExtensionInsets: UIEdgeInsets.init(top: imageExtensionVerticalFloat, left: 0, bottom: imageExtensionVerticalFloat, right: systemBackIndicatorImageSize.width - customBackIndicatorImageSize.width))?.withRenderingMode(navBarBackIndicatorImage!.renderingMode)
            }
            
            navBarAppearance.backIndicatorImage = navBarBackIndicatorImage
            navBarAppearance.backIndicatorTransitionMaskImage = navBarBackIndicatorImage
            navigationBar?.backIndicatorImage = navBarBackIndicatorImage
            navigationBar?.backIndicatorTransitionMaskImage = navBarBackIndicatorImage
        }
    }
    var navBarCloseButtonImage: UIImage?
    
    var navBarLoadingMarginRight: CGFloat = 3
    var navBarAccessoryViewMarginLeft: CGFloat = 5
    var navBarActivityIndicatorViewStyle: UIActivityIndicatorView.Style = .gray
    var navBarAccessoryViewTypeDisclosureIndicatorImage: UIImage?

    // MARK: TabBar
    var tabBarBackgroundImage: UIImage? {
        didSet {
            guard let tabBarBackgroundImage = tabBarBackgroundImage else { return }
            UITabBar.appearance().backgroundImage = tabBarBackgroundImage
            QMUIHelper.visibleViewController?.tabBarController?.tabBar.backgroundImage = tabBarBackgroundImage
        }
    }
    var tabBarBarTintColor: UIColor? {
        didSet {
            guard let tabBarBarTintColor = tabBarBarTintColor else { return }
            UITabBar.appearance().barTintColor = tabBarBarTintColor
            QMUIHelper.visibleViewController?.tabBarController?.tabBar.barTintColor = tabBarBarTintColor
        }
    }
    var tabBarShadowImageColor: UIColor? {
        didSet {
            guard let tabBarShadowImageColor = tabBarShadowImageColor else { return }
            let shadowImage = UIImage.qmui_image(color: tabBarShadowImageColor, size: CGSize(width: 1, height: PixelOne), cornerRadius: 0)
            UITabBar.appearance().shadowImage = shadowImage
            QMUIHelper.visibleViewController?.tabBarController?.tabBar.shadowImage = shadowImage
        }
    }
    var tabBarTintColor: UIColor? {
        didSet {
            guard let tabBarTintColor = tabBarTintColor else { return }
            QMUIHelper.visibleViewController?.tabBarController?.tabBar.tintColor = tabBarTintColor
        }
    }
    var tabBarItemTitleColor: UIColor? {
        didSet {
            guard let tabBarItemTitleColor = tabBarItemTitleColor else { return }
            let attributes = convertFromOptionalNSAttributedStringKeyDictionary(UITabBarItem.appearance().titleTextAttributes(for: .normal)) ?? [String: Any]()
            var textAttributes = Dictionary(uniqueKeysWithValues:attributes.lazy.map { (NSAttributedString.Key($0.key), $0.value) })
            textAttributes[NSAttributedString.Key.foregroundColor] = tabBarItemTitleColor
            UITabBarItem.appearance().setTitleTextAttributes(textAttributes, for: .normal)
            QMUIHelper.visibleViewController?.tabBarController?.tabBar.items?.forEach {
                $0.setTitleTextAttributes(textAttributes, for: .normal)
            }
        }
    }
    var tabBarItemTitleColorSelected: UIColor? {
        didSet {
            guard let tabBarItemTitleColorSelected = tabBarItemTitleColorSelected else { return }
            let attributes = convertFromOptionalNSAttributedStringKeyDictionary(UITabBarItem.appearance().titleTextAttributes(for: .normal)) ?? [String: Any]()
            var textAttributes = Dictionary(uniqueKeysWithValues:attributes.lazy.map { (NSAttributedString.Key($0.key), $0.value) })
            textAttributes[NSAttributedString.Key.foregroundColor] = tabBarItemTitleColorSelected
            UITabBarItem.appearance().setTitleTextAttributes(textAttributes, for: .selected)
            QMUIHelper.visibleViewController?.tabBarController?.tabBar.items?.forEach {
                $0.setTitleTextAttributes(textAttributes, for: .selected)
            }
        }
    }
    var tabBarItemTitleFont: UIFont? {
        didSet {
            guard let tabBarItemTitleFont = tabBarItemTitleFont else { return }
            let attributes = convertFromOptionalNSAttributedStringKeyDictionary(UITabBarItem.appearance().titleTextAttributes(for: .normal)) ?? [String: Any]()
            var textAttributes = Dictionary(uniqueKeysWithValues:attributes.lazy.map { (NSAttributedString.Key($0.key), $0.value) })
            textAttributes[NSAttributedString.Key.font] = tabBarItemTitleFont
            UITabBarItem.appearance().setTitleTextAttributes(textAttributes, for: .normal)
            QMUIHelper.visibleViewController?.tabBarController?.tabBar.items?.forEach {
                $0.setTitleTextAttributes(textAttributes, for: .normal)
            }
        }
    }

    // MARK: Toolbar
    var toolBarHighlightedAlpha: CGFloat = 0.4
    var toolBarDisabledAlpha: CGFloat = 0.4
    var toolBarTintColor: UIColor? {
        didSet {
            guard let toolBarTintColor = toolBarTintColor else { return }
            QMUIHelper.visibleViewController?.navigationController?.toolbar.tintColor = toolBarTintColor
        }
    }
    var toolBarTintColorHighlighted: UIColor?
    var toolBarTintColorDisabled: UIColor?
    var toolBarBackgroundImage: UIImage? {
        didSet {
            guard let toolBarBackgroundImage = toolBarBackgroundImage else { return }
            UIToolbar.appearance().setBackgroundImage(toolBarBackgroundImage, forToolbarPosition: .any, barMetrics: .default)
            QMUIHelper.visibleViewController?.navigationController?.toolbar
                .setBackgroundImage(toolBarBackgroundImage, forToolbarPosition: .any, barMetrics: .default)
        }
    }
    var toolBarBarTintColor: UIColor? {
        didSet {
            guard let toolBarBarTintColor = toolBarBarTintColor else { return }
            UIToolbar.appearance().barTintColor = toolBarBarTintColor
            QMUIHelper.visibleViewController?.navigationController?.toolbar.barTintColor = toolBarBarTintColor
        }
    }
    var toolBarShadowImageColor: UIColor? {
        didSet {
            guard let toolBarShadowImageColor = toolBarShadowImageColor else { return }
            let shadowImage = UIImage.qmui_image(color: toolBarShadowImageColor, size: CGSize(width: 1, height: PixelOne), cornerRadius: 0)
            UIToolbar.appearance().setShadowImage(shadowImage, forToolbarPosition: .any)
            QMUIHelper.visibleViewController?.navigationController?.toolbar.setShadowImage(shadowImage, forToolbarPosition: .any)
        }
    }
    var toolBarButtonFont: UIFont?

    // MARK: SearchBar
    var searchBarTextFieldBackground: UIColor?
    var searchBarTextFieldBorderColor: UIColor?
    var searchBarBottomBorderColor: UIColor?
    var searchBarBarTintColor: UIColor?
    var searchBarTintColor: UIColor?
    var searchBarTextColor: UIColor?
    var searchBarPlaceholderColor: UIColor
    var searchBarFont: UIFont?
    /// 搜索框放大镜icon的图片，大小必须为13x13pt，否则会失真（系统的限制）
    var searchBarSearchIconImage: UIImage?
    var searchBarClearIconImage: UIImage?
    var searchBarTextFieldCornerRadius: CGFloat = 2

    // MARK: TableView / TableViewCell
    var tableViewEstimatedHeightEnabled = true
    var tableViewBackgroundColor: UIColor?
    var tableViewGroupedBackgroundColor: UIColor?
    var tableSectionIndexColor: UIColor?
    var tableSectionIndexBackgroundColor: UIColor?
    var tableSectionIndexTrackingBackgroundColor: UIColor?
    var tableViewSeparatorColor: UIColor

    var tableViewCellNormalHeight: CGFloat = 44
    var tableViewCellTitleLabelColor: UIColor?
    var tableViewCellDetailLabelColor: UIColor?
    var tableViewCellBackgroundColor: UIColor
    var tableViewCellSelectedBackgroundColor = UIColor(r: 238, g: 239, b: 241)
    var tableViewCellWarningBackgroundColor: UIColor
    var tableViewCellDisclosureIndicatorImage: UIImage?
    var tableViewCellCheckmarkImage: UIImage?
    var tableViewCellDetailButtonImage: UIImage?
    var tableViewCellSpacingBetweenDetailButtonAndDisclosureIndicator: CGFloat = 12

    var tableViewSectionHeaderBackgroundColor = UIColor(r: 244, g: 244, b: 244)
    var tableViewSectionFooterBackgroundColor = UIColor(r: 244, g: 244, b: 244)
    var tableViewSectionHeaderFont = UIFontBoldMake(12)
    var tableViewSectionFooterFont = UIFontBoldMake(12)
    var tableViewSectionHeaderTextColor: UIColor
    var tableViewSectionFooterTextColor: UIColor
    var tableViewSectionHeaderAccessoryMargins = UIEdgeInsets.init(top: 0, left: 15, bottom: 0, right: 0)
    var tableViewSectionFooterAccessoryMargins = UIEdgeInsets.init(top: 0, left: 15, bottom: 0, right: 0)
    var tableViewSectionHeaderContentInset = UIEdgeInsets.init(top: 4, left: 15, bottom: 4, right: 15)
    var tableViewSectionFooterContentInset = UIEdgeInsets.init(top: 4, left: 15, bottom: 4, right: 15)

    var tableViewGroupedSectionHeaderFont = UIFontMake(12)
    var tableViewGroupedSectionFooterFont = UIFontMake(12)
    var tableViewGroupedSectionHeaderTextColor: UIColor
    var tableViewGroupedSectionFooterTextColor: UIColor
    var tableViewGroupedSectionHeaderAccessoryMargins = UIEdgeInsets.init(top: 0, left: 15, bottom: 0, right: 0)
    var tableViewGroupedSectionFooterAccessoryMargins = UIEdgeInsets.init(top: 0, left: 15, bottom: 0, right: 0)
    var tableViewGroupedSectionHeaderDefaultHeight = UITableView.automaticDimension
    var tableViewGroupedSectionFooterDefaultHeight = UITableView.automaticDimension
    var tableViewGroupedSectionHeaderContentInset = UIEdgeInsets.init(top: 16, left: 15, bottom: 8, right: 15)
    var tableViewGroupedSectionFooterContentInset = UIEdgeInsets.init(top: 8, left: 15, bottom: 2, right: 15)

    // MARK: UIWindowLevel
    var windowLevelQMUIAlertView: CGFloat = UIWindow.Level.alert.rawValue - 4
    var windowLevelQMUIImagePreviewView: CGFloat = UIWindow.Level.statusBar.rawValue + 1

    // MARK: QMUILog
//    var shouldPrintDefaultLog: Bool
//    var shouldPrintInfoLog: Bool
//    var shouldPrintWarnLog: Bool

    // MARK: Others
    var supportedOrientationMask: UIInterfaceOrientationMask = .portrait
    var automaticallyRotateDeviceOrientation: Bool = false
    var statusbarStyleLightInitially: Bool = false
    var needsBackBarButtonItemTitle: Bool = false
    var hidesBottomBarWhenPushedInitially: Bool = false
    var preventConcurrentNavigationControllerTransitions: Bool = true
    var navigationBarHiddenInitially: Bool = false
    var shouldFixTabBarTransitionBugInIPhoneX: Bool = false

    private func updateNavigationBarTitleAttributesIfNeeded() {
        if navBarTitleFont != nil || navBarTitleColor != nil {
            var titleTextAttributes = [NSAttributedString.Key: NSObject]()
            if let navBarTitleFont = navBarTitleFont {
                titleTextAttributes[NSAttributedString.Key.font] = navBarTitleFont
            }
            if let navBarTitleColor = navBarTitleColor {
                titleTextAttributes[NSAttributedString.Key.foregroundColor] = navBarTitleColor
            }
            UINavigationBar.appearance().titleTextAttributes = titleTextAttributes
            QMUIHelper.visibleViewController?.navigationController?.navigationBar.titleTextAttributes = titleTextAttributes
        }
    }
    
    private func updateNavigationBarLargeTitleTextAttributesIfNeeded() {
        if #available(iOS 11, *) {
            if navBarLargeTitleFont != nil || navBarLargeTitleColor != nil {
                var largeTitleTextAttributes = [NSAttributedString.Key: NSObject]()
                if let navBarLargeTitleFont = navBarLargeTitleFont {
                    largeTitleTextAttributes[NSAttributedString.Key.font] = navBarLargeTitleFont
                }
                if let navBarLargeTitleColor = navBarLargeTitleColor {
                    largeTitleTextAttributes[NSAttributedString.Key.foregroundColor] = navBarLargeTitleColor
                }
                UINavigationBar.appearance().largeTitleTextAttributes = largeTitleTextAttributes
                QMUIHelper.visibleViewController?.navigationController?
                    .navigationBar.largeTitleTextAttributes = largeTitleTextAttributes
            }
        }
    }
    
    func applyInitialTemplate() {
        if QMUI_hasAppliedInitialTemplate {
            return
        }
        // 自动寻找并应用模板的解释参照这里 https://github.com/QMUI/QMUI_iOS/issues/264
        let expectedClassCount = objc_getClassList(nil, 0)
        let allClasses = UnsafeMutablePointer<AnyClass>.allocate(capacity: Int(expectedClassCount))
        let autoreleasingAllClasses = AutoreleasingUnsafeMutablePointer<AnyClass>(allClasses)
        let actualClassCount:Int32 = objc_getClassList(autoreleasingAllClasses, expectedClassCount)
        
        for i in 0 ..< actualClassCount {
            let currentClass: AnyClass = allClasses[Int(i)]
            
            if let clazz = currentClass.self as? QMUIConfigurationTemplateProtocol.Type {
                let template = clazz.init()
                if template.shouldApplyTemplateAutomatically() {
                    QMUI_hasAppliedInitialTemplate = true
                    template.applyConfigurationTemplate()
                    // 只应用第一个 shouldApplyTemplateAutomatically 的主题
                    break
                }
            }
        }
        allClasses.deallocate()
    }
}

fileprivate var QMUI_hasAppliedInitialTemplate: Bool = false

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromOptionalNSAttributedStringKeyDictionary(_ input: [NSAttributedString.Key: Any]?) -> [String: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}
