//
//  UIColor+QMUI.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/1/17.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

extension UIColor {
    convenience init(hex: Int, alpha: CGFloat = 1) {

        let c = curry { $0 / CGFloat(255) }

        let red = c(CGFloat((hex & 0xFF0000) >> 16))
        let green = c(CGFloat((hex & 0xFF00) >> 8))
        let blue = c(CGFloat(hex & 0xFF))

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1) {
        self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a)
    }
}
