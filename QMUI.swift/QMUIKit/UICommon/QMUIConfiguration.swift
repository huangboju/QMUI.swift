//
//  QMUIConfiguration.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/1/17.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

/// 所有配置表都应该实现的 protocol
@objc protocol QMUIConfigurationTemplateProtocol {
    
    /// 应用配置表的设置
    @objc func applyConfigurationTemplate()
    
    /// 当返回 YES 时，启动 App 的时候 QMUIConfiguration 会自动应用这份配置表。但启动 App 时自动应用的配置表最多只允许一份，如果有多份则其他的会被忽略，需要在某些时机手动应用
    @objc optional func shouldApplyTemplateAutomatically() -> Bool
    
}

/**
 *  维护项目全局 UI 配置的单例，通过业务项目自己的 QMUIConfigurationTemplate 来为这个单例赋值，而业务代码里则通过 QMUIConfigurationMacros.swift 文件里的宏来使用这些值。
 */
class QMUIConfiguration: QMUIConfigurationTemplateProtocol {
    
    // MARK: Global Color
    public var clear = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
    public var white = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    public var black = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
    public var gray = UIColor(r: 179, g: 179, b: 179)
    public var grayDarken = UIColor(r: 163, g: 163, b: 163)
    public var grayLighten = UIColor(r: 198, g: 198, b: 198)
    public var red = UIColor(r: 227, g: 40, b: 40)
    public var green = UIColor(r: 79, g: 214, b: 79)
    public var blue = UIColor(r: 43, g: 133, b: 208)
    public var yellow = UIColor(r: 255, g: 252, b: 233)
    
    public var linkColor = UIColor(r: 56, g: 116, b: 171)
    public var disabledColor: UIColor?
    public var backgroundColor = UIColor(r: 246, g: 246, b: 246)
    public var maskDarkColor = UIColor(r: 0, g: 0, b: 0, a: 0.35)
    public var maskLightColor = UIColor(r: 255, g: 255, b: 255, a: 0.5)
    public var separatorColor = UIColor(r: 200, g: 199, b: 204)
    public var separatorDashedColor = UIColor(r: 17, g: 17, b: 17)
    public var placeholderColor = UIColor(r: 187, g: 187, b: 187)
    
    public var testColorRed = UIColor(r: 255, g: 0, b: 0, a: 0.3)
    public var testColorGreen = UIColor(r: 0, g: 255, b: 0, a: 0.3)
    public var testColorBlue = UIColor(r: 0, g: 0, b: 255, a: 0.3)

    // MARK: UIControl
    public var controlHighlightedAlpha: CGFloat = 0.5
    public var controlDisabledAlpha: CGFloat = 0.5
    
    // MARK: UIButton
    public var buttonHighlightedAlpha: CGFloat { get { return controlHighlightedAlpha } }
    public var buttonDisabledAlpha: CGFloat { get { return controlDisabledAlpha } }
    public var buttonTintColor: UIColor { get { return blue } }
    
    public var ghostButtonColorBlue: UIColor { get { return blue } }
    public var ghostButtonColorRed: UIColor { get { return red } }
    public var ghostButtonColorGreen: UIColor { get { return green } }
    public var ghostButtonColorGray: UIColor { get { return gray } }
    public var ghostButtonColorWhite: UIColor { get { return white } }
    public var fillButtonColorBlue: UIColor { get { return blue } }
    public var fillButtonColorRed: UIColor { get { return red } }
    public var fillButtonColorGreen: UIColor { get { return green } }
    public var fillButtonColorGray: UIColor { get { return white } }
    public var fillButtonColorWhite: UIColor { get { return white } }
    
    // MARK: UITextField & UITextView
    public var textFieldTintColor: UIColor?
    public var textFieldTextInsets = UIEdgeInsets(top: 0, left: 7, bottom: 0, right: 7)
    
