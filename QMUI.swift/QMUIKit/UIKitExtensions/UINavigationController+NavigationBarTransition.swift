//
//  UINavigationController+NavigationBarTransition.swift
//  QMUI.swift
//
//  Created by xnxin on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

/**
 *  因为系统的UINavigationController只有一个navBar，所以会导致在切换controller的时候，如果两个controller的navBar状态不一致（包括backgroundImgae、shadowImage、barTintColor等等），就会导致在刚要切换的瞬间，navBar的状态都立马变成下一个controller所设置的样式了，为了解决这种情况，QMUI给出了一个方案，有四个方法可以决定你在转场的时候要不要使用自定义的navBar来模仿真实的navBar。
 */
// NavigationBarTransition
extension UINavigationController {
    
    @objc func NavigationBarTransition_pushViewController(_ viewController: UIViewController, animated: Bool) {
        guard let disappearingViewController = viewControllers.last else {
            NavigationBarTransition_pushViewController(viewController, animated: animated)
            return
        }
        
        var shouldCustomNavigationBarTransition = false
        if disappearingViewController.canCustomNavigationBarTransitionWhenPushDisappearing {
            shouldCustomNavigationBarTransition = true
        }
        if !shouldCustomNavigationBarTransition && viewController.canCustomNavigationBarTransitionWhenPushAppearing {
            shouldCustomNavigationBarTransition = true
        }
        if shouldCustomNavigationBarTransition {
            disappearingViewController.addTransitionNavigationBarIfNeeded()
            disappearingViewController.prefersNavigationBarBackgroundViewHidden = true
        }
        NavigationBarTransition_pushViewController(viewController, animated: animated)
    }
    
    @objc func NavigationBarTransition_popViewController(animated: Bool) -> UIViewController? {
        guard let disappearingViewController = viewControllers.last else {
            return NavigationBarTransition_popViewController(animated:animated)
        }
        let appearingViewController = viewControllers.count >= 2 ? viewControllers[viewControllers.count - 2] : nil
        handlePopViewControllerNavigationBarTransition(with: disappearingViewController, appearViewController: appearingViewController)
        return NavigationBarTransition_popViewController(animated:animated)
    }
    
    @objc func NavigationBarTransition_popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        let disappearingViewController = viewControllers.last
        let appearingViewController = viewController
        if let poppedViewControllers = NavigationBarTransition_popToViewController(viewController, animated: animated) {
            handlePopViewControllerNavigationBarTransition(with: disappearingViewController, appearViewController: appearingViewController)
            return poppedViewControllers
        }
        return nil
    }
    
    @objc func NavigationBarTransition_popToRootViewController(animated: Bool) -> [UIViewController]? {
        let poppedViewControllers = NavigationBarTransition_popToRootViewController(animated: animated)
        if viewControllers.count > 1 {
            let disappearingViewController = viewControllers.last
            let appearingViewController = viewControllers.first
            if let poppedViewControllers = poppedViewControllers {
                handlePopViewControllerNavigationBarTransition(with: disappearingViewController, appearViewController: appearingViewController)
                return poppedViewControllers
            }
        }
        return nil
    }
    
    private func handlePopViewControllerNavigationBarTransition(with disappearViewController: UIViewController?, appearViewController: UIViewController?) {
        var shouldCustomNavigationBarTransition = false
        if let disappearViewController = disappearViewController, disappearViewController.canCustomNavigationBarTransitionWhenPopDisappearing {
            shouldCustomNavigationBarTransition = true
        }
        if let appearViewController = appearViewController, !shouldCustomNavigationBarTransition, appearViewController.canCustomNavigationBarTransitionWhenPopAppearing {
            shouldCustomNavigationBarTransition = true
        }
        if shouldCustomNavigationBarTransition {
            disappearViewController?.addTransitionNavigationBarIfNeeded()
            if let transitionNavigationBar = appearViewController?.transitionNavigationBar {
                // 假设从A→B→C，其中A设置了bar的样式，B跟随A所以B里没有设置bar样式的代码，C又把样式改为另一种，此时从C返回B时，由于B没有设置bar的样式的代码，所以bar的样式依然会保留C的，这就错了，所以每次都要手动改回来才保险
                UIViewController.replaceStyle(for: transitionNavigationBar, with: navigationBar)
            }
            disappearViewController?.prefersNavigationBarBackgroundViewHidden = true
        }
    }
}

/**
 *  为了响应<b>NavigationBarTransition</b>分类的功能，UIViewController需要做一些相应的支持。
 *  @see UINavigationController+NavigationBarTransition.h
 */
