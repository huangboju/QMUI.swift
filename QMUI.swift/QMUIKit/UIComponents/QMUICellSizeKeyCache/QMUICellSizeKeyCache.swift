//
//  QMUICellSizeKeyCache.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/5/24.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

class QMUICellSizeKeyCache: NSObject {

    private var cachedSizes: [AnyHashable: CGSize] = [:]
    
    /// 检查是否存在某个 key 的 size
    func existsSize(for key: AnyHashable) -> Bool {
        guard let _ = cachedSizes[key] else {
            return false
        }
        return true
    }
    
    /// 将某个 size 缓存到指定的 key
    func cacheSize(_ size: CGSize, for key: AnyHashable) {
        cachedSizes[key] = size
    }
    
    /// 获取指定 key 对应的 size，如果该 key 不存在，则返回 0
    func size(for key: AnyHashable) -> CGSize {
        return cachedSizes[key] ?? CGSize.zero
    }
    
    // 使 cache 失效，多用在 data 更新之后或 UICollectionView 的 size 发生变化的时候，但在 QMUI 里，UICollectionView 的 size 发生变化会自动更新，所以不用处理 size 变化的场景。
    func invalidateSize(for key: AnyHashable) {
        cachedSizes.removeValue(forKey: key)
    }
    
    func invalidateAllSizeCache() {
        cachedSizes.removeAll()
    }
    
    override var description: String {
        return "\(super.description), cachedSize = \(cachedSizes)"
    }
    
}
