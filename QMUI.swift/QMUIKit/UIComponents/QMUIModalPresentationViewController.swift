//
//  QMUIModalPresentationViewController.swift
//  QMUI.swift
//
//  Created by 黄伯驹 on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

@objc enum QMUIModalPresentationAnimationStyle: Int {
    case fade // 渐现渐隐，默认
    case popup // 从中心点弹出
    case slide // 从下往上升起
}

@objc protocol QMUIModalPresentationContentViewControllerProtocol {
    /**
     *  当浮层以 UIViewController 的形式展示（而非 UIView），并且使用 modalController 提供的默认布局时，则可通过这个方法告诉 modalController 当前浮层期望的大小
     *  @param  controller  当前的modalController
     *  @param  limitSize   浮层最大的宽高，由当前 modalController 的大小及 `contentViewMargins`、`maximumContentViewWidth` 决定
     *  @return 返回浮层在 `limitSize` 限定内的大小，如果业务自身不需要限制宽度/高度，则为 width/height 返回 `CGFLOAT_MAX` 即可
     */
    @objc optional func preferredContentSize(inModalPresentationViewController controller: QMUIModalPresentationViewController, limitSize: CGSize) -> CGSize
}

@objc protocol QMUIModalPresentationViewControllerDelegate {
    /**
     *  是否应该隐藏浮层，会在调用`hideWithAnimated:completion:`时，以及点击背景遮罩时被调用。默认为YES。
     *  @param  controller  当前的modalController
     *  @return 是否允许隐藏，YES表示允许隐藏，NO表示不允许隐藏
     */
    @objc optional func shouldHide(modalPresentationViewController controller: QMUIModalPresentationViewController) -> Bool

    /**
     *  modalController 即将隐藏时的回调方法，在调用完这个方法后才开始做一些隐藏前的准备工作，例如恢复 window 的 dimmed 状态等。
     *  @param  controller  当前的modalController
     */
    @objc optional func willHide(modalPresentationViewController controller: QMUIModalPresentationViewController)

    /**
     *  modalController隐藏后的回调方法，不管是直接调用`hideWithAnimated:completion:`，还是通过点击遮罩触发的隐藏，都会调用这个方法。
     *  如果你想区分这两种方式的隐藏回调，请直接使用hideWithAnimated方法的completion参数，以及`didHideByDimmingViewTappedBlock`属性。
     *  @param  controller  当前的modalController
     */
    @objc optional func didHide(modalPresentationViewController controller: QMUIModalPresentationViewController)

    @objc optional func requestHideAllModalPresentationViewController()
}

/**
 *  一个提供通用的弹出浮层功能的控件，可以将任意`UIView`或`UIViewController`以浮层的形式显示出来并自动布局。
 *
 *  支持 3 种方式显示浮层：
 *
 *  1. **推荐** 新起一个 `UIWindow` 盖在当前界面上，将 `QMUIModalPresentationViewController` 以 `rootViewController` 的形式显示出来，可通过 `supportedOrientationMask` 支持横竖屏，不支持在浮层不消失的情况下做界面切换（因为 window 会把背后的 controller 盖住，看不到界面切换）
 *  @code
 *  [modalPresentationViewController showWithAnimated:YES completion:nil]
 *  @endcode
 *
 *  2. 使用系统接口来显示，支持界面切换，**注意** 使用这种方法必定只能以动画的形式来显示浮层，无法以无动画的形式来显示，并且 `animated` 参数必须为 `NO`。可通过 `supportedOrientationMask` 支持横竖屏。
 *  @code
 *  [self presentViewController:modalPresentationViewController animated:NO completion:nil]
 *  @endcode
 *
 *  3. 将浮层作为一个 subview 添加到 `superview` 上，从而能够实现在浮层不消失的情况下进行界面切换，但需要 `superview` 自行管理浮层的大小和横竖屏旋转，而且 `QMUIModalPresentationViewController` 不能用局部变量来保存，会在显示后被释放，需要自行 retain。横竖屏跟随当前界面的设置。
 *  @code
 *  self.modalPresentationViewController.view.frame = CGRectMake(50, 50, 100, 100)
 *  [self.view addSubview:self.modalPresentationViewController.view]
 *  @endcode
 *
 *  默认的布局会将浮层居中显示，浮层的大小可通过接口控制：
 *  1. 如果是用 `contentViewController`，则可通过 `preferredContentSizeInModalPresentationViewController:limitSize:` 来设置
 *  2. 如果使用 `contentView`，或者使用 `contentViewController` 但没实现 `preferredContentSizeInModalPresentationViewController:limitSize:`，则调用`contentView`的`sizeThatFits:`方法获取大小。
 *  3. 浮层大小会受 `maximumContentViewWidth` 属性的限制，以及 `contentViewMargins` 属性的影响。
 *
 *  通过`layoutBlock`、`showingAnimation`、`hidingAnimation`可设置自定义的布局、打开及隐藏的动画，并允许你适配键盘升起时的场景。
 *
 *  默认提供背景遮罩`dimmingView`，你也可以使用自己的遮罩 view。
 *
 *  默认提供多种显示动画，可通过 `animationStyle` 来设置。
 *
 *  @warning 如果使用者retain了modalPresentationViewController，注意应该在`hideWithAnimated:completion:`里release
 *
 *  @see QMUIAlertController
 *  @see QMUIDialogViewController
 *  @see QMUIMoreOperationController
 */
