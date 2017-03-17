//
//  QMUICommonViewController.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/1/17.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

class QMUICommonViewController: UIViewController {

    var titleView: QMUINavigationTitleView?
    var supportedOrientationMask: UIInterfaceOrientationMask?

    var emptyView: QMUIEmptyView?

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
        hidesBottomBarWhenPushed = HidesBottomBarWhenPushedInitially

        // 不管navigationBar的backgroundImage如何设置，都让布局撑到屏幕顶部，方便布局的统一
        extendedLayoutIncludesOpaqueBars = true

        supportedOrientationMask = SupportedOrientationMask

        // 动态字体notification
        if IS_RESPOND_DYNAMICTYPE {
            NotificationCenter.default.addObserver(self, selector: #selector(contentSizeCategoryDidChanged), name: .UIContentSizeCategoryDidChange, object: nil)
        }
    }

    override var title: String? {
        didSet {
            titleView?.title = title
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColorForBackground

        initSubviews()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutEmptyView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationItems(isInEditMode: false, animated: false)
        setToolbarItems(isInEditMode: false, animated: false)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - 空列表视图 QMUIEmptyView
    /** 
     *  显示emptyView，将其放到tableFooterView。emptyView的系列接口可以按需进行重写
     *
     *  @see QMUIEmptyView
     *  @warning 如果是用在TableViewController的tableFooterView中，确保此时tableView的numberOfRows为空
     */
    func showEmptyView() {
        if emptyView == nil {
            emptyView = QMUIEmptyView(frame: view.bounds)
        }
        view.addSubview(emptyView!)
    }

    /** 
     *  隐藏emptyView
     */
    func hideEmptyView() {
        emptyView?.removeFromSuperview()
    }

    var isEmptyViewShowing: Bool {
        return emptyView != nil && emptyView?.superview != nil
    }

    /** 
     *  显示loading的emptyView
     */
    func showEmptyViewWithLoading() {
        showEmptyView()
        emptyView?.setLoadingView(false)
        emptyView?.setTextLabel(nil)
        emptyView?.setDetailTextLabel(nil)
        emptyView?.setActionButtonTitle(nil)
    }

    /** 
     *  显示带text、detailText、button的emptyView
     */
    func showEmptyView(with text: String?, detailText: String?, buttonTitle: String?, buttonAction: Selector) {
        showEmptyView(with: nil, text: text, detailText: detailText, buttonTitle: buttonTitle, buttonAction: buttonAction)
    }

    /** 
     *  显示带image、text、detailText、button的emptyView
     */
    func showEmptyView(with image: UIImage?, text: String?, detailText: String?, buttonTitle: String?, buttonAction: Selector) {
        showEmptyView()
        emptyView?.setLoadingView(true)
        emptyView?.set(image: image)
        emptyView?.setTextLabel(text)
        emptyView?.setDetailTextLabel(detailText)
        emptyView?.setActionButtonTitle(buttonTitle)
        emptyView?.actionButton?.removeTarget(nil, action: nil, for: .allEvents)
        emptyView?.actionButton?.addTarget(self, action: buttonAction, for: .touchUpInside)
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
            if emptyView.superview != nil || isViewLoaded {
                let newEmptyViewSize = emptyView.superview!.bounds.size
                let oldEmptyViewSize = emptyView.frame.size
                if (!newEmptyViewSize.equalTo(oldEmptyViewSize)) {
                    self.emptyView?.frame = CGRect(origin: emptyView.frame.origin, size: newEmptyViewSize)
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
        return supportedOrientationMask!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension QMUICommonViewController: QMUINavigationControllerDelegate {
    /** 
     *  在self.navigationController popViewControllerAnimated:内被调用，此时尚未被pop。一些自身被pop的时候需要做的事情可以写在这里。
     *
     *  在ARC环境下，viewController可能被放在autorelease池中，因此viewController被pop后不一定立即被销毁，所以一些对实时性要求很高的内存管理逻辑可以写在这里（而不是写在dealloc内）
     *
     *  @warning 不要尝试将willPopViewController视为点击返回按钮的回调，因为导致viewController被pop的情况不止点击返回按钮这一途径。系统的返回按钮是无法添加回调的，只能使用自定义的返回按钮。
     */
    func willPopViewController() {
        // 子类按需实现
    }

    /** 
     *  在self.navigationController popViewControllerAnimated:内被调用，此时self已经不在viewControllers数组内
     */
    func didPopViewController() {
        // 子类按需实现
    }

    // MARK: - <QMUINavigationControllerDelegate>
    var shouldSetStatusBarStyleLight: Bool {
        return StatusbarStyleLightInitially
    }
}

extension QMUICommonViewController {
    /** 
     *  负责初始化和设置controller里面的view，也就是self.view的subView。目的在于分类代码，所以与view初始化的相关代码都写在这里。
     *
     *  @warning initSubviews只负责subviews的init，不负责布局。布局相关的代码应该写在 <b>viewDidLayoutSubviews</b>
     */
    func initSubviews() {
        // 子类重写
    }

    /** 
     *  负责设置和更新navigationItem，包括title、leftBarButtonItem、rightBarButtonItem。viewDidLoad里面会自动调用，允许手动调用更新。目的在于分类代码，所有与navigationItem相关的代码都写在这里。在需要修改navigationItem的时候都只调用这个接口。
     *
     *  @param isInEditMode 是否用于编辑模式下
     *  @param animated     是否使用动画呈现
     */
    func setNavigationItems(isInEditMode: Bool, animated: Bool) {
        // 子类重写
        navigationItem.titleView = titleView
    }

    /** 
     *  负责设置和更新toolbarItem。在viewWillAppear里面自动调用（因为toolbar是navigationController的，是每个界面公用的，所以必须在每个界面的viewWillAppear时更新，不能放在viewDidLoad里），允许手动调用。目的在于分类代码，所有与toolbarItem相关的代码都写在这里。在需要修改toolbarItem的时候都只调用这个接口。
     *
     *  @param isInEditMode 是否用于编辑模式下
     *  @param animated     是否使用动画呈现
     */
    func setToolbarItems(isInEditMode: Bool, animated: Bool) {
        // 子类重写
    }

    /** 
     *  动态字体的回调函数。
     *
     *  交给子类重写，当系统字体发生变化的时候，会调用这个方法，一些font的设置或者reloadData可以放在里面
     *
     *  @param notification test
     */
    func contentSizeCategoryDidChanged(_ notification: Notification) {
        // 子类重写
        setUIAfterContentSizeCategoryChanged()
    }

    /** 
     *  动态字体的回调函数。
     *
     *  交给子类重写。这个方法是在contentSizeCategoryDidChanged:里面被调用的，主要用来设置写在controller里面的view的font
     */
    func setUIAfterContentSizeCategoryChanged() {
        // 子类重写
    }
}
