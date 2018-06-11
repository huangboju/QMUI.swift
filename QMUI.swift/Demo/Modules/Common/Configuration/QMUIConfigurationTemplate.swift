//
//  QMUIConfigurationTemplate.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/3/29.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

/**
 *  QMUIConfigurationTemplate 是一份配置表，用于配合 QMUIConfiguration 来管理整个 App 的全局样式，使用方式：
 *  在 QMUI 项目代码的文件夹里找到 QMUIConfigurationTemplate 目录，把里面所有文件复制到自己项目里，保证能被编译到即可，不需要在某些地方 import，也不需要手动运行。
 *
 *  @warning 更新 QMUIKit 的版本时，请留意 Release Log 里是否有提醒更新配置表，请尽量保持自己项目里的配置表与 QMUIKit 里的配置表一致，避免遗漏新的属性。
 *  @warning 配置表的 class 名必须以 QMUIConfigurationTemplate 开头，并且实现 <QMUIConfigurationTemplateProtocol>，因为这两者是 QMUI 识别该 NSObject 是否为一份配置表的条件。
 *  @warning QMUI 2.3.0 之后，配置表改为自动运行，不需要再在某个地方手动运行了。
 */
@objc(QMUIConfigurationTemplate)
class QMUIConfigurationTemplate: NSObject, QDThemeProtocol {
    
    override required init() {
        super.init()
    }
    
    var themeTintColor: UIColor {
        return UIColorBlue
    }
    
    var themeListTextColor: UIColor {
        return themeTintColor
    }
    
    var themeCodeColor: UIColor {
        return themeTintColor
    }
    
    var themeGridItemTintColor: UIColor? {
        return nil
    }
    
    var themeName: String {
        return "Default"
    }
    
