//
//  UILabel+QMUI.swift
//  QMUI.swift
//
//  Created by xnxin on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

extension UILabel {
    /**
     * 在UILabel的样式（如字体）设置完后，将label的text设置为一个测试字符，再调用sizeToFit，从而令label的高度适应字体
     * @warning 会setText:，因此确保在配置完样式后、设置text之前调用
     */
    public func qmui_calculateHeightAfterSetAppearance() {
        text = "测"
        sizeToFit()
        text = nil
    }
}
