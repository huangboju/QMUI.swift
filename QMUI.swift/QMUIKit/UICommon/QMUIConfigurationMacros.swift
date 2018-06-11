//
//  QMUIConfigurationMacros.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/3/27.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

/**
 *  提供一系列方便书写的宏，以便在代码里读取配置表的各种属性。
 *  @warning 请不要在 + load 方法里调用 QMUIConfigurationTemplate 或 QMUIConfigurationMacros 提供的宏，那个时机太早，可能导致 crash
 *  @waining 维护时，如果需要增加一个宏，则需要定义一个新的 QMUIConfiguration 属性。
 */

// 单例的宏
var QMUICMI: QMUIConfiguration {
    let shared = QMUIConfiguration.shared
    shared.applyInitialTemplate()
    return shared
}

// MARK: - Global Color

// MARK: TODO 这里的声明全是 let 常量，但实际上，QMUICMI里的属性时可变的，是否要改为可变的，比如说 TabBarTintColor

// 基础颜色
let UIColorClear = QMUICMI.clear
let UIColorWhite = QMUICMI.white
let UIColorBlack = QMUICMI.black
let UIColorGray = QMUICMI.gray
let UIColorGrayDarken = QMUICMI.grayDarken
let UIColorGrayLighten = QMUICMI.grayLighten
let UIColorRed = QMUICMI.red
let UIColorGreen = QMUICMI.green
let UIColorBlue = QMUICMI.blue
let UIColorYellow = QMUICMI.yellow

// 功能颜色
let UIColorLink = QMUICMI.linkColor // 全局统一文字链接颜色
let UIColorDisabled = QMUICMI.disabledColor // 全局统一文字disabled颜色
let UIColorForBackground = QMUICMI.backgroundColor // 全局统一的背景色
let UIColorMask = QMUICMI.maskDarkColor // 全局统一的mask背景色
let UIColorMaskWhite = QMUICMI.maskLightColor // 全局统一的mask背景色，白色
let UIColorSeparator = QMUICMI.separatorColor // 全局分隔线颜色
let UIColorSeparatorDashed = QMUICMI.separatorDashedColor // 全局分隔线颜色（虚线）
let UIColorPlaceholder = QMUICMI.placeholderColor // 全局的输入框的placeholder颜色

// 测试用的颜色
let UIColorTestRed = QMUICMI.testColorRed
let UIColorTestGreen = QMUICMI.testColorGreen
let UIColorTestBlue = QMUICMI.testColorBlue

// 可操作的控件

// MARK: - UIControl

let UIControlHighlightedAlpha = QMUICMI.controlHighlightedAlpha // 一般control的Highlighted透明值
let UIControlDisabledAlpha = QMUICMI.controlDisabledAlpha // 一般control的Disable透明值

// 按钮

// MARK: - UIButton

let ButtonHighlightedAlpha = QMUICMI.buttonHighlightedAlpha // 按钮Highlighted状态的透明度
let ButtonDisabledAlpha = QMUICMI.buttonDisabledAlpha // 按钮Disabled状态的透明度
let ButtonTintColor = QMUICMI.buttonTintColor // 普通按钮的颜色

let GhostButtonColorBlue = QMUICMI.ghostButtonColorBlue // QMUIGhostButtonColorBlue的颜色
let GhostButtonColorRed = QMUICMI.ghostButtonColorRed // QMUIGhostButtonColorRed的颜色
let GhostButtonColorGreen = QMUICMI.ghostButtonColorGreen // QMUIGhostButtonColorGreen的颜色
let GhostButtonColorGray = QMUICMI.ghostButtonColorGray // QMUIGhostButtonColorGray的颜色
let GhostButtonColorWhite = QMUICMI.ghostButtonColorWhite // QMUIGhostButtonColorWhite的颜色