// NavigationBarTransition
extension UIViewController {
    
    @objc func NavigationBarTransition_viewWillLayoutSubviews() {
        if let transitionCoordinator = self.transitionCoordinator {
            let fromViewController = transitionCoordinator.viewController(forKey: UITransitionContextViewControllerKey.from)
            let toViewController = transitionCoordinator.viewController(forKey: UITransitionContextViewControllerKey.to)
            
            let isCurrentToViewController = (self == navigationController?.viewControllers.last) && (self == toViewController)
            let isPushingViewContrller = fromViewController != nil && navigationController != nil && navigationController!.viewControllers.contains(fromViewController!)
            if isCurrentToViewController && !lockTransitionNavigationBar, let toViewController = toViewController, let fromViewController = fromViewController {
                var shouldCustomNavigationBarTransition = false
                if transitionNavigationBar == nil {
                    if isPushingViewContrller {
                        if toViewController.canCustomNavigationBarTransitionWhenPushAppearing || fromViewController.canCustomNavigationBarTransitionWhenPushDisappearing {
                            shouldCustomNavigationBarTransition = true
                        }
                    } else {
                        if toViewController.canCustomNavigationBarTransitionWhenPopAppearing || fromViewController.canCustomNavigationBarTransitionWhenPopDisappearing {
                            shouldCustomNavigationBarTransition = true
                        }
                    }
                }
                if shouldCustomNavigationBarTransition {
                    if let navigationBar = navigationController?.navigationBar, navigationBar.isTranslucent {
                        // 如果原生bar是半透明的，需要给containerView加个背景色，否则有可能会看到下面的默认黑色背景色
                        toViewController.originContainerViewBackgroundColor = transitionCoordinator.containerView.backgroundColor
                        transitionCoordinator.containerView.backgroundColor = containerViewBackgroundColor
                    }
                    fromViewController.originClipsToBounds = fromViewController.view.clipsToBounds
                    toViewController.originClipsToBounds = toViewController.view.clipsToBounds
                    fromViewController.view.clipsToBounds = false
                    toViewController.view.clipsToBounds = false
                    addTransitionNavigationBarIfNeeded()
                    resizeTransitionNavigationBarFrame()
                    navigationController?.navigationBar.transitionNavigationBar = transitionNavigationBar
                    prefersNavigationBarBackgroundViewHidden = true
                }
            }
        }
        NavigationBarTransition_viewWillLayoutSubviews()
    }
    
    @objc func NavigationBarTransition_viewWillAppear(_ animated: Bool) {
        // 放在最前面，留一个时机给业务可以覆盖
        renderNavigationStyle(inViewController: self, animated: animated)
        NavigationBarTransition_viewWillAppear(animated)
    }
    
    @objc func NavigationBarTransition_viewDidAppear(_ animated: Bool) {
        if let transitionNavigationBar = transitionNavigationBar, let navigationController = navigationController {
            UIViewController.replaceStyle(for: transitionNavigationBar, with: navigationController.navigationBar)
            removeTransitionNavigationBar()
            lockTransitionNavigationBar = true
            let transitionCoordinator = self.transitionCoordinator
            transitionCoordinator?.containerView.backgroundColor = originContainerViewBackgroundColor
            view.clipsToBounds = originClipsToBounds
        }
        prefersNavigationBarBackgroundViewHidden = false
        NavigationBarTransition_viewDidAppear(animated)
    }
    
    @objc func NavigationBarTransition_viewDidDisappear(_ animated: Bool) {
        if let _ = transitionNavigationBar {
            removeTransitionNavigationBar()
            lockTransitionNavigationBar = false
            
            view.clipsToBounds = originClipsToBounds;
        }
        NavigationBarTransition_viewDidDisappear(animated)
    }
    
