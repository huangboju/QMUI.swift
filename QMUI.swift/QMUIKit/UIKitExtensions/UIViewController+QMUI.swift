//
//  UIViewController+QMUI.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/3/21.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

extension UIViewController {
    var qmui_visibleViewControllerIfExist: UIViewController? {

        if let presentedViewController = presentedViewController {
            return presentedViewController.qmui_visibleViewControllerIfExist
        }
        if let nav = self as? UINavigationController {
            return nav.topViewController?.qmui_visibleViewControllerIfExist
        }
        if let tabbar = self as? UITabBarController {
            return tabbar.selectedViewController?.qmui_visibleViewControllerIfExist
        }

        if isViewLoaded && view.window != nil {
            return self
        } else {
            print("qmui_visibleViewControllerIfExist:，找不到可见的viewController。self = \(self), view.window = \(String(describing: view.window))")
            return nil
        }
    }
}