let FillButtonColorBlue = QMUICMI.fillButtonColorBlue // QMUIFillButtonColorBlue的颜色
let FillButtonColorRed = QMUICMI.fillButtonColorRed // QMUIFillButtonColorRed的颜色
let FillButtonColorGreen = QMUICMI.fillButtonColorGreen // QMUIFillButtonColorGreen的颜色
let FillButtonColorGray = QMUICMI.fillButtonColorGray // QMUIFillButtonColorGray的颜色
let FillButtonColorWhite = QMUICMI.fillButtonColorWhite // QMUIFillButtonColorWhite的颜色

// 输入框

// MARK: - TextField & TextView

let TextFieldTintColor = QMUICMI.textFieldTintColor // 全局UITextField、UITextView的tintColor
let TextFieldTextInsets = QMUICMI.textFieldTextInsets // QMUITextField的内边距

// MARK: - NavigationBar

let NavBarHighlightedAlpha = QMUICMI.navBarHighlightedAlpha
let NavBarDisabledAlpha = QMUICMI.navBarDisabledAlpha
let NavBarButtonFont = QMUICMI.navBarButtonFont
let NavBarButtonFontBold = QMUICMI.navBarButtonFontBold
var NavBarBackgroundImage: UIImage? { return QMUICMI.navBarBackgroundImage }
var NavBarShadowImage: UIImage? { return QMUICMI.navBarShadowImage }
let NavBarBarTintColor = QMUICMI.navBarBarTintColor
let NavBarTintColor = QMUICMI.navBarTintColor
var NavBarTitleColor: UIColor? { return QMUICMI.navBarTitleColor }
let NavBarTitleFont = QMUICMI.navBarTitleFont
let NavBarLargeTitleColor = QMUICMI.navBarLargeTitleColor
let NavBarLargeTitleFont = QMUICMI.navBarLargeTitleFont
let NavBarBarBackButtonTitlePositionAdjustment = QMUICMI.navBarBackButtonTitlePositionAdjustment
let NavBarBackIndicatorImage = QMUICMI.navBarBackIndicatorImage // 自定义的返回按钮，尺寸建议与系统的返回按钮尺寸一致（iOS8下实测系统大小是(13, 21)），可提高性能
let NavBarCloseButtonImage = QMUICMI.navBarCloseButtonImage

let NavBarLoadingMarginRight = QMUICMI.navBarLoadingMarginRight // titleView里左边的loading的右边距
let NavBarAccessoryViewMarginLeft = QMUICMI.navBarAccessoryViewMarginLeft // titleView里的accessoryView的左边距
let NavBarActivityIndicatorViewStyle = QMUICMI.navBarActivityIndicatorViewStyle // titleView loading 的style
let NavBarAccessoryViewTypeDisclosureIndicatorImage = QMUICMI.navBarAccessoryViewTypeDisclosureIndicatorImage // titleView上倒三角的默认图片

// MARK: - TabBar

let TabBarBackgroundImage = QMUICMI.tabBarBackgroundImage
let TabBarBarTintColor = QMUICMI.tabBarBarTintColor
let TabBarShadowImageColor = QMUICMI.tabBarShadowImageColor

var TabBarTintColor: UIColor? {
    return QMUICMI.tabBarTintColor
}

let TabBarItemTitleColor = QMUICMI.tabBarItemTitleColor
let TabBarItemTitleColorSelected = QMUICMI.tabBarItemTitleColorSelected
let TabBarItemTitleFont = QMUICMI.tabBarItemTitleFont

// MARK: - Toolbar

let ToolBarHighlightedAlpha = QMUICMI.toolBarHighlightedAlpha
let ToolBarDisabledAlpha = QMUICMI.toolBarDisabledAlpha
let ToolBarTintColor = QMUICMI.toolBarTintColor
let ToolBarTintColorHighlighted = QMUICMI.toolBarTintColorHighlighted
let ToolBarTintColorDisabled = QMUICMI.toolBarTintColorDisabled
let ToolBarBackgroundImage = QMUICMI.toolBarBackgroundImage
let ToolBarBarTintColor = QMUICMI.toolBarBarTintColor
let ToolBarShadowImageColor = QMUICMI.toolBarShadowImageColor
let ToolBarButtonFont = QMUICMI.toolBarButtonFont

