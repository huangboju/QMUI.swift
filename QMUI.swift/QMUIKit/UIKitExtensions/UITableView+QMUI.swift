//
//  UITableView+QMUI.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/3/17.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

enum QMUITableViewCellPosition {
    case none // 初始化用
    case firstInSection
    case middleInSection
    case lastInSection
    case singleInSection
    case normal
}

private let kFloatValuePrecision = 4 // 统一一个小数点运算精度

/**
 *  这个分类提供额外的功能包括：
 *  1. 将给定的 UITableView 格式化为 QMUITableView 风格的样式
 *  2. 计算给定的某个 view 处于哪个 indexPath 的 cell 上
 *  3. 计算给定的某个 view 处于哪个 sectionHeader 上
 *  4. 获取所有可视范围内的 sectionHeader 的 index
 *  5. 获取正处于 pinned 状态（也即悬停在顶部）的 sectionHeader 的 index
 *  6. 判断某个给定的 sectionHeader 是否处于 pinned 状态
 *  7. 判断某个给定的 cell indexPath 是否处于可视范围内
 *  8. 计算给定的 cell 的 indexPath 所对应的 QMUITableViewCellPosition
 *  9. 清除当前列表的所有 selection（选中的背景灰色）
 *  10. 在将 searchBar 作为 tableHeaderView 的情况下，获取列表真实的 contentSize
 *  11. 在将 searchBar 作为 tableHeaderView 的情况下，判断列表内容是否足够多到可滚动
 */
extension UITableView {
    /// 将当前tableView按照QMUI统一定义的宏来渲染外观
    func qmui_styledAsQMUITableView() {
        
        var backgroundColor: UIColor?
        if style == .plain {
            backgroundColor = TableViewBackgroundColor
            tableFooterView = UIView() // 去掉空白的cell
        } else {
            backgroundColor = TableViewGroupedBackgroundColor
        }
        if backgroundColor != nil {
            self.backgroundColor = backgroundColor
        }

        separatorColor = TableViewSeparatorColor
        backgroundView = UIView() // 设置一个空的backgroundView，去掉系统的，以使backgroundColor生效

        sectionIndexColor = TableSectionIndexColor
        sectionIndexTrackingBackgroundColor = TableSectionIndexTrackingBackgroundColor
        sectionIndexBackgroundColor = TableSectionIndexBackgroundColor
    }

    /**
     *  获取某个 view 在 tableView 里的 indexPath
     *
     *  使用场景：例如每个 cell 内均有一个按钮，在该按钮的 addTarget 点击事件回调里可以用这个方法计算出按钮所在的 indexPath
     *
     *  @param view 要计算的 UIView
     *  @return view 所在的 indexPath，若不存在则返回 nil
     */
    func qmui_indexPathForRow(at view: UIView) -> IndexPath? {
        guard let superview = view.superview else {
            return nil
        }
        let tmpView = view is UITableViewCell && String(describing: type(of: superview)) == "UITableViewWrapperView" ? superview.superview : superview
        if tmpView == self {
            // iOS 11 下，cell.superview 是 UITableView，iOS 11 以前，cell.superview 是 UITableViewWrapperView
            return indexPath(for: view as! UITableViewCell)
        }
        return qmui_indexPathForRow(at: superview)
    }

    /**
     *  计算某个 view 处于当前 tableView 里的哪个 sectionHeaderView 内
     *  @param view 要计算的 UIView
     *  @return view 所在的 sectionHeaderView 的 section，若不存在则返回 -1
     */
    func qmui_indexForSectionHeader(at view: UIView) -> Int {
        alertEstimatedHeightUsageIfDetected()
        
        var origin = convert(view.frame.origin, from: view.superview)
        origin = origin.fixed(kFloatValuePrecision) // 避免一些浮点数精度问题导致的计算错误
        // MARK: TODO molice 针对 section 特别多的场景，优化一下这里的遍历查找
        for i in 0..<numberOfSections {
            // MARK: TODO 这里的判断用整个 section 的 rect，可能需要加上“view 是否在 sectionHeader 上的判断”
            var rectForSection = rect(forSection: i)
            rectForSection = rectForSection.fixed(kFloatValuePrecision)
            if rectForSection.contains(origin) {
                return i
            }
        }
        return -1
    }
    
