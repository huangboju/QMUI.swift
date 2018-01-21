//
//  UINavigationBar+Transition.swift
//  QMUI.swift
//
//  Created by xnxin on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

extension UINavigationBar {
    private struct Keys {
        static var transitionNavigationBarKey = "transitionNavigationBarKey"
    }

    /// 用来模仿真的navBar，配合 UINavigationController+NavigationBarTransition 在转场过程中存在的一条假navBar
    public var transitionNavigationBar: UINavigationBar? {
        set {
            guard let bar = newValue else {
                return
            }
            objc_setAssociatedObject(self, &Keys.transitionNavigationBarKey, bar, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &Keys.transitionNavigationBarKey) as? UINavigationBar
        }
    }

    @objc
    func NavigationBarTransition_setShadowImage(_ image: UIImage) {
        NavigationBarTransition_setShadowImage(image)
        transitionNavigationBar?.shadowImage = image
    }

    @objc
    func NavigationBarTransition_setBarTintColor(_ tintColor: UIColor) {
        NavigationBarTransition_setBarTintColor(tintColor)
        transitionNavigationBar?.barTintColor = tintColor
    }

    @objc
    func NavigationBarTransition_setBackgroundImage(_ backgroundImage: UIImage, for barMetrics: UIBarMetrics) {
        NavigationBarTransition_setBackgroundImage(backgroundImage, for: barMetrics)
        transitionNavigationBar?.setBackgroundImage(backgroundImage, for: barMetrics)
    }
}
