//
//  UICollectionView+QMUICellSizeKeyCache.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/5/24.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

@objc protocol QMUICellSizeKeyCache_UICollectionViewDelegate {

    @objc optional func qmui_collectionView(_ collectionView: UICollectionView, cacheKeyForRowAt indexPath: IndexPath) -> AnyObject
}

import Foundation

extension UICollectionView {
    fileprivate struct Keys {
        static var qmui_cacheCellSizeByKeyAutomatically = "qmui_cacheCellSizeByKeyAutomatically"
        static var qmuiAllKeyCaches = "qmuiAllKeyCaches"
    }
    
    /// 控制是否要自动缓存 cell 的高度，默认为 false
    var qmui_cacheCellSizeByKeyAutomatically: Bool {
        get {
            return objc_getAssociatedObject(self, &Keys.qmui_cacheCellSizeByKeyAutomatically) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &Keys.qmui_cacheCellSizeByKeyAutomatically, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if newValue {
                assert(collectionViewLayout is UICollectionViewFlowLayout, "QMUICellSizeKeyCache 只支持 UICollectionViewFlowLayout")
                
                replaceMethodForDelegateIfNeeded(delegate)
                
                // 在上面那一句 replaceMethodForDelegateIfNeeded 里可能修改了 delegate 里的一些方法，所以需要通过重新设置 delegate 来触发 tableView 读取新的方法。与 UITableView 不同，UICollectionView 不管哪个 iOS 版本都要先置为 nil 再重新设置才能让 delegate 方法替
                let tempDelegate = delegate
                delegate = nil
                delegate = tempDelegate
            }
        }
    }
    
    fileprivate var qmui_allKeyCaches: [CGFloat: QMUICellSizeKeyCache] {
        get {
            return objc_getAssociatedObject(self, &Keys.qmuiAllKeyCaches) as? [CGFloat: QMUICellSizeKeyCache] ?? [:]
        }
        set {
            objc_setAssociatedObject(self, &Keys.qmuiAllKeyCaches, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

extension UICollectionView {
    
    var qmui_currentCellSizeKeyCache: QMUICellSizeKeyCache? {
        let width = widthForCacheKey()
        if width <= 0 {
            return nil
        }
        var cache = qmui_allKeyCaches[width]
        if cache == nil {
            cache = QMUICellSizeKeyCache()
            qmui_allKeyCaches[width] = cache
        }
        return cache
    }
    
    // 当 collectionView 水平滚动时，则认为垂直方向的内容区域会影响 cell 的 size 计算。而当 collectionView 垂直滚动时，则认为水平方向的内容区域会影响 cell 的 size 计算。
    private func widthForCacheKey() -> CGFloat {
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        if layout.scrollDirection == .horizontal {
            let height = bounds.height - qmui_contentInset.verticalValue - layout.sectionInset.verticalValue
            return height
        }
        let width = bounds.width - qmui_contentInset.horizontalValue - layout.sectionInset.horizontalValue
        return width
    }
    
    @objc func qmui_collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        collectionView.qmui_collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
        if collectionView.qmui_cacheCellSizeByKeyAutomatically, let delegate = self as? QMUICellSizeKeyCache_UICollectionViewDelegate {
            if delegate.qmui_collectionView(_:cacheKeyForRowAt:) == nil {
                assert(false, "\(delegate) 需要实现 \(NSStringFromSelector(#selector(QMUICellSizeKeyCache_UICollectionViewDelegate.qmui_collectionView(_:cacheKeyForRowAt:)))) 方法才能自动缓存 cell 高度")
            }
            let cachedKey = delegate.qmui_collectionView?(collectionView, cacheKeyForRowAt: indexPath)
            collectionView.qmui_currentCellSizeKeyCache?.cacheSize(cell.frame.size, for: cachedKey as! AnyHashable)
        }
    }
    
    private static var qmui_methodsReplacedClasses = Set<String>()
    
    private func replaceMethodForDelegateIfNeeded(_ delegate: UICollectionViewDelegate?) {
        guard let delegate = delegate, qmui_cacheCellSizeByKeyAutomatically else {
            return
        }
        let clazzString = String(describing: type(of: delegate))
        if UICollectionView.qmui_methodsReplacedClasses.contains(clazzString) {
            return
        }
        UICollectionView.qmui_methodsReplacedClasses.insert(clazzString)
        
        ReplaceMethodInTwoClasses(type(of: delegate), #selector(UICollectionViewDelegate.collectionView(_:willDisplay:forItemAt:)), type(of: self), #selector(qmui_collectionView(_:willDisplay:forItemAt:)))
//        ReplaceMethodInTwoClasses(type(of: delegate), #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:sizeForItemAt:)), type(of: self), #selector(qmui_collectionView(_:layout:sizeForItemAt:)))
    }
}

extension UICollectionView {
    @objc func qmui_setDelegate(_ delegate: UICollectionViewDelegate?) {
        replaceMethodForDelegateIfNeeded(delegate)
        qmui_setDelegate(delegate)
    }
}