    /// 获取可视范围内的所有 sectionHeader 的 index
    var qmui_indexForVisibleSectionHeaders: [Int]? {
        let visibleCellIndexPaths = indexPathsForVisibleRows ?? []
        var visibleSections:[Int] = []
        var result:[Int] = []
        for indexPath in visibleCellIndexPaths {
            if visibleSections.count == 0 || indexPath.section != visibleSections.last {
                visibleSections.append(indexPath.section)
            }
        }
        for section in visibleSections {
            if qmui_isHeaderVisible(for: section) {
                result.append(section)
            }
        }
        if result.count == 0 {
            return nil
        }
        return result
    }
    
    /// 获取正处于 pinned（悬停在顶部）状态的 sectionHeader 的序号
    var qmui_indexOfPinnedSectionHeader: Int {
        let visibleSectionIndex = qmui_indexForVisibleSectionHeaders ?? []
        for section in visibleSectionIndex {
            if qmui_isHeaderVisible(for: section) {
                return section
            } else {
                continue
            }
        }
        return -1
    }
    
    func qmui_isHeaderPinned(for section: Int) -> Bool {
        if style != .plain || section >= numberOfSections {
            return false
        }
        // 系统这两个接口获取到的 rect 是在 contentSize 里的 rect，而不是实际看到的 rect
        let rectForSection = rect(forSection: section)
        let rectForSectionHeader = rectForHeader(inSection: section)
        let isSectionScrollIntoContentInsetTop = contentOffset.y + qmui_contentInset.top > rectForSection.minY // 表示这个 section 已经往上滚动，超过 contentInset.top 那条线了
        let isSectionStayInContentInsetTop = contentOffset.y + qmui_contentInset.top <= rectForSection.maxY - rectForSectionHeader.height// 表示这个 section 还没被完全滚走
        let isPinned = isSectionScrollIntoContentInsetTop && isSectionStayInContentInsetTop
        return isPinned
    }
    
    private func qmui_isHeaderVisible(for section: Int) -> Bool {
        if style != .plain || section >= numberOfSections {
            return false
        }
        
        // 不存在 header 就不用判断
        let rectForSectionHeader = rectForHeader(inSection: section)
        if rectForSectionHeader.height <= 0 {
            return false
        }
        // 系统这个接口获取到的 rect 是在 contentSize 里的 rect，而不是实际看到的 rect
        let rectForSection = rect(forSection: section)
        let isSectionScrollIntoBounds = rectForSection.minY < contentOffset.y + bounds.height
        let isSectionStayInContentInsetTop = contentOffset.y + qmui_contentInset.top < rectForSection.maxY // 表示这个 section 还没被完全滚走
        let isVisible = isSectionScrollIntoBounds && isSectionStayInContentInsetTop
        return isVisible
    }
    
    /// 判断当前 indexPath 的 item 是否为可视的 item
    func qmui_cellVisible(at indexPath: IndexPath) -> Bool {
        if let visibleCellIndexPaths = indexPathsForVisibleRows {
            for visibleIndexPath in visibleCellIndexPaths{
                if indexPath == visibleIndexPath {
                    return true
                }
            }
        }
        return false
    }

    /**
     * 根据给定的indexPath，配合dataSource得到对应的cell在当前section中所处的位置
     * @param indexPath cell所在的indexPath
     * @return 给定indexPath对应的cell在当前section中所处的位置
     */
    func qmui_positionForRow(at indexPath: IndexPath) -> QMUITableViewCellPosition {

        let numberOfRowsInSection = dataSource?.tableView(self, numberOfRowsInSection: indexPath.section) ?? 0
        if numberOfRowsInSection == 1 {
            return .singleInSection
        }
        if indexPath.row == 0 {
            return .firstInSection
        }
        if indexPath.row == numberOfRowsInSection - 1 {
            return .lastInSection
        }
        return .middleInSection
    }

    // 取消选择状态
    func qmui_clearsSelection() {
        indexPathsForSelectedRows?.forEach {
            deselectRow(at: $0, animated: true)
        }
    }

