//
//  QMUINavigationController.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/1/23.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

enum QMUINavigationBarHiddenState {
    case showWithAnimated
    case showWithoutAnimated
    case hideWithAnimated
    case hideWithoutAnimated
}

/// 与 QMUINavigationController push/pop 相关的一些方法
@objc protocol QMUINavigationControllerTransitionDelegate {
    
    /// 当前界面正处于手势返回的过程中，可自行通过 gestureRecognizer.state 来区分手势返回的各个阶段。手势返回有多个阶段（手势返回开始、拖拽过程中、松手并成功返回、松手但不切换界面），不同阶段的 viewController 的状态可能不一样。
    ///
    /// - Parameters:
    ///   - navigationController: 当前正在手势返回的 QMUINavigationController，由于某些阶段下无法通过 vc.navigationController 获取到 nav 的引用，所以直接传一个参数
    ///   - gestureRecognizer: gestureRecognizer 手势对象
    ///   - willDisappear: 手势返回中顶部的那个 vc
    ///   - willAppear: 手势返回中背后的那个 vc
    /// - Returns: Void
    @objc optional func navigationController(_ navigationController: QMUINavigationController, poppingByInteractive gestureRecognizer: UIScreenEdgePanGestureRecognizer?, viewController willDisappear: UIViewController?, viewController willAppear: UIViewController?) -> Void
    
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
    @objc optional func willPopInNavigationController(with animated: Bool)
    
    /**
     *  在 self.navigationController 进行以下 4 个操作后，相应的 viewController 的 didPopInNavigationControllerWithAnimated: 方法会被调用：
     *  1. popViewControllerAnimated:
     *  2. popToViewController:animated:
     *  3. popToRootViewControllerAnimated:
     *  4. setViewControllers:animated:
     *
     *  @warning 此时 self 已经不在 viewControllers 数组内
     */
    @objc optional func didPopInNavigationController(with animated: Bool)
    
    /**
     *  当通过 setViewControllers:animated: 来修改 viewController 的堆栈时，如果参数 viewControllers.lastObject 与当前的 self.viewControllers.lastObject 不相同，则意味着会产生界面的切换，这种情况系统会自动调用两个切换的界面的生命周期方法，但如果两者相同，则意味着并不会产生界面切换，此时之前就已经在显示的那个 viewController 的 viewWillAppear:、viewDidAppear: 并不会被调用，那如果用户确实需要在这个时候修改一些界面元素，则找不到一个时机。所以这个方法就是提供这样一个时机给用户修改界面元素。
     */
    @objc optional func viewControllerKeepingAppearWhenSetViewControllers(with animated: Bool)
}

protocol QMUINavigationControllerDelegate: class {
    /// 是否需要将状态栏改为浅色文字，默认为宏StatusbarStyleLightInitially的值
    var shouldSetStatusBarStyleLight: Bool { get }

    /// 设置每个界面导航栏的显示/隐藏以及是否需要动画，为了减少对项目的侵入性，默认不开启这个接口的功能，只有当配置表中的 NavigationBarHiddenStateUsable 被设置 YES 时才会开启此功能。
    var preferredNavigationBarHiddenState: QMUINavigationBarHiddenState { get }

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
    func willPopInNavigationController(with animated: Bool)

    /**
     *  在 self.navigationController 进行以下 4 个操作后，相应的 viewController 的 didPopInNavigationControllerWithAnimated: 方法会被调用：
     *  1. popViewControllerAnimated:
     *  2. popToViewController:animated:
     *  3. popToRootViewControllerAnimated:
     *  4. setViewControllers:animated:
     *
     *  @warning 此时 self 已经不在 viewControllers 数组内
     */
    func didPopInNavigationController(with animated: Bool)

    /**
     *  当通过 setViewControllers:animated: 来修改 viewController 的堆栈时，如果参数 viewControllers.lastObject 与当前的 self.viewControllers.lastObject 不相同，则意味着会产生界面的切换，这种情况系统会自动调用两个切换的界面的生命周期方法，但如果两者相同，则意味着并不会产生界面切换，此时之前就已经在显示的那个 viewController 的 viewWillAppear:、viewDidAppear: 并不会被调用，那如果用户确实需要在这个时候修改一些界面元素，则找不到一个时机。所以这个方法就是提供这样一个时机给用户修改界面元素。
     */
    func viewControllerKeepingAppearWhenSetViewControllers(with animated: Bool)

