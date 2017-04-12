//
//  UIControl+QMUI.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/4/12.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

extension UIControl {
    
    private struct AssociatedKeys {
        static var qmui_outsideEdge = "qmui_outsideEdge"
    }

    var qmui_outsideEdge: UIEdgeInsets {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.qmui_outsideEdge, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys.qmui_outsideEdge) as? UIEdgeInsets) ?? .zero
        }
    }
}
