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
    func showEmptyView() {
        if emptyView == nil {
            emptyView = QMUIEmptyView(frame: view.bounds)
        }
        view.addSubview(emptyView!)
    }
    
    func hideEmptyView() {
        emptyView?.removeFromSuperview()
    }

    var isEmptyViewShowing: Bool {
        return emptyView != nil && emptyView?.superview != nil
    }

    func showEmptyViewWithLoading() {
        showEmptyView()
        emptyView?.setLoadingView(false)
        emptyView?.setTextLabel(nil)
        emptyView?.setDetailTextLabel(nil)
        emptyView?.setActionButtonTitle(nil)
    }

    func showEmptyView(with text: String?, detailText: String?, buttonTitle: String?, buttonAction: Selector) {
        showEmptyView(with: nil, text: text, detailText: detailText, buttonTitle: buttonTitle, buttonAction: buttonAction)
    }

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
    func willPopViewController() {
        // 子类按需实现 
    }

    func didPopViewController() {
        // 子类按需实现
    }

    // MARK: - <QMUINavigationControllerDelegate>
    var shouldSetStatusBarStyleLight: Bool {
        return StatusbarStyleLightInitially
    }
}

extension QMUICommonViewController {
    func initSubviews() {
        // 子类重写
    }

    func setNavigationItems(isInEditMode: Bool, animated: Bool) {
        // 子类重写
        navigationItem.titleView = titleView
    }

    func setToolbarItems(isInEditMode: Bool, animated: Bool) {
        // 子类重写
    }

    func contentSizeCategoryDidChanged(notification: Notification) {
        // 子类重写
        setUIAfterContentSizeCategoryChanged()
    }
    
    func setUIAfterContentSizeCategoryChanged() {
        // 子类重写
    }
}
