//
//  QMUINavigationController.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/1/23.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

/// 与 QMUINavigationController push/pop 相关的一些方法
@objc protocol QMUINavigationControllerTransitionDelegate: NSObjectProtocol {
    
    /// 当前界面正处于手势返回的过程中，可自行通过 gestureRecognizer.state 来区分手势返回的各个阶段。手势返回有多个阶段（手势返回开始、拖拽过程中、松手并成功返回、松手但不切换界面），不同阶段的 viewController 的状态可能不一样。
    ///
    /// - Parameters:
    ///   - navigationController: 当前正在手势返回的 QMUINavigationController，由于某些阶段下无法通过 vc.navigationController 获取到 nav 的引用，所以直接传一个参数
    ///   - gestureRecognizer: gestureRecognizer 手势对象
    ///   - willDisappear: 手势返回中顶部的那个 vc
    ///   - willAppear: 手势返回中背后的那个 vc
    @objc optional func navigationController(_ navigationController: QMUINavigationController, poppingByInteractive gestureRecognizer: UIScreenEdgePanGestureRecognizer?, viewController willDisappear: UIViewController?, viewController willAppear: UIViewController?)
    
    /**
     *  在 self.navigationController 进行以下 4 个操作前，相应的 viewController 的 willPopInNavigationControllerWithAnimated: 方法会被调用：
     *  1. popViewControllerAnimated:
     *  2. popToViewController:animated:
     *  3. popToRootViewControllerAnimated:
     *  4. setViewControllers:animated:
     *
     *  此时 self 仍存在于 self.navigationController.viewControllers 堆栈内。
     *
     *  在 ARC 环境下，viewController 可能被放在 autorelease 池中，因此 viewController 被pop后不一定立即被销毁，所以一些对实时性要求很高的内存管理逻辑可以写在这里（而不是写在dealloc内）
     *
     *  @warning 不要尝试将 willPopInNavigationControllerWithAnimated: 视为点击返回按钮的回调，因为导致 viewController 被 pop 的情况不止点击返回按钮这一途径。系统的返回按钮是无法添加回调的，只能使用自定义的返回按钮。
     */
    @objc optional func willPopInNavigationController(_ animated: Bool)
    
    /**
     *  在 self.navigationController 进行以下 4 个操作后，相应的 viewController 的 didPopInNavigationControllerWithAnimated: 方法会被调用：
     *  1. popViewControllerAnimated:
     *  2. popToViewController:animated:
     *  3. popToRootViewControllerAnimated:
     *  4. setViewControllers:animated:
     *
     *  @warning 此时 self 已经不在 viewControllers 数组内
     */
    @objc optional func didPopInNavigationController(_ animated: Bool)
    
    /**
     *  当通过 setViewControllers:animated: 来修改 viewController 的堆栈时，如果参数 viewControllers.lastObject 与当前的 self.viewControllers.lastObject 不相同，则意味着会产生界面的切换，这种情况系统会自动调用两个切换的界面的生命周期方法，但如果两者相同，则意味着并不会产生界面切换，此时之前就已经在显示的那个 viewController 的 viewWillAppear:、viewDidAppear: 并不会被调用，那如果用户确实需要在这个时候修改一些界面元素，则找不到一个时机。所以这个方法就是提供这样一个时机给用户修改界面元素。
     */
    @objc optional func viewControllerKeepingAppearWhenSetViewControllers(_ animated: Bool)
}

/// 与 QMUINavigationController 外观样式相关的方法
@objc protocol QMUINavigationControllerAppearanceDelegate: NSObjectProtocol {
    
    /// 是否需要将状态栏改为浅色文字，对于 QMUICommonViewController 子类，返回值默认为宏 StatusbarStyleLightInitially 的值，对于 UIViewController，不实现该方法则视为返回 NO。
    /// @warning 需在项目的 Info.plist 文件内设置字段 “View controller-based status bar appearance” 的值为 NO 才能生效，如果不设置，或者值为 YES，则请使用系统提供的 - preferredStatusBarStyle 方法
    @objc optional var shouldSetStatusBarStyleLight: Bool { get }

