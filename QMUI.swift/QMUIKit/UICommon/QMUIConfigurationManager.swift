//
//  QMUIConfigurationManager.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/1/17.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

class QMUIConfigurationManager {

    // MARK: - Global Color
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

    public var link = UIColor(r: 56, g: 116, b: 171)
    public var disabled: UIColor!
    public var background = UIColor(r: 246, g: 246, b: 246)
    public var maskDark = UIColor(r: 0, g: 0, b: 0, a: 0.35)
    public var maskLight = UIColor(r: 255, g: 255, b: 255, a: 0.5)
    public var separator = UIColor(r: 200, g: 199, b: 204)
    public var separatorDashed = UIColor(r: 17, g: 17, b: 17)
    public var placeholder = UIColor(r: 187, g: 187, b: 187)

    public var testColorRed = UIColor(r: 255, g: 0, b: 0, a: 0.3)
    public var testColorGreen = UIColor(r: 0, g: 255, b: 0, a: 0.3)
    public var testColorBlue = UIColor(r: 0, g: 0, b: 255, a: 0.3)

    // MARK: - UIWindowLevel
    public var windowLevelQMUIAlertView = UIWindowLevelAlert - 4.0
    public var windowLevelQMUIActionSheet = UIWindowLevelAlert - 4.0
    public var windowLevelQMUIMoreOperationController = UIWindowLevelStatusBar + 1
    public var windowLevelQMUIImagePreviewView = UIWindowLevelStatusBar + 1

    // MARK: - UIControl
    public var controlHighlightedAlpha: CGFloat = 0.5
    public var controlDisabledAlpha: CGFloat = 0.5

    public var segmentTextTintColor: UIColor!
    public var segmentTextSelectedTintColor: UIColor!
    public var segmentFontSize = UIFont(systemFor: 13)

    // MARK: - UIButton
    public var buttonHighlightedAlpha: CGFloat!
    public var buttonDisabledAlpha: CGFloat!
    public var buttonTintColor: UIColor!

    public var ghostButtonColorBlue: UIColor!
    public var ghostButtonColorRed: UIColor!
    public var ghostButtonColorGreen: UIColor!
    public var ghostButtonColorGray: UIColor!
    public var ghostButtonColorWhite: UIColor!

    public var fillButtonColorBlue: UIColor!
    public var fillButtonColorRed: UIColor!
    public var fillButtonColorGreen: UIColor!
    public var fillButtonColorGray: UIColor!
    public var fillButtonColorWhite: UIColor!

    // MARK: - UITextField & UITextView
    public var textFieldTintColor: UIColor!
    public var textFieldTextInsets = UIEdgeInsetsMake(0, 7, 0, 7)

    // MARK: - ActionSheet
    public var actionSheetButtonTintColor: UIColor!
    public var actionSheetButtonBackgroundColor = UIColor(r: 255, g: 255, b: 255)
    public var actionSheetButtonBackgroundColorHighlighted = UIColor(r: 235, g: 235, b: 235)
    public var actionSheetButtonFont = UIFont(systemFor: 21)
    public var actionSheetButtonFontBold = UIFont(boldFor: 21)

    // MARK: - NavigationBar
    public var navBarHighlightedAlpha: CGFloat = 0.2
    public var navBarDisabledAlpha: CGFloat = 0.2
    public var navBarButtonFont = UIFont(systemFor: 17)
    public var navBarButtonFontBold = UIFont(boldFor: 17)
    public var navBarBackgroundImage: UIImage?
    public var navBarShadowImage: UIImage?
    public var navBarShadowImageColor = UIColor(r: 178, g: 178, b: 178)
    public var navBarBarTintColor: UIColor?
    public var navBarTintColor: UIColor!
    public var navBarTintColorHighlighted: UIColor!
    public var navBarTintColorDisabled: UIColor!
    public var navBarTitleColor: UIColor?
    public var navBarTitleFont = UIFont(boldFor: 17)
    public var navBarBackButtonTitlePositionAdjustment = UIOffset.zero
    public var navBarBackIndicatorImage: UIImage!
    public var navBarCloseButtonImage: UIImage!
    public var navBarLoadingMarginRight: CGFloat = 3
    public var navBarAccessoryViewMarginLeft: CGFloat = 5
    public var navBarActivityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
    public var navBarAccessoryViewTypeDisclosureIndicatorImage: UIImage!

    // MARK: - TabBar
    public var tabBarBackgroundImage: UIImage?
    public var tabBarBarTintColor: UIColor?
    public var tabBarShadowImageColor: UIColor?
    public var tabBarTintColor = UIColor(r: 22, g: 147, b: 229)
    public var tabBarItemTitleColor = UIColor(r: 119, g: 119, b: 119)
    public var tabBarItemTitleColorSelected: UIColor!