// MARK: - SearchBar

let SearchBarTextFieldBackground = QMUICMI.searchBarTextFieldBackground
let SearchBarTextFieldBorderColor = QMUICMI.searchBarTextFieldBorderColor
let SearchBarBottomBorderColor = QMUICMI.searchBarBottomBorderColor
let SearchBarBarTintColor = QMUICMI.searchBarBarTintColor
let SearchBarTintColor = QMUICMI.searchBarTintColor
let SearchBarTextColor = QMUICMI.searchBarTextColor
let SearchBarPlaceholderColor = QMUICMI.searchBarPlaceholderColor
let SearchBarFont = QMUICMI.searchBarFont
let SearchBarSearchIconImage = QMUICMI.searchBarSearchIconImage
let SearchBarClearIconImage = QMUICMI.searchBarClearIconImage
let SearchBarTextFieldCornerRadius = QMUICMI.searchBarTextFieldCornerRadius

// MARK: - TableView / TableViewCell
let TableViewEstimatedHeightEnabled = QMUICMI.tableViewEstimatedHeightEnabled // 是否要开启全局 UITableView 的 estimatedRow(Section/Footer)Height

let TableViewBackgroundColor = QMUICMI.tableViewBackgroundColor // 普通列表的背景色
let TableViewGroupedBackgroundColor = QMUICMI.tableViewGroupedBackgroundColor // Grouped类型的列表的背景色
let TableSectionIndexColor = QMUICMI.tableSectionIndexColor // 列表右边索引条的文字颜色，iOS6及以后生效
let TableSectionIndexBackgroundColor = QMUICMI.tableSectionIndexBackgroundColor // 列表右边索引条的背景色，iOS7及以后生效
let TableSectionIndexTrackingBackgroundColor = QMUICMI.tableSectionIndexTrackingBackgroundColor // 列表右边索引条按下时的背景色，iOS6及以后生效
let TableViewSeparatorColor = QMUICMI.tableViewSeparatorColor // 列表分隔线颜色
let TableViewCellBackgroundColor = QMUICMI.tableViewCellBackgroundColor // 列表cel的背景色
let TableViewCellSelectedBackgroundColor = QMUICMI.tableViewCellSelectedBackgroundColor // 列表cell按下时的背景色
let TableViewCellWarningBackgroundColor = QMUICMI.tableViewCellWarningBackgroundColor // 列表cell在未读状态下的背景色
let TableViewCellNormalHeight = QMUICMI.tableViewCellNormalHeight // 默认cell的高度

let TableViewCellDisclosureIndicatorImage = QMUICMI.tableViewCellDisclosureIndicatorImage // 列表cell右边的箭头图片
let TableViewCellCheckmarkImage = QMUICMI.tableViewCellCheckmarkImage // 列表cell右边的打钩checkmark
let TableViewCellDetailButtonImage = QMUICMI.tableViewCellDetailButtonImage // 列表 cell 右边的 i 按钮
let TableViewCellSpacingBetweenDetailButtonAndDisclosureIndicator = QMUICMI.tableViewCellSpacingBetweenDetailButtonAndDisclosureIndicator // 列表 cell 右边的 i 按钮和向右箭头之间的间距（仅当两者都使用了自定义图片并且同时显示时才生效）