    // MARK: NavigationBar
    public var navBarHighlightedAlpha: CGFloat = 0.2
    public var navBarDisabledAlpha: CGFloat = 0.2
    public var navBarButtonFont: UIFont? {
        didSet {
            // by molice 2017-08-04 只要用 appearence 的方式修改 UIBarButtonItem 的 font，就会导致界面切换时 UIBarButtonItem 抖动，系统的问题，所以暂时不修改 appearance。
        }
    }
    public var navBarButtonFontBold: UIFont?
    public var navBarBackgroundImage: UIImage? {
        didSet {
            guard let navBarBackgroundImage = navBarBackgroundImage else { return }
            let appearance = UINavigationBar.appearance()
            appearance.setBackgroundImage(navBarBackgroundImage, for: .default)
            QMUIHelper.visibleViewController?.navigationController?
                .navigationBar.setBackgroundImage(navBarBackgroundImage, for: .default)
        }
    }
    public var navBarShadowImage: UIImage? {
        didSet {
            guard let navBarShadowImage = navBarShadowImage else { return }
            UINavigationBar.appearance().shadowImage = navBarShadowImage
            QMUIHelper.visibleViewController?.navigationController?.navigationBar.shadowImage = navBarShadowImage
        }
    }
    public var navBarBarTintColor: UIColor? {
        didSet {
            guard let navBarBarTintColor = navBarBarTintColor else { return }
            UINavigationBar.appearance().barTintColor = navBarBarTintColor
            QMUIHelper.visibleViewController?.navigationController?.navigationBar.barTintColor = navBarBarTintColor
        }
    }
    public var navBarTintColor: UIColor? {
        didSet {
            guard let navBarTintColor = navBarTintColor else { return }
            print(QMUIHelper.visibleViewController ?? "")
            QMUIHelper.visibleViewController?.navigationController?.navigationBar.tintColor = navBarTintColor
        }
    }
    public var navBarTitleColor: UIColor? {
        didSet {
            updateNavigationBarTitleAttributesIfNeeded()
        }
    }
    public var navBarTitleFont: UIFont? {
        didSet {
            updateNavigationBarTitleAttributesIfNeeded()
        }
    }
    public var navBarLargeTitleColor: UIColor? {
        didSet {
            updateNavigationBarLargeTitleTextAttributesIfNeeded()
        }
    }
    public var navBarLargeTitleFont: UIFont? {
        didSet {
            updateNavigationBarLargeTitleTextAttributesIfNeeded()
        }
    }
    public var navBarBackButtonTitlePositionAdjustment = UIOffset.zero {
        didSet {
            if !UIOffsetEqualToOffset(UIOffset.zero, navBarBackButtonTitlePositionAdjustment) {
                let backBarButtonItem = UIBarButtonItem.appearance()
                backBarButtonItem
                    .setBackButtonTitlePositionAdjustment(navBarBackButtonTitlePositionAdjustment,
                                                                       for: .default)
                QMUIHelper.visibleViewController?.navigationController?
                    .navigationItem.backBarButtonItem?.setBackButtonTitlePositionAdjustment(navBarBackButtonTitlePositionAdjustment, for: .default)
            }
        }
    }
    public var navBarBackIndicatorImage: UIImage? {
        didSet {
            if navBarBackIndicatorImage != nil {
                let navBarAppearance = UINavigationBar.appearance()
                let navigationBar = QMUIHelper.visibleViewController?.navigationController?.navigationBar
                // 返回按钮的图片frame是和系统默认的返回图片的大小一致的（13, 21），所以用自定义返回箭头时要保证图片大小与系统的箭头大小一样，否则无法对齐
                let systemBackIndicatorImageSize = CGSize(width: 13, height: 31)
                let customBackIndicatorImageSize = navBarBackIndicatorImage!.size
                if !(customBackIndicatorImageSize == systemBackIndicatorImageSize) {
                    let imageExtensionVerticalFloat = systemBackIndicatorImageSize.height.center(with: customBackIndicatorImageSize.height)
                    self.navBarBackIndicatorImage = navBarBackIndicatorImage!.qmui_image(spacingExtensionInsets: UIEdgeInsetsMake(imageExtensionVerticalFloat, 0, imageExtensionVerticalFloat, systemBackIndicatorImageSize.width - customBackIndicatorImageSize.width))?.withRenderingMode(navBarBackIndicatorImage!.renderingMode)
                }
                
                navBarAppearance.backIndicatorImage = self.navBarBackIndicatorImage;
                navBarAppearance.backIndicatorTransitionMaskImage = self.navBarBackIndicatorImage;
                navigationBar?.backIndicatorImage = self.navBarBackIndicatorImage;
                navigationBar?.backIndicatorTransitionMaskImage = self.navBarBackIndicatorImage;
            }
        }
    }
    public var navBarCloseButtonImage: UIImage? {
        get {
            return UIImage.qmui_image(shape: .navClose, size: CGSize(width: 16, height: 16), tintColor: navBarTintColor)
        }
    }
    
