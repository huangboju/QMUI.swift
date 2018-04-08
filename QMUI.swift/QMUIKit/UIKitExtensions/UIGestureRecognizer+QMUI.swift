//
//  UIGestureRecognizer+QMUI.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/3/28.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

extension UIGestureRecognizer {
    
    /// 获取当前手势直接作用到的 view（注意与 view 属性区分开：view 属性表示手势被添加到哪个 view 上，qmui_targetView 则是 view 属性里的某个 subview）
    public weak var qmui_targetView: UIView? {
        let locationPoint = location(in: view)
        let targetView = view?.hitTest(locationPoint, with: nil)
        return targetView
    }
}
