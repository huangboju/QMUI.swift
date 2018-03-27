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
        setNavigationItems(false, animated: false)
        setNavigationItems(false, animated: false)
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
        emptyView?.setLoadingViewHidden(false)
        emptyView?.setTextLabelText(nil)
        emptyView?.setDetailTextLabelText(nil)
        emptyView?.setActionButtonTitle(nil)
    }

    /**
     *  显示带image、text、detailText、button的emptyView
     */
    func showEmptyView(with image: UIImage? = nil, text: String?, detailText: String?, buttonTitle: String?, buttonAction: Selector?) {
        showEmptyView()
        emptyView?.setLoadingViewHidden(true)
        emptyView?.set(image: image)
        emptyView?.setTextLabelText(text)
        emptyView?.setDetailTextLabelText(detailText)
        emptyView?.setActionButtonTitle(buttonTitle)
        emptyView?.actionButton.removeTarget(nil, action: nil, for: .allEvents)
        guard let buttonAction = buttonAction else { return }
        emptyView?.actionButton.addTarget(self, action: buttonAction, for: .touchUpInside)
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
                if !newEmptyViewSize.equalTo(oldEmptyViewSize) {
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

    var preferredNavigationBarHiddenState: QMUINavigationBarHiddenState {
        return .showWithAnimated
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension QMUICommonViewController: QMUINavigationControllerDelegate {

    // MARK: - QMUINavigationControllerDelegate
    var shouldSetStatusBarStyleLight: Bool {
        return StatusbarStyleLightInitially
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return StatusbarStyleLightInitially ? .lightContent : .default
    }

    func viewControllerKeepingAppearWhenSetViewControllers(with _: Bool) {
        // 通常和 viewWillAppear: 里做的事情保持一致
        setNavigationItems(false, animated: false)
        setToolbarItems(isInEditMode: false, animated: false)
    }
}

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
    func setToolbarItems(isInEditMode _: Bool, animated _: Bool) {
        // 子类重写
    }

    /**
     *  动态字体的回调函数。
     *
     *  交给子类重写，当系统字体发生变化的时候，会调用这个方法，一些font的设置或者reloadData可以放在里面
     *
     *  @param notification test
     */
    @objc func contentSizeCategoryDidChanged(_: Notification) {
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
