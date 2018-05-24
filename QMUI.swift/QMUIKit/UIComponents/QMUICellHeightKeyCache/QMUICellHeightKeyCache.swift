//
//  QMUICellHeightKeyCache.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/5/23.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

/**
 *  通过业务定义的一个 key 来缓存 cell 的高度，需搭配 UITableView 使用，一般不用你自己去 init。
 *  具体使用方式请看 UITableView (QMUICellHeightKeyCache) 的注释。
 */
class QMUICellHeightKeyCache: NSObject {

    private var cachedHeights: [AnyHashable: CGFloat] = [:]
    
    func existsHeight(for key: AnyHashable) -> Bool {
        guard let _ = cachedHeights[key] else {
            return false
        }
        return true
    }
    
    func cacheHeight(_ height: CGFloat, for key: AnyHashable) {
        cachedHeights[key] = height
    }
    
    func height(for key: AnyHashable) -> CGFloat {
        return cachedHeights[key] ?? 0
    }
    
    // 使cache失效，多用在data更新之后
    func invalidateHeight(for key: AnyHashable) {
        cachedHeights.removeValue(forKey: key)
    }
    
    func invalidateAllHeightCache() {
        cachedHeights.removeAll()
    }
    
    override var description: String {
        return "\(super.description), cachedHeights = \(cachedHeights)"
    }
    
}