    /**
     * 将指定的row滚到指定的位置（row的顶边缘和指定位置重叠），并对一些特殊情况做保护（例如列表内容不够一屏、要滚动的row是最后一条等）
     * @param offsetY 目标row要滚到的y值，这个y值是相对于tableView的frame而言的
     * @param indexPath 要滚动的目标indexPath，请自行保证indexPath是合法的
     * @param animated 是否需要动画
     */
    func qmui_scrollToRowFittingOffsetY(_ offsetY: CGFloat, at indexPath: IndexPath, animated: Bool) {
        alertEstimatedHeightUsageIfDetected()
        
        if !qmui_canScroll {
            return
        }
        let rect = rectForRow(at: indexPath)
        // 如果要滚到的row在列表尾部，则这个row是不可能滚到顶部的（因为列表尾部已经不够空间了），所以要判断一下
        let canScrollRowToTop = rect.maxY + frame.height - (offsetY + rect.height) <= contentSize.height
        if canScrollRowToTop {
            setContentOffset(CGPoint(x: contentOffset.x, y: rect.minY - offsetY), animated: animated)
        } else {
            qmui_scrollToTopAnimated(animated)
        }
    }
    
    
    /**
     *  当tableHeaderView为UISearchBar时，tableView为了实现searchbar滚到顶部自动吸附的效果，会强制让self.contentSize.height至少为frame.size.height那么高（这样才能滚动，否则不满一屏就无法滚动了），所以此时如果通过self.contentSize获取tableView的内容大小是不准确的，此时可以使用`qmui_realContentSize`替代。
     *
     *  `qmui_realContentSize`是实时通过计算最后一个section的frame，与footerView的frame比较得到实际的内容高度，这个过程不会导致额外的cellForRow调用，请放心使用。
     */
    var qmui_realContentSize: CGSize {
        alertEstimatedHeightUsageIfDetected()
        
        if dataSource == nil || delegate == nil {
            return .zero
        }

        let footerViewMaxY = tableFooterView?.frame.maxY ?? 0
        var realContentSize = CGSize(width: contentSize.width, height: footerViewMaxY)

        let lastSection = numberOfSections - 1
        if lastSection < 0 {
            // 说明numberOfSetions为0，tableView没有cell，则直接取footerView的底边缘
            return realContentSize
        }

        let lastSectionRect = rect(forSection: lastSection)
        realContentSize.height = fmax(realContentSize.height, lastSectionRect.maxY)
        return realContentSize
    }

    /**
     *  UITableView的tableHeaderView如果是UISearchBar的话，tableView.contentSize会强制设置为至少比bounds高（从而实现headerView的吸附效果），从而导致qmui_canScroll的判断不准确。所以为UITableView重写了qmui_canScroll方法
     */
    override var qmui_canScroll: Bool {
        // 没有高度就不用算了，肯定不可滚动，这里只是做个保护
        if bounds.height <= 0 {
            return false
        }

        if tableHeaderView is UISearchBar {
            let canScroll = qmui_realContentSize.height + qmui_contentInset.verticalValue > bounds.height
            return canScroll
        } else {
            return super.qmui_canScroll
        }
    }
    
    private func alertEstimatedHeightUsageIfDetected() {
        let usingEstimatedRowHeight = estimatedRowHeight == UITableView.automaticDimension
        let usingEstimatedSectionHeaderHeight = estimatedSectionHeaderHeight == UITableView.automaticDimension
        let usingEstimatedSectionFooterHeight = estimatedSectionFooterHeight == UITableView.automaticDimension
        if usingEstimatedRowHeight || usingEstimatedSectionHeaderHeight || usingEstimatedSectionFooterHeight {
            QMUISymbolicUsingTableViewEstimatedHeightMakeWarning()
        }
    }
    
    private func QMUISymbolicUsingTableViewEstimatedHeightMakeWarning() {
        print("UITableView 的 estimatedRow(SectionHeader / SectionFooter)Height 属性会影响 contentSize、sizeThatFits:、rectForXxx 等方法的计算，导致计算结果不准确，建议重新考虑是否要使用 estimated。可添加 '\(#function)' 的 Symbolic Breakpoint 以捕捉此类信息\n\(Thread.callStackSymbols)")
    }
}