    public var navBarLoadingMarginRight: CGFloat = 3
    public var navBarAccessoryViewMarginLeft: CGFloat = 5
    public var navBarActivityIndicatorViewStyle: UIActivityIndicatorViewStyle = .gray
    public var navBarAccessoryViewTypeDisclosureIndicatorImage: UIImage? {
        get {
            return UIImage.qmui_image(shape: .triangle, size: CGSize(width: 8, height: 5), tintColor: navBarTintColor)?.qmui_image(orientation: .down)
        }
    }

    // MARK: TabBar
    public var tabBarBackgroundImage: UIImage? {
        didSet {
            guard let tabBarBackgroundImage = tabBarBackgroundImage else { return }
            UITabBar.appearance().backgroundImage = tabBarBackgroundImage
            QMUIHelper.visibleViewController?.tabBarController?.tabBar.backgroundImage = tabBarBackgroundImage
        }
    }
    public var tabBarBarTintColor: UIColor? {
        didSet {
            guard let tabBarBarTintColor = tabBarBarTintColor else { return }
            UITabBar.appearance().barTintColor = tabBarBarTintColor
            QMUIHelper.visibleViewController?.tabBarController?.tabBar.barTintColor = tabBarBarTintColor
        }
    }
    public var tabBarShadowImageColor: UIColor? {
        didSet {
            guard let tabBarShadowImageColor = tabBarShadowImageColor else { return }
            let shadowImage = UIImage.qmui_image(color: tabBarShadowImageColor, size: CGSize(width: 1, height: PixelOne), cornerRadius: 0)
            UITabBar.appearance().shadowImage = shadowImage
            QMUIHelper.visibleViewController?.tabBarController?.tabBar.shadowImage = shadowImage
        }
    }
    public var tabBarTintColor: UIColor? {
        didSet {
            guard let tabBarTintColor = tabBarTintColor else { return }
            QMUIHelper.visibleViewController?.tabBarController?.tabBar.tintColor = tabBarTintColor
        }
    }
    public var tabBarItemTitleColor: UIColor? {
        didSet {
            guard let tabBarItemTitleColor = tabBarItemTitleColor else { return }
            let attributes = UITabBarItem.appearance().titleTextAttributes(for: .normal) ?? [String: Any]()
            var textAttributes = Dictionary(uniqueKeysWithValues:attributes.lazy.map { (NSAttributedStringKey($0.key), $0.value) })
            textAttributes[NSAttributedStringKey.foregroundColor] = tabBarItemTitleColor
            UITabBarItem.appearance().setTitleTextAttributes(textAttributes, for: .normal)
            QMUIHelper.visibleViewController?.tabBarController?.tabBar.items?.forEach {
                $0.setTitleTextAttributes(textAttributes, for: .normal)
            }
        }
    }
    public var tabBarItemTitleColorSelected: UIColor? {
        get {
            return tabBarTintColor
        }
        set {
            guard let tabBarItemTitleColorSelected = self.tabBarItemTitleColorSelected else { return }
            let attributes = UITabBarItem.appearance().titleTextAttributes(for: .normal) ?? [String: Any]()
            var textAttributes = Dictionary(uniqueKeysWithValues:attributes.lazy.map { (NSAttributedStringKey($0.key), $0.value) })
            textAttributes[NSAttributedStringKey.foregroundColor] = tabBarItemTitleColorSelected
            UITabBarItem.appearance().setTitleTextAttributes(textAttributes, for: .normal)
            QMUIHelper.visibleViewController?.tabBarController?.tabBar.items?.forEach {
                $0.setTitleTextAttributes(textAttributes, for: .selected)
            }
        }
    }
    public var tabBarItemTitleFont: UIFont? {
        didSet {
            guard let tabBarItemTitleFont = tabBarItemTitleFont else { return }
            let attributes = UITabBarItem.appearance().titleTextAttributes(for: .normal) ?? [String: Any]()
            var textAttributes = Dictionary(uniqueKeysWithValues:attributes.lazy.map { (NSAttributedStringKey($0.key), $0.value) })
            textAttributes[NSAttributedStringKey.font] = tabBarItemTitleFont
            UITabBarItem.appearance().setTitleTextAttributes(textAttributes, for: .normal)
            QMUIHelper.visibleViewController?.tabBarController?.tabBar.items?.forEach {
                $0.setTitleTextAttributes(textAttributes, for: .normal)
            }
        }
    }

