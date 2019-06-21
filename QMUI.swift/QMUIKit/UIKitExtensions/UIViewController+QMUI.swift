//
//  UIViewController+QMUI.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/3/21.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

extension Notification {
    class QMUI {
        /// 当主题发生变化时，会发送这个通知
        static let TabBarStyleChanged = Notification.Name("Notification.QMUI.TabBarStyleChanged")
    }
}

extension UIViewController: SelfAware {
    private static let _onceToken = UUID().uuidString
    
    static func awake() {
        DispatchQueue.once(token: _onceToken) {
            let clazz = UIViewController.self
            
            // 为 description 增加更丰富的信息
            ReplaceMethod(clazz, #selector(description), #selector(qmui_description))
            
            // 兼容 iOS 9.0 以下的版本对 loadViewIfNeeded 方法的调用
            // MARK: TODO
            
            // 修复 iOS 11 scrollView 无法自动适配不透明的 tabBar，导致底部 inset 错误的问题
            // https://github.com/QMUI/QMUI_iOS/issues/218
            ReplaceMethod(clazz, #selector(UIViewController.viewDidLoad), #selector(UIViewController.qmui_UIViewController_viewDidLoad))
            
            // 实现 AutomaticallyRotateDeviceOrientation 开关的功能
            ReplaceMethod(clazz, #selector(viewWillAppear(_:)), #selector(qmui_viewWillAppear(_:)))
            
            // MARK: QMUINavigationControllerTransition
            ReplaceMethod(clazz, #selector(viewWillAppear(_:)), #selector(qmuiNav_viewWillAppear(_:)))
            ReplaceMethod(clazz, #selector(viewDidAppear(_:)), #selector(qmuiNav_viewDidAppear(_:)))
            ReplaceMethod(clazz, #selector(viewDidDisappear(_:)), #selector(qmuiNav_viewDidDisappear(_:)))
            
            // MARK: NavigationBarTransition
            ReplaceMethod(clazz, #selector(viewWillLayoutSubviews), #selector(NavigationBarTransition_viewWillLayoutSubviews))
            ReplaceMethod(clazz, #selector(viewWillAppear(_:)), #selector(NavigationBarTransition_viewWillAppear(_:)))
            ReplaceMethod(clazz, #selector(viewDidAppear(_:)), #selector(NavigationBarTransition_viewDidAppear(_:)))
            ReplaceMethod(clazz, #selector(viewDidDisappear(_:)), #selector(NavigationBarTransition_viewDidDisappear(_:)))
            
            ReplaceMethod(clazz, #selector(viewDidDisappear(_:)), #selector(navigationButton_viewDidAppear(_:)))
        }
    }
    
    @objc func qmui_description() -> String {
        var result = "\(qmui_description())\nsuperclass:\t\t\t\t\(String(describing: superclass))\ntitle:\t\t\t\t\t\(String(describing: title))\nview:\t\t\t\t\t\(isViewLoaded ? String(describing: view) : "")"
        if let navController = self as? UINavigationController {
            let navDescription = "\nviewControllers(\(navController.viewControllers.count):\t\t\(description(navController.viewControllers))\ntopViewController:\t\t\(navController.topViewController?.qmui_description() ?? "")\nvisibleViewController:\t\(navController.visibleViewController?.qmui_description() ?? "")"
            result = result + navDescription
        } else if let tabBarController = self as? UITabBarController, let viewControllers = tabBarController.viewControllers {
            let tabBarDescription = "\nviewControllers(\(viewControllers.count):\t\t\(description(viewControllers))\nselectedViewController(\(tabBarController.selectedIndex):\t\(tabBarController.selectedViewController?.qmui_description() ?? "")"
            result = result + tabBarDescription
        }
        return result
    }
    
    private func description(_ viewControllers:[UIViewController]) -> String {
        var string: String = "(\n"
        for (index, vc) in viewControllers.enumerated() {
            string += "\t\t\t\t\t\t\t[\(index)]\(vc.qmui_description())\(index < viewControllers.count - 1 ? "," : "")\n"
        }
        string += "\t\t\t\t\t\t)"
        return string
    }
    
    @objc func qmui_viewWillAppear(_ animated: Bool) {
        qmui_viewWillAppear(animated)
        if !AutomaticallyRotateDeviceOrientation {
            return
        }
        
        let statusBarOrientation = UIApplication.shared.statusBarOrientation
        let deviceOrientationBeforeChangingByHelper = QMUIHelper.shared.orientationBeforeChangingByHelper
        let shouldConsiderBeforeChanging = deviceOrientationBeforeChangingByHelper != .unknown
        let deviceOrientation = UIDevice.current.orientation
        
        // 虽然这两者的 unknow 值是相同的，但在启动 App 时可能只有其中一个是 unknown
        if statusBarOrientation == .unknown || deviceOrientation == .unknown {
            return
        }
        
        // 如果当前设备方向和界面支持的方向不一致，则主动进行旋转
        var deviceOrientationToRotate: UIDeviceOrientation = interfaceOrientationMask(supportedInterfaceOrientations, contains: deviceOrientation) ? deviceOrientation : deviceOrientationWithInterfaceOrientationMask(supportedInterfaceOrientations)
        
        // 之前没用私有接口修改过，那就按最标准的方式去旋转
        if !shouldConsiderBeforeChanging {
            if QMUIHelper.rotateToDeviceOrientation(deviceOrientationToRotate) {
                QMUIHelper.shared.orientationBeforeChangingByHelper = deviceOrientation
            } else {
                QMUIHelper.shared.orientationBeforeChangingByHelper = .unknown
            }
            return
        }
        
        // 用私有接口修改过方向，但下一个界面和当前界面方向不相同，则要把修改前记录下来的那个设备方向考虑进来
        deviceOrientationToRotate = interfaceOrientationMask(supportedInterfaceOrientations, contains: deviceOrientationBeforeChangingByHelper) ? deviceOrientationBeforeChangingByHelper : deviceOrientationWithInterfaceOrientationMask(supportedInterfaceOrientations)
        QMUIHelper.rotateToDeviceOrientation(deviceOrientationToRotate)
    }
    
    private func deviceOrientationWithInterfaceOrientationMask(_ mask: UIInterfaceOrientationMask) -> UIDeviceOrientation {
        if mask.contains(.all) {
            return UIDevice.current.orientation
        }
        if mask.contains(.allButUpsideDown) {
            return UIDevice.current.orientation
        }
        if mask.contains(.portrait) {
            return .portrait
        }
        if mask.contains(.landscape) {
            return UIDevice.current.orientation == .landscapeLeft ? .landscapeLeft : .landscapeRight
        }
        if mask.contains(.landscapeLeft) {
            return .landscapeRight
        }
        if mask.contains(.landscapeRight) {
            return .landscapeLeft
        }
        if mask.contains(.portraitUpsideDown) {
            return .portraitUpsideDown
        }
        return UIDevice.current.orientation
    }
    
    private func interfaceOrientationMask(_ mask: UIInterfaceOrientationMask, contains deviceOrientation: UIDeviceOrientation) -> Bool {
        if deviceOrientation == .unknown {
            return true // true 表示不用额外处理
        }
        if mask.contains(.all) {
            return true
        }
        if mask.contains(.allButUpsideDown) {
            return deviceOrientation != .portraitUpsideDown
        }
        if mask.contains(.portrait) {
            return deviceOrientation == .portrait
        }
        if mask.contains(.landscape) {
            return deviceOrientation == .landscapeLeft || deviceOrientation == .landscapeRight
        }
        if mask.contains(.landscapeLeft) {
            return deviceOrientation == .landscapeLeft
        }
        if mask.contains(.landscapeRight) {
            return deviceOrientation == .landscapeRight
        }
        if mask.contains(.portraitUpsideDown) {
            return deviceOrientation == .portraitUpsideDown
        }
        
        return true
    }
    
    @objc func qmui_UIViewController_viewDidLoad() {
        let isContainerViewController = self is UINavigationController || self is UITabBarController || self is UISplitViewController
        if !isContainerViewController {
            NotificationCenter.default.addObserver(self, selector: #selector(adjustsAdditionalSafeAreaInsetsForOpaqueTabBar(_:)), name: Notification.QMUI.TabBarStyleChanged, object: nil)
        }
        qmui_UIViewController_viewDidLoad()
    }
    
    @objc func adjustsAdditionalSafeAreaInsetsForOpaqueTabBar(_ notification: Notification) {
        if #available(iOS 11, *) {
            guard
                let object = notification.object as? UITabBar,
                let tabBarController = tabBarController,
                let navigationController = navigationController else {
                return
            }
            let isCurrentTabBar = navigationController.qmui_rootViewController == self && navigationController.parent == tabBarController && object == tabBarController.tabBar
            if !isCurrentTabBar {
                return
            }
            
            let tabBar = tabBarController.tabBar
            // 这串判断条件来源于这个 issue：https://github.com/QMUI/QMUI_iOS/issues/218
            let isOpaqueBarAndCanExtendedLayout = !tabBar.isTranslucent && extendedLayoutIncludesOpaqueBars
            if !isOpaqueBarAndCanExtendedLayout {
                return
            }
            
            let tabBarHidden = tabBar.isHidden
            // 这里直接用 CGRectGetHeight(tabBar.frame) 来计算理论上不准确，但因为系统有这个 bug（https://github.com/QMUI/QMUI_iOS/issues/217），所以暂时用 CGRectGetHeight(tabBar.frame) 来代替
            let correctSafeAreaInsetsBottom = tabBarHidden ? tabBar.safeAreaInsets.bottom : tabBar.frame.height
            let additionalSafeAreaInsetsBottom = correctSafeAreaInsetsBottom - tabBar.safeAreaInsets.bottom
            additionalSafeAreaInsets.bottom = additionalSafeAreaInsetsBottom
        }
    }
}

extension UIViewController {

    /** 获取和自身处于同一个UINavigationController里的上一个UIViewController */
    weak var qmui_previousViewController: UIViewController? {
        if let controllers = navigationController?.viewControllers,
            controllers.count > 1,
            navigationController?.topViewController == self {
            let controllerCount = controllers.count
            return controllers[controllerCount - 2]
        }

        return nil
    }

    /** 获取上一个UIViewController的title，可用于设置自定义返回按钮的文字 */
    var qmui_previousViewControllerTitle: String? {

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
    var qmui_visibleViewControllerIfExist: UIViewController? {

        if let presentedViewController = presentedViewController {
            return presentedViewController.qmui_visibleViewControllerIfExist
        }
        if self is UINavigationController, let nav = self as? UINavigationController {
            return nav.visibleViewController?.qmui_visibleViewControllerIfExist
        }
        if self is UITabBarController, let tabbar = self as? UITabBarController {
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
    var qmui_isPresented: Bool {
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
    var qmui_respondQMUINavigationControllerDelegate: Bool {
        return self is QMUINavigationControllerDelegate
    }

    /**
     *  是否应该响应一些UI相关的通知，例如 UIKeyboardNotification、UIMenuControllerNotification等，因为有可能当前界面已经被切走了（push到其他界面），但仍可能收到通知，所以在响应通知之前都应该做一下这个判断
     */
    var qmui_isViewLoadedAndVisible: Bool {
        return isViewLoaded && (view.window != nil)
    }
    
    /**
     *  UINavigationBar 在 self.view 坐标系里的 maxY，一般用于 self.view.subviews 布局时参考用
     *  @warning 注意由于使用了坐标系转换的计算，所以要求在 self.view.window 存在的情况下使用才可以，因此请勿在 viewDidLoad 内使用，建议在 viewDidLayoutSubviews、viewWillAppear: 里使用。
     *  @warning 如果不存在 UINavigationBar，则返回 0
     */
    var qmui_navigationBarMaxYInViewCoordinator: CGFloat {
        if !isViewLoaded {
            return 0
        }
        
        // 这里为什么要把 transitionNavigationBar 考虑进去，请参考 https://github.com/QMUI/QMUI_iOS/issues/268
        var navBar: UINavigationBar? = nil
        if let navigationController = navigationController, !navigationController.isNavigationBarHidden {
            navBar = navigationController.navigationBar
        } else if transitionNavigationBar != nil  {
            navBar = transitionNavigationBar
        }
        
        guard let navigationBar = navBar else {
            return 0
        }
        
        let navigationBarFrameInView = view.convert(navigationBar.frame, from: navigationBar.superview)
        let navigationBarFrame = view.bounds.intersection(navigationBarFrameInView)
        
        // 两个 rect 如果不存在交集，CGRectIntersection 计算结果可能为非法的 rect，所以这里做个保护
        if !navigationBarFrame.isValidated {
            return 0
        }
        
        let result = navigationBarFrame.maxY
        
        return result
    }
    
    /**
     *  底部 UIToolbar 在 self.view 坐标系里的占位高度，一般用于 self.view.subviews 布局时参考用
     *  @warning 注意由于使用了坐标系转换的计算，所以要求在 self.view.window 存在的情况下使用才可以，因此请勿在 viewDidLoad 内使用，建议在 viewDidLayoutSubviews、viewWillAppear: 里使用。
     *  @warning 如果不存在 UIToolbar，则返回 0
     */
    var qmui_toolbarSpacingInViewCoordinator: CGFloat {
        if !isViewLoaded {
            return 0
        }
        
        guard let navigationController = navigationController, let toolbar = navigationController.toolbar, !navigationController.isToolbarHidden else {
            return 0
        }
        
        let toolbarFrame = view.bounds.intersection(view.convert(toolbar.frame, from: toolbar.superview))
        
        // 两个 rect 如果不存在交集，CGRectIntersection 计算结果可能为非法的 rect，所以这里做个保护
        if !toolbarFrame.isValidated {
            return 0
        }
        
        let result = view.bounds.height - toolbarFrame.minY
        
        return result
    }
    
    /**
     *  底部 UITabBar 在 self.view 坐标系里的占位高度，一般用于 self.view.subviews 布局时参考用
     *  @warning 注意由于使用了坐标系转换的计算，所以要求在 self.view.window 存在的情况下使用才可以，因此请勿在 viewDidLoad 内使用，建议在 viewDidLayoutSubviews、viewWillAppear: 里使用。
     *  @warning 如果不存在 UITabBar，则返回 0
     */
    var qmui_tabBarSpacingInViewCoordinator: CGFloat {
        if !isViewLoaded {
            return 0
        }
        guard let tabBarController = tabBarController, !tabBarController.tabBar.isHidden else {
            return 0
        }
        
        let tabBarFrame = view.bounds.intersection(view.convert(tabBarController.tabBar.frame, from: tabBarController.tabBar.superview))
        
        // 两个 rect 如果不存在交集，CGRectIntersection 计算结果可能为非法的 rect，所以这里做个保护
        if !tabBarFrame.isValidated {
            return 0
        }
        
        let result = view.bounds.height - tabBarFrame.minY
        return result
    }
}

extension UIViewController {
    func qmui_hasOverrideUIKitMethod(_ selector: Selector) -> Bool {
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