    /// 添加假的navBar
    fileprivate func addTransitionNavigationBarIfNeeded() {
        guard let originBar = navigationController?.navigationBar, let _ = view.window else {
            return
        }
        
        let customBar = _QMUITransitionNavigationBar()
        
        if customBar.barStyle != originBar.barStyle {
            customBar.barStyle = originBar.barStyle
        }
        if customBar.isTranslucent != originBar.isTranslucent {
            customBar.isTranslucent = originBar.isTranslucent
        }
        if customBar.barTintColor != originBar.barTintColor {
            customBar.barTintColor = originBar.barTintColor
        }
        
        if var backgroundImage = originBar.backgroundImage(for: .default) {
            if backgroundImage.size == .zero {
                // 假设这里的图片时通过`[UIImage new]`这种形式创建的，那么会navBar会奇怪地显示为系统默认navBar的样式。不知道为什么 navController 设置自己的 navBar 为 [UIImage new] 却没事，所以这里做个保护。
                backgroundImage = UIImage.qmui_image(color: UIColorClear) ?? UIImage()
            }
            
            customBar.setBackgroundImage(backgroundImage, for: .default)
            customBar.shadowImage = originBar.shadowImage
        }
        
        transitionNavigationBar = customBar
        resizeTransitionNavigationBarFrame()
        
        if !navigationController!.isNavigationBarHidden {
            view.addSubview(transitionNavigationBar!)
        }
    }
    
    private func removeTransitionNavigationBar() {
        if transitionNavigationBar == nil {
            return
        }
        transitionNavigationBar!.removeFromSuperview()
        transitionNavigationBar = nil
    }
    
    private func resizeTransitionNavigationBarFrame() {
        guard view.window != nil else {
            return
        }
        
        if let backgroundView = navigationController?.navigationBar.value(forKey: "backgroundView") as? UIView {
            let rect = backgroundView.superview?.convert(backgroundView.frame, to: view) ?? .zero
            transitionNavigationBar?.frame = rect
        }
    }
    
    // MARK: 工具方法
    // 根据当前的viewController，统一处理导航栏底部的分隔线、状态栏的颜色
    private func renderNavigationStyle(inViewController viewController: UIViewController, animated: Bool) {
        // 针对一个 container view controller 里面包含了若干个 view controller，这总情况里面的 view controller 也会相应这个 render 方法，这样就会覆盖 container view controller 的设置，所以应该规避这种情况。
        if viewController != viewController.navigationController?.topViewController {
            return
        }
        
        // 以下用于控制 vc 的外观样式，如果某个方法有实现则用方法的返回值，否则再看配置表对应的值是否有配置，有配置就使用配置表，没配置则什么都不做，维持系统原生样式
        if let vc = viewController as? QMUINavigationControllerAppearanceDelegate {
            // 控制界面的状态栏颜色
            if let shouldSetStatusBarStyleLight = vc.shouldSetStatusBarStyleLight, shouldSetStatusBarStyleLight {
                if UIApplication.shared.statusBarStyle.rawValue < UIStatusBarStyle.lightContent.rawValue {
                    QMUIHelper.renderStatusBarStyleLight()
                }
            } else {
                if UIApplication.shared.statusBarStyle.rawValue >= UIStatusBarStyle.lightContent.rawValue {
                    QMUIHelper.renderStatusBarStyleDark()
                }
            }
            
            guard let navigationController = viewController.navigationController else { return }
            let navigationBar = navigationController.navigationBar
            
            // 显示/隐藏 导航栏
            if viewController.canCustomNavigationBarTransitionIfBarHiddenable {
                if viewController.hideNavigationBarWhenTransitioning {
                    if !navigationController.isNavigationBarHidden {
                        navigationController.setNavigationBarHidden(true, animated: animated)
                    }
                } else {
                    if navigationController.isNavigationBarHidden {
                        navigationController.setNavigationBarHidden(false, animated: animated)
                    }
                }
            }
            
            // 导航栏的背景
            if let backgroundImage = vc.navigationBarBackgroundImage {
                navigationBar.setBackgroundImage(backgroundImage, for: .default)
            } else {
                if let backgroundImage = NavBarBackgroundImage {
                    navigationBar.setBackgroundImage(backgroundImage, for: .default)
                }
            }
            
            // 导航栏底部的分隔线
            if let navigationBarShadowImage = vc.navigationBarShadowImage {
                if let shadowImage = navigationBarShadowImage {
                    navigationBar.shadowImage = shadowImage
                }
            } else {
                if let shadowImage = NavBarShadowImage {
                    navigationBar.shadowImage = shadowImage
                }
            }
            
            // 导航栏上控件的主题色
            if let navigationBarTintColor = vc.navigationBarTintColor {
                if let tintColor = navigationBarTintColor {
                    navigationBar.tintColor = tintColor
                }
            } else {
                if let tintColor = NavBarTintColor {
                    navigationBar.tintColor = tintColor
                }
            }
            
            // 导航栏title的颜色
            if let titleViewTintColor = vc.titleViewTintColor {
                if let tintColor = titleViewTintColor, let vc = vc as? QMUICommonViewController {
                    vc.titleView.tintColor = tintColor
                } else {
                    // MARK: TODO 对 UIViewController 也支持修改 title 颜色
                }
            } else {
                if let tintColor = NavBarTitleColor, let vc = vc as? QMUICommonViewController{
                    vc.titleView.tintColor = tintColor
                } else {
                    // MARK: TODO 对 UIViewController 也支持修改 title 颜色
                }
            }
        }
    }
    
