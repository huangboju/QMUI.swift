//
//  UIFont+QMUI.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/1/17.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

enum QMUIFontWeight {
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
     * 返回支持动态字体的UIFont
     *
     * @param pointSize 默认的size
     * @param bold 是否加粗
     *
     * @return 支持动态字体的UIFont对象
     */
    public static func qmui_dynamicFont(with size: CGFloat, bold: Bool) -> UIFont {
        return UIFont.qmui_dynamicFont(with: size, upperLimitSize: size + 3, lowerLimitSize: 0, bold: bold)
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
    public static func qmui_dynamicFont(with pointSize: CGFloat, upperLimitSize: CGFloat, lowerLimitSize: CGFloat, bold: Bool) -> UIFont {
        var font: UIFont
        var descriptor: UIFontDescriptor

        // 如果是系统的字号，先映射到系统提供的UIFontTextStyle，否则用UIFontDescriptor来做偏移计算
        let dict: [CGFloat: UIFontTextStyle] = [
            17: .body,
            15: .subheadline,
            13: .footnote,
            12: .caption1,
            11: .caption2
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
            font = UIFont.preferredFont(forTextStyle: textStyle!)// default fontSize = 17
            let offsetPointSize = font.pointSize - 17
            descriptor = descriptor.withSize(pointSize + offsetPointSize)
            if bold {
                descriptor = descriptor.withSymbolicTraits(.traitBold)!
            }
            font = UIFont(descriptor: descriptor, size: 0)
            if upperLimitSize > 0 && font.pointSize > upperLimitSize {
                font = UIFont(descriptor: descriptor, size: upperLimitSize)
            } else if (lowerLimitSize > 0 && font.pointSize < lowerLimitSize) {
                font = UIFont(descriptor: descriptor, size: lowerLimitSize)
            }
        }
        return font
    }
}