    /// 设置titleView的tintColor
    var titleViewTintColor: UIColor { get }

    /// 设置导航栏的背景图，默认为NavBarBackgroundImage
    var navigationBarBackgroundImage: UIImage { get }

    /// 设置导航栏底部的分隔线图片，默认为NavBarShadowImage，必须在navigationBar设置了背景图后才有效
    var navigationBarShadowImage: UIImage { get }

    /// 设置当前导航栏的UIBarButtonItem的tintColor，默认为NavBarTintColor
    var navigationBarTintColor: UIColor { get }

    /// 设置系统返回按钮title，如果返回nil则使用系统默认的返回按钮标题
    func backBarButtonItemTitle(with previousViewController: UIViewController) -> String

    /**
     *  设置当前导航栏是否需要使用自定义的 push/pop transition 效果，默认返回NO。<br/>
     *  因为系统的UINavigationController只有一个navBar，所以会导致在切换controller的时候，如果两个controller的navBar状态不一致（包括backgroundImgae、shadowImage、barTintColor等等），就会导致在刚要切换的瞬间，navBar的状态都立马变成下一个controller所设置的样式了，为了解决这种情况，QMUI给出了一个方案，有四个方法可以决定你在转场的时候要不要使用自定义的navBar来模仿真实的navBar。具体方法如下：
     *  @see UINavigationController+NavigationBarTransition.h
     */
    func shouldCustomNavigationBarTransitionWhenPushAppearing() -> Bool

    /**
     *  同上
     *  @see UINavigationController+NavigationBarTransition.h
     */
    func shouldCustomNavigationBarTransitionWhenPushDisappearing() -> Bool

    /**
     *  同上
     *  @see UINavigationController+NavigationBarTransition.h
     */
    func shouldCustomNavigationBarTransitionWhenPopAppearing() -> Bool

    /**
     *  同上
     *  @see UINavigationController+NavigationBarTransition.h
     */
    func shouldCustomNavigationBarTransitionWhenPopDisappearing() -> Bool
}

extension QMUINavigationControllerDelegate {

    var titleViewTintColor: UIColor {
        return UIColor.white
    }

    var navigationBarBackgroundImage: UIImage {
        return UIImage()
    }

    var navigationBarShadowImage: UIImage {
        return UIImage()
    }

    var navigationBarTintColor: UIColor {
        return UIColor.blue
    }

    func willPopInNavigationController(with _: Bool) {}

    func didPopInNavigationController(with _: Bool) {}

    func viewControllerKeepingAppearWhenSetViewControllers(with _: Bool) {}

    func backBarButtonItemTitle(with _: UIViewController) -> String {
        return ""
    }

    func shouldCustomNavigationBarTransitionWhenPushAppearing() -> Bool {
        return false
    }

    func shouldCustomNavigationBarTransitionWhenPushDisappearing() -> Bool {
        return false
    }

    func shouldCustomNavigationBarTransitionWhenPopAppearing() -> Bool {
        return false
    }

    func shouldCustomNavigationBarTransitionWhenPopDisappearing() -> Bool {
        return false
    }
}

class QMUINavigationController: UINavigationController {

    /// 记录当前是否正在 push/pop 界面的动画过程，如果动画尚未结束，不应该继续 push/pop 其他界面
    fileprivate var isViewControllerTransiting = false

    /// 即将要被pop的controller
    var viewControllerPopping: UIViewController?