    // 该 viewController 是否实现自定义 navBar 动画的协议
    
    fileprivate static func replaceStyle(for navbarA: UINavigationBar, with navbarB: UINavigationBar) {
        navbarB.barStyle = navbarA.barStyle
        navbarB.barTintColor = navbarA.barTintColor
        navbarB.setBackgroundImage(navbarA.backgroundImage(for: .default), for: .default)
        navbarB.shadowImage = navbarA.shadowImage
    }
    
    private var respondCustomNavigationBarTransitionWhenPushAppearing: Bool {
        var respondPushAppearing = false
        if let vc = self as? QMUICustomNavigationBarTransitionDelegate, let shouldCustomNavigationBarTransitionWhenPushAppearing = vc.shouldCustomNavigationBarTransitionWhenPushAppearing, shouldCustomNavigationBarTransitionWhenPushAppearing {
            respondPushAppearing = true
        }
        return respondPushAppearing
    }
    
    private var respondCustomNavigationBarTransitionWhenPushDisappearing: Bool {
        var respondPushDisappearing = false
        if let vc = self as? QMUICustomNavigationBarTransitionDelegate, let shouldCustomNavigationBarTransitionWhenPushDisappearing = vc.shouldCustomNavigationBarTransitionWhenPushDisappearing, shouldCustomNavigationBarTransitionWhenPushDisappearing {
            respondPushDisappearing = true
        }
        return respondPushDisappearing
    }
    
    private var respondCustomNavigationBarTransitionWhenPopAppearing: Bool {
        var respondPopAppearing = false
        if let vc = self as? QMUICustomNavigationBarTransitionDelegate, let shouldCustomNavigationBarTransitionWhenPopAppearing = vc.shouldCustomNavigationBarTransitionWhenPopAppearing, shouldCustomNavigationBarTransitionWhenPopAppearing {
            respondPopAppearing = true
        }
        return respondPopAppearing
    }
    
    private var respondCustomNavigationBarTransitionWhenPopDisappearing: Bool {
        var respondPopDisappearing = false
        if let vc = self as? QMUICustomNavigationBarTransitionDelegate, let shouldCustomNavigationBarTransitionWhenPopDisappearing = vc.shouldCustomNavigationBarTransitionWhenPopDisappearing, shouldCustomNavigationBarTransitionWhenPopDisappearing {
            respondPopDisappearing = true
        }
        return respondPopDisappearing
    }
    
    private var respondCustomNavigationBarTransitionIfBarHiddenable: Bool {
        var respondIfBarHiddenable = false
        if let vc = self as? QMUICustomNavigationBarTransitionDelegate, let shouldCustomizeNavigationBarTransitionIfHideable = vc.shouldCustomizeNavigationBarTransitionIfHideable, shouldCustomizeNavigationBarTransitionIfHideable {
            respondIfBarHiddenable = true
        }
        return respondIfBarHiddenable
    }
    
    private var respondCustomNavigationBarTransitionWithBarHiddenState: Bool {
        var respondWithBarHidden = false
        if let vc = self as? QMUICustomNavigationBarTransitionDelegate, let preferredNavigationBarHidden = vc.preferredNavigationBarHidden, preferredNavigationBarHidden {
            respondWithBarHidden = true
        }
        return respondWithBarHidden
    }
    
    // 该 viewController 实现自定义 navBar 动画的协议的返回值
    
    fileprivate var canCustomNavigationBarTransitionWhenPushAppearing: Bool {
        if respondCustomNavigationBarTransitionWhenPushAppearing, let vc = self as? QMUICustomNavigationBarTransitionDelegate {
            return vc.shouldCustomNavigationBarTransitionWhenPushAppearing ?? false
        }
        return false
    }
    
    fileprivate var canCustomNavigationBarTransitionWhenPushDisappearing: Bool {
        if respondCustomNavigationBarTransitionWhenPushDisappearing, let vc = self as? QMUICustomNavigationBarTransitionDelegate {
            return vc.shouldCustomNavigationBarTransitionWhenPushDisappearing ?? false
        }
        return false
    }
    