    func applyConfigurationTemplate() {
        
        // === 修改配置值 === //
        
        // MARK: Global Color
        QMUICMI.clear = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
        QMUICMI.white = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        QMUICMI.black = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        QMUICMI.gray = UIColorGray4 // UIColorGray  : 最常用的灰色
        QMUICMI.grayDarken = UIColorGray3 // UIColorGrayDarken : 深一点的灰色
        QMUICMI.grayLighten = UIColorGray7 // UIColorGrayLighten : 浅一点的灰色
        QMUICMI.red = UIColor(r: 250, g: 58, b: 58) // UIColorRed : 红色
        QMUICMI.green = UIColorTheme4 // UIColorGreen : 绿色
        QMUICMI.blue = UIColor(r: 49, g: 189, b: 243) // UIColorBlue : 蓝色
        QMUICMI.yellow = UIColorTheme3 // UIColorYellow : 黄色
        
        QMUICMI.linkColor = UIColor(r: 56, g: 116, b: 171) // UIColorLink : 文字链接颜色
        QMUICMI.disabledColor = UIColorGray
        QMUICMI.backgroundColor = UIColorWhite // UIColorForBackground : 界面背景色，默认用于 QMUICommonViewController.view 的背景色
        QMUICMI.maskDarkColor = UIColorMakeWithRGBA(0, 0, 0, 0.35) // UIColorMask : 深色的背景遮罩，默认用于 QMAlertController、QMUIDialogViewController 等弹出控件的遮罩
        QMUICMI.maskLightColor = UIColorMakeWithRGBA(255, 255, 255, 0.5) // UIColorMaskWhite : 浅色的背景遮罩，QMUIKit 里默认没用到，只是占个位
        QMUICMI.separatorColor = UIColor(r: 222, g: 224, b: 226) // UIColorSeparator : 全局默认的分割线颜色，默认用于列表分隔线颜色、UIView (QMUI_Border) 分隔线颜色
        QMUICMI.separatorDashedColor = UIColor(r: 17, g: 17, b: 17) // UIColorSeparatorDashed : 全局默认的虚线分隔线的颜色，默认 QMUIKit 暂时没用到
        QMUICMI.placeholderColor = UIColorGray8 // UIColorPlaceholder，全局的输入框的 placeholder 颜色，默认用于 QMUITextField、QMUITextView，不影响系统 UIKit 的输入框
        
        // 测试用的颜色
        QMUICMI.testColorRed = UIColorMakeWithRGBA(255, 0, 0, 0.3)
        QMUICMI.testColorGreen = UIColorMakeWithRGBA(0, 255, 0, 0.3)
        QMUICMI.testColorBlue = UIColorMakeWithRGBA(0, 0, 255, 0.3)
        
        // MARK: UIControl
        QMUICMI.controlHighlightedAlpha = 0.5 // UIControlHighlightedAlpha : UIControl 系列控件在 highlighted 时的 alpha，默认用于 QMUIButton、 QMUINavigationTitleView
        QMUICMI.controlDisabledAlpha = 0.5 // UIControlDisabledAlpha : UIControl 系列控件在 disabled 时的 alpha，默认用于 QMUIButton
        
        // MARK: UIButton
        QMUICMI.buttonHighlightedAlpha = UIControlHighlightedAlpha // ButtonHighlightedAlpha : QMUIButton 在 highlighted 时的 alpha，不影响系统的 UIButton
        QMUICMI.buttonDisabledAlpha = UIControlDisabledAlpha // ButtonDisabledAlpha : QMUIButton 在 disabled 时的 alpha，不影响系统的 UIButton
        QMUICMI.buttonTintColor = themeTintColor // ButtonTintColor : QMUIButton 默认的 tintColor，不影响系统的 UIButton
        
        QMUICMI.ghostButtonColorBlue = UIColorBlue // GhostButtonColorBlue : QMUIGhostButtonColorBlue 的颜色
        QMUICMI.ghostButtonColorRed = UIColorRed // GhostButtonColorRed : QMUIGhostButtonColorRed 的颜色
        QMUICMI.ghostButtonColorGreen = UIColorGreen // GhostButtonColorGreen : QMUIGhostButtonColorGreen 的颜色
        QMUICMI.ghostButtonColorGray = UIColorGray // GhostButtonColorGray : QMUIGhostButtonColorGray 的颜色
        QMUICMI.ghostButtonColorWhite = UIColorWhite // GhostButtonColorWhite : QMUIGhostButtonColorWhite 的颜色
        
        QMUICMI.fillButtonColorBlue = UIColorBlue // FillButtonColorBlue : QMUIFillButtonColorBlue 的颜色
        QMUICMI.fillButtonColorRed = UIColorRed // FillButtonColorRed : QMUIFillButtonColorRed 的颜色
        QMUICMI.fillButtonColorGreen = UIColorGreen // FillButtonColorGreen : QMUIFillButtonColorGreen 的颜色
        QMUICMI.fillButtonColorGray = UIColorGray // FillButtonColorGray : QMUIFillButtonColorGray 的颜色
        QMUICMI.fillButtonColorWhite = UIColorWhite // FillButtonColorWhite : QMUIFillButtonColorWhite 的颜色
        
        // MARK: TextField & TextView
        QMUICMI.textFieldTintColor = themeTintColor // TextFieldTintColor : QMUITextField、QMUITextView 的 tintColor，不影响 UIKit 的输入框
        QMUICMI.textFieldTextInsets = UIEdgeInsetsMake(0, 7, 0, 7);                 // TextFieldTextInsets : QMUITextField 的内边距，不影响 UITextField
        
        // MARK: NavigationBar
        QMUICMI.navBarHighlightedAlpha = 0.2 // NavBarHighlightedAlpha : QMUINavigationButton 在 highlighted 时的 alpha
        QMUICMI.navBarDisabledAlpha = 0.2 // NavBarDisabledAlpha : QMUINavigationButton 在 disabled 时的 alpha
        QMUICMI.navBarButtonFont = UIFontMake(17) // NavBarButtonFont : QMUINavigationButtonTypeNormal 的字体（由于系统存在一些 bug，这个属性默认不对 UIBarButtonItem 生效）
        QMUICMI.navBarButtonFontBold = UIFontBoldMake(17) // NavBarButtonFontBold : QMUINavigationButtonTypeBold 的字体
        QMUICMI.navBarBackgroundImage = UIImageMake("navigationbar_background") // NavBarBackgroundImage : UINavigationBar 的背景图
        QMUICMI.navBarShadowImage = UIImage() // NavBarShadowImage : UINavigationBar.shadowImage，也即导航栏底部那条分隔线
        QMUICMI.navBarBarTintColor = nil // NavBarBarTintColor : UINavigationBar.barTintColor，也即背景色
        QMUICMI.navBarTintColor = UIColorWhite // NavBarTintColor : QMUINavigationController.navigationBar 的 tintColor，也即导航栏上面的按钮颜色，由于 tintColor 不支持 appearance，所以这里只支持 QMUINavigationController
        QMUICMI.navBarTitleColor = NavBarTintColor // NavBarTitleColor : UINavigationBar 的标题颜色，以及 QMUINavigationTitleView 的默认文字颜色
        QMUICMI.navBarTitleFont = UIFontBoldMake(17) // NavBarTitleFont : UINavigationBar 的标题字体，以及 QMUINavigationTitleView 的默认字体
        QMUICMI.navBarLargeTitleColor = nil // NavBarLargeTitleColor : UINavigationBar 在大标题模式下的标题颜色，仅在 iOS 11 之后才有效
        QMUICMI.navBarLargeTitleFont = nil // NavBarLargeTitleFont : UINavigationBar 在大标题模式下的标题字体，仅在 iOS 11 之后才有效
        QMUICMI.navBarBackButtonTitlePositionAdjustment = UIOffset.zero // NavBarBarBackButtonTitlePositionAdjustment : 导航栏返回按钮的文字偏移
        QMUICMI.navBarBackIndicatorImage = UIImage.qmui_image(shape: .navBack, size: CGSize(width: 13, height: 21), tintColor: NavBarTintColor) // NavBarBackIndicatorImage : 导航栏的返回按钮的图片，图片尺寸需要为(13, 21)，如果尺寸不一致则会自动调整，以保证与系统的返回按钮图片布局相同。
        QMUICMI.navBarCloseButtonImage = UIImage.qmui_image(shape: .navClose, size: CGSize(width: 16, height: 16), tintColor: NavBarTintColor) // NavBarCloseButtonImage : QMUINavigationButton 用到的 × 的按钮图片
        
        QMUICMI.navBarLoadingMarginRight = 3 // NavBarLoadingMarginRight : QMUINavigationTitleView 里左边 loading 的右边距
        QMUICMI.navBarAccessoryViewMarginLeft = 5  // NavBarAccessoryViewMarginLeft : QMUINavigationTitleView 里右边 accessoryView 的左边距
        QMUICMI.navBarActivityIndicatorViewStyle = .gray // NavBarActivityIndicatorViewStyle : QMUINavigationTitleView 里左边 loading 的主题
        QMUICMI.navBarAccessoryViewTypeDisclosureIndicatorImage = UIImage.qmui_image(shape: .triangle, size: CGSize(width: 8, height: 5), tintColor: UIColorWhite)    // NavBarAccessoryViewTypeDisclosureIndicatorImage : QMUINavigationTitleView 右边箭头的图片
        
        // MARK: TabBar
        
        QMUICMI.tabBarBackgroundImage = UIImage.qmui_image(color: UIColor(r: 249, g: 249, b: 249))?.resizableImage(withCapInsets: UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)) // TabBarBackgroundImage : UITabBar 的背景图
        QMUICMI.tabBarBarTintColor = nil // TabBarBarTintColor : UITabBar 的 barTintColor
        QMUICMI.tabBarShadowImageColor = UIColorSeparator // TabBarShadowImageColor : UITabBar 的 shadowImage 的颜色，会自动创建一张 1px 高的图片
        QMUICMI.tabBarTintColor = UIColor(r: 4, g: 189, b: 231) // TabBarTintColor : UITabBar 的 tintColor
        QMUICMI.tabBarItemTitleColor = UIColorGray6 // TabBarItemTitleColor : 未选中的 UITabBarItem 的标题颜色
        QMUICMI.tabBarItemTitleColorSelected = TabBarTintColor // TabBarItemTitleColorSelected : 选中的 UITabBarItem 的标题颜色
        QMUICMI.tabBarItemTitleFont = nil // TabBarItemTitleFont : UITabBarItem 的标题字体
        
