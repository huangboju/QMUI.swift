//
//  UITabBar+QMUI.swift
//  QMUI.swift
//
//  Created by xnxin on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

extension UITabBar: SelfAware2 {

    private static let kLastTouchedTabBarItemIndexNone = -1

    private static let _onceToken = UUID().uuidString

    static func awake2() {
        DispatchQueue.once(token: _onceToken) {
            let clazz = UITabBar.self
            
            let selectors = [
                #selector(setItems(_:animated:)),
                #selector(setter: selectedItem),
                #selector(setter: frame),
                #selector(setter: backgroundImage),
                #selector(setter: isTranslucent),
                #selector(setter: isHidden),
            ]
            selectors.forEach({
                //                print("qmui_" + $0.description)
                ReplaceMethod(clazz, $0, Selector("qmui_" + $0.description))
            })
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
            olderSelectedIndex = items.index(of: selectedItem) ?? -1
        }
        qmui_setSelectedItem(selectedItem)
        let newerSelectedIndex = Int(items.index(of: selectedItem) ?? -1)
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

        guard let selectedIndex = items?.index(of: selectedItem!) else {
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

    public var canItemRespondDoubleTouch: Bool {
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

    public var lastTouchedTabBarItemViewIndex: Int {
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

    public var tabBarItemViewTouchCount: Int {
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