    /// 设置titleView的tintColor
    ///
    /// - Returns: UIColor
    @objc optional var titleViewTintColor: UIColor? { get }
    
    /// 设置导航栏的背景图，默认为NavBarBackgroundImage
    @objc optional var  navigationBarBackgroundImage: UIImage? { get }
    
    /// 设置导航栏底部的分隔线图片，默认为NavBarShadowImage，必须在navigationBar设置了背景图后才有效
    @objc optional var navigationBarShadowImage: UIImage? { get }
    
    /// 设置当前导航栏的UIBarButtonItem的tintColor，默认为NavBarTintColor
    @objc optional var navigationBarTintColor: UIColor? { get }
    
    /// 设置系统返回按钮title，如果返回nil则使用系统默认的返回按钮标题
    @objc optional func backBarButtonItemTitle(_ previousViewController: UIViewController?) -> String?
}

/// 与 QMUINavigationController 控制 navigationBar 显隐/动画相关的方法
@objc protocol QMUICustomNavigationBarTransitionDelegate: NSObjectProtocol {
    
    /// 设置每个界面导航栏的显示/隐藏，为了减少对项目的侵入性，默认不开启这个接口的功能，只有当 shouldCustomizeNavigationBarTransitionIfHideable 返回 true 时才会开启此功能。如果需要全局开启，那么就在 Controller 基类里面返回 true；如果是老项目并不想全局使用此功能，那么则可以在单独的界面里面开启。
    @objc optional var preferredNavigationBarHidden: Bool  { get }
    
    /**
     *  当切换界面时，如果不同界面导航栏的显示状态不同，可以通过 shouldCustomizeNavigationBarTransitionIfHideable 设置是否需要接管导航栏的显示和隐藏。从而不需要在各自的界面的 viewWillappear 和 viewWillDisappear 里面去管理导航栏的状态。
     *  @see UINavigationController+NavigationBarTransition.h
     *  @see preferredNavigationBarHidden
     */
    @objc optional var shouldCustomizeNavigationBarTransitionIfHideable: Bool { get }

    /**
     *  设置当前导航栏是否需要使用自定义的 push/pop transition 效果，默认返回NO。<br/>
     *  因为系统的UINavigationController只有一个navBar，所以会导致在切换controller的时候，如果两个controller的navBar状态不一致（包括backgroundImage、shadowImage、barTintColor等等），就会导致在刚要切换的瞬间，navBar的状态都立马变成下一个controller所设置的样式了，为了解决这种情况，QMUI给出了一个方案，有四个方法可以决定你在转场的时候要不要使用自定义的navBar来模仿真实的navBar。具体方法如下：
     *  @see UINavigationController+NavigationBarTransition.h
     */
    @objc optional var shouldCustomNavigationBarTransitionWhenPushAppearing: Bool { get }
    
    /// @see UINavigationController+NavigationBarTransition.h
    ///
    /// - Returns: Bool
    @objc optional var shouldCustomNavigationBarTransitionWhenPushDisappearing: Bool { get }
    
    /// @see UINavigationController+NavigationBarTransition.h
    ///
    /// - Returns: Bool
    @objc optional var shouldCustomNavigationBarTransitionWhenPopAppearing: Bool { get }
    
    /// @see UINavigationController+NavigationBarTransition.h
    ///
    /// - Returns: Bool
    @objc optional var shouldCustomNavigationBarTransitionWhenPopDisappearing: Bool { get }
    
    /**
     *  自定义navBar效果过程中UINavigationController的containerView的背景色
     *  @see UINavigationController+NavigationBarTransition.h
     */
    @objc optional var containerViewBackgroundColorWhenTransitioning: UIColor?  { get }
}

/**
 *  配合 QMUINavigationController 使用，当 navController 里的 UIViewController 实现了这个协议时，则可得到协议里各个方法的功能。
 *  QMUICommonViewController、QMUICommonTableViewController 默认实现了这个协议，所以子类无需再手动实现一遍。
 */
