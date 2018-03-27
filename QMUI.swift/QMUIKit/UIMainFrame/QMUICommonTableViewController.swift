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

let QMUICommonTableViewControllerSectionHeaderIdentifier = "QMUISectionHeaderView"
let QMUICommonTableViewControllerSectionFooterIdentifier = "QMUISectionFooterView"

let kSectionHeaderFooterLabelTag = 1024

/**
 *  可作为项目内所有 `UITableViewController` 的基类，注意是继承自 `QMUICommonViewController` 而不是 `UITableViewController`。
 *
 *  一般通过 `initWithStyle:` 方法初始化，对于要生成 `UITableViewStylePlain` 类型的列表，推荐使用 `init:` 方法。
 *
 *  提供的功能包括：
 *
 *  1. 集成 `QMUISearchController`，可通过在 `shouldShowSearchBarInTableView:` 里返回 `YES` 来快速为列表生成一个搜索框。
 *
 *  2. 通过属性 `tableViewInitialContentInset` 和 `tableViewInitialScrollIndicatorInsets` 来提供对界面初始状态下的列表 `contentInset`、`contentOffset` 的调整能力，一般在系统的 `automaticallyAdjustsScrollViewInsets` 属性无法满足需求时使用。
 *
 *  @warning 在 `QMUICommonTableViewController` 里的 emptyView 将会以 `tableFooterView` 的方式显示出来，所以如果你的界面拥有自己的 `tableFooterView`，则需要重写 `showEmptyView`、`hideEmptyView` 来处理你的 footerView 和 emptyView 的显隐冲突问题。
 *
 *  @see QMUISearchController
 */
class QMUICommonTableViewController: QMUICommonViewController {
    /// 获取当前的 `UITableViewStyle`
    private(set) var style: UITableViewStyle!

    /// 获取当前的 tableView
    fileprivate(set) var tableView: QMUITableView!

    private var hasHideTableHeaderViewInitial = false
    private var hasSetInitialContentInset = false

    fileprivate var _searchController: QMUISearchController?
    fileprivate var _searchBar: UISearchBar?

    /**
     *  列表使用自定义的contentInset，不使用系统默认计算的，默认为QMUICommonTableViewControllerInitialContentInsetNotSet。<br/>
     *  当更改了这个值后，会把self.automaticallyAdjustsScrollViewInsets = NO
     */
    var tableViewInitialContentInset: UIEdgeInsets! {
        didSet {
            if tableViewInitialContentInset == QMUICommonTableViewControllerInitialContentInsetNotSet {
                automaticallyAdjustsScrollViewInsets = true
            } else {
                automaticallyAdjustsScrollViewInsets = false
            }
        }
    }

    /**
     *  是否需要让scrollIndicatorInsets与tableView.contentInsets区分开来，如果不设置，则与tableView.contentInset保持一致。
     *
     *  只有当更改了tableViewInitialContentInset后，这个属性才会生效。
     */
    var tableViewInitialScrollIndicatorInsets: UIEdgeInsets!

    convenience init() {
        self.init(style: .plain)
    }

    init(style: UITableViewStyle) {
        super.init(nibName: nil, bundle: nil)
        didInitialized(with: style)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        didInitialized(with: .plain)
    }

    func didInitialized(with style: UITableViewStyle) {
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
        view.backgroundColor = style == .plain ? TableViewBackgroundColor : TableViewGroupedBackgroundColor
    }

    override func initSubviews() {
        super.initSubviews()
        initTableView()
        initSearchController()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.qmui_clearsSelection()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let shouldChangeTableViewFrame = view.bounds != tableView.frame
        if shouldChangeTableViewFrame {
            tableView.frame = view.bounds
        }

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

        hideTableHeaderViewInitialIfCan(with: false)

        layoutEmptyView()
    }

    // MARK: - 工具方法

    //    var tableView {
    //        if (!_tableView) {
    //            loadViewIfNeeded()
    //        }
    //        return _tableView
    //    }

    func hideTableHeaderViewInitialIfCan(with animated: Bool) {
        guard let tableHeaderView = tableView.tableHeaderView, shouldHideTableHeaderViewInitial && !hasHideTableHeaderViewInitial else {
            return
        }
        let contentOffset = CGPoint(x: tableView.contentOffset.x, y: tableView.contentOffset.y + tableHeaderView.frame.height)
        tableView.setContentOffset(contentOffset, animated: animated)
        hasHideTableHeaderViewInitial = true
    }