    fileprivate var canCustomNavigationBarTransitionWhenPopAppearing: Bool {
        if respondCustomNavigationBarTransitionWhenPopAppearing, let vc = self as? QMUICustomNavigationBarTransitionDelegate {
            return vc.shouldCustomNavigationBarTransitionWhenPopAppearing ?? false
        }
        return false
    }
    
    fileprivate var canCustomNavigationBarTransitionWhenPopDisappearing: Bool {
        if respondCustomNavigationBarTransitionWhenPopDisappearing, let vc = self as? QMUICustomNavigationBarTransitionDelegate {
            return vc.shouldCustomNavigationBarTransitionWhenPopDisappearing ?? false
        }
        return false
    }
    
    private var canCustomNavigationBarTransitionIfBarHiddenable: Bool {
        if respondCustomNavigationBarTransitionIfBarHiddenable, let vc = self as? QMUICustomNavigationBarTransitionDelegate {
            return vc.shouldCustomizeNavigationBarTransitionIfHideable ?? false
        }
        return false
    }
    
    private var hideNavigationBarWhenTransitioning: Bool {
        if respondCustomNavigationBarTransitionWithBarHiddenState, let vc = self as? QMUICustomNavigationBarTransitionDelegate {
            return vc.preferredNavigationBarHidden ?? false
        }
        return false
    }
    
    private var containerViewBackgroundColor: UIColor {
        var backgroundColor = UIColorWhite
        if let delegate = self as? QMUICustomNavigationBarTransitionDelegate, let color = delegate.containerViewBackgroundColorWhenTransitioning {
            backgroundColor = color ?? backgroundColor
        }
        return backgroundColor
    }
    
}


extension UIViewController {
    
    private struct Keys {
        static var transitionNavigationBar = "transitionNavigationBar"
        static var prefersNavigationBarBackgroundViewHidden = "prefersNavigationBarBackgroundViewHidden"
        static var lockTransitionNavigationBar = "lockTransitionNavigationBar"
        static var originClipsToBounds = "originClipsToBounds"
        static var originContainerViewBackgroundColor = "originContainerViewBackgroundColor"
    }

    /// 用来模仿真的navBar的，在转场过程中存在的一条假navBar
    var transitionNavigationBar: _QMUITransitionNavigationBar? {
        set {
            objc_setAssociatedObject(self, &Keys.transitionNavigationBar, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &Keys.transitionNavigationBar) as? _QMUITransitionNavigationBar
        }
    }

    /// 是否要把真的navBar隐藏
    fileprivate var prefersNavigationBarBackgroundViewHidden: Bool {
        set {
            (navigationController?.navigationBar.value(forKey: "backgroundView") as? UIView)?.isHidden = newValue
            objc_setAssociatedObject(self, &Keys.prefersNavigationBarBackgroundViewHidden, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return (objc_getAssociatedObject(self, &Keys.prefersNavigationBarBackgroundViewHidden) as? Bool) ?? false
        }
    }

    /// 原始的clipsToBounds
    fileprivate var originClipsToBounds: Bool {
        set {
            objc_setAssociatedObject(self, &Keys.originClipsToBounds, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return (objc_getAssociatedObject(self, &Keys.originClipsToBounds) as? Bool) ?? false
        }
    }

    /// 原始containerView的背景色
    fileprivate var originContainerViewBackgroundColor: UIColor? {
        set {
            objc_setAssociatedObject(self, &Keys.originContainerViewBackgroundColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &Keys.originContainerViewBackgroundColor) as? UIColor
        }
    }

    /// .m文件里自己赋值和使用。因为有些特殊情况下viewDidAppear之后，有可能还会调用到viewWillLayoutSubviews，导致原始的navBar隐藏，所以用这个属性做个保护。
    fileprivate var lockTransitionNavigationBar: Bool {
        set {
            objc_setAssociatedObject(self, &Keys.lockTransitionNavigationBar, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return (objc_getAssociatedObject(self, &Keys.lockTransitionNavigationBar) as? Bool) ?? false
        }
    }
}

class _QMUITransitionNavigationBar: UINavigationBar {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // iOS 11 以前，自己 init 的 navigationBar，它的 backgroundView 默认会一直保持与 navigationBar 的高度相等，但 iOS 11 Beta1 里，自己 init 的 navigationBar.backgroundView.height 默认一直是 44，所以才加上这个兼容
        if IOS_VERSION >= 11.0 {
            if let backgroundView = value(forKey: "backgroundView") as? UIView {
                backgroundView.frame = bounds
            }
        }
    }
}
