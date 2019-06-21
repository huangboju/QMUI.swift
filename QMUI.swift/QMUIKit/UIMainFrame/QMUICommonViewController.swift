
//  QMUICommonViewController.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/1/17.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

/**
 *  可作为项目内所有 `UIViewController` 的基类，提供的功能包括：
 *
 *  1. 自带顶部标题控件 `QMUINavigationTitleView`，支持loading、副标题、下拉菜单，设置标题依然使用系统的 `setTitle:` 方法
 *
 *  2. 自带空界面控件 `QMUIEmptyView`，支持显示loading、空文案、操作按钮
 *
 *  3. 自动在 `dealloc` 时移除所有注册到 `NSNotificationCenter` 里的监听，避免野指针 crash
 *
 *  4. 统一约定的常用接口，例如初始化 subview、设置顶部 `navigationItem`、底部 `toolbarItem`、响应系统的动态字体大小变化、...，从而保证相同类型的代码集中到同一个方法内，避免多人交叉维护时代码分散难以查找
 *
 *  5. 配合 `QMUINavigationController` 使用时，可以得到 `willPopInNavigationControllerWithAnimated:`、`didPopInNavigationControllerWithAnimated:` 这两个时机
 *
 *  @see QMUINavigationTitleView
 *  @see QMUIEmptyView
 */
class QMUICommonViewController: UIViewController {

    /**
     *  QMUICommonViewController默认都会增加一个QMUINavigationTitleView的titleView，然后重写了setTitle来间接设置titleView的值。所以设置title的时候就跟系统的接口一样：self.title = xxx。
     *
     *  同时，QMUINavigationTitleView提供了更多的功能，具体可以参考QMUINavigationTitleView的文档。<br/>
     *  @see QMUINavigationTitleView
     */
    var titleView: QMUINavigationTitleView!
    
    /**
     *  修改当前界面要支持的横竖屏方向，默认为 SupportedOrientationMask
     */
    var supportedOrientationMask: UIInterfaceOrientationMask!
    