    override func contentSizeCategoryDidChanged(_ notification: Notification) {
        super.contentSizeCategoryDidChanged(notification)
        tableView.reloadData()
    }

    var shouldAdjustTableViewContentInsetsInitially: Bool {
        return tableViewInitialContentInset != QMUICommonTableViewControllerInitialContentInsetNotSet
    }

    var shouldAdjustTableViewScrollIndicatorInsetsInitially: Bool {
        return tableViewInitialScrollIndicatorInsets != QMUICommonTableViewControllerInitialContentInsetNotSet
    }

    // MARK: - 空列表视图 QMUIEmptyView

    override func showEmptyView() {
        if emptyView == nil {
            emptyView = QMUIEmptyView()
        }
        tableView.addSubview(emptyView!)
        layoutEmptyView()

        if shouldHideSearchBarWhenEmptyViewShowing && tableView.tableHeaderView == searchBar {
            tableView.tableHeaderView = nil
        }
    }

    override func hideEmptyView() {
        emptyView?.removeFromSuperview()

        if shouldShowSearchBar(in: tableView) && shouldHideSearchBarWhenEmptyViewShowing && tableView.tableHeaderView == nil {
            initSearchController()
            tableView.tableHeaderView = searchBar
            hideTableHeaderViewInitialIfCan(with: false)
        }
    }

    @discardableResult
    override func layoutEmptyView() -> Bool {
        if emptyView == nil || emptyView?.superview == nil {
            return false
        }

        // 当存在 tableHeaderView 时，emptyView 的高度为 tableView 的高度减去 headerView 的高度
        if let tableHeaderView = tableView.tableHeaderView {
            emptyView?.frame = CGRect(x: 0, y: tableHeaderView.frame.maxY, width: tableView.bounds.width - tableView.contentInset.horizontalValue, height: tableView.bounds.height - tableView.contentInset.verticalValue - tableHeaderView.frame.maxY)
        } else {
            emptyView?.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width - tableView.contentInset.horizontalValue, height: tableView.bounds.height - tableView.contentInset.verticalValue)
        }
        return true
    }
}