        // MARK: Toolbar
        
        QMUICMI.toolBarHighlightedAlpha = 0.4 // ToolBarHighlightedAlpha : QMUIToolbarButton 在 highlighted 状态下的 alpha
        QMUICMI.toolBarDisabledAlpha = 0.4 // ToolBarDisabledAlpha : QMUIToolbarButton 在 disabled 状态下的 alpha
        QMUICMI.toolBarTintColor = UIColorBlue // ToolBarTintColor : UIToolbar 的 tintColor，以及 QMUIToolbarButton normal 状态下的文字颜色
        QMUICMI.toolBarTintColorHighlighted = ToolBarTintColor?.withAlphaComponent(ToolBarHighlightedAlpha) // ToolBarTintColorHighlighted : QMUIToolbarButton 在 highlighted 状态下的文字颜色
        QMUICMI.toolBarTintColorDisabled = ToolBarTintColor?.withAlphaComponent(ToolBarDisabledAlpha)         // ToolBarTintColorDisabled : QMUIToolbarButton 在 disabled 状态下的文字颜色
        QMUICMI.toolBarBackgroundImage = nil // ToolBarBackgroundImage : UIToolbar 的背景图
        QMUICMI.toolBarBarTintColor = nil // ToolBarBarTintColor : UIToolbar 的 tintColor
        QMUICMI.toolBarShadowImageColor = UIColorSeparator // ToolBarShadowImageColor : UIToolbar 的 shadowImage 的颜色，会自动创建一张 1px 高的图片
        QMUICMI.toolBarButtonFont = UIFontMake(17) // ToolBarButtonFont : QMUIToolbarButton 的字体
        
