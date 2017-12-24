//
//  NSMutableParagraphStyle+QMUI.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/4/13.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

extension NSMutableParagraphStyle {
    /**
     *  快速创建一个NSMutableParagraphStyle，等同于`qmui_paragraphStyleWithLineHeight:lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentLeft`
     *  @param  lineHeight      行高
     *  @return 一个NSMutableParagraphStyle对象
     */

    convenience init(lineHeight: CGFloat) {
        self.init(lineHeight: lineHeight, lineBreakMode: .byWordWrapping, textAlignment: .left)
    }

    /**
     *  快速创建一个NSMutableParagraphStyle，等同于`qmui_paragraphStyleWithLineHeight:lineBreakMode:textAlignment:NSTextAlignmentLeft`
     *  @param  lineHeight      行高
     *  @param  lineBreakMode   换行模式
     *  @return 一个NSMutableParagraphStyle对象
     */
    convenience init(lineHeight: CGFloat, lineBreakMode: NSLineBreakMode) {
        self.init(lineHeight: lineHeight, lineBreakMode: lineBreakMode, textAlignment: .left)
    }

    /**
     *  快速创建一个NSMutableParagraphStyle
     *  @param  lineHeight      行高
     *  @param  lineBreakMode   换行模式
     *  @param  textAlignment   文本对齐方式
     *  @return 一个NSMutableParagraphStyle对象
     */
    convenience init(lineHeight: CGFloat, lineBreakMode: NSLineBreakMode, textAlignment: NSTextAlignment) {
        self.init()
        minimumLineHeight = lineHeight
        maximumLineHeight = lineHeight
        self.lineBreakMode = lineBreakMode
        alignment = textAlignment
    }
}