    /**
     *  因为QMUINavigationController把delegate指向了自己来做一些基类要做的事情，所以如果当外面重新指定了delegate，那么就会覆盖原本的delegate。<br/>
     *  为了避免这个问题，并且外面也可以实现实现navigationController的delegate方法，这里使用delegateProxy来保存外面指定的delegate，然后在基类的delegate方法实现里面会去调用delegateProxy的方法实现。
     */
    var delegateProxy: UINavigationControllerDelegate?

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
    }

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
        interactivePopGestureRecognizer?.addTarget(self, action: #selector(handleInteractivePop))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 在这里为什么还需要调用一次，是因为如果把一个界面dismiss后回来这里，此时并不会调用navigationController:willShowViewController，但会调用viewWillAppear
        renderStyle(in: self, currentViewController: topViewController)
    }

    override func popViewController(animated: Bool) -> UIViewController? {
        isViewControllerTransiting = animated
        qmui_isPoppingViewController = true
        let viewController = topViewController
        viewControllerPopping = viewController
        if let vc = viewController as? QMUINavigationControllerDelegate {
            vc.willPopInNavigationController(with: animated)
            vc.didPopInNavigationController(with: animated)
        }
        return viewController
    }

    override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        // 从横屏界面pop 到竖屏界面，系统会调用两次 popViewController，如果这里加这个 if 判断，会误拦第二次 pop，导致错误
        //    if (self.isViewControllerTransiting) {
        //        NSAssert(NO, @"isViewControllerTransiting = YES, %s, self.viewControllers = %@", __func__, self.viewControllers)
        //        return nil
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

            if let vc = viewControllerPopping as? QMUINavigationControllerDelegate {
                let animatedArgument = i == viewControllers.count - 1 ? animated : false // 只有当前可视的那个 viewController 的 animated 是跟随参数走的，其他 viewController 由于不可视，不管参数的值为多少，都认为是无动画地 pop
                vc.willPopInNavigationController(with: animatedArgument)
            }
        }

        guard let poppedViewControllers = super.popToViewController(viewController, animated: animated) else {
            return nil
        }

        // did pop
        for (i, viewControllerPopped) in poppedViewControllers.reversed().enumerated() {
            if let vc = viewControllerPopped as? QMUINavigationControllerDelegate {
                let animatedArgument = i == poppedViewControllers.count - 1 ? animated : false // 只有当前可视的那个 viewController 的 animated 是跟随参数走的，其他 viewController 由于不可视，不管参数的值为多少，都认为是无动画地 pop
                vc.didPopInNavigationController(with: animatedArgument)
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
            if let vc = viewControllerPopping as? QMUINavigationControllerDelegate {
                let animatedArgument = i == viewControllers.count - 1 ? animated : false // 只有当前可视的那个 viewController 的 animated 是跟随参数走的，其他 viewController 由于不可视，不管参数的值为多少，都认为是无动画地 pop
                vc.willPopInNavigationController(with: animatedArgument)
            }
        }

        guard let poppedViewControllers = super.popToRootViewController(animated: animated) else {
            return nil
        }

        // did pop
        for (i, viewControllerPopped) in poppedViewControllers.reversed().enumerated() {
            if let vc = viewControllerPopped as? QMUINavigationControllerDelegate {
                let animatedArgument = i == poppedViewControllers.count - 1 ? animated : false // 只有当前可视的那个 viewController 的 animated 是跟随参数走的，其他 viewController 由于不可视，不管参数的值为多少，都认为是无动画地 pop
                vc.didPopInNavigationController(with: animatedArgument)
            }
        }

        return poppedViewControllers
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if isViewControllerTransiting {
            assert(false, "isViewControllerTransiting = YES, \(#function), self.viewControllers = \(viewControllers)")
        }

        isViewControllerTransiting = true

        if let currentViewController = topViewController {
            if NeedsBackBarButtonItemTitle {
                currentViewController.navigationItem.backBarButtonItem = QMUINavigationButton.barButtonItem(with: .normal, title: "", position: .left, target: nil, action: nil)
            } else {
                if let vc = viewController as? QMUINavigationControllerDelegate {
                    let title = vc.backBarButtonItemTitle(with: currentViewController)
                    currentViewController.navigationItem.backBarButtonItem = QMUINavigationButton.barButtonItem(with: .normal, title: title, position: .left, target: nil, action: nil)
                }
            }
        }

        super.pushViewController(viewController, animated: animated)
    }

    override var delegate: UINavigationControllerDelegate? {
        didSet {
            delegateProxy = (delegate as? QMUINavigationController == nil ? delegate : nil)
        }
    }

    // MARK: - 自定义方法

    // 根据当前的viewController，统一处理导航栏底部的分隔线、状态栏的颜色
    func renderStyle(in _: UINavigationController, currentViewController: UIViewController?) {
        if let vc = currentViewController as? QMUINavigationControllerDelegate {
            // 控制界面的状态栏颜色
            if vc.shouldSetStatusBarStyleLight {
                if UIApplication.shared.statusBarStyle.rawValue < UIStatusBarStyle.lightContent.rawValue {
                    QMUIHelper.renderStatusBarStyleLight()
                }
            } else {
                if UIApplication.shared.statusBarStyle.rawValue >= UIStatusBarStyle.lightContent.rawValue {
                    QMUIHelper.renderStatusBarStyleDark()
                }
            }

            // 导航栏的背景
            let backgroundImage = vc.navigationBarBackgroundImage
            if backgroundImage != UIImage() {
                navigationBar.setBackgroundImage(backgroundImage, for: .default)
            } else {
                navigationBar.setBackgroundImage(NavBarBackgroundImage, for: .default)
            }

            // 导航栏底部的分隔线
            let shadowImage = vc.navigationBarShadowImage
            if shadowImage != UIImage() {
                navigationBar.shadowImage = shadowImage
            } else {
                navigationBar.shadowImage = NavBarShadowImage
            }

            // 导航栏上控件的主题色
            let tintColor = vc.navigationBarTintColor
            if tintColor != UIColor.blue {
                navigationBar.tintColor = tintColor
            } else {
                navigationBar.tintColor = NavBarTintColor
            }

            // 导航栏title的颜色
            if let qmuiVC = currentViewController as? QMUICommonViewController {
                if qmuiVC.titleViewTintColor != UIColor.white {
                    let tintColor = qmuiVC.titleViewTintColor
                    qmuiVC.titleView?.tintColor = tintColor
                } else {
                    qmuiVC.titleView?.tintColor = QMUINavigationTitleView.appearance().tintColor
                }
            }
        }
    }

    // 接管系统手势返回的回调
    @objc func handleInteractivePop(gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        let state = gestureRecognizer.state
        if state == .ended {
            if (topViewController?.view.superview?.frame.minX ?? 0) < 0 {
                // by molice:只是碰巧发现如果是手势返回取消时，不管在哪个位置取消，self.topViewController.view.superview.frame.orgin.x必定是-124，所以用这个<0的条件来判断
                navigationController(self, willShow: viewControllerPopping!, animated: true)
                qmui_isPoppingViewController = false
                viewControllerPopping = nil
                isViewControllerTransiting = false
                print("手势返回放弃了")
            } else {
                print("执行手势返回")
            }
        }
    }
}