        // MARK: SearchBar
        
        QMUICMI.searchBarTextFieldBackground = UIColor(r: 237, g: 238, b: 240) // SearchBarTextFieldBackground : QMUISearchBar 里的文本框的背景颜色
        QMUICMI.searchBarTextFieldBorderColor = nil // SearchBarTextFieldBorderColor : QMUISearchBar 里的文本框的边框颜色
        QMUICMI.searchBarBottomBorderColor = UIColorClear // SearchBarBottomBorderColor : QMUISearchBar 底部分隔线颜色
        QMUICMI.searchBarBarTintColor = UIColorWhite // SearchBarBarTintColor : QMUISearchBar 的 barTintColor，也即背景色
        QMUICMI.searchBarTintColor = themeTintColor // SearchBarTintColor : QMUISearchBar 的 tintColor，也即上面的操作控件的主题色
        QMUICMI.searchBarTextColor = UIColorBlack // SearchBarTextColor : QMUISearchBar 里的文本框的文字颜色
        QMUICMI.searchBarPlaceholderColor = UIColor(r: 136, g: 136, b: 143) // SearchBarPlaceholderColor : QMUISearchBar 里的文本框的 placeholder 颜色
        QMUICMI.searchBarFont = nil // SearchBarFont : QMUISearchBar 里的文本框的文字字体及 placeholder 的字体
        QMUICMI.searchBarSearchIconImage = nil // SearchBarSearchIconImage : QMUISearchBar 里的放大镜 icon
        QMUICMI.searchBarClearIconImage = nil // SearchBarClearIconImage : QMUISearchBar 里的文本框输入文字时右边的清空按钮的图片
        QMUICMI.searchBarTextFieldCornerRadius = 4 // SearchBarTextFieldCornerRadius : QMUISearchBar 里的文本框的圆角大小
        
        // MARK: TableView / TableViewCell
        
        QMUICMI.tableViewEstimatedHeightEnabled = false // TableViewEstimatedHeightEnabled : 是否要开启全局 UITableView 的 estimatedRow(Section/Footer)Height
        
