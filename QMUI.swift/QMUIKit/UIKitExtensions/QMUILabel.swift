//
//  QMUILabel.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/3/17.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

/** 
 * `QMUILabel`支持通过`contentEdgeInsets`属性来实现类似padding的效果。
 *
 * 同时通过将`canPerformCopyAction`置为`YES`来开启长按复制文本的功能，长按时label的背景色默认为`highlightedBackgroundColor`
 */
class QMUILabel: UILabel {
    /// 控制label内容的padding，默认为UIEdgeInsetsZero
    var contentEdgeInsets: UIEdgeInsets?
}
