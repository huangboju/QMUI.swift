//
//  UIFont+QMUI.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/1/17.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

public enum QMUIFontWeight {
    case light, normal, bold
}

extension UIFont {

    /**
     *  返回系统字体的细体
     *
     * @param fontSize 字体大小
     *
     * @return 变细的系统字体的UIFont对象
     */
    public static func qmui_lightSystemFont(ofSize fontSize: CGFloat) -> UIFont {
        return UIFont(name: IOS_VERSION >= 9.0 ? ".SFUIText-Light" : "HelveticaNeue-Light", size: fontSize)!
    }

    /**
     *  根据需要生成一个 UIFont 对象并返回
     *  @param size     字号大小
     *  @param weight   字体粗细
     *  @param italic   是否斜体
     */
    public static func qmui_systemFont(ofSize size: CGFloat, weight: QMUIFontWeight, italic: Bool) -> UIFont {
        let isLight = weight == .light
        let isBold = weight == .bold

        let shouldUsingHardCode = IOS_VERSION < 10.0 // 这 UIFontDescriptor 也是醉人，相同代码只有 iOS 10 能得出正确结果，7-9都无法获取到 Light + Italic 的字体，只能写死。
        if shouldUsingHardCode {
            let name = IOS_VERSION < 9.0 ? "HelveticaNeue" : ".SFUIText"
            let fontSuffix = (isLight ? "Light" : (isBold ? "Bold" : "")) + (italic ? "Italic" : "")
            let fontName = name + (fontSuffix.length > 0 ? "-" : "") + fontSuffix
            let font = UIFont(name: fontName, size: size)
            return font!
        }

        // iOS 10 以上使用常规写法
        var font: UIFont!

        if #available(iOS 8.2, *) {
            font = UIFont.systemFont(ofSize: size, weight: isLight ? UIFont.Weight.light : (isBold ? UIFont.Weight.bold : UIFont.Weight.regular))
        } else {
            font = UIFont.systemFont(ofSize: size)
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
     * 返回支持动态字体的UIFont，支持定义最小和最大字号
     *
     * @param pointSize 默认的size
     * @param upperLimitSize 最大的字号限制
     * @param lowerLimitSize 最小的字号显示
     * @param bold 是否加粗
     *
     * @return 支持动态字体的UIFont对象
     */
    public static func qmui_dynamicFont(withSize pointSize: CGFloat, upperLimitSize: CGFloat, lowerLimitSize: CGFloat, bold: Bool) -> UIFont {
        var font: UIFont
        var descriptor: UIFontDescriptor

        // 如果是系统的字号，先映射到系统提供的UIFontTextStyle，否则用UIFontDescriptor来做偏移计算
        let dict: [CGFloat: UIFontTextStyle] = [
            17: .body,
            15: .subheadline,
            13: .footnote,
            12: .caption1,
            11: .caption2,
        ]
        var textStyle: UIFontTextStyle? = dict[pointSize]

        if let textStyle = textStyle {
            descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: textStyle)
            if bold {
                descriptor = descriptor.withSymbolicTraits(.traitBold)!
                font = UIFont(descriptor: descriptor, size: 0)
                if upperLimitSize > 0 && font.pointSize > upperLimitSize {
                    font = UIFont(descriptor: descriptor, size: upperLimitSize)
                } else if lowerLimitSize > 0 && font.pointSize < lowerLimitSize {
                    font = UIFont(descriptor: descriptor, size: lowerLimitSize)
                }
            } else {
                font = UIFont.preferredFont(forTextStyle: textStyle)
                if upperLimitSize > 0 && font.pointSize > upperLimitSize {
                    font = UIFont.systemFont(ofSize: upperLimitSize)
                } else if lowerLimitSize > 0 && font.pointSize < lowerLimitSize {
                    font = UIFont.systemFont(ofSize: lowerLimitSize)
                }
            }
        } else {
            textStyle = UIFontTextStyle.body
            descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: textStyle!)
            // 对于非系统默认字号的情况，用body类型去做偏移计算
            font = UIFont.preferredFont(forTextStyle: textStyle!) // default fontSize = 17
            let offsetPointSize = font.pointSize - 17
            descriptor = descriptor.withSize(pointSize + offsetPointSize)
            if bold {
                descriptor = descriptor.withSymbolicTraits(.traitBold)!
            }
            font = UIFont(descriptor: descriptor, size: 0)
            if upperLimitSize > 0 && font.pointSize > upperLimitSize {
                font = UIFont(descriptor: descriptor, size: upperLimitSize)
            } else if lowerLimitSize > 0 && font.pointSize < lowerLimitSize {
                font = UIFont(descriptor: descriptor, size: lowerLimitSize)
            }
        }
        return font
    }

    /**
     * 返回支持动态字体的UIFont
     *
     * @param pointSize 默认的size
     * @param bold 是否加粗
     *
     * @return 支持动态字体的UIFont对象
     */
    public static func qmui_dynamicFont(withSize size: CGFloat, bold: Bool) -> UIFont {
        return UIFont.qmui_dynamicFont(withSize: size, upperLimitSize: size + 3, lowerLimitSize: 0, bold: bold)
    }
}