        QMUICMI.tableViewBackgroundColor = nil // TableViewBackgroundColor : Plain 类型的 QMUITableView 的背景色颜色
        QMUICMI.tableViewGroupedBackgroundColor = UIColor(r: 246, g: 246, b: 246) // TableViewGroupedBackgroundColor : Grouped 类型的 QMUITableView 的背景色
        QMUICMI.tableSectionIndexColor = UIColorGrayDarken // TableSectionIndexColor : 列表右边的字母索引条的文字颜色
        QMUICMI.tableSectionIndexBackgroundColor = UIColorClear // TableSectionIndexBackgroundColor : 列表右边的字母索引条的背景色
        QMUICMI.tableSectionIndexTrackingBackgroundColor = UIColorClear // TableSectionIndexTrackingBackgroundColor : 列表右边的字母索引条在选中时的背景色
        QMUICMI.tableViewSeparatorColor = UIColorSeparator // TableViewSeparatorColor : 列表的分隔线颜色
        
        QMUICMI.tableViewCellNormalHeight = 56 // TableViewCellNormalHeight : 列表默认的 cell 高度
        QMUICMI.tableViewCellTitleLabelColor = UIColorGray3 // TableViewCellTitleLabelColor : QMUITableViewCell 的 textLabel 的文字颜色
        QMUICMI.tableViewCellDetailLabelColor = UIColorGray5 // TableViewCellDetailLabelColor : QMUITableViewCell 的 detailTextLabel 的文字颜色
        QMUICMI.tableViewCellBackgroundColor = UIColorWhite // TableViewCellBackgroundColor : QMUITableViewCell 的背景色
        QMUICMI.tableViewCellSelectedBackgroundColor = UIColor(r: 238, g: 239, b: 241) // TableViewCellSelectedBackgroundColor : QMUITableViewCell 点击时的背景色
        QMUICMI.tableViewCellWarningBackgroundColor = UIColorYellow // TableViewCellWarningBackgroundColor : QMUITableViewCell 用于表示警告时的背景色，备用
        QMUICMI.tableViewCellDisclosureIndicatorImage = UIImage.qmui_image(shape: .disclosureIndicator, size: CGSize(width: 6, height: 10), lineWidth: 1, tintColor: UIColor(r: 173, g: 180, b: 190)) // TableViewCellDisclosureIndicatorImage : QMUITableViewCell 当 accessoryType 为 UITableViewCellAccessoryDisclosureIndicator 时的箭头的图片
        QMUICMI.tableViewCellCheckmarkImage = UIImage.qmui_image(shape: .checkmark, size: CGSize(width: 15, height: 12), tintColor: themeTintColor) // TableViewCellCheckmarkImage : QMUITableViewCell 当 accessoryType 为 UITableViewCellAccessoryCheckmark 时的打钩的图片
        QMUICMI.tableViewCellDetailButtonImage = UIImage.qmui_image(shape: .detailButtonImage, size: CGSize(width: 20, height: 20), tintColor: themeTintColor) // TableViewCellDetailButtonImage : QMUITableViewCell 当 accessoryType 为 UITableViewCellAccessoryDetailButton 或 UITableViewCellAccessoryDetailDisclosureButton 时右边的 i 按钮图片
        QMUICMI.tableViewCellSpacingBetweenDetailButtonAndDisclosureIndicator = 12 // TableViewCellSpacingBetweenDetailButtonAndDisclosureIndicator : 列表 cell 右边的 i 按钮和向右箭头之间的间距（仅当两者都使用了自定义图片并且同时显示时才生效）
        