/// ====================== 计算动态cell高度相关 =======================

/**
 *  UITableView 定义了一套动态计算 cell 高度的方式：
 *
 *  其思路是参考开源代码：https://github.com/forkingdog/UITableView-FDTemplateLayoutCell。
 *
 *  1. cell 必须实现 sizeThatFits: 方法，在里面计算自身的高度并返回
 *  2. 初始化一个 QMUITableView，并为其指定一个 QMUITableViewDataSource
 *  3. 实现 qmui_tableView:cellWithIdentifier: 方法，在里面为不同的 identifier 创建不同的 cell 实例
 *  4. 在 tableView:cellForRowAtIndexPath: 里使用 qmui_tableView:cellWithIdentifier: 获取 cell
 *  5. 在 tableView:heightForRowAtIndexPath: 里使用 UITableView (QMUILayoutCell) 提供的几种方法得到 cell 的高度
 *
 *  这套方式的好处是 tableView 能直接操作 cell 的实例，cell 无需增加额外的专门用于获取 cell 高度的方法。并且这套方式支持基本的高度缓存（可按 key 缓存或按 indexPath 缓存），若使用了缓存，请注意在适当的时机去更新缓存（例如某个 cell 的内容发生变化，可能 cell 的高度也会变化，则需要更新这个 cell 已被缓存起来的高度）。
 *
 *  使用这套方式额外的消耗是每个 identifier 都会生成一个多余的 cell 实例（专用于高度计算），但大部分情况下一个生成一个 cell 实例并不会带来过多的负担，所以一般不用担心这个问题。
 */

// MARK: - QMUIKeyedHeightCache
extension UITableView {
    fileprivate struct Keys {
        static var keyedHeightCache = "keyedHeightCache"
        static var indexPathHeightCache = "indexPathHeightCache"
        static var templateCellsByIdentifiers = "templateCellsByIdentifiers"
        static var staticCellDataSource = "staticCellDataSource"
    }

    var qmui_keyedHeightCache: QMUICellHeightKeyCache {
        guard let cache = objc_getAssociatedObject(self, &Keys.keyedHeightCache) as? QMUICellHeightKeyCache else {
            let cache = QMUICellHeightKeyCache()
            objc_setAssociatedObject(self, &Keys.keyedHeightCache, cache, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return cache
        }
        return cache
    }
}

// MARK: - QMUICellHeightIndexPathCache
extension UITableView {

    var qmui_indexPathHeightCache: QMUICellHeightIndexPathCache {
        guard let cache = objc_getAssociatedObject(self, &Keys.indexPathHeightCache) as? QMUICellHeightIndexPathCache else {
            let cache = QMUICellHeightIndexPathCache()
            objc_setAssociatedObject(self, &Keys.indexPathHeightCache, cache, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return cache
        }
        return cache
    }
}

// MARK: - QMUIIndexPathHeightCacheInvalidation
extension UITableView: SelfAware3 {
    private static let _onceToken = UUID().uuidString

    static func awake3() {
        DispatchQueue.once(token: _onceToken) {
            let clazz = UITableView.self
            
            let selectors = [
                #selector(UITableView.reloadData),
                #selector(UITableView.insertSections(_:with:)),
                #selector(UITableView.deleteSections(_:with:)),
                #selector(UITableView.reloadSections(_:with:)),
                #selector(UITableView.moveSection(_:toSection:)),
                #selector(UITableView.insertRows(at:with:)),
                #selector(UITableView.deleteRows(at:with:)),
                #selector(UITableView.reloadRows(at:with:)),
                #selector(UITableView.moveRow(at:to:)),
                #selector(UITableView.sizeThatFits(_:)),
                #selector(setter: dataSource),
                #selector(setter: delegate),
            ]
            
            let qmui_selectors = [
                #selector(UITableView.qmui_reloadData),
                #selector(UITableView.qmui_insertSections(_:with:)),
                #selector(UITableView.qmui_deleteSections(_:with:)),
                #selector(UITableView.qmui_reloadSections(_:with:)),
                #selector(UITableView.qmui_moveSection(_:toSection:)),
                #selector(UITableView.qmui_insertRows(at:with:)),
                #selector(UITableView.qmui_deleteRows(at:with:)),
                #selector(UITableView.qmui_reloadRows(at:with:)),
                #selector(UITableView.qmui_moveRow(at:to:)),
                #selector(UITableView.qmui_sizeThatFits(_:)),
                #selector(UITableView.staticCell_setDataSource),
                #selector(UITableView.staticCell_setDelegate),
            ]
            
            for index in 0..<selectors.count {
                ReplaceMethod(clazz, selectors[index], qmui_selectors[index])
            }
            
            if #available(iOS 11, *) {
                ReplaceMethod(clazz, #selector(UITableView.safeAreaInsetsDidChange), #selector(UITableView.cellHeightCache_safeAreaInsetsDidChange))
            }
        }
    }
}

extension UITableView {
    