class QMUIModalPresentationViewController: UIViewController {

    weak var delegate: QMUIModalPresentationViewControllerDelegate?

    /**
     *  要被弹出的浮层
     *  @warning 当设置了`contentView`时，不要再设置`contentViewController`
     */
    var contentView: UIView?

    /**
     *  要被弹出的浮层，适用于浮层以UIViewController的形式来管理的情况。
     *  @warning 当设置了`contentViewController`时，`contentViewController.view`会被当成`contentView`使用，因此不要再自行设置`contentView`
     *  @warning 注意`contentViewController`是强引用，容易导致循环引用，使用时请注意
     */
    var contentViewController: (UIViewController & QMUIModalPresentationContentViewControllerProtocol)? {
        didSet {
            contentView = contentViewController?.view
        }
    }

    /**
     *  设置`contentView`布局时与外容器的间距，默认为(20, 20, 20, 20)
     *  @warning 当设置了`layoutBlock`属性时，此属性不生效
     */
    @objc dynamic var contentViewMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)

    /**
     *  限制`contentView`布局时的最大宽度，默认为iPhone 6竖屏下的屏幕宽度减去`contentViewMargins`在水平方向的值，也即浮层在iPhone 6 Plus或iPad上的宽度以iPhone 6上的宽度为准。
     *  @warning 当设置了`layoutBlock`属性时，此属性不生效
     */
    var maximumContentViewWidth: CGFloat = QMUIHelper.screenSizeFor47Inch.width - UIEdgeInsets.init(top: 20, left: 20, bottom: 20, right: 20).horizontalValue

    /**
     *  背景遮罩，默认为一个普通的`UIView`，背景色为`UIColorMask`，可设置为自己的view，注意`dimmingView`的大小将会盖满整个控件。
     *
     *  `QMUIModalPresentationViewController`会自动给自定义的`dimmingView`添加手势以实现点击遮罩隐藏浮层。
     */
    private var _dimmingView:  UIView?
    var dimmingView: UIView? {
        get {
            return _dimmingView
        }
        set {
            if !isViewLoaded {
                _dimmingView = newValue
            } else {
                if let new = newValue, let old = _dimmingView {
                    view.insertSubview(new, aboveSubview: old)
                }
                _dimmingView?.removeFromSuperview()
                _dimmingView = newValue
                view.setNeedsLayout()
            }
            addTapGestureRecognizerToDimmingViewIfNeeded()
        }
    }

    /**
     *  由于点击遮罩导致浮层被隐藏时的回调（区分于`hideWithAnimated:completion:`里的completion，这里是特地用于点击遮罩的情况）
     */
    var didHideByDimmingViewTappedClosure: (() -> Void)?

    /**
     *  控制当前是否以模态的形式存在。如果以模态的形式存在，则点击空白区域不会隐藏浮层。
     *
     *  默认为false，也即点击空白区域将会自动隐藏浮层。
     */
    var isModal = false

    /**
     *  标志当前浮层的显示/隐藏状态，默认为false。
     */
    var isVisible = false

    /**
     *  修改当前界面要支持的横竖屏方向，默认为 SupportedOrientationMask。
     */
    var supportedOrientationMask: UIInterfaceOrientationMask = SupportedOrientationMask

    /**
     *  设置要使用的显示/隐藏动画的类型，默认为`QMUIModalPresentationAnimationStyleFade`。
     *  @warning 当使用了`showingAnimation`和`hidingAnimation`时，该属性无效
     */
    @objc dynamic var animationStyle: QMUIModalPresentationAnimationStyle = .fade
    
    /// 是否以 UIWindow 的方式显示，建议在显示之后才使用，否则可能不准确。
    private var isShownInWindowMode: Bool {
        return containerWindow != nil
    }
    
    /// 是否以系统 present 的方式显示，建议在显示之后才使用，否则可能不准确。
    private var isShownInPresentedMode: Bool {
        return !isShownInWindowMode && presentingViewController != nil && presentingViewController?.presentedViewController == self
    }
    
    /// 是否以 addSubview 的方式显示，建议在显示之后才使用，否则可能不准确。
    private var isShownInSubviewMode: Bool {
        return !isShownInPresentedMode && view.superview != nil
    }
    
    private var isShowingPresentedViewController: Bool {
        return isShownInPresentedMode && (presentedViewController != nil) && presentedViewController?.presentingViewController == self
    }

    /**
     *  管理自定义的浮层布局，将会在浮层显示前、控件的容器大小发生变化时（例如横竖屏、来电状态栏）被调用
     *  @arg  containerBounds         浮层所在的父容器的大小，也即`self.view.bounds`
     *  @arg  keyboardHeight          键盘在当前界面里的高度，若无键盘，则为0
     *  @arg  contentViewDefaultFrame 不使用自定义布局的情况下的默认布局，会受`contentViewMargins`、`maximumContentViewWidth`、`contentView sizeThatFits:`的影响
     *
     *  @see contentViewMargins
     *  @see maximumContentViewWidth
     */
    var layoutClosure: ((_ containerBounds: CGRect, _ keyboardHeight: CGFloat, _ contentViewDefaultFrame: CGRect) -> Void)?

    /**
     *  管理自定义的显示动画，需要管理的对象包括`contentView`和`dimmingView`，在`showingAnimation`被调用前，`contentView`已被添加到界面上。若使用了`layoutBlock`，则会先调用`layoutBlock`，再调用`showingAnimation`。在动画结束后，必须调用参数里的`completion` block。
     *  @arg  dimmingView         背景遮罩的View，请自行设置显示遮罩的动画
     *  @arg  containerBounds     浮层所在的父容器的大小，也即`self.view.bounds`
     *  @arg  keyboardHeight      键盘在当前界面里的高度，若无键盘，则为0
     *  @arg  contentViewFrame    动画执行完后`contentView`的最终frame，若使用了`layoutBlock`，则也即`layoutBlock`计算完后的frame
     *  @arg  completion          动画结束后给到modalController的回调，modalController会在这个回调里做一些状态设置，务必调用。
     */
    var showingAnimationClosure: ((_ dimmingView: UIView?, _ containerBounds: CGRect, _ keyboardHeight: CGFloat, _ contentViewFrame: CGRect, _ completion: ((Bool) -> Void)?) -> Void)?

    /**
     *  管理自定义的隐藏动画，需要管理的对象包括`contentView`和`dimmingView`，在动画结束后，必须调用参数里的`completion` block。
     *  @arg  dimmingView         背景遮罩的View，请自行设置隐藏遮罩的动画
     *  @arg  containerBounds     浮层所在的父容器的大小，也即`self.view.bounds`
     *  @arg  keyboardHeight      键盘在当前界面里的高度，若无键盘，则为0
     *  @arg  completion          动画结束后给到modalController的回调，modalController会在这个回调里做一些清理工作，务必调用
     */
    var hidingAnimationClosure: ((_ dimmingView: UIView?, _ containerBounds: CGRect, _ keyboardHeight: CGFloat, _ completion: ((Bool) -> Void)?) -> Void)?

    private var containerWindow: QMUIModalPresentationWindow?
    private weak var previousKeyWindow: UIWindow?

    private var appearAnimated = false
    private var appearCompletionClosure: ((Bool) -> Void)?

    private var disappearAnimated = false
    private var disappearCompletionClosure: ((Bool) -> Void)?

    /// 标志是否已经走过一次viewWillAppear了，用于hideInView的情况
    private var hasAlreadyViewWillDisappear = false

    private var dimmingViewTapGestureRecognizer: UITapGestureRecognizer?
    private var keyboardHeight: CGFloat = 0
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        didInitialized()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        didInitialized()
    }
    
    private func didInitialized() {
        animationStyle = .fade
        contentViewMargins = UIEdgeInsets.init(top: 20, left: 20, bottom: 20, right: 20)
        maximumContentViewWidth = QMUIHelper.screenSizeFor47Inch.width - contentViewMargins.horizontalValue
        
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .custom
        initDefaultDimmingViewWithoutAddToView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // 在 IB 里设置了 contentViewController 的话，通过这个调用去触发 contentView 的更新
        if let contentViewController = self.contentViewController {
            self.contentViewController = contentViewController
        }
    }

    deinit {
        containerWindow = nil
    }

    override var shouldAutomaticallyForwardAppearanceMethods: Bool {
        // 屏蔽对childViewController的生命周期函数的自动调用，改为手动控制
        return false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let dimmingView = dimmingView, dimmingView.superview == nil {
            view.addSubview(dimmingView)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        dimmingView?.frame = view.bounds

        let contentViewFrame = contentViewFrameForShowing
        if let layoutClosure = layoutClosure {
            layoutClosure(view.bounds, keyboardHeight, contentViewFrame)
        } else {
            contentView?.frame = contentViewFrame
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        var _animated = animated

        if containerWindow != nil {
            // 只有使用showWithAnimated:completion:显示出来的浮层，才需要修改之前就记住的animated的值
            _animated = appearAnimated
        }

        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        if contentViewController != nil {
            contentViewController!.qmui_modalPresentationViewController = self
            contentViewController!.beginAppearanceTransition(true, animated: _animated)
        }
        
        // 如果是因为 present 了新的界面再从那边回来，导致走到 viewWillAppear，则后面那些升起浮层的操作都可以不用做了，因为浮层从来没被降下去过
        let willAppearByPresentedViewController = isShowingPresentedViewController
        if willAppearByPresentedViewController {
            return
        }

        if isShownInWindowMode {
            QMUIHelper.dimmedApplicationWindow()
        }
        
        let didShownCompletion: (Bool) -> Void = {
            self.contentViewController?.endAppearanceTransition()

            self.isVisible = true

            if let appearCompletionClosure = self.appearCompletionClosure {
                appearCompletionClosure($0)
                self.appearCompletionClosure = nil
            }

            self.appearAnimated = false
        }

        if _animated {
            view.addSubview(contentView!)
            view.layoutIfNeeded()

            var contentViewFrame = contentViewFrameForShowing
            if let showingAnimationClosure = showingAnimationClosure {
                // 使用自定义的动画
                if let layoutClosure = layoutClosure {
                    layoutClosure(view.bounds, keyboardHeight, contentViewFrame)
                    contentViewFrame = contentView!.frame
                }
                showingAnimationClosure(dimmingView, view.bounds, keyboardHeight, contentViewFrame, didShownCompletion)
            } else {
                contentView?.frame = contentViewFrame
                contentView?.setNeedsLayout()
                contentView?.layoutIfNeeded()

                showingAnimation(didShownCompletion)
            }
        } else {
            let contentViewFrame = contentViewFrameForShowing
            contentView?.frame = contentViewFrame
            view.addSubview(contentView!)
            dimmingView?.alpha = 1
            didShownCompletion(true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if hasAlreadyViewWillDisappear {
            return
        }
        
        super.viewWillDisappear(animated)
        
        var _animated = animated
        
        if isShownInWindowMode {
            _animated = disappearAnimated
        }
        
        let willDisappearByPresentedViewController = isShowingPresentedViewController
        if !willDisappearByPresentedViewController {
            delegate?.willHide?(modalPresentationViewController: self)
        }
        
        // 在降下键盘前取消对键盘事件的监听，从而避免键盘影响隐藏浮层的动画
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // 如果是因为 present 了新的界面导致走到 willDisappear，则后面那些降下浮层的操作都可以不用做了
        if willDisappearByPresentedViewController {
            return
        }
        
        if isShownInWindowMode {
            QMUIHelper.resetDimmedApplicationWindow()
        }
        
        contentViewController?.beginAppearanceTransition(false, animated: _animated)
        
        let didHiddenCompletion: (Bool) -> Void = {_ in
            if self.isShownInWindowMode {
                // 恢复 keyWindow 之前做一下检查，避免这个问题 https://github.com/QMUI/QMUI_iOS/issues/90
                if UIApplication.shared.keyWindow == self.containerWindow {
                    self.previousKeyWindow?.makeKey()
                }
                self.containerWindow?.isHidden = true
                self.containerWindow?.rootViewController = nil
                self.previousKeyWindow = nil
                self.endAppearanceTransition()
            }
            
            if self.isShownInSubviewMode {
                // 这句是给addSubview的形式显示的情况下使用，但会触发第二次viewWillDisappear:，所以要搭配self.hasAlreadyViewWillDisappear使用
                self.view.removeFromSuperview()
                self.hasAlreadyViewWillDisappear = false
            }
            
            self.contentView?.removeFromSuperview()
            self.contentViewController?.endAppearanceTransition()
            
            self.isVisible = false

            self.delegate?.didHide?(modalPresentationViewController: self)
            
            if let disappearCompletionClosure = self.disappearCompletionClosure {
                disappearCompletionClosure(true)
                self.disappearCompletionClosure = nil
            }
            
            if self.contentViewController != nil {
                self.contentViewController!.qmui_modalPresentationViewController = nil
                self.contentViewController = nil
            }
            
            self.disappearAnimated = false
        }
        
        if _animated {
            if let hidingAnimationClosure = hidingAnimationClosure {
                hidingAnimationClosure(dimmingView, view.bounds, keyboardHeight, didHiddenCompletion)
            } else {
                hidingAnimation(didHiddenCompletion)
            }
        } else {
            didHiddenCompletion(true)
        }
    }

    private func initDefaultDimmingViewWithoutAddToView() {
        guard dimmingView == nil else {
            return
        }
        dimmingView = UIView()
        dimmingView!.backgroundColor = UIColorMask
        addTapGestureRecognizerToDimmingViewIfNeeded()
        if isViewLoaded {
            view.addSubview(dimmingView!)
        }
    }

    // 要考虑用户可能创建了自己的dimmingView，则tap手势也要重新添加上去
    private func addTapGestureRecognizerToDimmingViewIfNeeded() {
        guard let dimmingView = dimmingView else { return }

        if dimmingViewTapGestureRecognizer?.view == dimmingView {
            return
        }

        if dimmingViewTapGestureRecognizer == nil {
            dimmingViewTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDimmingViewTapGestureRecognizer(_:)))
        }
        dimmingView.addGestureRecognizer(dimmingViewTapGestureRecognizer!)
        dimmingView.isUserInteractionEnabled = true // UIImageView默认userInteractionEnabled为NO，为了兼容UIImageView，这里必须主动设置为YES
    }

    @objc func handleDimmingViewTapGestureRecognizer(_: UITapGestureRecognizer) {
        if isModal {
            return
        }
        
        if isShownInWindowMode {
            hide(true, completion: { [weak self] _ in
                self?.didHideByDimmingViewTappedClosure?()
            })
        } else if isShownInPresentedMode {
            dismiss(animated: true) {
                self.didHideByDimmingViewTappedClosure?()
            }
        } else if isShownInSubviewMode {
            hide(in: view.superview!, animated: true) { [weak self] _ in
                self?.didHideByDimmingViewTappedClosure?()
            }
        }
    }
    
    /**
     *  请求重新计算浮层的布局
     */
    func updateLayout() {
        if isViewLoaded {
            view.setNeedsLayout()
        }
    }

    // MARK: - Showing and Hiding

    private func showingAnimation(_ completion: ((Bool) -> Void)?) {
        if animationStyle == .fade {
            dimmingView?.alpha = 0.0
            contentView?.alpha = 0.0
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveOut, animations: {
                self.dimmingView?.alpha = 1.0
                self.contentView?.alpha = 1.0
            }, completion: completion)
        } else if animationStyle == .popup {
            dimmingView?.alpha = 0.0
            contentView?.transform = CGAffineTransform(scaleX: 0, y: 0)
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveOut, animations: {
                self.dimmingView?.alpha = 1.0
                self.contentView?.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: { finished in
                self.contentView?.transform = .identity
                completion?(finished)
            })
        } else if animationStyle == .slide {
            dimmingView?.alpha = 0.0
            contentView?.transform = CGAffineTransform(translationX: 0, y: view.bounds.height - contentView!.frame.minY)

            UIView.animate(withDuration: 0.3, delay: 0, options: .curveOut, animations: {
                self.dimmingView?.alpha = 1.0
                self.contentView?.transform = .identity
            }, completion: completion)
        }
    }

    /**
     *  将浮层以 UIWindow 的方式显示出来
     *  @param animated    是否以动画的形式显示
     *  @param completion  显示动画结束后的回调
     */
    func show(_ animated: Bool, completion: ((Bool) -> Void)?) {
        // makeKeyAndVisible 导致的 viewWillAppear: 必定 animated 是 NO 的，所以这里用额外的变量保存这个 animated 的值
        appearAnimated = animated
        appearCompletionClosure = completion
        previousKeyWindow = UIApplication.shared.keyWindow
        if containerWindow == nil {
            containerWindow = QMUIModalPresentationWindow()
            containerWindow?.windowLevel = UIWindow.Level(rawValue: UIWindowLevelQMUIAlertView)
            containerWindow?.backgroundColor = UIColorClear // 避免横竖屏旋转时出现黑色
        }

        supportedOrientationMask = QMUIHelper.visibleViewController?.supportedInterfaceOrientations ?? supportedOrientationMask
        containerWindow?.rootViewController = self
        containerWindow?.makeKeyAndVisible()
    }

    private func hidingAnimation(_ completion: ((Bool) -> Void)?) {
        if animationStyle == .fade {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveOut, animations: {
                self.dimmingView?.alpha = 0.0
                self.contentView?.alpha = 0.0
            }, completion: completion)
        } else if animationStyle == .popup {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveOut, animations: {
                self.dimmingView?.alpha = 0.0
                self.contentView?.transform = CGAffineTransform(scaleX: 0, y: 0)
            }, completion: { finished in
                if let completion = completion {
                    self.contentView?.transform = .identity
                    completion(finished)
                }
            })
        } else if animationStyle == .slide {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveOut, animations: {
                self.dimmingView?.alpha = 0.0
                self.contentView?.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height - self.contentView!.frame.minY)
            }, completion: { finished in
                if let completion = completion {
                    self.contentView?.transform = .identity
                    completion(finished)
                }
            })
        }
    }

    /**
     *  将浮层隐藏掉
     *  @param animated    是否以动画的形式隐藏
     *  @param completion  隐藏动画结束后的回调
     *  @warning 这里的`completion`只会在你显式调用`hideWithAnimated:completion:`方法来隐藏浮层时会被调用，如果你通过点击`dimmingView`来触发`hideWithAnimated:completion:`，则completion是不会被调用的，那种情况下如果你要在浮层隐藏后做一些事情，请使用`delegate`提供的`didHideModalPresentationViewController:`方法。
     */
    func hide(_ animated: Bool, completion: ((Bool) -> Void)?) {
        disappearAnimated = animated
        disappearCompletionClosure = completion

        let shouldHide = delegate?.shouldHide?(modalPresentationViewController: self) ?? true

        if !shouldHide {
            return
        }

        // window模式下，通过手动触发viewWillDisappear:来做界面消失的逻辑
        if containerWindow != nil {
            beginAppearanceTransition(false, animated: animated)
        }
    }

    /**
     *  将浮层以 addSubview 的方式显示出来
     *
     *  @param view         要显示到哪个 view 上
     *  @param animated     是否以动画的形式显示
     *  @param completion   显示动画结束后的回调
     */
    func show(in view: UIView, animated: Bool, completion: ((Bool) -> Void)?) {
        appearCompletionClosure = completion
        if #available(iOS 9.0, *) {
            loadViewIfNeeded()
        }
        beginAppearanceTransition(true, animated: animated)
        view.addSubview(self.view)
        endAppearanceTransition()
    }

    /**
     *  将某个 view 上显示的浮层隐藏掉
     *  @param view         要隐藏哪个 view 上的浮层
     *  @param animated     是否以动画的形式隐藏
     *  @param completion   隐藏动画结束后的回调
     *  @warning 这里的`completion`只会在你显式调用`hideInView:animated:completion:`方法来隐藏浮层时会被调用，如果你通过点击`dimmingView`来触发`hideInView:animated:completion:`，则completion是不会被调用的，那种情况下如果你要在浮层隐藏后做一些事情，请使用`delegate`提供的`didHideModalPresentationViewController:`方法。
     */
    func hide(in view: UIView, animated: Bool, completion: ((Bool) -> Void)?) {
        disappearCompletionClosure = completion
        beginAppearanceTransition(false, animated: animated)
        hasAlreadyViewWillDisappear = true
        endAppearanceTransition()
    }

    private var contentViewFrameForShowing: CGRect {
        let contentViewContainerSize = CGSize(width: view.bounds.width - contentViewMargins.horizontalValue, height: view.bounds.height - keyboardHeight - contentViewMargins.verticalValue)
        let contentViewLimitSize = CGSize(width: min(maximumContentViewWidth, contentViewContainerSize.width), height: contentViewContainerSize.height)
        var contentViewSize = CGSize.zero
        if let contentViewController = contentViewController {
            contentViewSize = contentViewController.preferredContentSize?(inModalPresentationViewController: self, limitSize: contentViewLimitSize) ?? .zero
        } else {
            contentViewSize = contentView!.sizeThatFits(contentViewLimitSize)
        }
        contentViewSize.width = min(contentViewLimitSize.width, contentViewSize.width)
        contentViewSize.height = min(contentViewLimitSize.height, contentViewSize.height)
        var contentViewFrame = CGRect(x: contentViewContainerSize.width.center(contentViewSize.width) + contentViewMargins.left,
                                      y: contentViewContainerSize.height.center(contentViewSize.height) + contentViewMargins.top,
                                      width: contentViewSize.width,
                                      height: contentViewSize.height)

        // showingAnimation、hidingAnimation里会通过设置contentView的transform来做动画，所以可能在showing的过程中设置了transform后，系统触发viewDidLayoutSubviews，在viewDidLayoutSubviews里计算的frame又是最终状态的frame，与showing时的transform冲突，导致动画过程中浮层跳动或者位置错误，所以为了保证layout时计算出来的frame与showing/hiding时计算的frame一致，这里给frame应用了transform。但这种处理方法也有局限：如果你在showingAnimation/hidingAnimation里对contentView.frame的更改不是通过修改transform而是直接修改frame来得到结果，那么这里这句CGRectApplyAffineTransform就没用了，viewDidLayoutSubviews里算出来的frame依然会和showingAnimation/hidingAnimation冲突。
        contentViewFrame = contentViewFrame.applying(contentView!.transform)
        return contentViewFrame
    }

    // MARK: - Keyboard

    @objc func handleKeyboardWillShow(_ notification: Notification) {
        let keyboardHeight = QMUIHelper.keyboardHeight(notification, in: view)
        if keyboardHeight > 0 {
            self.keyboardHeight = keyboardHeight
            view.setNeedsLayout()
        }
    }

    @objc func handleKeyboardWillHide(_ notification: NSNotification) {
        keyboardHeight = 0
        view.setNeedsLayout()
    }

    // MARK: - 屏幕旋转
    override var shouldAutorotate: Bool {
        let visibleViewController = QMUIHelper.visibleViewController
        if visibleViewController != self {
            return visibleViewController?.shouldAutorotate ?? true
        }
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        let visibleViewController = QMUIHelper.visibleViewController
        if visibleViewController != self {
            return visibleViewController?.supportedInterfaceOrientations ?? supportedOrientationMask
        }
        return supportedOrientationMask
    }
    
    // MARK: - 屏幕旋转
    override var preferredStatusBarStyle: UIStatusBarStyle {
        let style: UIStatusBarStyle = StatusbarStyleLightInitially ? .lightContent : .default
        return style
    }
}

