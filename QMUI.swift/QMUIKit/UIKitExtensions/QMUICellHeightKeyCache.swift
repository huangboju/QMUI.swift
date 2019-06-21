//
//  QMUICellHeightKeyCache.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/6/2.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

/**
 *  通过业务定义的一个 key 来缓存 cell 的高度，需搭配 UITableView 或 UICollectionView 使用。
 */
class QMUICellHeightKeyCache: NSObject {
    private var mutableHeightsByKeyForPortrait: [String: CGFloat] = [:]
    private var mutableHeightsByKeyForLandscape: [String: CGFloat] = [:]

    private var mutableHeightsByKeyForCurrentOrientation: [String: CGFloat] {
        return UIDevice.current.orientation.isPortrait ? mutableHeightsByKeyForPortrait : mutableHeightsByKeyForLandscape
    }

    func existsHeight(for key: String) -> Bool {
        guard let number = mutableHeightsByKeyForCurrentOrientation[key] else {
            return false
        }
        return number != -1
    }

    func cache(_ height: CGFloat, by key: String) {
        var mutableHeights = mutableHeightsByKeyForCurrentOrientation
        mutableHeights[key] = height
    }

    func height(for key: String) -> CGFloat {
        return mutableHeightsByKeyForCurrentOrientation[key] ?? 0
    }

    // 使cache失效，多用在data更新之后
    func invalidateHeight(for key: String) {
        mutableHeightsByKeyForPortrait.removeValue(forKey: key)
        mutableHeightsByKeyForLandscape.removeValue(forKey: key)
    }

    func invalidateAllHeightCache() {
        mutableHeightsByKeyForPortrait.removeAll(keepingCapacity: true)
        mutableHeightsByKeyForLandscape.removeAll(keepingCapacity: true)
    }
    
    override var description: String {
        return "\(super.description), mutableHeightsByKeyForPortrait = \(mutableHeightsByKeyForPortrait), mutableHeightsByKeyForLandscape = \(mutableHeightsByKeyForLandscape)"
    }
}
