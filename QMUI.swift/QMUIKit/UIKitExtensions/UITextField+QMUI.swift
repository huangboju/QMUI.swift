//
//  UITextField+QMUI.swift
//  QMUI.swift
//
//  Created by xnxin on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

import Foundation

extension UITextField {

    /// UITextField只有selectedTextRange属性（在<UITextInput>协议里定义），这里拓展了一个方法可以将UITextRange类型的selectedTextRange转换为NSRange类型的selectedRange
    var qmui_selectedRange: NSRange? {
        guard let selectedTextRange = self.selectedTextRange else {
            return nil
        }

        let location = offset(from: beginningOfDocument, to: selectedTextRange.start)
        let length = offset(from: beginningOfDocument, to: selectedTextRange.start)
        return NSMakeRange(location, length)
    }
}