    // MARK: - Toolbar
    public var toolBarHighlightedAlpha: CGFloat = 0.4
    public var toolBarDisabledAlpha: CGFloat = 0.4
    public var toolBarTintColor: UIColor!
    public var toolBarTintColorHighlighted: UIColor!
    public var toolBarTintColorDisabled: UIColor!
    public var toolBarBackgroundImage: UIImage?
    public var toolBarBarTintColor: UIColor?
    public var toolBarShadowImageColor = UIColor(r: 178, g: 178, b: 178)
    public var toolBarButtonFont = UIFont(systemFor: 17)

    // MARK: - SearchBar
    public var searchBarTextFieldBackground: UIColor!
    public var searchBarTextFieldBorderColor = UIColor(r: 205, g: 208, b: 210)
    public var searchBarBottomBorderColor = UIColor(r: 205, g: 208, b: 210)
    public var searchBarBarTintColor = UIColor(r: 247, g: 247, b: 247)
    public var searchBarTintColor: UIColor!
    public var searchBarTextColor: UIColor!
    public var searchBarPlaceholderColor: UIColor!
    public var searchBarSearchIconImage: UIImage?
    public var searchBarClearIconImage: UIImage?
    public var searchBarTextFieldCornerRadius: CGFloat = 2.0

    // MARK: - TableView / TableViewCell
    public var tableViewBackgroundColor: UIColor!
    public var tableViewGroupedBackgroundColor: UIColor!
    public var tableSectionIndexColor: UIColor!
    public var tableSectionIndexBackgroundColor: UIColor!
    public var tableSectionIndexTrackingBackgroundColor: UIColor!
    public var tableViewSeparatorColor: UIColor!
    public var tableViewCellBackgroundColor: UIColor!
    public var tableViewCellSelectedBackgroundColor = UIColor(r: 232, g: 232, b: 232)
    public var tableViewCellWarningBackgroundColor: UIColor!
    public var tableViewCellNormalHeight: CGFloat = 44
    public var tableViewCellDisclosureIndicatorImage: UIImage!
    public var tableViewCellCheckmarkImage: UIImage!
    public var tableViewSectionHeaderBackgroundColor = UIColor(r: 244, g: 244, b: 244)
    public var tableViewSectionFooterBackgroundColor = UIColor(r: 244, g: 244, b: 244)
    public var tableViewSectionHeaderFont = UIFont(boldFor: 12)
    public var tableViewSectionFooterFont = UIFont(boldFor: 12)
    public var tableViewSectionHeaderTextColor: UIColor!
    public var tableViewSectionFooterTextColor: UIColor!
    public var tableViewSectionHeaderHeight: CGFloat = 20
    public var tableViewSectionFooterHeight: CGFloat = 0
    public var tableViewSectionHeaderContentInset = UIEdgeInsetsMake(4, 15, 4, 15)
    public var tableViewSectionFooterContentInset = UIEdgeInsetsMake(4, 15, 4, 15)
    public var tableViewGroupedSectionHeaderFont = UIFont(systemFor: 12)
    public var tableViewGroupedSectionFooterFont = UIFont(systemFor: 12)
    public var tableViewGroupedSectionHeaderTextColor: UIColor!
    public var tableViewGroupedSectionFooterTextColor: UIColor!
    public var tableViewGroupedSectionHeaderHeight: CGFloat = 15
    public var tableViewGroupedSectionFooterHeight: CGFloat = 1
    public var tableViewGroupedSectionHeaderContentInset = UIEdgeInsetsMake(16, 15, 8, 15)
    public var tableViewGroupedSectionFooterContentInset = UIEdgeInsetsMake(8, 15, 2, 15)
    public var tableViewCellTitleLabelColor: UIColor!
    public var tableViewCellDetailLabelColor: UIColor!
    public var tableViewCellContentDefaultPaddingLeft: CGFloat = 15
    public var tableViewCellContentDefaultPaddingRight: CGFloat = 10

    // MARK: - Others
    public var supportedOrientationMask = UIInterfaceOrientationMask.portrait
    public var statusbarStyleLightInitially = false
    public var needsBackBarButtonItemTitle = false
    public var hidesBottomBarWhenPushedInitially = true

    static let shared = QMUIConfigurationManager()

    private init() {}

