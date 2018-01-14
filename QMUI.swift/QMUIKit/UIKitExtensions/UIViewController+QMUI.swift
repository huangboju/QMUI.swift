//
//  UIViewController+QMUI.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/3/21.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

// TODO: - Method Swizzle
extension UIViewController {

    /** 获取和自身处于同一个UINavigationController里的上一个UIViewController */
    public weak var qmui_previousViewController: UIViewController? {
        if let controllers = navigationController?.viewControllers,
            controllers.count > 1,
            navigationController?.topViewController == self {
            let controllerCount = controllers.count
            return controllers[controllerCount - 2]
        }

        return nil
    }

    /** 获取上一个UIViewController的title，可用于设置自定义返回按钮的文字 */
    public var qmui_previousViewControllerTitle: String? {

        if let previousViewController = qmui_previousViewController {
            return previousViewController.title
        }

        return nil
    }

    /**
     *  获取当前controller里的最高层可见viewController（可见的意思是还会判断self.view.window是否存在）
     *
     *  @see 如果要获取当前App里的可见viewController，请使用 [QMUIHelper visibleViewController]
     *
     *  @return 当前controller里的最高层可见viewController
     */
    public var qmui_visibleViewControllerIfExist: UIViewController? {

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

    /**
     *  当前 viewController 是否是被以 present 的方式显示的，是则返回 YES，否则返回 NO
     *  @warning 对于被放在 UINavigationController 里显示的 UIViewController，如果 self 是 self.navigationController 的第一个 viewController，则如果 self.navigationController 是被 present 起来的，那么 self.qmui_isPresented = self.navigationController.qmui_isPresented = YES。利用这个特性，可以方便地给 navigationController 的第一个界面的左上角添加关闭按钮。
     */
    public var qmui_isPresented: Bool {
        var viewController = self
        if let navigationController = self.navigationController {
            if navigationController.qmui_rootViewController != self {
                return false
            }
            viewController = navigationController
        }

        return viewController.presentingViewController?.presentedViewController == viewController
    }

    /** 是否响应 QMUINavigationControllerDelegate */
    public var qmui_respondQMUINavigationControllerDelegate: Bool {
        return self is QMUINavigationControllerDelegate
    }

    /**
     *  是否应该响应一些UI相关的通知，例如 UIKeyboardNotification、UIMenuControllerNotification等，因为有可能当前界面已经被切走了（push到其他界面），但仍可能收到通知，所以在响应通知之前都应该做一下这个判断
     */
    public var qmui_isViewLoadedAndVisible: Bool {
        return isViewLoaded && (view.window != nil)
    }
}

extension UIViewController {
    public func qmui_hasOverrideUIKitMethod(_ selector: Selector) -> Bool {
        // 排序依照 Xcode Interface Builder 里的控件排序，但保证子类在父类前面
        var viewControllerSuperclasses = [
            UIImagePickerController.self,
            UINavigationController.self,
            UITableViewController.self,
            UICollectionViewController.self,
            UITabBarController.self,
            UISplitViewController.self,
            UIPageViewController.self,
            UIViewController.self,
        ]
        if NSClassFromString("UIAlertController") != nil {
            viewControllerSuperclasses.append(UIAlertController.self)
        }

        if NSClassFromString("UISearchController") != nil {
            viewControllerSuperclasses.append(UISearchController.self)
        }

        for superClass in viewControllerSuperclasses {
            if qmui_hasOverrideMethod(selector: selector, of: superClass) {
                return true
            }
        }

        return false
    }
}