extension QMUICommonTableViewController: QMUITableViewDelegate {
    // 默认拿title来构建一个view然后添加到viewForHeaderInSection里面，如果业务重写了viewForHeaderInSection，则titleForHeaderInSection被覆盖
    // viewForFooterInSection同上
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let title = _tableView(tableView, realTitleForHeaderIn: section)
        if let title = title {
            let headerFooterView = tableHeaderFooterLabel(in: tableView, identifier: "headerTitle")
            let label = headerFooterView.contentView.viewWithTag(kSectionHeaderFooterLabelTag) as? QMUILabel
            label?.text = title
            let isPlain = tableView.style == .plain
            label?.contentEdgeInsets = isPlain ? TableViewSectionHeaderContentInset : TableViewGroupedSectionHeaderContentInset
            label?.font = isPlain ? TableViewSectionHeaderFont : TableViewGroupedSectionHeaderFont
            label?.textColor = isPlain ? TableViewSectionHeaderTextColor : TableViewGroupedSectionHeaderTextColor
            label?.backgroundColor = isPlain ? TableViewSectionHeaderBackgroundColor : UIColorClear
            let labelLimitWidth = tableView.bounds.width - tableView.contentInset.horizontalValue
            let labelSize = label!.sizeThatFits(CGSize(width: labelLimitWidth, height: CGFloat.infinity))
            label?.frame = CGRect(x: 0, y: 0, width: labelLimitWidth, height: labelSize.height)
            return label!
        }
        return nil
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let title = _tableView(tableView, realTitleForFooterIn: section)
        if let title = title {
            let headerFooterView = tableHeaderFooterLabel(in: tableView, identifier: "footerTitle")
            let label = headerFooterView.contentView.viewWithTag(kSectionHeaderFooterLabelTag) as? QMUILabel
            label?.text = title
            let isPlain = tableView.style == .plain
            label?.contentEdgeInsets = isPlain ? TableViewSectionFooterContentInset : TableViewGroupedSectionFooterContentInset
            label?.font = isPlain ? TableViewSectionFooterFont : TableViewGroupedSectionFooterFont
            label?.textColor = isPlain ? TableViewSectionFooterTextColor : TableViewGroupedSectionFooterTextColor
            label?.backgroundColor = isPlain ? TableViewSectionFooterBackgroundColor : UIColorClear
            let labelLimitWidth = tableView.bounds.width - tableView.contentInset.horizontalValue
            let labelSize = label!.sizeThatFits(CGSize(width: labelLimitWidth, height: .infinity))
            label?.frame = CGRect(x: 0, y: 0, width: labelLimitWidth, height: labelSize.height)
            return label!
        }
        return nil
    }

    func tableHeaderFooterLabel(in tableView: UITableView, identifier: String) -> UITableViewHeaderFooterView {
        var headerFooterView = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier)
        if headerFooterView == nil {
            let label = QMUILabel()
            label.tag = kSectionHeaderFooterLabelTag
            label.numberOfLines = 0
            headerFooterView = UITableViewHeaderFooterView(reuseIdentifier: identifier)
            headerFooterView?.contentView.addSubview(label)
        }
        return headerFooterView!
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let headerView = tableView.delegate?.tableView?(tableView, viewForHeaderInSection: section) else {
            // 默认 plain 类型直接设置为 0，TableViewSectionHeaderHeight 是在需要重写 headerHeight 的时候才用的
            return tableView.style == .plain ? 0 : TableViewGroupedSectionHeaderDefaultHeight
        }
        return max(headerView.bounds.height, tableView.style == .plain ? 0 : TableViewGroupedSectionHeaderDefaultHeight)
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard let footerView = tableView.delegate?.tableView?(tableView, viewForFooterInSection: section) else {
            // 默认 plain 类型直接设置为 0，TableViewSectionFooterHeight 是在需要重写 footerHeight 的时候才用的
            return tableView.style == .plain ? 0 : TableViewGroupedSectionFooterDefaultHeight
        }
        return max(footerView.bounds.height, tableView.style == .plain ? 0 : TableViewGroupedSectionFooterDefaultHeight)
    }

    // 是否有定义某个section的header title
    func _tableView(_ tableView: UITableView, realTitleForHeaderIn section: Int) -> String? {
        guard let sectionTitle = tableView.dataSource?.tableView?(tableView, titleForHeaderInSection: section), !sectionTitle.isEmpty else {
            return nil
        }
        return sectionTitle
    }

    // 是否有定义某个section的footer title(编译器bug添加_)
    func _tableView(_ tableView: UITableView, realTitleForFooterIn section: Int) -> String? {
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
        view.addSubview(tableView)
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

extension QMUICommonTableViewController: QMUISearchControllerDelegate {
    /**
     *  获取当前的searchController，注意只有当 `shouldShowSearchBarInTableView:` 返回 `YES` 时才有用
     *
     *  默认为 `nil`
     *
     *  @see QMUITableViewDelegate
     */
    var searchController: QMUISearchController? {
        return _searchController
    }

    /**
     *  获取当前的searchBar，注意只有当 `shouldShowSearchBarInTableView:` 返回 `YES` 时才有用
     *
     *  默认为 `nil`
     *
     *  @see QMUITableViewDelegate
     */
    var searchBar: UISearchBar? {
        return _searchBar
    }

    /**
     *  是否应该在显示空界面时自动隐藏搜索框
     *
     *  默认为 `false`
     */
    var shouldHideSearchBarWhenEmptyViewShowing: Bool { return false }

    /**
     *  初始化searchController和searchBar，在initSubViews的时候被自动调用。
     *
     *  会询问 `[self.tableView.delegate shouldShowSearchBarInTableView:]`，若返回 `YES`，则创建 searchBar 并将其以 `tableHeaderView` 的形式呈现在界面里；若返回 `NO`，则将 `tableHeaderView` 置为nil。
     *
     *  @warning `shouldShowSearchBarInTableView:` 默认返回 NO，需要 searchBar 的界面必须重写该方法并返回 `YES`
     */
    func initSearchController() {
        guard let delegate = tableView.delegate as? QMUITableViewDelegate else { return }
        if delegate.shouldShowSearchBar(in: tableView) && searchController == nil {
            _searchController = QMUISearchController(contentsViewController: self)
            searchController?.searchResultsDelegate = self
            searchController?.searchBar?.placeholder = "搜索"
            tableView.tableHeaderView = searchController?.searchBar
            _searchBar = searchController?.searchBar
        }
    }

    func searchController(_: QMUISearchController, updateResultsFor _: String?) {}
}
