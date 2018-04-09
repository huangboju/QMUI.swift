//
//  UINavigationController+QMUI.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/2/6.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//
import UIKit

@objc protocol UINavigationControllerBackButtonHandlerProtocol: NSObjectProtocol {
    /// 是否需要拦截系统返回按钮的事件，只有当这里返回YES的时候，才会询问方法：`canPopViewController`
    @objc optional func shouldHoldBackButtonEvent() -> Bool
    
    /// 是否可以`popViewController`，可以在这个返回里面做一些业务的判断，比如点击返回按钮的时候，如果输入框里面的文本没有满足条件的则可以弹alert并且返回NO
    @objc optional func canPopViewController() -> Bool
    
    /// 当自定义了`leftBarButtonItem`按钮之后，系统的手势返回就失效了。可以通过`forceEnableInteractivePopGestureRecognizer`来决定要不要把那个手势返回强制加回来。当 interactivePopGestureRecognizer.enabled = NO 或者当前`UINavigationController`堆栈的viewControllers小于2的时候此方法无效。
    @objc optional func forceEnableInterativePopGestureRecognizer() -> Bool
}

extension UINavigationController: SelfAware2
 {
    private static let _onceToken = UUID().uuidString

    static func awake2() {
        DispatchQueue.once(token: _onceToken) {
            let clazz = UINavigationController.self
            
            ReplaceMethod(clazz, #selector(UINavigationController.viewDidLoad), #selector(UINavigationController.qmui_viewDidLoad))
            ReplaceMethod(clazz, #selector(UINavigationBarDelegate.navigationBar(_:shouldPop:)), #selector(UINavigationController.qmui_navigationBar(_:shouldPop:)))
            
            // MARK: NavigationBarTransition
            ReplaceMethod(clazz, #selector(UINavigationController.pushViewController(_:animated:)), #selector(UINavigationController.NavigationBarTransition_pushViewController(_:animated:)))
            ReplaceMethod(clazz, #selector(UINavigationController.popViewController(animated:)), #selector(UINavigationController.NavigationBarTransition_popViewController(animated:)))
            ReplaceMethod(clazz, #selector(UINavigationController.popToViewController(_:animated:)), #selector(UINavigationController.NavigationBarTransition_popToViewController(_:animated:)))
            ReplaceMethod(clazz, #selector(UINavigationController.popToRootViewController(animated:)), #selector(UINavigationController.NavigationBarTransition_popToRootViewController(animated:)))
        }
    }
}

extension UINavigationController {

    private struct AssociatedKeys {
        static var tmp_topViewController = "tmp_topViewController"
        static var isPushingViewControllerKey = "isPushingViewControllerKey"
        static var isPoppingViewController = "isPoppingViewController"
        static var originGestureDelegateKey = "originGestureDelegateKey"
    }
    
    var tmp_topViewController: UIViewController? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.tmp_topViewController) as? UIViewController
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.tmp_topViewController, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
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

    @objc func qmui_viewDidLoad() {
        qmui_viewDidLoad()

        objc_setAssociatedObject(self, &AssociatedKeys.originGestureDelegateKey, interactivePopGestureRecognizer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        interactivePopGestureRecognizer?.delegate = self
    }

    @objc func qmui_navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
        
        // 如果nav的vc栈中有两个vc，第一个是root，第二个是second。这是second页面如果点击系统的返回按钮，topViewController获取的栈顶vc是second，而如果是直接代码写的pop操作，则获取的栈顶vc是root。也就是说只要代码写了pop操作，则系统会直接将顶层vc也就是second出栈，然后才回调的，所以这时我们获取到的顶层vc就是root了。然而不管哪种方式，参数中的item都是second的item。
        let isPopedByCoding = item != topViewController?.navigationItem
        
        // !isPopedByCoding 要放在前面，这样当 !isPopedByCoding 不满足的时候就不会去询问 canPopViewController 了，可以避免额外调用 canPopViewController 里面的逻辑导致
        let canPop = !isPopedByCoding && canPopViewController(tmp_topViewController ?? topViewController)
        if canPop || isPopedByCoding {
            tmp_topViewController = nil
            return qmui_navigationBar(navigationBar, shouldPop: item)
        } else {
            resetSubviewsInNavBar(navigationBar)
            tmp_topViewController = nil
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
    
    private func canPopViewController(_ viewController: UIViewController?) -> Bool {
        var canPop = true
        
        if let vc = viewController as? UINavigationControllerBackButtonHandlerProtocol, let shouldHoldBackButtonEvent = vc.shouldHoldBackButtonEvent, shouldHoldBackButtonEvent(), let canPopViewController = vc.canPopViewController, !canPopViewController() {
            canPop = false
        }
        
        return canPop
    }
}

extension UINavigationController: UIGestureRecognizerDelegate {
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == interactivePopGestureRecognizer {
            tmp_topViewController = topViewController
            let canPop = canPopViewController(tmp_topViewController)

            if canPop {
                if let originGestureDelegate = objc_getAssociatedObject(self, &AssociatedKeys.originGestureDelegateKey) as? UIGestureRecognizerDelegate, (originGestureDelegate.gestureRecognizerShouldBegin != nil)  {
                    return originGestureDelegate.gestureRecognizerShouldBegin!(gestureRecognizer)
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
        if gestureRecognizer == interactivePopGestureRecognizer {
            if let originGestureDelegate = objc_getAssociatedObject(self, &AssociatedKeys.originGestureDelegateKey) as? UIGestureRecognizerDelegate {
                // 先判断要不要强制开启手势返回
                if viewControllers.count > 1, interactivePopGestureRecognizer?.isEnabled ?? false, let viewController =  topViewController as? UINavigationControllerBackButtonHandlerProtocol,  viewController.forceEnableInterativePopGestureRecognizer != nil, viewController.forceEnableInterativePopGestureRecognizer!() {
                    return true
                }

                // 调用默认实现
                return originGestureDelegate.gestureRecognizer?(gestureRecognizer, shouldReceive: touch) ?? false
            }
        }
        return true
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == interactivePopGestureRecognizer {
            if let originGestureDelegate = objc_getAssociatedObject(self, &AssociatedKeys.originGestureDelegateKey) as? UIGestureRecognizerDelegate {
                return originGestureDelegate.gestureRecognizer?(gestureRecognizer, shouldRecognizeSimultaneouslyWith: otherGestureRecognizer) ?? false
            }
        }
        return false
    }

    // 是否要gestureRecognizer检测失败了，才去检测otherGestureRecognizer
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy _: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == interactivePopGestureRecognizer {
            // 如果只是实现了上面几个手势的delegate，那么返回的手势和当前界面上的scrollview或者其他存在的手势会冲突，所以如果判断是返回手势，则优先响应返回手势再响应其他手势。
            // 不知道为什么，系统竟然没有实现这个delegate，那么它是怎么处理返回手势和其他手势的优先级的
            return true
        }
        return false
    }
}
