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
    // TODO: - 这里有几个swizzle
}

/**
 *  为了响应<b>NavigationBarTransition</b>分类的功能，UIViewController需要做一些相应的支持。
 *  @see UINavigationController+NavigationBarTransition.h
 */
// NavigationBarTransition
extension UIViewController {
    // TODO: - 这里还有几个Method Swizzle需要做

    private struct Keys {
        static var transitionNavigationBar = "transitionNavigationBar"
        static var prefersNavigationBarBackgroundViewHidden = "prefersNavigationBarBackgroundViewHidden"
        static var lockTransitionNavigationBar = "lockTransitionNavigationBar"
        static var willAppearInjectBlock = "willAppearInjectBlock"
        static var originClipsToBounds = "originClipsToBounds"
        static var originContainerViewBackgroundColor = "originContainerViewBackgroundColor"
    }

    /// 用来模仿真的navBar的，在转场过程中存在的一条假navBar
    public var transitionNavigationBar: _QMUITransitionNavigationBar {
        set {
            objc_setAssociatedObject(self, &Keys.transitionNavigationBar, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return (objc_getAssociatedObject(self, &Keys.transitionNavigationBar) as? _QMUITransitionNavigationBar) ?? _QMUITransitionNavigationBar()
        }
    }

    /// 是否要把真的navBar隐藏
    public var prefersNavigationBarBackgroundViewHidden: Bool {
        set {
            (navigationController?.navigationBar.value(forKey: "backgroundView") as? UIView)?.isHidden = newValue
            objc_setAssociatedObject(self, &Keys.prefersNavigationBarBackgroundViewHidden, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return (objc_getAssociatedObject(self, &Keys.prefersNavigationBarBackgroundViewHidden) as? Bool) ?? false
        }
    }

    /// 原始的clipsToBounds
    public var originClipsToBounds: Bool {
        set {
            objc_setAssociatedObject(self, &Keys.originClipsToBounds, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return (objc_getAssociatedObject(self, &Keys.originClipsToBounds) as? Bool) ?? false
        }
    }

    /// 原始containerView的背景色
    public var originContainerViewBackgroundColor: UIColor? {
        set {
            objc_setAssociatedObject(self, &Keys.originContainerViewBackgroundColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return (objc_getAssociatedObject(self, &Keys.originContainerViewBackgroundColor) as? UIColor) ?? nil
        }
    }

    /// 用于插入到fromVC和toVC的block
    public typealias navigationBarTransitionWillAppearInjectBlock = (_ viewController: UIViewController, _ animated: Bool) -> Void
    public var willAppearInjectBlock: navigationBarTransitionWillAppearInjectBlock? {
        set {
            objc_setAssociatedObject(self, &Keys.willAppearInjectBlock, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        get {
            return (objc_getAssociatedObject(self, &Keys.willAppearInjectBlock) as? navigationBarTransitionWillAppearInjectBlock) ?? nil
        }
    }

    /// 添加假的navBar
    public func addTransitionNavigationBarIfNeeded() {
        guard let originBar = self.navigationController?.navigationBar, let _ = self.view.window else {
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
                backgroundImage = UIImage.qmui_image(withColor: UIColorClear) ?? UIImage()
            }

            customBar.setBackgroundImage(backgroundImage, for: .default)
            customBar.shadowImage = originBar.shadowImage
        }

        transitionNavigationBar = customBar
        resizeTransitionNavigationBarFrame()

        if navigationController?.isNavigationBarHidden ?? false {
            view.addSubview(transitionNavigationBar)
        }
    }

    /// .m文件里自己赋值和使用。因为有些特殊情况下viewDidAppear之后，有可能还会调用到viewWillLayoutSubviews，导致原始的navBar隐藏，所以用这个属性做个保护。
    var lockTransitionNavigationBar: Bool {
        set {
            objc_setAssociatedObject(self, &Keys.lockTransitionNavigationBar, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return (objc_getAssociatedObject(self, &Keys.lockTransitionNavigationBar) as? Bool) ?? false
        }
    }

    private func resizeTransitionNavigationBarFrame() {
        guard view.window != nil else {
            return
        }

        if let backgroundView = self.navigationController?.navigationBar.value(forKey: "backgroundView") as? UIView {
            let rect = backgroundView.superview?.convert(backgroundView.frame, to: view) ?? .zero
            transitionNavigationBar.frame = rect
        }
    }
}

public class _QMUITransitionNavigationBar: UINavigationBar {
    public override func layoutSubviews() {
        super.layoutSubviews()
        // iOS 11 以前，自己 init 的 navigationBar，它的 backgroundView 默认会一直保持与 navigationBar 的高度相等，但 iOS 11 Beta1 里，自己 init 的 navigationBar.backgroundView.height 默认一直是 44，所以才加上这个兼容
        if IOS_VERSION >= 11.0 {
            if let backgroundView = self.value(forKey: "backgroundView") as? UIView {
                backgroundView.frame = bounds
                setValue(backgroundView, forKey: "backgroundView")
            }
        }
    }
}
