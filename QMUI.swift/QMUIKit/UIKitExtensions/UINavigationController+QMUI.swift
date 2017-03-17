//
//  UINavigationController+QMUI.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/2/6.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

extension UINavigationController {

    private struct AssociatedKeys {
        static var isPushingViewControllerKey = "isPushingViewControllerKey"
        static var isPoppingViewController = "isPoppingViewController"
    }

    var qmui_rootViewController: UIViewController? {
        return viewControllers.first
    }

    var qmui_isPushingViewController: Bool {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.isPushingViewControllerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }

        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys.isPushingViewControllerKey) as? Bool) ?? false
        }
    }

    var qmui_isPoppingViewController: Bool {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.isPoppingViewController, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }

        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys.isPoppingViewController) as? Bool) ?? false
        }
    }
}