    // MARK: Toolbar
    public var toolBarHighlightedAlpha: CGFloat = 0.4
    public var toolBarDisabledAlpha: CGFloat = 0.4
    public var toolBarTintColor: UIColor? {
        didSet {
            guard let toolBarTintColor = toolBarTintColor else { return }
            QMUIHelper.visibleViewController?.navigationController?.toolbar.tintColor = toolBarTintColor
        }
    }
    public var toolBarTintColorHighlighted: UIColor? {
        get {
            return toolBarTintColor?.withAlphaComponent(toolBarHighlightedAlpha)
        }
    }
    public var toolBarTintColorDisabled: UIColor? {
        get {
            return toolBarTintColor?.withAlphaComponent(toolBarDisabledAlpha)
        }
    }
    public var toolBarBackgroundImage: UIImage? {
        didSet {
            guard let toolBarBackgroundImage = toolBarBackgroundImage else { return }
            UIToolbar.appearance().setBackgroundImage(toolBarBackgroundImage, forToolbarPosition: .any, barMetrics: .default)
            QMUIHelper.visibleViewController?.navigationController?.toolbar
                .setBackgroundImage(toolBarBackgroundImage, forToolbarPosition: .any, barMetrics: .default)
        }
    }
    public var toolBarBarTintColor: UIColor? {
        didSet {
            guard let toolBarBarTintColor = toolBarBarTintColor else { return }
            UIToolbar.appearance().barTintColor = toolBarBarTintColor
            QMUIHelper.visibleViewController?.navigationController?.toolbar.barTintColor = toolBarBarTintColor
        }
    }
    public var toolBarShadowImageColor: UIColor? {
        didSet {
            guard let toolBarShadowImageColor = toolBarShadowImageColor else { return }
            let shadowImage = UIImage.qmui_image(color: toolBarShadowImageColor, size: CGSize(width: 1, height: PixelOne), cornerRadius: 0)
            UIToolbar.appearance().setShadowImage(shadowImage, forToolbarPosition: .any)
            QMUIHelper.visibleViewController?.navigationController?.toolbar.setShadowImage(shadowImage, forToolbarPosition: .any)
        }
    }
    public var toolBarButtonFont: UIFont?

    // MARK: SearchBar
    public var searchBarTextFieldBackground: UIColor?
    public var searchBarTextFieldBorderColor: UIColor?
    public var searchBarBottomBorderColor: UIColor?
    public var searchBarBarTintColor: UIColor?
    public var searchBarTintColor: UIColor?
    public var searchBarTextColor: UIColor?
    public var searchBarPlaceholderColor: UIColor { get { return placeholderColor } }
    public var searchBarFont: UIFont?
    /// 搜索框放大镜icon的图片，大小必须为13x13pt，否则会失真（系统的限制）
    public var searchBarSearchIconImage: UIImage?
    public var searchBarClearIconImage: UIImage?
    public var searchBarTextFieldCornerRadius: CGFloat = 2

    // MARK: TableView / TableViewCell
    public var tableViewEstimatedHeightEnabled = true
    public var tableViewBackgroundColor: UIColor?
    public var tableViewGroupedBackgroundColor: UIColor?
    public var tableSectionIndexColor: UIColor?
    public var tableSectionIndexBackgroundColor: UIColor?
    public var tableSectionIndexTrackingBackgroundColor: UIColor?
    public var tableViewSeparatorColor: UIColor { get { return separatorColor } }

    public var tableViewCellNormalHeight: CGFloat = 44
    public var tableViewCellTitleLabelColor: UIColor?
    public var tableViewCellDetailLabelColor: UIColor?
    public var tableViewCellBackgroundColor: UIColor { get { return white } }
    public var tableViewCellSelectedBackgroundColor = UIColor(r: 238, g: 239, b: 241)
    public var tableViewCellWarningBackgroundColor: UIColor { get { return yellow } }
    public var tableViewCellDisclosureIndicatorImage: UIImage?
    public var tableViewCellCheckmarkImage: UIImage?
    public var tableViewCellDetailButtonImage: UIImage?
    public var tableViewCellSpacingBetweenDetailButtonAndDisclosureIndicator: CGFloat = 12