        QMUICMI.tableViewSectionHeaderBackgroundColor = UIColor(r: 244, g: 244, b: 244) // TableViewSectionHeaderBackgroundColor : Plain 类型的 QMUITableView sectionHeader 的背景色
        QMUICMI.tableViewSectionFooterBackgroundColor = UIColor(r: 244, g: 244, b: 244) // TableViewSectionFooterBackgroundColor : Plain 类型的 QMUITableView sectionFooter 的背景色
        QMUICMI.tableViewSectionHeaderFont = UIFontBoldMake(12) // TableViewSectionHeaderFont : Plain 类型的 QMUITableView sectionHeader 里的文字字体
        QMUICMI.tableViewSectionFooterFont = UIFontBoldMake(12) // TableViewSectionFooterFont : Plain 类型的 QMUITableView sectionFooter 里的文字字体
        QMUICMI.tableViewSectionHeaderTextColor = UIColorGray5 // TableViewSectionHeaderTextColor : Plain 类型的 QMUITableView sectionHeader 里的文字颜色
        QMUICMI.tableViewSectionFooterTextColor = UIColorGray // TableViewSectionFooterTextColor : Plain 类型的 QMUITableView sectionFooter 里的文字颜色
        QMUICMI.tableViewSectionHeaderAccessoryMargins = UIEdgeInsetsMake(0, 15, 0, 0) // TableViewSectionHeaderAccessoryMargins : Plain 类型的 QMUITableView sectionHeader accessoryView 的间距
        QMUICMI.tableViewSectionFooterAccessoryMargins = UIEdgeInsetsMake(0, 15, 0, 0) // TableViewSectionFooterAccessoryMargins : Plain 类型的 QMUITableView sectionFooter accessoryView 的间距
        QMUICMI.tableViewSectionHeaderContentInset = UIEdgeInsetsMake(4, 15, 4, 15) // TableViewSectionHeaderContentInset : Plain 类型的 QMUITableView sectionHeader 里的内容的 padding
        QMUICMI.tableViewSectionFooterContentInset = UIEdgeInsetsMake(4, 15, 4, 15) // TableViewSectionFooterContentInset : Plain 类型的 QMUITableView sectionFooter 里的内容的 padding
        
        QMUICMI.tableViewGroupedSectionHeaderFont = UIFontMake(12) // TableViewGroupedSectionHeaderFont : Grouped 类型的 QMUITableView sectionHeader 里的文字字体
        QMUICMI.tableViewGroupedSectionFooterFont = UIFontMake(12) // TableViewGroupedSectionFooterFont : Grouped 类型的 QMUITableView sectionFooter 里的文字字体
        QMUICMI.tableViewGroupedSectionHeaderTextColor = UIColorGrayDarken // TableViewGroupedSectionHeaderTextColor : Grouped 类型的 QMUITableView sectionHeader 里的文字颜色
        QMUICMI.tableViewGroupedSectionFooterTextColor = UIColorGray // TableViewGroupedSectionFooterTextColor : Grouped 类型的 QMUITableView sectionFooter 里的文字颜色
        QMUICMI.tableViewGroupedSectionHeaderAccessoryMargins = UIEdgeInsetsMake(0, 15, 0, 0) // TableViewGroupedSectionHeaderAccessoryMargins : Grouped 类型的 QMUITableView sectionHeader accessoryView 的间距
        QMUICMI.tableViewGroupedSectionFooterAccessoryMargins = UIEdgeInsetsMake(0, 15, 0, 0) // TableViewGroupedSectionFooterAccessoryMargins : Grouped 类型的 QMUITableView sectionFooter accessoryView 的间距
        QMUICMI.tableViewGroupedSectionHeaderDefaultHeight = UITableViewAutomaticDimension // TableViewGroupedSectionHeaderDefaultHeight : Grouped 类型的 QMUITableView sectionHeader 的默认高度（也即没使用自定义的 sectionHeaderView 时的高度），注意如果不需要间距，请用 CGFLOAT_MIN
        QMUICMI.tableViewGroupedSectionFooterDefaultHeight = UITableViewAutomaticDimension // TableViewGroupedSectionFooterDefaultHeight : Grouped 类型的 QMUITableView sectionFooter 的默认高度（也即没使用自定义的 sectionFooterView 时的高度），注意如果不需要间距，请用 CGFLOAT_MIN
        QMUICMI.tableViewGroupedSectionHeaderContentInset = UIEdgeInsetsMake(16, PreferredVarForDevices(20, 15, 15, 15), 8, PreferredVarForDevices(20, 15, 15, 15)) // TableViewGroupedSectionHeaderContentInset : Grouped 类型的 QMUITableView sectionHeader 里的内容的 padding
        QMUICMI.tableViewGroupedSectionFooterContentInset = UIEdgeInsetsMake(8, 15, 2, 15) // TableViewGroupedSectionFooterContentInset : Grouped 类型的 QMUITableView sectionFooter 里的内容的 padding
        