@objc protocol QMUINavigationControllerDelegate: QMUINavigationControllerTransitionDelegate, QMUINavigationControllerAppearanceDelegate, QMUICustomNavigationBarTransitionDelegate {
    
}

let UIViewControllerIsViewWillAppearPropertyKey = "qmuiNav_isViewWillAppear"

class QMUINavigationController: UINavigationController {

    /// 记录当前是否正在 push/pop 界面的动画过程，如果动画尚未结束，不应该继续 push/pop 其他界面。
    /// 在 getter 方法里会根据配置表开关 PreventConcurrentNavigationControllerTransitions 的值来控制这个属性是否生效。
    fileprivate var _isViewControllerTransiting: Bool = false
    fileprivate var isViewControllerTransiting: Bool {
        get {
            if !PreventConcurrentNavigationControllerTransitions {
                return false
            }
            return _isViewControllerTransiting
        }
        set {
            _isViewControllerTransiting = newValue
        }
    }

    /// 即将要被pop的controller
    fileprivate weak var viewControllerPopping: UIViewController?

    /**
     *  因为QMUINavigationController把delegate指向了自己来做一些基类要做的事情，所以如果当外面重新指定了delegate，那么就会覆盖原本的delegate。<br/>
     *  为了避免这个问题，并且外面也可以实现实现navigationController的delegate方法，这里使用delegateProxy来保存外面指定的delegate，然后在基类的delegate方法实现里面会去调用delegateProxy的方法实现。
     */
    private weak var originalDelegate: QMUINavigationControllerDelegate?
    
    override var delegate: UINavigationControllerDelegate? {
        didSet {
            originalDelegate = delegate as? QMUINavigationControllerDelegate
        }
    }