    @objc func qmui_init(frame: CGRect, style: UITableView.Style) {
        qmui_init(frame: frame, style: style)
        // iOS 11 之后 estimatedRowHeight 默认值变成 UITableViewAutomaticDimension 了，会导致 contentSize 之类的计算不准确，所以这里给一个途径让项目可以方便地禁掉所有 UITableView 的 estimatedXxxHeight
        
        if !TableViewEstimatedHeightEnabled {
            estimatedRowHeight = 0
            estimatedSectionHeaderHeight = 0
            estimatedSectionFooterHeight = 0
        } else {
            estimatedRowHeight = UITableView.automaticDimension
            estimatedSectionHeaderHeight = UITableView.automaticDimension
            estimatedSectionFooterHeight = UITableView.automaticDimension
        }
    }
    
    @objc func qmui_sizeThatFits(_ size: CGSize) -> CGSize {
        alertEstimatedHeightUsageIfDetected()
        let result = qmui_sizeThatFits(size)
        return result
    }
}

extension UITableView {

    @objc func qmui_reloadData() {
        if qmui_indexPathHeightCache.automaticallyInvalidateEnabled {
            qmui_indexPathHeightCache.enumerateAllOrientations(handle: { heightsBySection in
                heightsBySection.removeAll()
            })
        }
        qmui_reloadData()
    }

    @objc func qmui_insertSections(_ sections: IndexSet, with rowAnimation: UITableView.RowAnimation) {
        if qmui_indexPathHeightCache.automaticallyInvalidateEnabled {
            for section in sections {
                qmui_indexPathHeightCache.buildSectionsIfNeeded(section)
                qmui_indexPathHeightCache.enumerateAllOrientations(handle: { heightsBySection in
                    heightsBySection.insert([], at: section)
                })
            }
        }
        qmui_insertSections(sections, with: rowAnimation)
    }

    @objc func qmui_deleteSections(_ sections: IndexSet, with rowAnimation: UITableView.RowAnimation) {
        if qmui_indexPathHeightCache.automaticallyInvalidateEnabled {
            for section in sections {
                qmui_indexPathHeightCache.buildSectionsIfNeeded(section)
                qmui_indexPathHeightCache.enumerateAllOrientations(handle: { heightsBySection in
                    heightsBySection.remove(at: section)
                })
            }
            qmui_deleteSections(sections, with: rowAnimation)
        }
    }

    @objc func qmui_reloadSections(_ sections: IndexSet, with rowAnimation: UITableView.RowAnimation) {
        if qmui_indexPathHeightCache.automaticallyInvalidateEnabled {
            for section in sections {
                qmui_indexPathHeightCache.buildSectionsIfNeeded(section)
                qmui_indexPathHeightCache.enumerateAllOrientations(handle: { heightsBySection in
                    heightsBySection[section].removeAll()
                })
            }
        }
        qmui_reloadSections(sections, with: rowAnimation)
    }

    @objc func qmui_moveSection(_ section: Int, toSection newSection: Int) {
        if qmui_indexPathHeightCache.automaticallyInvalidateEnabled {
            qmui_indexPathHeightCache.buildSectionsIfNeeded(section)
            qmui_indexPathHeightCache.enumerateAllOrientations(handle: { heightsBySection in
                heightsBySection.swapAt(section, newSection)
            })
        }
        qmui_moveSection(section, toSection: newSection)
    }