        // MARK: UIWindowLevel
        QMUICMI.windowLevelQMUIAlertView = UIWindowLevelAlert - 4 // UIWindowLevelQMUIAlertView : QMUIModalPresentationViewController、QMUIPopupContainerView 里使用的 UIWindow 的 windowLevel
        QMUICMI.windowLevelQMUIImagePreviewView = UIWindowLevelStatusBar + 1 // UIWindowLevelQMUIImagePreviewView : QMUIImagePreviewViewController 里使用的 UIWindow 的 windowLevel
        
        // MARK: QMUILog
//        QMUICMI.shouldPrintDefaultLog = true // ShouldPrintDefaultLog : 是否允许输出 QMUILogLevelDefault 级别的 log
//        QMUICMI.shouldPrintInfoLog = true // ShouldPrintInfoLog : 是否允许输出 QMUILogLevelInfo 级别的 log
//        QMUICMI.shouldPrintWarnLog = true // ShouldPrintInfoLog : 是否允许输出 QMUILogLevelWarn 级别的 log
        
        // MARK: Others
        
        QMUICMI.supportedOrientationMask = .all // SupportedOrientationMask : 默认支持的横竖屏方向
        QMUICMI.automaticallyRotateDeviceOrientation = true // AutomaticallyRotateDeviceOrientation : 是否在界面切换或 viewController.supportedOrientationMask 发生变化时自动旋转屏幕
        QMUICMI.statusbarStyleLightInitially = true // StatusbarStyleLightInitially : 默认的状态栏内容是否使用白色，默认为 false，也即黑色
        QMUICMI.needsBackBarButtonItemTitle = true // NeedsBackBarButtonItemTitle : 全局是否需要返回按钮的 title，不需要则只显示一个返回image
        QMUICMI.hidesBottomBarWhenPushedInitially = true // HidesBottomBarWhenPushedInitially : QMUICommonViewController.hidesBottomBarWhenPushed 的初始值，默认为 false，以保持与系统默认值一致，但通常建议改为 YES，因为一般只有 tabBar 首页那几个界面要求为 false
        QMUICMI.preventConcurrentNavigationControllerTransitions = true // PreventConcurrentNavigationControllerTransitions : 自动保护 QMUINavigationController 在上一次 push/pop 尚未结束的时候就进行下一次 push/pop 的行为，避免产生 crash
        QMUICMI.navigationBarHiddenInitially = false // NavigationBarHiddenInitially : QMUINavigationControllerDelegate preferredNavigationBarHidden 的初始值，默认为false
        QMUICMI.shouldFixTabBarTransitionBugInIPhoneX = true // ShouldFixTabBarTransitionBugInIPhoneX : 是否需要自动修复 iOS 11 下，iPhone X 的设备在 push 界面时，tabBar 会瞬间往上跳的 bug
    }
    
    // QMUI 2.3.0 版本里，配置表新增这个方法，返回 true 表示在 App 启动时要自动应用这份配置表。仅当你的 App 里存在多份配置表时，才需要把除默认配置表之外的其他配置表的返回值改为 false。
    func shouldApplyTemplateAutomatically() -> Bool {
        if let themeName = UserDefaults.standard.string(forKey: QDSelectedThemeClassName) {
            let result = themeName == String(describing: type(of: self))
            if result {
                QDThemeManager.shared.currentTheme = self
            }
            return result
        }
        QDThemeManager.shared.currentTheme = self
        return true
    }
}
