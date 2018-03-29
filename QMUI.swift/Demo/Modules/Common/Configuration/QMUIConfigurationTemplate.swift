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
class QMUIConfigurationTemplate: NSObject, QDThemeProtocol {
    
    override required init() {
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
        QMUICMI().clear = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
        QMUICMI().white = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        QMUICMI().black = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        QMUICMI().gray = UIColorGray4 // UIColorGray  : 最常用的灰色
        QMUICMI().grayDarken = UIColorGray3 // UIColorGrayDarken : 深一点的灰色
        QMUICMI().grayLighten = UIColorGray7 // UIColorGrayLighten : 浅一点的灰色
        QMUICMI().red = UIColor(r: 250, g: 58, b: 58) // UIColorRed : 红色
        QMUICMI().green = UIColorTheme4 // UIColorGreen : 绿色
        QMUICMI().blue = UIColor(r: 49, g: 189, b: 243) // UIColorBlue : 蓝色
        QMUICMI().yellow = UIColorTheme3 // UIColorYellow : 黄色
        
        QMUICMI().linkColor = UIColor(r: 56, g: 116, b: 171) // UIColorLink : 文字链接颜色
        QMUICMI().disabledColor = UIColorGray
        QMUICMI().backgroundColor = UIColorWhite // UIColorForBackground : 界面背景色，默认用于 QMUICommonViewController.view 的背景色
        QMUICMI().maskDarkColor = UIColor(r: 0, g: 0, b: 0, a: 0.35) // UIColorMask : 深色的背景遮罩，默认用于 QMAlertController、QMUIDialogViewController 等弹出控件的遮罩
        QMUICMI().maskLightColor = UIColor(r: 255, g: 255, b: 255, a: 0.5) // UIColorMaskWhite : 浅色的背景遮罩，QMUIKit 里默认没用到，只是占个位
        QMUICMI().separatorColor = UIColor(r: 222, g: 224, b: 226) // UIColorSeparator : 全局默认的分割线颜色，默认用于列表分隔线颜色、UIView (QMUI_Border) 分隔线颜色
        QMUICMI().separatorDashedColor = UIColor(r: 17, g: 17, b: 17) // UIColorSeparatorDashed : 全局默认的虚线分隔线的颜色，默认 QMUIKit 暂时没用到
        QMUICMI().placeholderColor = UIColorGray8 // UIColorPlaceholder，全局的输入框的 placeholder 颜色，默认用于 QMUITextField、QMUITextView，不影响系统 UIKit 的输入框
        
        // 测试用的颜色
        QMUICMI().testColorRed = UIColor(r: 255, g: 0, b: 0, a: 0.3)
        QMUICMI().testColorGreen = UIColor(r: 0, g: 255, b: 0, a: 0.3)
        QMUICMI().testColorBlue = UIColor(r: 0, g: 0, b: 255, a: 0.3)
        
        
    }
    
    // QMUI 2.3.0 版本里，配置表新增这个方法，返回 true 表示在 App 启动时要自动应用这份配置表。仅当你的 App 里存在多份配置表时，才需要把除默认配置表之外的其他配置表的返回值改为 false。
    func shouldApplyTemplateAutomatically() -> Bool {
        let result = QDThemeManager.shared.currentTheme == nil || UserDefaults.standard.string(forKey: QDSelectedThemeClassName) == String(describing: self)
        if result {
            QDThemeManager.shared.currentTheme = self
        }
        return result
    }
}
