//
//  UIView+QMUI.swift
//  QMUI.swift
//
//  Created by xnxin on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

enum QMUIBorderViewPosition: Int {
    case none      = 0
    case top
    case left
    case bottom
    case right
}

extension UIView {
    
    fileprivate struct Keys {
        static var borderPosition = "borderPosition"
    }

    /**
     * 获取当前view在superview内的垂直居中时的minX
     */
    public var qmui_minYWhenCenterInSuperview: CGFloat {
        return superview?.bounds.height.center(with: frame.height) ?? 0
    }

    public var qmui_borderPosition: QMUIBorderViewPosition? {
        set {
            objc_setAssociatedObject(self, &Keys.borderPosition, newValue ?? QMUIBorderViewPosition.none, .OBJC_ASSOCIATION_RETAIN)
            setNeedsLayout()
        }
        get {
            return (objc_getAssociatedObject(self, &Keys.borderPosition) as? QMUIBorderViewPosition) ?? QMUIBorderViewPosition.none
        }
    }
}
