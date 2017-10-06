//
//  QMUITextField.swift
//  QMUI.swift
//
//  Created by xnxin on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

import UIKit

class QMUITextField: UITextField {

    /**
     *  文字在输入框内的 padding。如果出现 clearButton，则 textInsets.right 会控制 clearButton 的右边距
     *
     *  默认为 TextFieldTextInsets
     */
    public var textInsets: UIEdgeInsets = .zero

    /**
     *  显示允许输入的最大文字长度，默认为 NSUIntegerMax，也即不限制长度。
     */
    @IBInspectable
    public var maximumTextLength = Int.max
}
