//
//  QMUICommonTableViewController.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/2/9.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

/**
 *  配合属性 `tableViewInitialContentInset` 使用，标志 `tableViewInitialContentInset` 是否有被修改过
 *  @see tableViewInitialContentInset
 */
let QMUICommonTableViewControllerInitialContentInsetNotSet = UIEdgeInsets(top: -1, left: -1, bottom: -1, right: -1)

private let QMUICommonTableViewControllerSectionHeaderIdentifier = "QMUISectionHeaderView"
private let QMUICommonTableViewControllerSectionFooterIdentifier = "QMUISectionFooterView"

/**
 *  可作为项目内所有 `UITableViewController` 的基类，注意是继承自 `QMUICommonViewController` 而不是 `UITableViewController`。
 *
 *  一般通过 `initWithStyle:` 方法初始化，对于要生成 `UITableViewStylePlain` 类型的列表，推荐使用 `init:` 方法。
 *
 *  提供的功能包括：
 *
 *  1. 集成 `QMUISearchController`，可通过属性 `shouldShowSearchBar` 来快速为列表生成一个 searchBar 及 searchController，具体请查看 QMUICommonTableViewController (Search)。
 *
 *  2. 通过属性 `tableViewInitialContentInset` 和 `tableViewInitialScrollIndicatorInsets` 来提供对界面初始状态下的列表 `contentInset`、`contentOffset` 的调整能力，一般在系统的 `automaticallyAdjustsScrollViewInsets` 属性无法满足需求时使用。
 *
 *  @note emptyView 会从 tableHeaderView 的下方开始布局到 tableView 最底部，因此它会遮挡 tableHeaderView 之外的部分（比如 tableFooterView 和 cells ），你可以重写 layoutEmptyView 来改变这个布局方式
 *
 *  @see QMUISearchController
 */
class QMUICommonTableViewController: QMUICommonViewController {
    /// 获取当前的 `UITableViewStyle`
    private(set) var style: UITableView.Style = .plain

