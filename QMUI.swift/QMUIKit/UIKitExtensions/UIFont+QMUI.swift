//
//  UIFont+QMUI.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/1/17.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

extension UIFont {
    convenience init(systemFor size: CGFloat) {
        self.init(name: ".SFUIText", size: size)!
    }

    convenience init(boldFor size: CGFloat) {
        self.init(name: ".SFUIText-Semibold", size: size)!
    }
}
