//
//  UITabBarItem+QMUI.swift
//  QMUI.swift
//
//  Created by xnxin on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

import Foundation

extension UITabBarItem {

    private struct AssociatedKeys {
        static var kDoubleTapBlock = "kDoubleTapBlock"
    }

    typealias Qmui_doubleTapClosureType = (_ tabBarItem: UITabBarItem, _ index: Int) -> Void?

    /**
     *  双击 tabBarItem 时的回调，默认为 nil。
     *  @arg tabBarItem 被双击的 UITabBarItem
     *  @arg index      被双击的 UITabBarItem 的序号
     */
    var qmui_doubleTapClosure: Qmui_doubleTapClosureType? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.kDoubleTapBlock) as? Qmui_doubleTapClosureType
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.kDoubleTapBlock, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }

    /**
     * 获取一个UITabBarItem内的按钮，里面包含imageView、label等子View
     */
    func qmui_barButton() -> UIControl? {
        return value(forKey: "view") as? UIControl
    }

    /**
     * 获取一个UITabBarItem内显示图标的UIImageView，如果找不到则返回nil
     * @warning 需要对nil的返回值做保护
     */
    func qmui_imageView() -> UIImageView? {
        guard let barButton = qmui_barButton() else {
            return nil
        }

        var result: UIImageView?

        barButton.subviews.forEach {
            // iOS10及以后，imageView都是用UITabBarSwappableImageView实现的，所以遇到这个class就直接拿
            if String(describing: type(of: $0)).isEqual("UITabBarSwappableImageView") {
                result = $0 as? UIImageView
            }

            if IOS_VERSION < 10 {
                // iOS10以前，选中的item的高亮是用UITabBarSelectionIndicatorView实现的，所以要屏蔽掉
                if $0 is UIImageView && String(describing: type(of: $0)).isEqual("UITabBarSelectionIndicatorView") {
                    result = $0 as? UIImageView
                }
            }
        }

        return result
    }
}