    /// 获取当前的 tableView
    fileprivate var _tableView: QMUITableView?
    fileprivate(set) var tableView: QMUITableView! {
        get {
            if #available(iOS 9.0, *) {
                loadViewIfNeeded()
            } else {
                view.alpha = 1
            }
            return _tableView!
        }
        set {
            _tableView = newValue
        }
    }

    private var hasHideTableHeaderViewInitial = false
    private var hasSetInitialContentInset = false

    /**
     *  列表使用自定义的contentInset，不使用系统默认计算的，默认为QMUICommonTableViewControllerInitialContentInsetNotSet。<br/>
     *  @warning 当更改了这个值后，在 iOS 11 及以后里，会把 self.tableView.contentInsetAdjustmentBehavior 改为 UIScrollViewContentInsetAdjustmentNever，而在 iOS 11 以前，会把 self.automaticallyAdjustsScrollViewInsets 改为 NO。
     */
    var tableViewInitialContentInset: UIEdgeInsets! {
        didSet {
            if tableViewInitialContentInset == QMUICommonTableViewControllerInitialContentInsetNotSet {
                if #available(iOS 11, *) {
                    if isViewLoaded {
                        tableView.contentInsetAdjustmentBehavior = .automatic
                    }
                } else {
                    automaticallyAdjustsScrollViewInsets = true
                }
            } else {
                if #available(iOS 11, *) {
                    if isViewLoaded {
                        tableView.contentInsetAdjustmentBehavior = .never
                    }
                } else {
                    automaticallyAdjustsScrollViewInsets = false
                }
            }
        }
    }

    /**
     *  是否需要让scrollIndicatorInsets与tableView.contentInsets区分开来，如果不设置，则与tableView.contentInset保持一致。
     *
     *  只有当更改了tableViewInitialContentInset后，这个属性才会生效。
     */
    var tableViewInitialScrollIndicatorInsets: UIEdgeInsets = QMUICommonTableViewControllerInitialContentInsetNotSet

    convenience init() {
        self.init(style: .plain)
    }

    init(style: UITableView.Style) {
        super.init(nibName: nil, bundle: nil)
        didInitialized(with: style)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        didInitialized(with: .plain)
    }

    func didInitialized(with style: UITableView.Style) {
        self.style = style
        tableViewInitialContentInset = QMUICommonTableViewControllerInitialContentInsetNotSet
        tableViewInitialScrollIndicatorInsets = QMUICommonTableViewControllerInitialContentInsetNotSet
    }

    deinit {
        tableView.delegate = nil
        tableView.dataSource = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let backgroundColor = style == .plain ? TableViewBackgroundColor : TableViewGroupedBackgroundColor {
            view.backgroundColor = backgroundColor
        }
    }

    override func initSubviews() {
        super.initSubviews()
        initTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.qmui_clearsSelection()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        layoutTableView()

        if shouldAdjustTableViewContentInsetsInitially && !hasSetInitialContentInset {
            tableView.contentInset = tableViewInitialContentInset
            if shouldAdjustTableViewScrollIndicatorInsetsInitially {
                tableView.scrollIndicatorInsets = tableViewInitialScrollIndicatorInsets
            } else {
                // 默认和tableView.contentInset一致
                tableView.scrollIndicatorInsets = tableView.contentInset
            }
            tableView.qmui_scrollToTop()
            hasSetInitialContentInset = true
        }

        hideTableHeaderViewInitialIfCan(animated: false, force: false)

        layoutEmptyView()
    }

    // MARK: - 工具方法

    func hideTableHeaderViewInitialIfCan(animated: Bool, force: Bool) {
        if let tableHeaderView = tableView.tableHeaderView, shouldHideTableHeaderViewInitial && (force || !hasHideTableHeaderViewInitial) {
            let contentOffset = CGPoint(x: tableView.contentOffset.x, y: -tableView.qmui_contentInset.top + tableHeaderView.frame.height )
            tableView.setContentOffset(contentOffset, animated: animated)
            hasHideTableHeaderViewInitial = true
        }
    }

    override func contentSizeCategoryDidChanged(_ notification: Notification) {
        super.contentSizeCategoryDidChanged(notification)
        tableView.reloadData()
    }

    var shouldAdjustTableViewContentInsetsInitially: Bool {
        let result = tableViewInitialContentInset != QMUICommonTableViewControllerInitialContentInsetNotSet
        return result
    }

    var shouldAdjustTableViewScrollIndicatorInsetsInitially: Bool {
        let result = tableViewInitialScrollIndicatorInsets != QMUICommonTableViewControllerInitialContentInsetNotSet
        return result
    }

    // MARK: - 空列表视图 QMUIEmptyView
    override func showEmptyView() {
        if emptyView == nil {
            emptyView = QMUIEmptyView()
        }
        tableView.addSubview(emptyView!)
        layoutEmptyView()
    }

    override func hideEmptyView() {
        emptyView?.removeFromSuperview()
    }

    @discardableResult
    override func layoutEmptyView() -> Bool {
        guard let emptyView = emptyView, let _ = emptyView.superview else {
            return false
        }
        
        var insets = tableView.contentInset
        
        if #available(iOS 11, *) {
            if tableView.contentInsetAdjustmentBehavior != .never {
                insets = tableView.adjustedContentInset
            }
        }

        // 当存在 tableHeaderView 时，emptyView 的高度为 tableView 的高度减去 headerView 的高度
        if let tableHeaderView = tableView.tableHeaderView {
            emptyView.frame = CGRect(x: 0, y: tableHeaderView.frame.maxY, width: tableView.bounds.width - insets.horizontalValue, height: tableView.bounds.height - insets.verticalValue - tableHeaderView.frame.maxY)
        } else {
            emptyView.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width - insets.horizontalValue, height: tableView.bounds.height - insets.verticalValue)
        }
        return true
    }
}

