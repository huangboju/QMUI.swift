//
//  UICollectionView+QMUI.swift
//  QMUI.swift
//
//  Created by xnxin on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

extension UICollectionView {

    /// 清除所有已选中的item的选中状态
    func qmui_clearsSelection() {
        guard let selectedItemIndexPaths = indexPathsForSelectedItems else {
            return
        }
        for indexPath in selectedItemIndexPaths {
            deselectItem(at: indexPath, animated: true)
        }
    }

    /// 重新`reloadData`，同时保持`reloadData`前item的选中状态
    func qmui_reloadDataKeepingSelection() {
        guard let selectedIndexPaths = indexPathsForSelectedItems else {
            return
        }
        reloadData()
        for indexPath in selectedIndexPaths {
            selectItem(at: indexPath, animated: false, scrollPosition: [])
        }
    }

    /// 递归找到view在哪个cell里，不存在则返回nil
    private func parentCell(for view: UIView) -> UICollectionViewCell? {
        if view.superview == nil {
            return nil
        }
        if let cell = view.superview as? UICollectionViewCell {
            return cell
        }
        return parentCell(for: view.superview!)
    }

    /**
     *  获取某个view在collectionView内对应的indexPath
     *
     *  例如某个view是某个cell里的subview，在这个view的点击事件回调方法里，就能通过`qmui_indexPathForItemAtView:`获取被点击的view所处的cell的indexPath
     *
     *  @warning 注意返回的indexPath有可能为nil，要做保护。
     */
    func qmui_indexPathForItem(at view: UIView) -> IndexPath? {
        if let parentCell = parentCell(for: view) {
            return indexPath(for: parentCell)
        }
        return nil
    }

    /// 判断当前 indexPath 的 item 是否为可视的 item
    func qmui_itemVisible(at indexPath: IndexPath) -> Bool {
        for visibleIndexPath in indexPathsForVisibleItems {
            if indexPath == visibleIndexPath {
                return true
            }
        }
        return false
    }

    /**
     *  获取可视区域内第一个cell的indexPath。
     *
     *  为什么需要这个方法是因为系统的indexPathsForVisibleItems方法返回的数组成员是无序排列的，所以不能直接通过firstObject拿到第一个cell。
     *
     *  @warning 若可视区域为CGRectZero，则返回nil
     */
    func qmui_indexPathForFirstVisibleCell() -> IndexPath? {
        let visibleIndexPaths = indexPathsForVisibleItems
        if visibleIndexPaths.isEmpty {
            return nil
        }

        var minimumIndexPath: IndexPath?

        for indexPath in visibleIndexPaths {
            if minimumIndexPath == nil {
                minimumIndexPath = indexPath
                continue
            }

            if indexPath.section < minimumIndexPath?.section ?? 0 {
                minimumIndexPath = indexPath
                continue
            }

            if indexPath.item < minimumIndexPath?.item ?? 0 {
                minimumIndexPath = indexPath
                continue
            }
        }
        return minimumIndexPath
    }
}

/// ====================== 计算动态cell高度相关 =======================

/// QMUIKeyedHeightCache
extension UICollectionView {
    private struct Keys {
        static var qmui_keyedHeightCache = "qmui_keyedHeightCache"
        static var qmui_indexPathHeightCache = "qmui_indexPathHeightCache"
        static var qmui_templateCell = "qmui_templateCell"
    }