// MARK: - Manager
extension QMUIModalPresentationViewController {
    /**
     *  判断当前App里是否有modalViewController正在显示（存在modalViewController但不可见的时候，也视为不存在）
     *  @return 只要存在正在显示的浮层，则返回true，否则返回false
     */
    static var isAnyModalPresentationViewControllerVisible: Bool {
        for window in UIApplication.shared.windows {
            if window is QMUIModalPresentationWindow && !window.isHidden {
                return true
            }
        }
        return false
    }

    /**
     *  把所有正在显示的并且允许被隐藏的modalViewController都隐藏掉
     *  @return 只要遇到一个正在显示的并且不能被隐藏的浮层，就会返回false，否则都返回true，表示成功隐藏掉所有可视浮层
     *  @see    shouldHideModalPresentationViewController:
     */
    static var hideAllVisibleModalPresentationViewControllerIfCan: Bool {
        var hideAllFinally = true

        for window in UIApplication.shared.windows {
            if !(window is QMUIModalPresentationWindow) {
                continue
            }

            // 存在modalViewController，但并没有显示出来，所以不用处理
            if window.isHidden {
                continue
            }

            // 存在window，但不存在modalViewController，则直接把这个window移除
            if window.rootViewController == nil {
                window.isHidden = true
                continue
            }

            let modalViewController = window.rootViewController as? QMUIModalPresentationViewController
            
            let canHide = modalViewController?.delegate?.shouldHide?(modalPresentationViewController: modalViewController!) ?? true

            if canHide {
                if let delegate = modalViewController?.delegate {
                    delegate.requestHideAllModalPresentationViewController?()
                } else {
                    modalViewController!.hide(false, completion: nil)
                }
            } else {
                // 只要有一个modalViewController正在显示但却无法被隐藏，就返回NO
                hideAllFinally = false
            }
        }

        return hideAllFinally
    }
}

/// 专用于QMUIModalPresentationViewController的UIWindow，这样才能在`[[UIApplication sharedApplication] windows]`里方便地区分出来
fileprivate class QMUIModalPresentationWindow: UIWindow {}

extension UIViewController {

    private struct Keys {
        static var modalPresentationViewController = "ModalPresentationViewController"
    }

    fileprivate(set) var qmui_modalPresentationViewController: QMUIModalPresentationViewController? {
        set {
            if let vc = newValue {
                objc_setAssociatedObject(self, &Keys.modalPresentationViewController, vc, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
        get {
            return objc_getAssociatedObject(self, &Keys.modalPresentationViewController) as? QMUIModalPresentationViewController
        }
    }
}
