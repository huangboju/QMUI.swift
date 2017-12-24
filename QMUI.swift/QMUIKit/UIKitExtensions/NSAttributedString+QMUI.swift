//
//  NSAttributedString+QMUI.swift
//  QMUI.swift
//
//  Created by xnxin on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

extension NSAttributedString {

    /**
     *  按照中文 2 个字符、英文 1 个字符的方式来计算文本长度
     */
    public func qmui_lengthWhenCountingNonASCIICharacterAsTwo() -> Int {
        return string.qmui_lengthWhenCountingNonASCIICharacterAsTwo
    }
}