    // MARK: - 生命周期函数 && 基类方法重写
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        didInitialized()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        didInitialized()
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        didInitialized()
    }

    /**
     *  初始化时调用的方法，会在 initWithNibName:bundle: 和 initWithCoder: 这两个指定的初始化方法中被调用，所以子类如果需要同时支持两个初始化方法，则建议把初始化时要做的事情放到这个方法里。否则仅需重写要支持的那个初始化方法即可。
     */
    func didInitialized() {
        // UIView.tintColor 并不支持 UIAppearance 协议，所以不能通过 appearance 来设置，只能在实例里设置
        navigationBar.tintColor = NavBarTintColor
        toolbar.tintColor = ToolBarTintColor
    }

    deinit {
        delegate = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if delegate == nil {
            delegate = self
        }
        interactivePopGestureRecognizer?.addTarget(self, action: #selector(handleInteractivePop(_:)))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let topViewController = topViewController else { return }
        willShow(topViewController, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let topViewController = topViewController else { return }
        didShow(topViewController, animated: animated)
    }

    override func popViewController(animated: Bool) -> UIViewController? {
        // 从横屏界面pop 到竖屏界面，系统会调用两次 popViewController，如果这里加这个 if 判断，会误拦第二次 pop，导致错误
        //    if (self.isViewControllerTransiting) {
        //        NSAssert(NO, @"isViewControllerTransiting = YES, %s, self.viewControllers = %@", __func__, self.viewControllers);
        //        return nil;
        //    }
        if viewControllers.count < 2 {
            // 只剩 1 个 viewController 或者不存在 viewController 时，调用 popViewControllerAnimated: 后不会有任何变化，所以不需要触发 willPop / didPop
            return super.popViewController(animated: animated)
        }
        
        if animated {
            isViewControllerTransiting = true
        }
        
        if let viewController = topViewController as? QMUINavigationControllerDelegate {
            viewControllerPopping = viewController as? UIViewController
            if viewController.responds(to: #selector(QMUINavigationControllerDelegate.willPopInNavigationController(_:))) {
                viewController.willPopInNavigationController!(animated)
            }
        }
        if let viewController = super.popViewController(animated: animated) as? QMUINavigationControllerDelegate {
            if viewController.responds(to: #selector(QMUINavigationControllerDelegate.didPopInNavigationController(_:))) {
                viewController.didPopInNavigationController!(animated)
            }
            return viewController as? UIViewController
        }
        return nil
    }

    override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        // 从横屏界面pop 到竖屏界面，系统会调用两次 popViewController，如果这里加这个 if 判断，会误拦第二次 pop，导致错误
        //    if (self.isViewControllerTransiting) {
        //        NSAssert(NO, @"isViewControllerTransiting = YES, %s, self.viewControllers = %@", __func__, self.viewControllers);
        //        return nil;
        //    }

        if topViewController == viewController {
            // 当要被 pop 到的 viewController 已经处于最顶层时，调用 super 默认也是什么都不做，所以直接 return 掉
            return super.popToViewController(viewController, animated: animated)
        }

        if animated {
            isViewControllerTransiting = true
        }

        viewControllerPopping = topViewController

        // will pop

        for (i, viewControllerPopping) in viewControllers.reversed().enumerated() {
            if viewControllerPopping == viewController {
                break
            }

            if let viewControllerPopping = viewControllerPopping as? QMUINavigationControllerDelegate {
                if viewControllerPopping.responds(to: #selector(QMUINavigationControllerDelegate.willPopInNavigationController(_:))) {
                    let animatedArgument = i == viewControllers.count - 1 ? animated : false // 只有当前可视的那个 viewController 的 animated 是跟随参数走的，其他 viewController 由于不可视，不管参数的值为多少，都认为是无动画地 pop
                    viewControllerPopping.willPopInNavigationController!(animatedArgument)
                }
            }
        }

        guard let poppedViewControllers = super.popToViewController(viewController, animated: animated) else {
            return nil
        }

        // did pop
        for (i, viewControllerPopped) in poppedViewControllers.reversed().enumerated() {
            if let viewControllerPopped = viewControllerPopped as? QMUINavigationControllerDelegate {
                if viewControllerPopped.responds(to: #selector(QMUINavigationControllerDelegate.didPopInNavigationController(_:))) {
                    let animatedArgument = i == poppedViewControllers.count - 1 ? animated : false // 只有当前可视的那个 viewController 的 animated 是跟随参数走的，其他 viewController 由于不可视，不管参数的值为多少，都认为是无动画地 pop
                    viewControllerPopped.didPopInNavigationController!(animatedArgument)
                }
            }
        }
        return poppedViewControllers
    }

    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        // 从横屏界面pop 到竖屏界面，系统会调用两次 popViewController，如果这里加这个 if 判断，会误拦第二次 pop，导致错误
        //    if (self.isViewControllerTransiting) {
        //        NSAssert(NO, @"isViewControllerTransiting = YES, %s, self.viewControllers = %@", __func__, self.viewControllers)
        //        return nil
        //    }

        // 在配合 tabBarItem 使用的情况下，快速重复点击相同 item 可能会重复调用 popToRootViewControllerAnimated:，而此时其实已经处于 rootViewController 了，就没必要继续走后续的流程，否则一些变量会得不到重置。
        if topViewController == qmui_rootViewController {
            return nil
        }

        if animated {
            isViewControllerTransiting = true
        }

        viewControllerPopping = topViewController

        // will pop
        for (i, viewControllerPopping) in viewControllers.reversed().enumerated() {
            if let viewControllerPopping = viewControllerPopping as? QMUINavigationControllerDelegate {
                if viewControllerPopping.responds(to: #selector(QMUINavigationControllerDelegate.willPopInNavigationController(_:))) {
                    let animatedArgument = i == viewControllers.count - 1 ? animated : false // 只有当前可视的那个 viewController 的 animated 是跟随参数走的，其他 viewController 由于不可视，不管参数的值为多少，都认为是无动画地 pop
                    viewControllerPopping.willPopInNavigationController!(animatedArgument)
                }
            }
        }

        guard let poppedViewControllers = super.popToRootViewController(animated: animated) else {
            return nil
        }

        // did pop
        for (i, viewControllerPopped) in poppedViewControllers.reversed().enumerated() {
            if let viewControllerPopped = viewControllerPopped as? QMUINavigationControllerDelegate {
                if viewControllerPopped.responds(to: #selector(QMUINavigationControllerDelegate.didPopInNavigationController(_:))) {
                    let animatedArgument = i == poppedViewControllers.count - 1 ? animated : false // 只有当前可视的那个 viewController 的 animated 是跟随参数走的，其他 viewController 由于不可视，不管参数的值为多少，都认为是无动画地 pop
                    viewControllerPopped.didPopInNavigationController!(animatedArgument)
                }
            }
        }

        return poppedViewControllers
    }
    
    override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        let topViewController = self.topViewController
        
        // will pop
        let viewControllersPopping = self.viewControllers.filter { (viewController) -> Bool in
            !viewControllers.contains(viewController)
        }
        viewControllersPopping.forEach { (viewController) in
            if let viewControllerPopping = viewController as? QMUINavigationControllerDelegate {
                if viewControllerPopping.responds(to: #selector(QMUINavigationControllerDelegate.willPopInNavigationController(_:))) {
                    let animatedArgument = (viewControllerPopping as? UIViewController)  == topViewController ? animated : false // 只有当前可视的那个 viewController 的 animated 是跟随参数走的，其他 viewController 由于不可视，不管参数的值为多少，都认为是无动画地 pop
                    viewControllerPopping.willPopInNavigationController!(animatedArgument)
                }
            }
        }
        
        super.setViewControllers(viewControllers, animated: animated)
        
        // did pop
        viewControllersPopping.forEach { (viewController) in
            if let viewControllerPopping = viewController as? QMUINavigationControllerDelegate {
                if viewControllerPopping.responds(to: #selector(QMUINavigationControllerDelegate.didPopInNavigationController(_:))) {
                    let animatedArgument = (viewControllerPopping as? UIViewController)  == topViewController ? animated : false // 只有当前可视的那个 viewController 的 animated 是跟随参数走的，其他 viewController 由于不可视，不管参数的值为多少，都认为是无动画地 pop
                    viewControllerPopping.didPopInNavigationController!(animatedArgument)
                }
            }
        }
        
        // 操作前后如果 topViewController 没发生变化，则为它调用一个特殊的时机
        if topViewController == viewControllers.last {
            if let viewController = topViewController as? QMUINavigationControllerDelegate {
                if viewController.responds(to: #selector(QMUINavigationControllerDelegate.viewControllerKeepingAppearWhenSetViewControllers(_:))) {
                    viewController.viewControllerKeepingAppearWhenSetViewControllers!(animated)
                }
            }
        }
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if isViewControllerTransiting {
            print("\(type(of: self)), 上一次界面切换的动画尚未结束就试图进行新的 push 操作，为了避免产生 bug，拦截了这次 push, \(#function), isViewControllerTransiting = \(isViewControllerTransiting), viewController = \(viewController), self.viewControllers = \(viewControllers)")
            return
        }
        
        // 增加一个 presentedViewController 作为判断条件是因为这个 issue：https://github.com/QMUI/QMUI_iOS/issues/261
        if presentedViewController == nil && animated {
            isViewControllerTransiting = true
        }
        
        if presentedViewController != nil {
            print("push 的时候 navigationController 存在一个盖在上面的 presentedViewController，可能导致一些 UINavigationControllerDelegate 不会被调用")
        }
        
        if let currentViewController = topViewController {
            if !NeedsBackBarButtonItemTitle {
                currentViewController.navigationItem.backBarButtonItem = UIBarButtonItem.item(title: "", target: nil, action: nil)
            } else {
                if let vc = viewController as? QMUINavigationControllerAppearanceDelegate {
                    if vc.responds(to: #selector(QMUINavigationControllerAppearanceDelegate.backBarButtonItemTitle(_:))) {
                        if let title = vc.backBarButtonItemTitle!(currentViewController) {
                            currentViewController.navigationItem.backBarButtonItem = UIBarButtonItem.item(title: title, target: nil, action: nil)
                        }
                    }
                }
            }
        }

        super.pushViewController(viewController, animated: animated)
    }

    // 重写这个方法才能让 viewControllers 对 statusBar 的控制生效
    override var childForStatusBarStyle: UIViewController? {
        return topViewController
    }
    
    override var shouldAutorotate: Bool {
        if let topViewController = topViewController {
            return topViewController.qmui_hasOverrideUIKitMethod(#function) ? topViewController.shouldAutorotate : true
        } else {
            return true
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if let topViewController = topViewController {
            return topViewController.qmui_hasOverrideUIKitMethod(#function) ? topViewController.supportedInterfaceOrientations : SupportedOrientationMask
        } else {
            return SupportedOrientationMask
        }
    }
    
    
    // MARK: - 自定义方法
    // 接管系统手势返回的回调
    @objc func handleInteractivePop(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        let state = gestureRecognizer.state
        if state == .began {
            viewControllerPopping?.addObserver(self, forKeyPath: UIViewControllerIsViewWillAppearPropertyKey, options: .new, context: nil)
        }
        
        var viewControllerWillDisappear = viewControllerPopping
        var viewControllerWillAppear = topViewController
        
        if state == .ended {
            if (topViewController?.view.superview?.frame.minX ?? 0) < 0 {
                // by molice:只是碰巧发现如果是手势返回取消时，不管在哪个位置取消，self.topViewController.view.superview.frame.orgin.x必定是-124，所以用这个<0的条件来判断
                print("手势返回放弃了")
                viewControllerWillDisappear = topViewController
                viewControllerWillAppear = viewControllerPopping
            } else {
                print("执行手势返回")
            }
        }
        
        viewControllerWillDisappear?.qmui_poppingByInteractivePopGestureRecognizer = true
        viewControllerWillDisappear?.qmui_willAppearByInteractivePopGestureRecognizer = false
        
        viewControllerWillDisappear?.qmui_poppingByInteractivePopGestureRecognizer = false
        viewControllerWillAppear?.qmui_willAppearByInteractivePopGestureRecognizer = true
        
        if let viewControllerWillDisappear = viewControllerWillDisappear as? QMUINavigationControllerTransitionDelegate {
            if viewControllerWillDisappear.responds(to: #selector(QMUINavigationControllerTransitionDelegate.navigationController(_:poppingByInteractive:viewController:viewController:))) {
                viewControllerWillDisappear.navigationController!(self, poppingByInteractive: gestureRecognizer, viewController: viewControllerWillDisappear as? UIViewController, viewController: viewControllerWillAppear)
            }
        }
        
        if let viewControllerWillAppear = viewControllerWillAppear as? QMUINavigationControllerTransitionDelegate {
            if viewControllerWillAppear.responds(to: #selector(QMUINavigationControllerTransitionDelegate.navigationController(_:poppingByInteractive:viewController:viewController:))) {
                viewControllerWillAppear.navigationController!(self, poppingByInteractive: gestureRecognizer, viewController: viewControllerWillDisappear, viewController: viewControllerWillAppear as? UIViewController)
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == UIViewControllerIsViewWillAppearPropertyKey {
            viewControllerPopping?.removeObserver(self, forKeyPath: UIViewControllerIsViewWillAppearPropertyKey)
            let newValue = change?[NSKeyValueChangeKey.newKey] as? Bool ?? false
            if newValue && viewControllerPopping != nil {
                navigationController(self, willShow: viewControllerPopping!, animated: true)
                viewControllerPopping = nil
                isViewControllerTransiting = false
            }
        }
    }
}

// MARK: UISubclassingHooks
extension QMUINavigationController {
    
    func willShow(_ viewController: UIViewController, animated: Bool) {
        // 子类可以重写
    }
    
    func didShow(_ viewController: UIViewController, animated: Bool) {
        // 子类可以重写
    }
}

extension QMUINavigationController: UINavigationControllerDelegate {
    
    // 注意如果实现了某一个navigationController的delegate方法，必须同时检查并且调用delegateProxy相对应的方法
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        willShow(viewController, animated: animated)
//        if let delegateProxy = delegateProxy, delegateProxy.responds(to: #selector(UINavigationControllerDelegate.navigationController(_:willShow:animated:))) {
//            delegateProxy.navigationController!(navigationController, willShow: viewController, animated: animated)
//        }
    }

    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        viewControllerPopping = nil
        isViewControllerTransiting = false
        didShow(viewController, animated: animated)
//        if let delegateProxy = delegateProxy, delegateProxy.responds(to: #selector(UINavigationControllerDelegate.navigationController(_:didShow:animated:))) {
//            delegateProxy.navigationController!(navigationController, didShow: viewController, animated: animated)
//        }
    }
}

// MARK: QMUINavigationController
extension UIViewController {
    fileprivate struct Keys {
        static var poppingByInteractivePopGestureRecognizer = "poppingByInteractivePopGestureRecognizer"
        static var willAppearByInteractivePopGestureRecognizer = "willAppearByInteractivePopGestureRecognizer"
        static var qmuiNavIsViewWillAppear = "qmuiNavIsViewWillAppear"
        static var navigationControllerPopGestureRecognizerChanging = "navigationControllerPopGestureRecognizerChanging"
    }
    
    /// 判断当前 viewController 是否处于手势返回中，仅对当前手势返回涉及到的前后两个 viewController 有效
    var qmui_navigationControllerPoppingInteracted: Bool {
        return qmui_poppingByInteractivePopGestureRecognizer || qmui_willAppearByInteractivePopGestureRecognizer
    }
    
    /// 基本与上一个属性 qmui_navigationControllerPoppingInteracted 相同，只不过 qmui_navigationControllerPoppingInteracted 是在 began 时就为 YES，而这个属性仅在 changed 时才为 YES。
    /// @note viewController 会在走完 viewWillAppear: 之后才将这个值置为 YES。
    fileprivate(set) var qmui_navigationControllerPopGestureRecognizerChanging: Bool {
        set {
            objc_setAssociatedObject(self, &Keys.navigationControllerPopGestureRecognizerChanging, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return (objc_getAssociatedObject(self, &Keys.navigationControllerPopGestureRecognizerChanging) as? Bool) ?? false
        }
    }
    
    /// 当前 viewController 是否正在被手势返回 pop
    fileprivate(set) var qmui_poppingByInteractivePopGestureRecognizer: Bool {
        set {
            objc_setAssociatedObject(self, &Keys.poppingByInteractivePopGestureRecognizer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return (objc_getAssociatedObject(self, &Keys.poppingByInteractivePopGestureRecognizer) as? Bool) ?? false
        }
    }
    
    /// 当前 viewController 是否是手势返回中，背后的那个界面
    fileprivate(set) var qmui_willAppearByInteractivePopGestureRecognizer: Bool {
        set {
            objc_setAssociatedObject(self, &Keys.willAppearByInteractivePopGestureRecognizer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return (objc_getAssociatedObject(self, &Keys.willAppearByInteractivePopGestureRecognizer) as? Bool) ?? false
        }
    }
}

// MARK: QMUINavigationControllerTransition
extension UIViewController {
    
    @objc func qmuiNav_viewWillAppear(_ animated: Bool) {
        qmuiNav_viewWillAppear(animated)
        qmuiNav_isViewWillAppear = true
    }
    
    @objc func qmuiNav_viewDidAppear(_ animated: Bool) {
        qmuiNav_viewDidAppear(animated)
        qmui_poppingByInteractivePopGestureRecognizer = false
        qmui_willAppearByInteractivePopGestureRecognizer = false
    }
    
    @objc func qmuiNav_viewDidDisappear(_ animated: Bool) {
        qmuiNav_viewDidDisappear(animated)
        qmuiNav_isViewWillAppear = false
        qmui_poppingByInteractivePopGestureRecognizer = false
        qmui_willAppearByInteractivePopGestureRecognizer = false
    }
    
    private var qmuiNav_isViewWillAppear: Bool {
        set {
            objc_setAssociatedObject(self, &Keys.qmuiNavIsViewWillAppear, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return (objc_getAssociatedObject(self, &Keys.qmuiNavIsViewWillAppear) as? Bool) ?? false
        }
    }
}
