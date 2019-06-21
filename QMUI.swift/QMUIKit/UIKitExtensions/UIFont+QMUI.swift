//
//  UIFont+QMUI.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/1/17.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

enum QMUIFontWeight {
    case light
    case normal
    case bold
}

extension UIFont {

    /**
     *  返回系统字体的细体
     *
     * @param fontSize 字体大小
     *
     * @return 变细的系统字体的UIFont对象
     */
    static func qmui_lightSystemFont(ofSize fontSize: CGFloat) -> UIFont {
        return UIFont(name: IOS_VERSION >= 9.0 ? ".SFUIText-Light" : "HelveticaNeue-Light", size: fontSize)!
    }

    /**
     *  根据需要生成一个 UIFont 对象并返回
     *  @param size     字号大小
     *  @param weight   字体粗细
     *  @param italic   是否斜体
     */
    static func qmui_systemFont(ofSize fontSize: CGFloat,
                                weight: QMUIFontWeight,
                                italic: Bool) -> UIFont {
        let isLight = weight == .light
        let isBold = weight == .bold

        let shouldUsingHardCode = IOS_VERSION < 10.0 // 这 UIFontDescriptor 也是醉人，相同代码只有 iOS 10 能得出正确结果，7-9都无法获取到 Light + Italic 的字体，只能写死。
        if shouldUsingHardCode {
            let name = IOS_VERSION < 9.0 ? "HelveticaNeue" : ".SFUIText"
            let fontSuffix = (isLight ? "Light" : (isBold ? "Bold" : "")) + (italic ? "Italic" : "")
            let fontName = name + (fontSuffix.length > 0 ? "-" : "") + fontSuffix
            let font = UIFont(name: fontName, size: fontSize)
            return font!
        }

        // iOS 10 以上使用常规写法
        var font: UIFont!

        if #available(iOS 8.2, *) {
            font = UIFont.systemFont(ofSize: fontSize, weight: isLight ? UIFont.Weight.light : (isBold ? UIFont.Weight.bold : UIFont.Weight.regular))
            // 后面那些都是对斜体的操作，所以如果不需要斜体就直接 return
            if !italic {
                return font
            }
        } else {
            font = UIFont.systemFont(ofSize: fontSize)
        }

        var fontDescriptor = font.fontDescriptor
        var traitsAttribute: [UIFontDescriptor.TraitKey: Any]? = fontDescriptor.fontAttributes[UIFontDescriptor.AttributeName.traits] as? [UIFontDescriptor.TraitKey: Any]
        if #available(iOS 8.2, *) {
            traitsAttribute?[UIFontDescriptor.TraitKey.weight] = isLight ? -1.0 : (isBold ? 1.0 : 0.0)
        }
        traitsAttribute?[UIFontDescriptor.TraitKey.slant] = italic ? 1.0 : 0.0

        fontDescriptor = fontDescriptor.addingAttributes([UIFontDescriptor.AttributeName.traits: traitsAttribute!])
        font = UIFont(descriptor: fontDescriptor, size: 0)
        return font
    }
    
    /**
     *  返回支持动态字体的UIFont，支持定义最小和最大字号
     *
     *  @param pointSize        默认的size
     *  @param upperLimitSize   最大的字号限制
     *  @param lowerLimitSize   最小的字号显示
     *  @param weight           字重
     *  @param italic           是否斜体
     *
     *  @return                 支持响应动态字体大小调整的 UIFont 对象
     */
    static func qmui_dynamicFont(ofSize fontSize: CGFloat,
                                 upperLimitSize: CGFloat = 0,
                                 lowerLimitSize: CGFloat = 0,
                                 weight: QMUIFontWeight,
                                 italic: Bool) -> UIFont {
        // 计算出 body 类型比默认的大小要变化了多少，然后在 pointSize 的基础上叠加这个变化
        var tmpUpperLimitSize: CGFloat = 0
        if upperLimitSize == 0 {
            tmpUpperLimitSize = fontSize + 5
        }
        var font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
        let offsetPointSize = font.pointSize - 17 // default UIFontTextStyleBody fontSize is 17
        var finalPointSize = fontSize + offsetPointSize
        finalPointSize = max(min(finalPointSize, tmpUpperLimitSize), lowerLimitSize)
        font = UIFont.qmui_systemFont(ofSize: finalPointSize, weight: weight, italic: false)
        return font
    }
}