    @objc func qmui_insertRows(at indexPaths: [IndexPath], with rowAnimation: UITableView.RowAnimation) {
        if qmui_indexPathHeightCache.automaticallyInvalidateEnabled {
            qmui_indexPathHeightCache.buildCachesAtIndexPathsIfNeeded(indexPaths)
            for indexPath in indexPaths {
                qmui_indexPathHeightCache.enumerateAllOrientations(handle: { heightsBySection in
                    heightsBySection[indexPath.section].insert(-1, at: indexPath.row)
                })
            }
        }
        qmui_insertRows(at: indexPaths, with: rowAnimation)
    }

    @objc func qmui_deleteRows(at indexPaths: [IndexPath], with rowAnimation: UITableView.RowAnimation) {
        if qmui_indexPathHeightCache.automaticallyInvalidateEnabled {
            qmui_indexPathHeightCache.buildCachesAtIndexPathsIfNeeded(indexPaths)

            var mutableIndexSetsToRemove: [Int: IndexSet] = [:]

            for indexPath in indexPaths {
                var mutableIndexSet = mutableIndexSetsToRemove[indexPath.section]
                if mutableIndexSet == nil {
                    mutableIndexSet = IndexSet()
                    mutableIndexSetsToRemove[indexPath.section] = mutableIndexSet
                }
                mutableIndexSet?.insert(indexPath.row)
            }

            for (key, indexSet) in mutableIndexSetsToRemove {
                qmui_indexPathHeightCache.enumerateAllOrientations(handle: { heightsBySection in
                    heightsBySection[key].remove(at: indexSet)
                })
            }

            qmui_deleteRows(at: indexPaths, with: rowAnimation)
        }
    }

    @objc func qmui_reloadRows(at indexPaths: [IndexPath], with rowAnimation: UITableView.RowAnimation) {
        if qmui_indexPathHeightCache.automaticallyInvalidateEnabled {
            qmui_indexPathHeightCache.buildCachesAtIndexPathsIfNeeded(indexPaths)
            for indexPath in indexPaths {
                qmui_indexPathHeightCache.enumerateAllOrientations(handle: { heightsBySection in
                    heightsBySection[indexPath.section][indexPath.row] = -1
                })
            }
        }
        qmui_reloadRows(at: indexPaths, with: rowAnimation)
    }

    @objc func qmui_moveRow(at indexPath: IndexPath, to newIndexPath: IndexPath) {
        if qmui_indexPathHeightCache.automaticallyInvalidateEnabled {
            qmui_indexPathHeightCache.buildCachesAtIndexPathsIfNeeded([indexPath, newIndexPath])
            qmui_indexPathHeightCache.enumerateAllOrientations(handle: { heightsBySection in
                var sourceRows = heightsBySection[indexPath.section]
                var destinationRows = heightsBySection[newIndexPath.section]
                let sourceValue = sourceRows[indexPath.row]
                let destinationValue = destinationRows[newIndexPath.row]
                sourceRows[indexPath.row] = destinationValue
                destinationRows[newIndexPath.row] = sourceValue
            })
        }
        qmui_moveRow(at: indexPath, to: newIndexPath)
    }
    
