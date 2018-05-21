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
    func qmui_lengthWhenCountingNonASCIICharacterAsTwo() -> Int {
        return string.qmui_lengthWhenCountingNonASCIICharacterAsTwo
    }

    /**
     * @brief 创建一个包含图片的 attributedString
     * @param image 要用的图片
     * @param offset 图片相对基线的垂直偏移（当 offset > 0 时，图片会向上偏移）
     * @param leftMargin 图片距离左侧内容的间距
     * @param rightMargin 图片距离右侧内容的间距
     * @note leftMargin 和 rightMargin 必须大于或等于 0
     */
    static func qmui_attributedString(with image: UIImage?,
                                      baselineOffset: CGFloat = 0,
                                      leftMargin: CGFloat = 0,
                                      rightMargin: CGFloat = 0) -> NSAttributedString? {
        guard let image = image else {
            return nil
        }
        let attachment = NSTextAttachment()
        attachment.image = image
        attachment.bounds = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        let string = NSMutableAttributedString(attributedString: NSAttributedString(attachment: attachment))
        string.addAttribute(NSAttributedStringKey.baselineOffset, value: baselineOffset, range: NSRange(location: 0, length: string.length))
        if leftMargin > 0 {
            string.insert(qmui_attributedStringWithFixedSpace(leftMargin), at: 0)
        }
        if rightMargin > 0 {
            string.append(qmui_attributedStringWithFixedSpace(rightMargin))
        }
        return string
    }

    /**
     * @brief 创建一个用来占位的空白 attributedString
     * @param width 空白占位符的宽度
     */
    static func qmui_attributedStringWithFixedSpace(_ width: CGFloat) -> NSAttributedString {
        UIGraphicsBeginImageContext(CGSize(width: width, height: 1))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return qmui_attributedString(with: image) ?? NSAttributedString()
    }
}