extension QMUINavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        renderStyle(in: navigationController, currentViewController: viewController)
        if let delegateProxy = delegateProxy, delegateProxy.responds(to: #selector(UINavigationControllerDelegate.navigationController(_:willShow:animated:))) {
            delegateProxy.navigationController!(navigationController, willShow: viewController, animated: animated)
        }
    }

    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        qmui_isPushingViewController = false
        qmui_isPoppingViewController = false
        viewControllerPopping = nil
        isViewControllerTransiting = false
        if let delegateProxy = delegateProxy, delegateProxy.responds(to: #selector(UINavigationControllerDelegate.navigationController(_:didShow:animated:))) {
            delegateProxy.navigationController!(navigationController, didShow: viewController, animated: animated)
        }
    }

    // http://stackoverflow.com/questions/26953559/in-swift-how-do-i-have-a-uiscrollview-subclass-that-has-an-internal-and-externa
    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        if delegateProxy?.responds(to: aSelector) == true {
            return delegateProxy
        } else {
            return super.forwardingTarget(for: aSelector)
        }
    }

    override func responds(to aSelector: Selector!) -> Bool {
        return super.responds(to: aSelector) || shouldRespondDelegeateProxy(with: aSelector) && (delegateProxy?.responds(to: aSelector) ?? false)
    }

    func shouldRespondDelegeateProxy(with selector: Selector) -> Bool {
        // 目前仅支持下面两个delegate方法，如果需要增加全局的自定义转场动画，可以额外增加多上面注释的两个方法。
        let strs = [
            "navigationController:didShowViewController:animated:",
            "navigationController:willShowViewController:animated:",
        ]
        return strs.contains("\(selector)")
    }
}
