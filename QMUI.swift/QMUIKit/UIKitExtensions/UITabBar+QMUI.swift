//
//  UITabBar+QMUI.swift
//  QMUI.swift
//
//  Created by xnxin on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//
extension UITabBar: SelfAware2 {
    
    // MARK: TODO 比较奇怪，UITabBar 无法执行，在 harmlessFunction 遍历类时竟然没有实现 SelfAware2

    private static let kLastTouchedTabBarItemIndexNone = -1

    private static let _onceToken = UUID().uuidString

    static func awake2() {
        DispatchQueue.once(token: _onceToken) {
            let clazz = UITabBar.self
            
            let selectors = [
                #selector(setItems(_:animated:)),
                #selector(setter: selectedItem),
                #selector(setter: frame),
            ]
            let qmui_selectors = [
                #selector(UITabBar.qmui_setItems(_:animated:)),
                #selector(UITabBar.qmui_setSelectedItem(_:)),
                #selector(UITabBar.qmui_setFrame(_:)),
                ]
            for index in 0..<selectors.count {
                ReplaceMethod(clazz, selectors[index], qmui_selectors[index])
            }
            
            if #available(iOS 11, *) {
                let selectors = [
                    #selector(setter: backgroundImage),
                    #selector(setter: isTranslucent),
                    #selector(setter: isHidden),
                    #selector(setter: frame),
                    ]
                let qmui_selectors = [
                    #selector(UITabBar.qmui_setBackgroundImage),
                    #selector(UITabBar.qmui_setTranslucent),
                    #selector(UITabBar.qmui_setHidden),
                    #selector(UITabBar.qmui_nav_setFrame(_:)),
                    ]
                for index in 0..<selectors.count {
                    ReplaceMethod(clazz, selectors[index], qmui_selectors[index])
                }
            }
        }
    }

    @objc func qmui_setItems(_ items: [UITabBarItem]?, animated: Bool) {
        qmui_setItems(items, animated: animated)

        items?.forEach({
            if let itemView = $0.qmui_barButton() {
                itemView.addTarget(self, action: #selector(handleTabBarItemViewEvent(_:)), for: .touchUpInside)
            }
        })
    }

    @objc func qmui_setSelectedItem(_ selectedItem: UITabBarItem?) {
        guard let selectedItem = selectedItem, let items = self.items else { return }
        var olderSelectedIndex = -1
        if self.selectedItem != nil {
            olderSelectedIndex = items.firstIndex(of: selectedItem) ?? -1
        }
        qmui_setSelectedItem(selectedItem)
        let newerSelectedIndex = Int(items.firstIndex(of: selectedItem) ?? -1)
        // 只有双击当前正在显示的界面的 tabBarItem，才能正常触发双击事件
        canItemRespondDoubleTouch = olderSelectedIndex == newerSelectedIndex
    }

    @objc func qmui_setFrame(_ frame: CGRect) {
        var newFrame = frame
        if IOS_VERSION < 11.2 && IS_58INCH_SCREEN && ShouldFixTabBarTransitionBugInIPhoneX {
            if frame.height == TabBarHeight && frame.maxY < superview?.bounds.height ?? 0 {
                // iOS 11 在界面 push 的过程中 tabBar 会瞬间往上跳，所以做这个修复。这个 bug 在 iOS 11.2 里已被系统修复。
                // https://github.com/QMUI/QMUI_iOS/issues/217
                newFrame = newFrame.setY(superview?.bounds.height ?? 0 - newFrame.height)
            }
        }
        qmui_setFrame(newFrame)
    }
    
    @objc func qmui_setBackgroundImage(_ image: UIImage?) {
        let shouldNotify = self.backgroundImage != image
        qmui_setBackgroundImage(image)
        if shouldNotify {
            NotificationCenter.default.post(name: Notification.QMUI.TabBarStyleChanged, object: self)
        }
    }
    
    @objc func qmui_setTranslucent(_ translucent: Bool) {
        let shouldNotify = self.isTranslucent != translucent
        qmui_setTranslucent(translucent)
        if shouldNotify {
            NotificationCenter.default.post(name: Notification.QMUI.TabBarStyleChanged, object: self)
        }
    }
    
    @objc func qmui_setHidden(_ hidden: Bool) {
        let shouldNotify = self.isHidden != hidden
        qmui_setHidden(hidden)
        if shouldNotify {
            NotificationCenter.default.post(name: Notification.QMUI.TabBarStyleChanged, object: self)
        }
    }
    
    @objc func qmui_nav_setFrame(_ frame: CGRect) {
        let shouldNotify = self.frame.minY != frame.minY
        qmui_nav_setFrame(frame)
        if shouldNotify {
            NotificationCenter.default.post(name: Notification.QMUI.TabBarStyleChanged, object: self)
        }
    }

    @objc private func handleTabBarItemViewEvent(_: UIControl) {
        if !canItemRespondDoubleTouch {
            return
        }
        guard let qmui_doubleTapClosure = selectedItem?.qmui_doubleTapClosure else {
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.revertTabBarItemTouch()
        }

        guard let selectedIndex = items?.firstIndex(of: selectedItem!) else {
            return
        }
        if lastTouchedTabBarItemViewIndex == UITabBar.kLastTouchedTabBarItemIndexNone {
            // 记录第一次点击的 index
            lastTouchedTabBarItemViewIndex = selectedIndex
        } else if lastTouchedTabBarItemViewIndex != selectedIndex {
            // 后续的点击如果与第一次点击的 index 不一致，则认为是重新开始一次新的点击
            revertTabBarItemTouch()
            lastTouchedTabBarItemViewIndex = selectedIndex
            return
        }

        tabBarItemViewTouchCount += 1
        if tabBarItemViewTouchCount == 2 {
            // 第二次点击了相同的 tabBarItem，触发双击事件
            if let item = items?[selectedIndex] {
                qmui_doubleTapClosure(item, selectedIndex)
            }
            revertTabBarItemTouch()
        }
    }

    private func revertTabBarItemTouch() {
        lastTouchedTabBarItemViewIndex = UITabBar.kLastTouchedTabBarItemIndexNone
        tabBarItemViewTouchCount = 0
    }

    private struct AssociatedKeys {
        static var kCanItemRespondDoubleTouch = "kCanItemRespondDoubleTouch"
        static var kLastTouchedTabBarItemViewIndex = "kLastTouchedTabBarItemViewIndex"
        static var kTabBarItemViewTouchCount = "kTabBarItemViewTouchCount"
    }

    fileprivate var canItemRespondDoubleTouch: Bool {
        get {
            guard let canItemRespondDoubleTouch = objc_getAssociatedObject(self, &AssociatedKeys.kCanItemRespondDoubleTouch) else {
                return false
            }
            return canItemRespondDoubleTouch as! Bool
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.kCanItemRespondDoubleTouch, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    fileprivate var lastTouchedTabBarItemViewIndex: Int {
        get {
            guard let lastTouchedTabBarItemViewIndex = objc_getAssociatedObject(self, &AssociatedKeys.kLastTouchedTabBarItemViewIndex) else {
                return UITabBar.kLastTouchedTabBarItemIndexNone
            }
            return lastTouchedTabBarItemViewIndex as! Int
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.kLastTouchedTabBarItemViewIndex, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    fileprivate var tabBarItemViewTouchCount: Int {
        get {
            guard let tabBarItemViewTouchCount = objc_getAssociatedObject(self, &AssociatedKeys.kTabBarItemViewTouchCount) else {
                return 0
            }
            return tabBarItemViewTouchCount as! Int
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.kTabBarItemViewTouchCount, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