extension QMUICommonTableViewController: QMUITableViewDelegate {
    // 默认拿title来构建一个view然后添加到viewForHeaderInSection里面，如果业务重写了viewForHeaderInSection，则titleForHeaderInSection被覆盖
    // viewForFooterInSection同上
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let title = _tableView(tableView: tableView, realTitleForHeaderIn: section) {
            if let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: QMUICommonTableViewControllerSectionHeaderIdentifier) as? QMUITableViewHeaderFooterView {
                headerView.parentTableView = tableView
                headerView.type = .header
                headerView.titleLabel.text = title
                return headerView
            }
        }
        return nil
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if let title = _tableView(tableView: tableView, realTitleForFooterIn: section) {
            if let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: QMUICommonTableViewControllerSectionFooterIdentifier) as? QMUITableViewHeaderFooterView {
                footerView.parentTableView = tableView
                footerView.type = .footer
                footerView.titleLabel.text = title
                return footerView
            }
        }
        return nil
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let view = tableView.delegate?.tableView?(tableView, viewForHeaderInSection: section) else {
            // 分别测试过 iOS 11 前后的系统版本，最终总结，对于 Plain 类型的 tableView 而言，要去掉 header / footer 请使用 0，对于 Grouped 类型的 tableView 而言，要去掉 header / footer 请使用 CGFloat.leastNormalMagnitude
            return tableView.style == .plain ? 0 : TableViewGroupedSectionHeaderDefaultHeight
        }
        let height = view.sizeThatFits(CGSize(width: tableView.bounds.width - tableView.qmui_safeAreaInsets.horizontalValue, height: CGFloat.greatestFiniteMagnitude)).height
        return height
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard let view = tableView.delegate?.tableView?(tableView, viewForFooterInSection: section) else {
            // 分别测试过 iOS 11 前后的系统版本，最终总结，对于 Plain 类型的 tableView 而言，要去掉 header / footer 请使用 0，对于 Grouped 类型的 tableView 而言，要去掉 header / footer 请使用 CGFloat.leastNormalMagnitude
            return tableView.style == .plain ? 0 : TableViewGroupedSectionHeaderDefaultHeight
        }
        let height = view.sizeThatFits(CGSize(width: tableView.bounds.width - tableView.qmui_safeAreaInsets.horizontalValue, height: CGFloat.greatestFiniteMagnitude)).height
        return height
    }

    // 是否有定义某个section的header title
    private func _tableView(tableView: UITableView, realTitleForHeaderIn section: Int) -> String? {
        guard let sectionTitle = tableView.dataSource?.tableView?(tableView, titleForHeaderInSection: section), !sectionTitle.isEmpty else {
            return nil
        }
        return sectionTitle
    }

    // 是否有定义某个section的footer title
    private func _tableView(tableView: UITableView, realTitleForFooterIn section: Int) -> String? {
        guard let sectionFooter = tableView.dataSource?.tableView?(tableView, titleForFooterInSection: section), !sectionFooter.isEmpty else {
            return nil
        }
        return sectionFooter
    }
}

extension QMUICommonTableViewController: QMUITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return 0
    }

    func tableView(_: UITableView, cellForRowAt _: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return TableViewCellNormalHeight
    }
}

// MARK: - QMUISubclassingHooks
extension QMUICommonTableViewController {
    /**
     *  初始化tableView，在initSubViews的时候被自动调用。
     *
     *  一般情况下，有关tableView的设置属性的代码都应该写在这里。
     */
    @objc func initTableView() {
        
        tableView = QMUITableView(frame: view.bounds, style: style)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(QMUITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: QMUICommonTableViewControllerSectionHeaderIdentifier)
        tableView.register(QMUITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: QMUICommonTableViewControllerSectionFooterIdentifier)
        
        if #available(iOS 11, *) {
            if shouldAdjustTableViewContentInsetsInitially {
                tableView.contentInsetAdjustmentBehavior = .never
            }
        }
        
        view.addSubview(tableView)
    }
    
    /**
     *  布局 tableView 的方法独立抽取出来，方便子类在需要自定义 tableView.frame 时能重写并且屏蔽掉 super 的代码。如果不独立一个方法而是放在 viewDidLayoutSubviews 里，子类就很难屏蔽 super 里对 tableView.frame 的修改。
     *  默认的实现是撑满 self.view，如果要自定义，可以写在这里而不调用 super，或者干脆重写这个方法但留空
     */
    @objc func layoutTableView() {
        let shouldChangeTableViewFrame = view.bounds != tableView.frame
        if shouldChangeTableViewFrame {
            tableView.frame = view.bounds
        }
    }

    /**
     *  是否需要在第一次进入界面时将tableHeaderView隐藏（通过调整self.tableView.contentOffset实现）
     *
     *  默认为false
     *
     *  @see QMUITableViewDelegate
     */
    var shouldHideTableHeaderViewInitial: Bool { return false }
}