    var qmui_keyedHeightCache: QMUICellHeightKeyCache? {
        var cache = objc_getAssociatedObject(self, &Keys.qmui_keyedHeightCache) as? QMUICellHeightKeyCache
        if cache == nil {
            cache = QMUICellHeightKeyCache()
            objc_setAssociatedObject(self, &Keys.qmui_keyedHeightCache, cache, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        return cache
    }
}

/// QMUIKeyedHeightCache
extension UICollectionView {

    var qmui_indexPathHeightCache: QMUICellHeightIndexPathCache? {
        var cache = objc_getAssociatedObject(self, &Keys.qmui_indexPathHeightCache) as? QMUICellHeightIndexPathCache
        if cache == nil {
            cache = QMUICellHeightIndexPathCache()
            objc_setAssociatedObject(self, &Keys.qmui_indexPathHeightCache, cache, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        return cache
    }
}

/// QMUIIndexPathHeightCacheInvalidation
extension UICollectionView: SelfAware3 {
    private static let _onceToken = UUID().uuidString

    static func awake3() {
        DispatchQueue.once(token: _onceToken) {
            let clazz = UICollectionView.self
            
            let selectors = [
                #selector(UICollectionView.reloadData),
                #selector(UICollectionView.insertSections),
                #selector(UICollectionView.deleteSections),
                #selector(UICollectionView.reloadSections),
                #selector(UICollectionView.moveSection(_:toSection:)),
                #selector(UICollectionView.insertItems(at:)),
                #selector(UICollectionView.deleteItems(at:)),
                #selector(UICollectionView.reloadItems(at:)),
                #selector(UICollectionView.moveItem(at:to:)),
            ]
            
            let qmui_selectors = [
                #selector(UICollectionView.qmui_reloadData),
                #selector(UICollectionView.qmui_insertSections),
                #selector(UICollectionView.qmui_deleteSections),
                #selector(UICollectionView.qmui_reloadSections),
                #selector(UICollectionView.qmui_moveSection(_:toSection:)),
                #selector(UICollectionView.qmui_insertItems(at:)),
                #selector(UICollectionView.qmui_deleteItems(at:)),
                #selector(UICollectionView.qmui_reloadItems(at:)),
                #selector(UICollectionView.qmui_moveItem(at:to:)),
                ]

            for index in 0..<selectors.count {
                ReplaceMethod(clazz, selectors[index], qmui_selectors[index])
            }
        }
    }

    @objc open func qmui_reloadDataWithoutInvalidateIndexPathHeightCache() {
        qmui_reloadData()
    }

    @objc open func qmui_reloadData() {
        if qmui_indexPathHeightCache?.automaticallyInvalidateEnabled ?? false {
            qmui_indexPathHeightCache?.enumerateAllOrientations(handle: { heightsBySection in
                heightsBySection.removeAll()
            })
        }
        qmui_reloadData()
    }

    @objc open func qmui_insertSections(_ sections: IndexSet) {
        if qmui_indexPathHeightCache?.automaticallyInvalidateEnabled ?? false {
            for section in sections {
                qmui_indexPathHeightCache?.buildSectionsIfNeeded(section)
                qmui_indexPathHeightCache?.enumerateAllOrientations(handle: { heightsBySection in
                    heightsBySection.insert([], at: section)
                })
            }
        }
        qmui_insertSections(sections)
    }

    @objc open func qmui_deleteSections(_ sections: IndexSet) {
        if qmui_indexPathHeightCache?.automaticallyInvalidateEnabled ?? false {
            for section in sections {
                qmui_indexPathHeightCache?.buildSectionsIfNeeded(section)
                qmui_indexPathHeightCache?.enumerateAllOrientations(handle: { heightsBySection in
                    heightsBySection.remove(at: section)
                })
            }
        }
        qmui_deleteSections(sections)
    }

    @objc open func qmui_reloadSections(_ sections: IndexSet) {
        if qmui_indexPathHeightCache?.automaticallyInvalidateEnabled ?? false {
            for section in sections {
                qmui_indexPathHeightCache?.buildSectionsIfNeeded(section)
                qmui_indexPathHeightCache?.enumerateAllOrientations(handle: { heightsBySection in
                    heightsBySection[section].removeAll()
                })
            }
        }
        qmui_reloadSections(sections)
    }

    @objc open func qmui_moveSection(_ section: Int, toSection newSection: Int) {
        if qmui_indexPathHeightCache?.automaticallyInvalidateEnabled ?? false {
            qmui_indexPathHeightCache?.buildSectionsIfNeeded(section)
            qmui_indexPathHeightCache?.buildSectionsIfNeeded(newSection)
            qmui_indexPathHeightCache?.enumerateAllOrientations(handle: { heightsBySection in
                heightsBySection.swapAt(section, newSection)
            })
        }
        qmui_moveSection(section, toSection: newSection)
    }

    @objc open func qmui_insertItems(at indexPaths: [IndexPath]) {
        if qmui_indexPathHeightCache?.automaticallyInvalidateEnabled ?? false {
            qmui_indexPathHeightCache?.buildCachesAtIndexPathsIfNeeded(indexPaths)
            for indexPath in indexPaths {
                qmui_indexPathHeightCache?.enumerateAllOrientations(handle: { heightsBySection in
                    var rows = heightsBySection[indexPath.section]
                    rows.insert(-1, at: indexPath.item)
                    heightsBySection[indexPath.section] = rows
                })
            }
        }
        qmui_insertItems(at: indexPaths)
    }

    @objc open func qmui_deleteItems(at indexPaths: [IndexPath]) {
        if qmui_indexPathHeightCache?.automaticallyInvalidateEnabled ?? false {
            qmui_indexPathHeightCache?.buildCachesAtIndexPathsIfNeeded(indexPaths)
            var mutableIndexSetsToRemove: [Int: IndexSet] = [:]
            for indexPath in indexPaths {
                var mutableIndexSet = mutableIndexSetsToRemove[indexPath.section]
                if mutableIndexSet == nil {
                    mutableIndexSet = IndexSet()
                    mutableIndexSetsToRemove[indexPath.section] = mutableIndexSet
                }
                mutableIndexSet?.insert(indexPath.item)
            }

            for dict in mutableIndexSetsToRemove {
                qmui_indexPathHeightCache?.enumerateAllOrientations(handle: { heightsBySection in
                    var rows = heightsBySection[dict.key]
                    rows.remove(at: dict.value)
                    heightsBySection[dict.key] = rows
                })
            }
        }
        qmui_deleteItems(at: indexPaths)
    }

    @objc open func qmui_reloadItems(at indexPaths: [IndexPath]) {
        if qmui_indexPathHeightCache?.automaticallyInvalidateEnabled ?? false {
            qmui_indexPathHeightCache?.buildCachesAtIndexPathsIfNeeded(indexPaths)
            for indexPath in indexPaths {
                qmui_indexPathHeightCache?.enumerateAllOrientations(handle: { heightsBySection in
                    heightsBySection[indexPath.section][indexPath.item] = -1
                })
            }
        }
        qmui_reloadItems(at: indexPaths)
    }

    @objc open func qmui_moveItem(at indexPath: IndexPath, to newIndexPath: IndexPath) {
        if qmui_indexPathHeightCache?.automaticallyInvalidateEnabled ?? false {
            qmui_indexPathHeightCache?.buildCachesAtIndexPathsIfNeeded([indexPath, newIndexPath])
            qmui_indexPathHeightCache?.enumerateAllOrientations(handle: { heightsBySection in
                if heightsBySection.count > 0 && heightsBySection.count > indexPath.section && heightsBySection.count > newIndexPath.section {
                    let sourceValue = heightsBySection[indexPath.section][indexPath.item]
                    let destinationValue = heightsBySection[newIndexPath.section][newIndexPath.item]
                    heightsBySection[newIndexPath.section][newIndexPath.item] = sourceValue
                    heightsBySection[indexPath.section][indexPath.item] = destinationValue
                }
            })
        }
        qmui_moveItem(at: indexPath, to: newIndexPath)
    }
}

/// QMUILayoutCell
extension UICollectionView {
    func templateCell(for identifier: String, cellClass: UICollectionViewCell.Type) -> UICollectionViewCell? {
        assert(identifier.length > 0, "Expect a valid identifier - \(identifier)")
        assert(collectionViewLayout is UICollectionViewFlowLayout, "only flow layout accept")
        var templateCellsByIdentifiers = objc_getAssociatedObject(self, &Keys.qmui_templateCell) as? [String: UICollectionViewCell]
        if templateCellsByIdentifiers == nil {
            templateCellsByIdentifiers = [:]
            objc_setAssociatedObject(self, &Keys.qmui_templateCell, templateCellsByIdentifiers!, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        var templateCell = templateCellsByIdentifiers?[identifier]
        if templateCell == nil {
            // CollecionView 跟 TableView 不太一样，无法通过 dequeueReusableCellWithReuseIdentifier:forIndexPath: 来拿到cell（如果这样做，首先indexPath不知道传什么值，其次是这样做会已知crash，说数组越界），所以只能通过传一个class来通过init方法初始化一个cell，但是也有缓存来复用cell。
            // templateCell = [self dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]]
            templateCell = cellClass.init(frame: .zero)
            assert(templateCell != nil, "Cell must be registered to collection view for identifier - \(identifier)")
        }
        templateCell!.contentView.translatesAutoresizingMaskIntoConstraints = false
        templateCellsByIdentifiers?[identifier] = templateCell
        return templateCell
    }

    func qmui_heightForCell(with identifier: String, cellClass: UICollectionViewCell.Type, itemWidth: CGFloat, configuration: ((UICollectionViewCell?) -> Void)?) -> CGFloat {
        if bounds.isEmpty {
            return 0
        }
        let cell = templateCell(for: identifier, cellClass: cellClass)
        cell?.prepareForReuse()
        configuration?(cell)
        var fitSize = CGSize.zero
        if cell != nil && itemWidth > 0 {
            //            let selector = #selector(sizeThatFits)
            //            let overrided = [cell.class instanceMethodForSelector:selector] != [UICollectionViewCell instanceMethodForSelector:selector]
            //            if (inherited && !overrided) {
            //                NSAssert(NO, @"Customized cell must override '-sizeThatFits:' method if not using auto layout.")
            //            }
            fitSize = cell?.sizeThatFits(CGSize(width: itemWidth, height: CGFloat.infinity)) ?? .zero
        }
        return ceil(fitSize.height)
    }

    // 通过indexPath缓存高度
    func qmui_heightForCell(with identifier: String, cellClass: UICollectionViewCell.Type, itemWidth: CGFloat, cacheBy indexPath: IndexPath, configuration: ((UICollectionViewCell?) -> Void)?) -> CGFloat {
        if bounds.isEmpty {
            return 0
        }
        if qmui_indexPathHeightCache?.existsHeight(at: indexPath) ?? false {
            return qmui_indexPathHeightCache?.height(for: indexPath) ?? 0
        }
        let height = qmui_heightForCell(with: identifier, cellClass: cellClass, itemWidth: itemWidth, configuration: configuration)
        qmui_indexPathHeightCache?.cache(height: height, by: indexPath)
        return height
    }

    // 通过key缓存高度
    func qmui_heightForCell(with identifier: String, cellClass: UICollectionViewCell.Type, itemWidth: CGFloat, cacheBy key: String, configuration: ((UICollectionViewCell?) -> Void)?) -> CGFloat {
        if bounds.isEmpty {
            return 0
        }
        if qmui_keyedHeightCache?.existsHeight(for: key) ?? false {
            return qmui_keyedHeightCache?.height(for: key) ?? 0
        }
        let height = qmui_heightForCell(with: identifier, cellClass: cellClass, itemWidth: itemWidth, configuration: configuration)
        qmui_keyedHeightCache?.cache(height, by: key)
        return height
    }
}
