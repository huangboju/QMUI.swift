//
//  UIColor+QMUI.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/1/17.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

extension UIColor: SelfAware {
    private static let _onceToken = UUID().uuidString

    static func awake() {
        DispatchQueue.once(token: _onceToken) {
            let clazz = UIColor.self
            ReplaceMethod(clazz, #selector(description), #selector(getter: qmui_description))
        }
    }
}

extension UIColor {

    @objc var qmui_description: String {
        let red = qmui_red * 255
        let green = qmui_green * 255
        let blue = qmui_blue * 255
        let alpha = qmui_alpha
        let description = "color = RGBA: (\(red), \(green), \(blue), \(alpha)), AARRGGBB: \(qmui_hexString)"
        return description
    }

    /**
     *  使用HEX命名方式的颜色字符串生成一个UIColor对象
     *
     *  @param hexString
     *      #RGB        例如#f0f，等同于#ffff00ff，RGBA(255, 0, 255, 1)
     *      #ARGB       例如#0f0f，等同于#00ff00ff，RGBA(255, 0, 255, 0)
     *      #RRGGBB     例如#ff00ff，等同于#ffff00ff，RGBA(255, 0, 255, 1)
     *      #AARRGGBB   例如#00ff00ff，等同于RGBA(255, 0, 255, 0)
     *
     * @return UIColor对象
     */
    convenience init(hexStr: String) {

        let colorString = hexStr.replacingOccurrences(of: "#", with: "").uppercased()

        var alpha: CGFloat = 0
        var red: CGFloat = 0
        var blue: CGFloat = 0
        var green: CGFloat = 0

        switch colorString.length {
        case 3: // #RGB
            alpha = 1.0

            red = UIColor.colorComponent(from: colorString, start: 0, length: 1)
            green = UIColor.colorComponent(from: colorString, start: 1, length: 1)
            blue = UIColor.colorComponent(from: colorString, start: 2, length: 1)
        case 4: // #ARGB
            alpha = UIColor.colorComponent(from: colorString, start: 0, length: 1)
            red = UIColor.colorComponent(from: colorString, start: 1, length: 1)
            green = UIColor.colorComponent(from: colorString, start: 2, length: 1)
            blue = UIColor.colorComponent(from: colorString, start: 3, length: 1)
        case 6: // #RRGGBB
            alpha = 1.0
            red = UIColor.colorComponent(from: colorString, start: 0, length: 2)
            green = UIColor.colorComponent(from: colorString, start: 2, length: 2)
            blue = UIColor.colorComponent(from: colorString, start: 4, length: 2)
        case 8: // #AARRGGBB
            alpha = UIColor.colorComponent(from: colorString, start: 0, length: 2)
            red = UIColor.colorComponent(from: colorString, start: 2, length: 2)
            green = UIColor.colorComponent(from: colorString, start: 4, length: 2)
            blue = UIColor.colorComponent(from: colorString, start: 6, length: 2)
        default:

            // TODO:
            //            [NSException raise:@"Invalid color value" format: @"Color value %@ is invalid.  It should be a hex value of the form #RBG, #ARGB, #RRGGBB, or #AARRGGBB", hexString]
            break
        }

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

    private static func colorComponent(from string: String, start: Int, length: Int) -> CGFloat {
        let substring = string.substring(with: NSRange(location: start, length: length))
        let fullHex = length == 2 ? substring : substring + substring
        var hexComponent: UInt32 = 0
        Scanner(string: fullHex).scanHexInt32(&hexComponent)
        return CGFloat(hexComponent) / 255.0
    }

    convenience init(hex: Int, alpha: CGFloat = 1) {

        let c = curry { $0 / CGFloat(255) }

        let red = c(CGFloat((hex & 0xFF0000) >> 16))
        let green = c(CGFloat((hex & 0xFF00) >> 8))
        let blue = c(CGFloat(hex & 0xFF))

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

    /**
     *  将当前色值转换为hex字符串，通道排序是AARRGGBB（与Android保持一致）
     */
    var qmui_hexString: String {
        let alpha = qmui_alpha * 255
        let red = qmui_red * 255
        let green = qmui_green * 255
        let blue = qmui_blue * 255

        let str = "#\(alignColorHexStringLength(hexString: String.qmui_hexString(with: Int(alpha))))\(alignColorHexStringLength(hexString: String.qmui_hexString(with: Int(red))))\(alignColorHexStringLength(hexString: String.qmui_hexString(with: Int(green))))\(alignColorHexStringLength(hexString: String.qmui_hexString(with: Int(blue))))"
        return str
    }

    // 对于色值只有单位数的，在前面补一个0，例如“F”会补齐为“0F”
    private func alignColorHexStringLength(hexString: String) -> String {
        return hexString.length < 2 ? "0" + hexString : hexString
    }

    /**
     *  获取当前UIColor对象里的红色色值
     *
     *  @return 红色通道的色值，值范围为0.0-1.0
     */
    var qmui_red: CGFloat {
        var r: CGFloat = 0
        if getRed(&r, green: nil, blue: nil, alpha: nil) {
            return r
        }
        return 0
    }

    /**
     *  获取当前UIColor对象里的绿色色值
     *
     *  @return 绿色通道的色值，值范围为0.0-1.0
     */
    var qmui_green: CGFloat {
        var g: CGFloat = 0
        if getRed(nil, green: &g, blue: nil, alpha: nil) {
            return g
        }
        return 0
    }

    /**
     *  获取当前UIColor对象里的蓝色色值
     *
     *  @return 蓝色通道的色值，值范围为0.0-1.0
     */
    var qmui_blue: CGFloat {
        var b: CGFloat = 0
        if getRed(nil, green: nil, blue: &b, alpha: nil) {
            return b
        }
        return 0
    }

    /**
     *  获取当前UIColor对象里的透明色值
     *
     *  @return 透明通道的色值，值范围为0.0-1.0
     */
    var qmui_alpha: CGFloat {
        var a: CGFloat = 0
        if getRed(nil, green: nil, blue: nil, alpha: &a) {
            return a
        }
        return 0
    }

    /**
     *  获取当前UIColor对象里的hue（色相）
     */
    var qmui_hue: CGFloat {
        var h: CGFloat = 0
        if getHue(&h, saturation: nil, brightness: nil, alpha: nil) {
            return h
        }
        return 0
    }

    /**
     *  获取当前UIColor对象里的saturation（饱和度）
     */
    var qmui_saturation: CGFloat {
        var s: CGFloat = 0
        if getHue(nil, saturation: &s, brightness: nil, alpha: nil) {
            return s
        }
        return 0
    }

    /**
     *  获取当前UIColor对象里的brightness（亮度）
     */
    var qmui_brightness: CGFloat {
        var b: CGFloat = 0
        if getHue(nil, saturation: nil, brightness: &b, alpha: nil) {
            return b
        }
        return 0
    }

    /**
     *  将当前UIColor对象剥离掉alpha通道后得到的色值。相当于把当前颜色的半透明值强制设为1.0后返回
     *
     *  @return alpha通道为1.0，其他rgb通道与原UIColor对象一致的新UIColor对象
     */
    var qmui_colorWithoutAlpha: UIColor? {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        if getRed(&r, green: &g, blue: &b, alpha: nil) {
            return UIColor(red: r, green: g, blue: b, alpha: 1)
        } else {
            return nil
        }
    }

    /**
     *  计算当前color叠加了alpha之后放在指定颜色的背景上的色值
     */
    func qmui_color(with alpha: CGFloat, backgroundColor: UIColor) -> UIColor {
        return UIColor.qmui_colorWithBackendColor(backgroundColor, frontColor: withAlphaComponent(alpha))
    }

    /**
     *  计算当前color叠加了alpha之后放在白色背景上的色值
     */
    func qmui_colorWithAlphaAddedToWhite(_ alpha: CGFloat) -> UIColor {
        return qmui_color(with: alpha, backgroundColor: UIColorWhite)
    }

    /**
     *  将自身变化到某个目标颜色，可通过参数progress控制变化的程度，最终得到一个纯色
     *  @param toColor 目标颜色
     *  @param progress 变化程度，取值范围0.0f~1.0f
     */
    func qmui_transition(to color: UIColor, progress: CGFloat) -> UIColor {
        return UIColor.qmui_color(from: self, to: color, progress: progress)
    }

    /**
     *  计算两个颜色叠加之后的最终色（注意区分前景色后景色的顺序）<br/>
     *  @link http://stackoverflow.com/questions/10781953/determine-rgba-colour-received-by-combining-two-colours @/link
     */
    static func qmui_colorWithBackendColor(_ backendColor: UIColor, frontColor: UIColor) -> UIColor {
        let bgAlpha = backendColor.qmui_alpha
        let bgRed = backendColor.qmui_red
        let bgGreen = backendColor.qmui_green
        let bgBlue = backendColor.qmui_blue

        let frAlpha = frontColor.qmui_alpha
        let frRed = frontColor.qmui_red
        let frGreen = frontColor.qmui_green
        let frBlue = frontColor.qmui_blue

        let resultAlpha = frAlpha + bgAlpha * (1 - frAlpha)
        let resultRed = (frRed * frAlpha + bgRed * bgAlpha * (1 - frAlpha)) / resultAlpha
        let resultGreen = (frGreen * frAlpha + bgGreen * bgAlpha * (1 - frAlpha)) / resultAlpha
        let resultBlue = (frBlue * frAlpha + bgBlue * bgAlpha * (1 - frAlpha)) / resultAlpha

        return UIColor(red: resultRed, green: resultGreen, blue: resultBlue, alpha: resultAlpha)
    }

    /**
     *  将颜色A变化到颜色B，可通过progress控制变化的程度
     *  @param fromColor 起始颜色
     *  @param toColor 目标颜色
     *  @param progress 变化程度，取值范围0.0f~1.0f
     */
    static func qmui_color(from fromColor: UIColor, to toColor: UIColor, progress: CGFloat) -> UIColor {
        let progress = min(progress, 1.0)
        let fromRed = fromColor.qmui_red
        let fromGreen = fromColor.qmui_green
        let fromBlue = fromColor.qmui_blue
        let fromAlpha = fromColor.qmui_alpha

        let toRed = toColor.qmui_red
        let toGreen = toColor.qmui_green
        let toBlue = toColor.qmui_blue
        let toAlpha = toColor.qmui_alpha

        let finalRed = fromRed + (toRed - fromRed) * progress
        let finalGreen = fromGreen + (toGreen - fromGreen) * progress
        let finalBlue = fromBlue + (toBlue - fromBlue) * progress
        let finalAlpha = fromAlpha + (toAlpha - fromAlpha) * progress

        return UIColor(red: finalRed, green: finalGreen, blue: finalBlue, alpha: finalAlpha)
    }

    /**
     *  产生一个随机色，大部分情况下用于测试
     */
    static var qmui_randomColor: UIColor {

        let red = (CGFloat(arc4random()).truncatingRemainder(dividingBy: 255) / 255.0)
        let green = (CGFloat(arc4random()).truncatingRemainder(dividingBy: 255) / 255.0)
        let blue = (CGFloat(arc4random()).truncatingRemainder(dividingBy: 255) / 255.0)

        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }

    /**
     *  判断当前颜色是否为深色，可用于根据不同色调动态设置不同文字颜色的场景。
     *
     *  @link http://stackoverflow.com/questions/19456288/text-color-based-on-background-image @/link
     *
     *  @return 若为深色则返回“YES”，浅色则返回“NO”
     */
    var qmui_colorIsDark: Bool {
        var red: CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, alpha: CGFloat = 0.0

        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let referenceValue: CGFloat = 0.411
        let colorDelta = ((red * 0.299) + (green * 0.587) + (blue * 0.114))

        return 1.0 - colorDelta > referenceValue
    }

    /**
     *  当前颜色的反色
     *
     *  @link http://stackoverflow.com/questions/5893261/how-to-get-inverse-color-from-uicolor @/link
     */
    var qmui_inverseColor: UIColor {
        guard let componentColors = cgColor.components else { return self }
        let newColor = UIColor(red: 1.0 - componentColors[0], green: 1.0 - componentColors[1], blue: 1.0 - componentColors[2], alpha: componentColors[3])
        return newColor
    }

    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1) {
        self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a)
    }
    
    /**
     *  获取当前系统的默认 tintColor 色值
     */
    static var _systemTintColor: UIColor? = nil
    static var qmui_isSystemTintColor: UIColor {
        if _systemTintColor == nil {
            let view = UIView()
            _systemTintColor = view.tintColor
        }
        return _systemTintColor!
    }
}
