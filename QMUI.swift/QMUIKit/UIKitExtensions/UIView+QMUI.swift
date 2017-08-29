//
//  UIView+QMUI.swift
//  QMUI.swift
//
//  Created by xnxin on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

extension UIView {
    /**
     * 获取当前view在superview内的垂直居中时的minX
     */
    var qmui_minYWhenCenterInSuperview: CGFloat {
        return superview?.bounds.height.center(with: frame.height) ?? 0
    }
}