let TableViewSectionHeaderBackgroundColor = QMUICMI.tableViewSectionHeaderBackgroundColor
let TableViewSectionFooterBackgroundColor = QMUICMI.tableViewSectionFooterBackgroundColor
let TableViewSectionHeaderFont = QMUICMI.tableViewSectionHeaderFont
let TableViewSectionFooterFont = QMUICMI.tableViewSectionFooterFont
let TableViewSectionHeaderTextColor = QMUICMI.tableViewSectionHeaderTextColor
let TableViewSectionFooterTextColor = QMUICMI.tableViewSectionFooterTextColor
let TableViewSectionHeaderAccessoryMargins = QMUICMI.tableViewSectionHeaderAccessoryMargins
let TableViewSectionFooterAccessoryMargins = QMUICMI.tableViewSectionFooterAccessoryMargins
let TableViewSectionHeaderContentInset = QMUICMI.tableViewSectionHeaderContentInset
let TableViewSectionFooterContentInset = QMUICMI.tableViewSectionFooterContentInset

let TableViewGroupedSectionHeaderFont = QMUICMI.tableViewGroupedSectionHeaderFont
let TableViewGroupedSectionFooterFont = QMUICMI.tableViewGroupedSectionFooterFont
let TableViewGroupedSectionHeaderTextColor = QMUICMI.tableViewGroupedSectionHeaderTextColor
let TableViewGroupedSectionFooterTextColor = QMUICMI.tableViewGroupedSectionFooterTextColor
let TableViewGroupedSectionHeaderAccessoryMargins = QMUICMI.tableViewGroupedSectionHeaderAccessoryMargins
let TableViewGroupedSectionFooterAccessoryMargins = QMUICMI.tableViewGroupedSectionFooterAccessoryMargins
let TableViewGroupedSectionHeaderDefaultHeight = QMUICMI.tableViewGroupedSectionHeaderDefaultHeight
let TableViewGroupedSectionFooterDefaultHeight = QMUICMI.tableViewGroupedSectionFooterDefaultHeight
let TableViewGroupedSectionHeaderContentInset = QMUICMI.tableViewGroupedSectionHeaderContentInset
let TableViewGroupedSectionFooterContentInset = QMUICMI.tableViewGroupedSectionFooterContentInset

let TableViewCellTitleLabelColor = QMUICMI.tableViewCellTitleLabelColor // cell的title颜色
let TableViewCellDetailLabelColor = QMUICMI.tableViewCellDetailLabelColor // cell的detailTitle颜色

// MARK: - UIWindowLevel

let UIWindowLevelQMUIAlertView = QMUICMI.windowLevelQMUIAlertView
let UIWindowLevelQMUIImagePreviewView = QMUICMI.windowLevelQMUIImagePreviewView

// MARK: - Others

let SupportedOrientationMask = QMUICMI.supportedOrientationMask // 默认支持的横竖屏方向
let AutomaticallyRotateDeviceOrientation = QMUICMI.automaticallyRotateDeviceOrientation // 是否在界面切换或 viewController.supportedOrientationMask 发生变化时自动旋转屏幕，默认为 NO
let StatusbarStyleLightInitially = QMUICMI.statusbarStyleLightInitially // 默认的状态栏内容是否使用白色，默认为NO，也即黑色
let NeedsBackBarButtonItemTitle = QMUICMI.needsBackBarButtonItemTitle // 全局是否需要返回按钮的title，不需要则只显示一个返回image
let HidesBottomBarWhenPushedInitially = QMUICMI.hidesBottomBarWhenPushedInitially // QMUICommonViewController.hidesBottomBarWhenPushed的初始值，默认为YES
let PreventConcurrentNavigationControllerTransitions = QMUICMI.preventConcurrentNavigationControllerTransitions // PreventConcurrentNavigationControllerTransitions : 自动保护 QMUINavigationController 在上一次 push/pop 尚未结束的时候就进行下一次 push/pop 的行为，避免产生 crash

let NavigationBarHiddenInitially = QMUICMI.navigationBarHiddenInitially // preferredNavigationBarHidden 的初始值，默认为NO

let ShouldFixTabBarTransitionBugInIPhoneX = QMUICMI.shouldFixTabBarTransitionBugInIPhoneX // 是否需要自动修复 iOS 11 下，iPhone X 的设备在 push 界面时，tabBar 会瞬间往上跳的 bug