    // iOS 11 里，横竖屏带来的 safeAreaInsets 变化时机晚于计算 cell 高度，所以在计算 cell 高度时是获取不到准确的 safeAreaInsets，所以需要在 safeAreaInsetsDidChange 里重新计算
    // 至于为什么只判断水平方向的变化，请看 https://github.com/QMUI/QMUI_iOS/issues/253
    @objc func cellHeightCache_safeAreaInsetsDidChange() {
        let horizontalSafeAreaInsetsChanged = qmui_safeAreaInsetsBeforeChange.left != qmui_safeAreaInsets.left || qmui_safeAreaInsetsBeforeChange.right != qmui_safeAreaInsets.right
        
        cellHeightCache_safeAreaInsetsDidChange()
        
        if horizontalSafeAreaInsetsChanged {
            if let delegate = delegate as? QMUICellHeightCache_UITableViewDelegate {
                delegate.qmui_willReloadAfterSafeAreaInsetsDidChange?(in: self)
            }
            qmui_keyedHeightCache.invalidateAllHeightCache()
            qmui_indexPathHeightCache.invalidateAllHeightCache()
            qmui_reloadData()
        }
    }
}

// MARK: - QMUILayoutCell
extension UITableView {
    func templateCell(forReuseIdentifier identifier: String) -> UITableViewCell {
        assert(!identifier.isEmpty, "Expect a valid identifier - \(identifier)")
        var templateCellsByIdentifiers = objc_getAssociatedObject(self, &Keys.templateCellsByIdentifiers) as? [String: UITableViewCell]
        if templateCellsByIdentifiers == nil {
            templateCellsByIdentifiers = [:]
            objc_setAssociatedObject(self, &Keys.templateCellsByIdentifiers, templateCellsByIdentifiers, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        var templateCell = templateCellsByIdentifiers![identifier]
        if templateCell == nil {
            // 是否有通过dataSource返回的cell
            if let qmui_dataSource = dataSource as? QMUICellHeightCache_UITableViewDataSource {
                templateCell = qmui_dataSource.qmui_tableView?(self, cellWithIdentifier: identifier)
            }
            // 没有的话，则需要通过register来注册一个cell，否则会crash
            if templateCell == nil {
                templateCell = dequeueReusableCell(withIdentifier: identifier)
                assert(templateCell != nil, "Cell must be registered to table view for identifier - \(identifier)")
            }
            templateCell!.contentView.translatesAutoresizingMaskIntoConstraints = false
            templateCellsByIdentifiers?[identifier] = templateCell
        }
        return templateCell!
    }

    /**
     *  通过 qmui_tableView:cellWithIdentifier: 得到 identifier 对应的 cell 实例，并在 configuration 里对 cell 进行渲染后，得到 cell 的高度。
     *  @param  identifier cell 的 identifier
     *  @param  configuration 用于渲染 cell 的block，一般与 tableView:cellForRowAtIndexPath: 里渲染 cell 的代码一样
     */
    func qmui_heightForCell(withIdentifier identifier: String, configuration: ((UITableViewCell) -> Void)?) -> CGFloat {
        if bounds.isEmpty {
            return 0
        }

        let cell = templateCell(forReuseIdentifier: identifier)
        cell.prepareForReuse()
        configuration?(cell)
        let contentWidth = bounds.width - contentInset.horizontalValue
        var fitSize = CGSize.zero
        if contentWidth > 0 {
            let selector = #selector(sizeThatFits)
            let inherited = !cell.isMember(of: UITableViewCell.self) // 是否UITableViewCell

            let overrided = type(of: cell).instanceMethod(for: selector) != UITableViewCell.instanceMethod(for: selector) // 是否重写了sizeThatFit:
            if inherited && !overrided {
                assert(false, "Customized cell must override '-sizeThatFits:' method if not using auto layout.")
            }
            fitSize = cell.sizeThatFits(CGSize(width: contentWidth, height: CGFloat.greatestFiniteMagnitude))
        }
        return ceil(fitSize.height)
    }

    // 通过indexPath缓存高度
    func qmui_heightForCell(withIdentifier identifier: String, cacheBy indexPath: IndexPath, configuration: ((UITableViewCell) -> Void)?) -> CGFloat {
        if bounds.isEmpty {
            return 0
        }

        if qmui_indexPathHeightCache.existsHeight(at: indexPath) {
            return qmui_indexPathHeightCache.height(for: indexPath)
        }

        let height = qmui_heightForCell(withIdentifier: identifier, configuration: configuration)
        qmui_indexPathHeightCache.cache(height: height, by: indexPath)
        return height
    }

    // 通过key缓存高度
    func qmui_heightForCell(withIdentifier identifier: String, cacheByKey key: String, configuration: ((UITableViewCell) -> Void)?) -> CGFloat {
        if bounds.isEmpty {
            return 0
        }

        if qmui_keyedHeightCache.existsHeight(for: key) {
            return qmui_keyedHeightCache.height(for: key)
        }

        let height = qmui_heightForCell(withIdentifier: identifier, configuration: configuration)
        qmui_keyedHeightCache.cache(height, by: key)
        return height
    }
    
}