    fileprivate var _hideKeyboardTapGestureRecognizer: UITapGestureRecognizer!
    fileprivate var _hideKeyboardManager: QMUIKeyboardManager!
    fileprivate var _hideKeyboadDelegateObject: QMUIViewControllerHideKeyboardDelegateObject!

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        didInitialized()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        didInitialized()
    }

    func didInitialized() {
        titleView = QMUINavigationTitleView()
        titleView.title = title // 从 storyboard 初始化的话，可能带有 self.title 的值
        
        hidesBottomBarWhenPushed = HidesBottomBarWhenPushedInitially

        // 不管navigationBar的backgroundImage如何设置，都让布局撑到屏幕顶部，方便布局的统一
        extendedLayoutIncludesOpaqueBars = true

        supportedOrientationMask = SupportedOrientationMask

        // 动态字体notification
        NotificationCenter.default.addObserver(self, selector: #selector(contentSizeCategoryDidChanged(_:)), name: UIContentSizeCategory.didChangeNotification, object: nil)
    }

    override var title: String? {
        didSet {
            titleView?.title = title
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if view.backgroundColor == nil {
            view.backgroundColor = UIColorForBackground
        }
        
        // 点击空白区域降下键盘 QMUICommonViewController (QMUIKeyboard)
        _hideKeyboadDelegateObject = QMUIViewControllerHideKeyboardDelegateObject(self)
        _hideKeyboardTapGestureRecognizer = UITapGestureRecognizer(target: nil, action: nil)
        hideKeyboardTapGestureRecognizer.delegate = _hideKeyboadDelegateObject
        hideKeyboardTapGestureRecognizer.isEnabled = true
        view.addGestureRecognizer(hideKeyboardTapGestureRecognizer)
        
        _hideKeyboardManager = QMUIKeyboardManager(with: _hideKeyboadDelegateObject)
        
        initSubviews()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutEmptyView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationItems(false, animated: false)
        setToolbarItems(isInEditMode: false, animated: false)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - 空列表视图 QMUIEmptyView
    
    /**
     *  空列表控件，支持显示提示文字、loading、操作按钮
     */
    var emptyView: QMUIEmptyView?
    
    /// 当前self.emptyView是否显示
    var isEmptyViewShowing: Bool {
        return emptyView != nil && emptyView?.superview != nil
    }
    
    /**
     *  显示emptyView，将其放到tableFooterView。emptyView的系列接口可以按需进行重写
     *
     *  @see QMUIEmptyView
     *  @warning 如果是用在TableViewController的tableFooterView中，确保此时tableView的numberOfRows为空
     */
    @objc func showEmptyView() {
        if emptyView == nil {
            emptyView = QMUIEmptyView(frame: view.bounds)
        }
        view.addSubview(emptyView!)
    }
    
    /**
     *  隐藏emptyView
     */
    @objc func hideEmptyView() {
        emptyView?.removeFromSuperview()
    }

    /**
     *  显示loading的emptyView
     */
    func showEmptyViewWithLoading() {
        showEmptyView()
        guard let emptyView = emptyView else { return }
        emptyView.set(image: nil)
        emptyView.setLoadingViewHidden(false)
        emptyView.setTextLabel(nil)
        emptyView.setDetailTextLabel(nil)
        emptyView.setActionButtonTitle(nil)
    }
    
    /**
     *  显示带loading、image、text、detailText、button的emptyView，带了with 防止与 showEmptyView() 混淆
     */
    func showEmptyViewWith(showLoading: Bool = false,
                           image: UIImage? = nil,
                           text: String?,
                           detailText: String?,
                           buttonTitle: String?,
                           buttonAction: Selector?) {
        showEmptyView()
        guard let emptyView = emptyView else { return }
        emptyView.setLoadingViewHidden(!showLoading)
        emptyView.set(image: image)
        emptyView.setTextLabel(text)
        emptyView.setDetailTextLabel(detailText)
        emptyView.setActionButtonTitle(buttonTitle)
        emptyView.actionButton.removeTarget(nil, action: nil, for: .allEvents)
        guard let buttonAction = buttonAction else { return }
        emptyView.actionButton.addTarget(self, action: buttonAction, for: .touchUpInside)
    }

    /**
     *  布局emptyView，如果emptyView没有被初始化或者没被添加到界面上，则直接忽略掉。
     *
     *  如果有特殊的情况，子类可以重写，实现自己的样式
     *
     *  @return YES表示成功进行一次布局，NO表示本次调用并没有进行布局操作（例如emptyView还没被初始化）
     */
    @discardableResult
    func layoutEmptyView() -> Bool {
        if let emptyView = emptyView {
            // 由于为self.emptyView设置frame时会调用到self.view，为了避免导致viewDidLoad提前触发，这里需要判断一下self.view是否已经被初始化
            if emptyView.superview != nil && isViewLoaded {
                let newEmptyViewSize = emptyView.superview!.bounds.size
                let oldEmptyViewSize = emptyView.frame.size
                if !(newEmptyViewSize == oldEmptyViewSize) {
                    self.emptyView!.frame = CGRect(origin: emptyView.frame.origin, size: newEmptyViewSize)
                }
                return true
            }
        }
        return false
    }

    // MARK: - 屏幕旋转
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return supportedOrientationMask
    }
}

extension QMUICommonViewController: QMUINavigationControllerDelegate {

    var shouldSetStatusBarStyleLight: Bool {
        return StatusbarStyleLightInitially
    }
    
    var preferredNavigationBarHidden: Bool {
        return NavigationBarHiddenInitially
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return StatusbarStyleLightInitially ? .lightContent : .default
    }
    
    func viewControllerKeepingAppearWhenSetViewControllers(_ animated: Bool) {
        // 通常和 viewWillAppear: 里做的事情保持一致
        setNavigationItems(false, animated: false)
        setToolbarItems(isInEditMode: false, animated: false)
    }
}

// MARK: QMUISubclassingHooks
// @objc 的作用是，让子类可以重写 extension 中的方法
extension QMUICommonViewController {
    
    /**
     *  负责初始化和设置controller里面的view，也就是self.view的subView。目的在于分类代码，所以与view初始化的相关代码都写在这里。
     *
     *  @warning initSubviews只负责subviews的init，不负责布局。布局相关的代码应该写在 <b>viewDidLayoutSubviews</b>
     */
    @objc func initSubviews() {
        // 子类重写
    }

    /**
     *  负责设置和更新navigationItem，包括title、leftBarButtonItem、rightBarButtonItem。viewDidLoad里面会自动调用，允许手动调用更新。目的在于分类代码，所有与navigationItem相关的代码都写在这里。在需要修改navigationItem的时候都只调用这个接口。
     *
     *  @param isInEditMode 是否用于编辑模式下
     *  @param animated     是否使用动画呈现
     */
    @objc func setNavigationItems(_ isInEditMode: Bool, animated: Bool) {
        // 子类重写
        navigationItem.titleView = titleView
    }

    /**
     *  负责设置和更新toolbarItem。在viewWillAppear里面自动调用（因为toolbar是navigationController的，是每个界面公用的，所以必须在每个界面的viewWillAppear时更新，不能放在viewDidLoad里），允许手动调用。目的在于分类代码，所有与toolbarItem相关的代码都写在这里。在需要修改toolbarItem的时候都只调用这个接口。
     *
     *  @param isInEditMode 是否用于编辑模式下
     *  @param animated     是否使用动画呈现
     */
    @objc func setToolbarItems(isInEditMode: Bool, animated: Bool) {
        // 子类重写
    }

    /**
     *  动态字体的回调函数。
     *
     *  交给子类重写，当系统字体发生变化的时候，会调用这个方法，一些font的设置或者reloadData可以放在里面
     *
     *  @param notification test
     */
    @objc func contentSizeCategoryDidChanged(_ notification: Notification) {
        // 子类重写
    }
}

/**
 *  为了方便实现“点击空白区域降下键盘”的需求，QMUICommonViewController 内部集成一个 tap 手势对象并添加到 self.view 上，而业务只需要通过重写 -shouldHideKeyboardWhenTouchInView: 方法并根据当前被点击的 view 返回一个 BOOL 来控制键盘的显隐即可。
 *  @note 为了避免不必要的事件拦截，集成的手势 hideKeyboardTapGestureRecognizer：
 *  1. 默认的 enabled = NO。
 *  2. 如果当前 viewController 或其父类（非 QMUICommonViewController 那个层级的父类）没重写 -shouldHideKeyboardWhenTouchInView:，则永远 enabled = NO。
 *  3. 在键盘升起时，并且当前 viewController 重写了 -shouldHideKeyboardWhenTouchInView: 且处于可视状态下，此时手势的 enabled 才会被修改为 YES，并且在键盘消失时置为 NO。
 */
extension QMUICommonViewController {
    
    /// 在 viewDidLoad 内初始化，并且 gestureRecognizerShouldBegin: 必定返回 NO。
    public var hideKeyboardTapGestureRecognizer: UITapGestureRecognizer! {
        return _hideKeyboardTapGestureRecognizer
    }
    public var hideKeyboardManager: QMUIKeyboardManager! {
        return _hideKeyboardManager
    }
    
    /**
     *  当用户点击界面上某个 view 时，如果此时键盘处于升起状态，则可通过重写这个方法并返回一个 true 来达到“点击空白区域自动降下键盘”的需求。默认返回 false，也即不处理键盘。
     *  @warning 注意如果被点击的 view 本身消耗了事件（iOS 11 下测试得到这种类型的所有系统的 view 仅有 UIButton 和 UISwitch），则这个方法并不会被触发。
     *  @warning 有可能参数传进去的 view 是某个 subview 的 subview，所以建议用 isDescendantOfView: 来判断是否点到了某个目标 subview
     */
    @objc func shouldHideKeyboardWhenTouch(in view: UIView) -> Bool {
        // 子类重写，默认返回 false，也即不主动干预键盘的状态
        return false;
    }
}

fileprivate class QMUIViewControllerHideKeyboardDelegateObject: NSObject {
    
    weak var viewController: QMUICommonViewController!
    
    init(_ viewController: QMUICommonViewController) {
        self.viewController = viewController
    }
    
}

extension QMUIViewControllerHideKeyboardDelegateObject: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer != viewController.hideKeyboardTapGestureRecognizer {
            return true
        }
        
        if !QMUIKeyboardManager.isKeyboardVisible {
            return false
        }
        
        guard let targetView = gestureRecognizer.qmui_targetView else { return false }
        
        // 点击了本身就是输入框的 view，就不要降下键盘了
        if targetView is UITextField || targetView is UITextView {
            return false
        }
        
        if viewController.shouldHideKeyboardWhenTouch(in: targetView) {
            viewController.view.endEditing(true)
        }
        
        return false
    }
    
}

extension QMUIViewControllerHideKeyboardDelegateObject: QMUIKeyboardManagerDelegate {
    
    func keyBoardWillShow(_ userInfo: QMUIKeyboardUserInfo?) {
        if !viewController.qmui_isViewLoadedAndVisible {
            return
        }
        
        let hasOverrideMethod = viewController.qmui_hasOverrideMethod(selector: #selector(QMUICommonViewController.shouldHideKeyboardWhenTouch(in:)), of: QMUICommonViewController.self)
        viewController.hideKeyboardTapGestureRecognizer?.isEnabled = hasOverrideMethod
    }
    
    func keyboardWillHide(_ userInfo: QMUIKeyboardUserInfo?) {
        viewController.hideKeyboardTapGestureRecognizer?.isEnabled = false
    }
}
