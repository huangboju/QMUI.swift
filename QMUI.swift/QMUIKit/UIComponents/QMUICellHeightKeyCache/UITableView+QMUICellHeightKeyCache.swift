//
//  UITableView+QMUICellHeightKeyCache.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/5/23.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import Foundation

/**
 *  自动缓存 self-sizing cell 的高度，避免重复计算。使用方法：
 *  1. 将 tableView.qmui_cacheCellHeightByKeyAutomatically = YES
 *  2. 实现 tableView 的 delegate 方法 qmui_tableView:cacheKeyForRowAtIndexPath: 返回一个 key。建议 key 由所有可能影响高度的字段拼起来，这样当数据发生变化时不需要手动更新缓存。
 *
 *  @note 注意这里的高度缓存仅适合于使用 self-sizing 机制的 tableView（也即 tableView.rowHeight = UITableViewAutomaticDimension），QMUICellHeightKeyCache 会自动在 willDisplayCell 里将 cell 的当前高度缓存起来，然后在 heightForRow 里从缓存中读取高度后使用。而如果你的 tableView 并没有使用 self-sizing 机制（也即自己重写了 heightForRow），则请勿使用本控件的功能。
 *
 *  @note 在 UITableView 的宽度和 contentInset 发生变化时（例如横竖屏旋转、iPad 分屏），高度缓存会自动刷新，所以无需为这种情况做保护。
 */
extension UITableView {
    fileprivate struct Keys {
        static var qmuiCacheCellHeightByKeyAutomatically = "qmuiCacheCellHeightByKeyAutomatically"
        static var qmuiAllKeyCaches = "qmuiAllKeyCaches"
    }
    
    /// 控制是否要自动缓存 cell 的高度，默认为 false
    var qmui_cacheCellHeightByKeyAutomatically: Bool {
        get {
            return objc_getAssociatedObject(self, &Keys.qmuiCacheCellHeightByKeyAutomatically) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &Keys.qmuiCacheCellHeightByKeyAutomatically, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if newValue {
                assert(delegate == nil || delegate!.responds(to: #selector(QMUICellHeightKeyCache_UITableViewDelegate.qmui_tableView(_:cacheKeyForRowAt:))), "\(String(describing: delegate)) 需要实现 \(NSStringFromSelector(#selector(QMUICellHeightKeyCache_UITableViewDelegate.qmui_tableView(_:cacheKeyForRowAt:)))) 方法才能自动缓存 cell 高度")
                assert(estimatedRowHeight != 0, "estimatedRowHeight 不能为 0，否则无法开启 self-sizing cells 功能")
                
                replaceMethodForDelegateIfNeeded(delegate)
                // 在上面那一句 replaceMethodForDelegateIfNeeded 里可能修改了 delegate 里的一些方法，所以需要通过重新设置 delegate 来触发 tableView 读取新的方法。iOS 8 要先置空再设置才能生效。
                
                let tempDelegate = delegate
                if #available(iOS 9.0, *) {
                } else {
                    delegate = nil
                }
                delegate = tempDelegate
            }
        }
    }
    
    fileprivate var qmui_allKeyCaches: [CGFloat: QMUICellHeightKeyCache] {
        get {
            return objc_getAssociatedObject(self, &Keys.qmuiAllKeyCaches) as? [CGFloat: QMUICellHeightKeyCache] ?? [:]
        }
        set {
            objc_setAssociatedObject(self, &Keys.qmuiAllKeyCaches, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 获取当前的缓存容器。tableView 的宽度和 contentInset 发生变化时，这个数组也会跟着变，但当 tableView 宽度小于 0 时会返回 nil。
    var qmui_currentCellHeightKeyCache: QMUICellHeightKeyCache? {
        let width = widthForCacheKey()
        if width <= 0 {
            return nil
        }
        var cache = qmui_allKeyCaches[width]
        if cache == nil {
            cache = QMUICellHeightKeyCache()
            qmui_allKeyCaches[width] = cache
        }
        return cache
    }
    
    // 只考虑内容区域的宽度，因为 cell 的宽度就由这个来决定
    private func widthForCacheKey() -> CGFloat {
        let width = bounds.width - qmui_contentInset.horizontalValue
        return width
    }
    
    @objc func qmui_tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        tableView.qmui_tableView(tableView, willDisplay: cell, forRowAt: indexPath)
        if tableView.qmui_cacheCellHeightByKeyAutomatically, let delegate = self as? QMUICellHeightKeyCache_UITableViewDelegate {
            let cachedKey = delegate.qmui_tableView?(tableView, cacheKeyForRowAt: indexPath)
            tableView.qmui_currentCellHeightKeyCache?.cacheHeight(cell.frame.height, for: cachedKey as! AnyHashable)
        }
    }
    
    @objc func qmui_tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView.qmui_cacheCellHeightByKeyAutomatically {
            if let delegate = self as? QMUICellHeightKeyCache_UITableViewDelegate {
                let cachedKey = delegate.qmui_tableView?(tableView, cacheKeyForRowAt: indexPath)
                if tableView.qmui_currentCellHeightKeyCache?.existsHeight(for: cachedKey as! AnyHashable) ?? false {
                    return tableView.qmui_currentCellHeightKeyCache!.height(for: cachedKey as! AnyHashable)
                }
                // 由于 QMUICellHeightKeyCache 只对 self-sizing 的 cell 生效，所以这里返回这个值，以使用 self-sizing 效果
                return UITableViewAutomaticDimension
            }
        }
        // 对于开启过 qmui_cacheCellHeightByKeyAutomatically 然后又关闭的 class 就会走到这里，此时已经无法调用回之前被替换的方法的实现，所以直接使用 tableView.rowHeight
        // TODO: molice 最好应该在 replaceMethodForDelegateIfNeeded: 里判断在替换方法之前 delegate 是否已经有实现 heightForRow，如果有，则在这里调用回它自己的实现，如果没有，再使用 tableView.rowHeight，不然现在的做法会导致 delegate 里关闭了自动缓存的情况下就算实现了 heightForRow，也无法被调用。
        return tableView.rowHeight
    }
    
    private static var qmui_methodsReplacedClasses = Set<String>()
    
    private func replaceMethodForDelegateIfNeeded(_ delegate: UITableViewDelegate?) {
        guard let delegate = delegate, qmui_cacheCellHeightByKeyAutomatically else {
            return
        }
        let clazzString = String(describing: type(of: delegate))
        if UITableView.qmui_methodsReplacedClasses.contains(clazzString) {
            return
        }
        UITableView.qmui_methodsReplacedClasses.insert(clazzString)
        
        ReplaceMethodInTwoClasses(type(of: delegate), #selector(UITableViewDelegate.tableView(_:willDisplay:forRowAt:)), type(of: self), #selector(qmui_tableView(_:willDisplay:forRowAt:)))
        ReplaceMethodInTwoClasses(type(of: delegate), #selector(UITableViewDelegate.tableView(_:heightForRowAt:)), type(of: self), #selector(qmui_tableView(_:heightForRowAt:)))
    }
    
    func qmui_invalidateAllCellHeightKeyCache() {
        qmui_allKeyCaches.removeAll()
    }
}

extension UITableView {
    @objc func qmui_setDelegate(_ delegate: UITableViewDelegate?) {
        replaceMethodForDelegateIfNeeded(delegate)
        qmui_setDelegate(delegate)
    }
}