    func initDefaultConfiguration() {
        // MARK: - Global Color
        disabled = gray

        // MARK: - UIControl
        segmentTextTintColor = blue
        segmentTextSelectedTintColor = white

        // MARK: - UIButton
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

        // MARK: - UITextField & UITextView
        textFieldTintColor = blue

        // MARK: - ActionSheet
        actionSheetButtonTintColor = blue

        // MARK: - NavigationBar
        navBarTintColor = black

        navBarTintColorHighlighted = navBarBarTintColor?.withAlphaComponent(navBarHighlightedAlpha)
        navBarTintColorDisabled = navBarTintColor?.withAlphaComponent(navBarDisabledAlpha)
        navBarBackIndicatorImage = UIImage.qmui_image(with: .navBack, size: CGSize(width: 12, height: 20), tintColor: navBarTintColor)
        navBarCloseButtonImage = UIImage.qmui_image(with: .navClose, size: CGSize(width: 16, height: 16), tintColor: navBarTintColor)
        navBarAccessoryViewTypeDisclosureIndicatorImage = UIImage.qmui_image(with: .triangle, size: CGSize(width: 8, height: 5), tintColor: white).qmui_image(with: .down)

        // MARK: - TabBar
        tabBarItemTitleColorSelected = tabBarTintColor

        // MARK: - Toolbar
        toolBarTintColor = blue
        toolBarTintColorHighlighted = toolBarTintColor.withAlphaComponent(toolBarHighlightedAlpha)
        toolBarTintColorDisabled = toolBarTintColor.withAlphaComponent(toolBarDisabledAlpha)
        toolBarBackgroundImage = nil
        toolBarBarTintColor = nil

        // MARK: - SearchBar
        searchBarTextFieldBackground = white
        searchBarTintColor = blue
        searchBarTextColor = black
        searchBarPlaceholderColor = placeholder

        // MARK: - TableView / TableViewCell
        tableViewBackgroundColor = white
        tableViewGroupedBackgroundColor = background
        tableSectionIndexColor = grayDarken
        tableSectionIndexBackgroundColor = clear
        tableSectionIndexTrackingBackgroundColor = clear
        tableViewSeparatorColor = separator
        tableViewCellBackgroundColor = white
        tableViewCellWarningBackgroundColor = yellow

        tableViewCellDisclosureIndicatorImage = UIImage.qmui_image(with: .disclosureIndicator, size: CGSize(width: 8, height: 13), tintColor: UIColor(r: 0, g: 0, b: 0, a: 0.2))
        tableViewCellCheckmarkImage = UIImage.qmui_image(with: .checkmark, size: CGSize(width: 15, height: 12), tintColor: blue)

        tableViewSectionHeaderTextColor = grayDarken
        tableViewSectionFooterTextColor = gray

        tableViewGroupedSectionHeaderTextColor = grayDarken
        tableViewGroupedSectionFooterTextColor = gray

        tableViewCellTitleLabelColor = black
        tableViewCellDetailLabelColor = gray

        // MARK: - Others
    }
}

extension QMUIConfigurationManager {
    static func renderGlobalAppearances() {

        // QMUIButton
        QMUINavigationButton.renderNavigationButtonAppearanceStyle()
        QMUIToolbarButton.renderToolbarButtonAppearanceStyle()

        // UINavigationBar
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.barTintColor = NavBarBarTintColor
        navigationBarAppearance.setBackgroundImage(NavBarBackgroundImage, for: .default)
        navigationBarAppearance.shadowImage = NavBarShadowImage

        // UIToolBar
        let toolBarAppearance = UIToolbar.appearance()
        toolBarAppearance.barTintColor = ToolBarBarTintColor
        toolBarAppearance.setBackgroundImage(ToolBarBackgroundImage, forToolbarPosition: .any, barMetrics: .default)
        toolBarAppearance.setShadowImage(UIImage.qmui_image(with: ToolBarShadowImageColor, size: CGSize(width: 1, height: PixelOne), cornerRadius: 0), forToolbarPosition: .any)

        // UITabBar
        let tabBarAppearance = UITabBar.appearance()
        tabBarAppearance.barTintColor = TabBarBarTintColor
        tabBarAppearance.backgroundImage = TabBarBackgroundImage
        tabBarAppearance.shadowImage = UIImage.qmui_image(with: TabBarShadowImageColor!, size: CGSize(width: 1, height: PixelOne), cornerRadius: 0)

        // UITabBarItem
        let tabBarItemAppearance = UITabBarItem.appearance()
        tabBarItemAppearance.setTitleTextAttributes([NSForegroundColorAttributeName: TabBarItemTitleColor], for: .normal)
        tabBarItemAppearance.setTitleTextAttributes([NSForegroundColorAttributeName: TabBarItemTitleColorSelected!], for: .selected)
    }
}