    public var tableViewSectionHeaderBackgroundColor = UIColor(r: 244, g: 244, b: 244)
    public var tableViewSectionFooterBackgroundColor = UIColor(r: 244, g: 244, b: 244)
    public var tableViewSectionHeaderFont = UIFontBoldMake(12)
    public var tableViewSectionFooterFont = UIFontBoldMake(12)
    public var tableViewSectionHeaderTextColor: UIColor { get { return grayDarken } }
    public var tableViewSectionFooterTextColor: UIColor { get { return gray } }
    public var tableViewSectionHeaderAccessoryMargins = UIEdgeInsetsMake(0, 15, 0, 0)
    public var tableViewSectionFooterAccessoryMargins = UIEdgeInsetsMake(0, 15, 0, 0)
    public var tableViewSectionHeaderContentInset = UIEdgeInsetsMake(4, 15, 4, 15)
    public var tableViewSectionFooterContentInset = UIEdgeInsetsMake(4, 15, 4, 15)

    public var tableViewGroupedSectionHeaderFont = UIFontMake(12)
    public var tableViewGroupedSectionFooterFont = UIFontMake(12)
    public var tableViewGroupedSectionHeaderTextColor: UIColor { get { return grayDarken } }
    public var tableViewGroupedSectionFooterTextColor: UIColor { get { return gray } }
    public var tableViewGroupedSectionHeaderAccessoryMargins = UIEdgeInsetsMake(0, 15, 0, 0)
    public var tableViewGroupedSectionFooterAccessoryMargins = UIEdgeInsetsMake(0, 15, 0, 0)
    public var tableViewGroupedSectionHeaderDefaultHeight = UITableViewAutomaticDimension
    public var tableViewGroupedSectionFooterDefaultHeight = UITableViewAutomaticDimension
    public var tableViewGroupedSectionHeaderContentInset = UIEdgeInsetsMake(16, 15, 8, 15)
    public var tableViewGroupedSectionFooterContentInset = UIEdgeInsetsMake(8, 15, 2, 15)

    // MARK: UIWindowLevel
    public var windowLevelQMUIAlertView: CGFloat = UIWindowLevelAlert - 4
    public var windowLevelQMUIImagePreviewView: CGFloat = UIWindowLevelStatusBar + 1

    // MARK: QMUILog
//    public var shouldPrintDefaultLog: Bool
//    public var shouldPrintInfoLog: Bool
//    public var shouldPrintWarnLog: Bool

    // MARK: Others
    public var supportedOrientationMask: UIInterfaceOrientationMask = .portrait
    public var automaticallyRotateDeviceOrientation: Bool = false
    public var statusbarStyleLightInitially: Bool = false
    public var needsBackBarButtonItemTitle: Bool = false
    public var hidesBottomBarWhenPushedInitially: Bool = false
    public var preventConcurrentNavigationControllerTransitions: Bool = true
    public var navigationBarHiddenInitially: Bool = false
    public var shouldFixTabBarTransitionBugInIPhoneX: Bool = false
    
    static let shared = QMUIConfiguration()
    
    private init() {
    }
    
    private func updateNavigationBarTitleAttributesIfNeeded() {
        if navBarTitleFont != nil || navBarTitleColor != nil {
            var titleTextAttributes = [NSAttributedStringKey: NSObject]()
            if let navBarTitleFont = navBarTitleFont {
                titleTextAttributes[NSAttributedStringKey.font] = navBarTitleFont
            }
            if let navBarTitleColor = navBarTitleColor {
                titleTextAttributes[NSAttributedStringKey.foregroundColor] = navBarTitleColor
            }
            UINavigationBar.appearance().titleTextAttributes = titleTextAttributes
            QMUIHelper.visibleViewController?.navigationController?.navigationBar.titleTextAttributes = titleTextAttributes;
        }
    }
    
    func updateNavigationBarLargeTitleTextAttributesIfNeeded() {
        if #available(iOS 11, *) {
            if navBarLargeTitleFont != nil || navBarLargeTitleColor != nil {
                var largeTitleTextAttributes = [NSAttributedStringKey: NSObject]()
                if let navBarLargeTitleFont = navBarLargeTitleFont {
                    largeTitleTextAttributes[NSAttributedStringKey.font] = navBarLargeTitleFont
                }
                if let navBarLargeTitleColor = navBarLargeTitleColor {
                    largeTitleTextAttributes[NSAttributedStringKey.foregroundColor] = navBarLargeTitleColor
                }
                UINavigationBar.appearance().largeTitleTextAttributes = largeTitleTextAttributes
                QMUIHelper.visibleViewController?.navigationController?
                    .navigationBar.largeTitleTextAttributes = largeTitleTextAttributes;
            }
        }
    }
    
    func applyInitialTemplate() -> QMUIConfiguration {
        
        return self
    }
    
    func applyConfigurationTemplate() {
        
    }
    
}
