//
//  UINavigationController+QMUI.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/2/6.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//
import UIKit

extension UINavigationController: SelfAware2 {
    private static let _onceToken = UUID().uuidString

    static func awake2() {
        DispatchQueue.once(token: _onceToken) {
            ReplaceMethod(self, #selector(viewDidLoad), #selector(qmui_viewDidLoad))
            // TODO: 这里UINavigationController没有显示的该方法，所以Swift类型推不出来
            //            ReplaceMethod(NSClassFromString("UINavigationController")!, #selector(navigationBar(_:shouldPop:)), #selector(qmui_navigationBar(_:shouldPop:)))
        }
    }
}

public protocol UINavigationControllerBackButtonHandlerProtocol {
    /// 是否需要拦截系统返回按钮的事件，只有当这里返回YES的时候，才会询问方法：`canPopViewController`
    func shouldHoldBackButtonEvent() -> Bool

    /// 是否可以`popViewController`，可以在这个返回里面做一些业务的判断，比如点击返回按钮的时候，如果输入框里面的文本没有满足条件的则可以弹alert并且返回NO
    func canPopViewController() -> Bool

    /// 当自定义了`leftBarButtonItem`按钮之后，系统的手势返回就失效了。可以通过`forceEnableInteractivePopGestureRecognizer`来决定要不要把那个手势返回强制加回来。当 interactivePopGestureRecognizer.enabled = NO 或者当前`UINavigationController`堆栈的viewControllers小于2的时候此方法无效。
    func forceEnableInterativePopGestureRecognizer() -> Bool
}

extension UINavigationControllerBackButtonHandlerProtocol {
    public func shouldHoldBackButtonEvent() -> Bool {
        return false
    }

    public func canPopViewController() -> Bool {
        return false
    }

    public func forceEnableInterativePopGestureRecognizer() -> Bool {
        return false
    }
}

extension UIViewController: UINavigationControllerBackButtonHandlerProtocol {
}

extension UINavigationController {

    private struct AssociatedKeys {
        static var isPushingViewControllerKey = "isPushingViewControllerKey"
        static var isPoppingViewController = "isPoppingViewController"
        static var originGestureDelegateKey = "originGestureDelegateKey"
    }

    public var qmui_rootViewController: UIViewController? {
        return viewControllers.first
    }

    public var qmui_isPushingViewController: Bool {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.isPushingViewControllerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }

        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys.isPushingViewControllerKey) as? Bool) ?? false
        }
    }

    public var qmui_isPoppingViewController: Bool {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.isPoppingViewController, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }

        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys.isPoppingViewController) as? Bool) ?? false
        }
    }

    @objc public func qmui_viewDidLoad() {
        self.qmui_viewDidLoad()

        objc_setAssociatedObject(self, &AssociatedKeys.originGestureDelegateKey, interactivePopGestureRecognizer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        interactivePopGestureRecognizer?.delegate = self
    }

    @objc public func qmui_navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
        let viewController = self.topViewController

        // item == viewController.navigationItem to fix: 如果前后2个controller都需要hold时的BUG.
        let canPop = canPopViewController(viewController) && item == viewController?.navigationItem

        // 如果nav的vc栈中有两个vc，第一个是root，第二个是second。这是second页面如果点击系统的返回按钮，topViewController获取的栈顶vc是second，而如果是直接代码写的pop操作，则获取的栈顶vc是root。也就是说只要代码写了pop操作，则系统会直接将顶层vc也就是second出栈，然后才回调的，所以这时我们获取到的顶层vc就是root了。然而不管哪种方式，参数中的item都是second的item。
        // 综上所述，使用item != viewController.navigationItem来判断就是为了解决这个问题。
        if canPop || item != viewController?.navigationItem {
            return self.qmui_navigationBar(navigationBar, shouldPop: item)
        } else {
            resetSubviewsInNavBar(navigationBar)
        }

        return false
    }

    private func resetSubviewsInNavBar(_ navBar: UINavigationBar) {
        // Workaround for >= iOS7.1. Thanks to @boliva - http://stackoverflow.com/posts/comments/34452906
        for view in navBar.subviews {
            if view.alpha < 1.0 {
                UIView.animate(withDuration: 0.25) {
                    view.alpha = 1.0
                }
            }
        }
    }
}

extension UINavigationController: UIGestureRecognizerDelegate {
    private func canPopViewController(_ viewController: UIViewController?) -> Bool {
        var canPop = true

        if let notNilViewController = viewController, notNilViewController.shouldHoldBackButtonEvent() && !notNilViewController.canPopViewController() {
            canPop = false
        }

        return canPop
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.interactivePopGestureRecognizer {
            let canPop = canPopViewController(self.topViewController)

            if canPop {
                if let originGestureDelegate = objc_getAssociatedObject(self, &AssociatedKeys.originGestureDelegateKey) as? UIGestureRecognizerDelegate {
                    return originGestureDelegate.gestureRecognizerShouldBegin?(gestureRecognizer) ?? false
                } else {
                    return false
                }
            } else {
                return false
            }
        }
        return true
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if gestureRecognizer == self.interactivePopGestureRecognizer {
            if let originGestureDelegate = objc_getAssociatedObject(self, &AssociatedKeys.originGestureDelegateKey) as? UIGestureRecognizerDelegate {
                // 先判断要不要强制开启手势返回
                let viewController = self.topViewController
                if self.viewControllers.count > 1 && self.interactivePopGestureRecognizer?.isEnabled ?? false && viewController?.forceEnableInterativePopGestureRecognizer() ?? false {
                    return true
                }

                // 调用默认实现
                return originGestureDelegate.gestureRecognizer?(gestureRecognizer, shouldReceive: touch) ?? false
            }
        }
        return true
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.interactivePopGestureRecognizer {
            if let originGestureDelegate = objc_getAssociatedObject(self, &AssociatedKeys.originGestureDelegateKey) as? UIGestureRecognizerDelegate {
                return originGestureDelegate.gestureRecognizer?(gestureRecognizer, shouldRecognizeSimultaneouslyWith: otherGestureRecognizer) ?? false
            }
        }
        return false
    }

    // 是否要gestureRecognizer检测失败了，才去检测otherGestureRecognizer
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy _: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.interactivePopGestureRecognizer {
            // 如果只是实现了上面几个手势的delegate，那么返回的手势和当前界面上的scrollview或者其他存在的手势会冲突，所以如果判断是返回手势，则优先响应返回手势再响应其他手势。
            // 不知道为什么，系统竟然没有实现这个delegate，那么它是怎么处理返回手势和其他手势的优先级的
            return true
        }
        return false
    }
}
