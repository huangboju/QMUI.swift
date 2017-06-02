//
//  QMUICellHeightKeyCache.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/6/2.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

class QMUICellHeightKeyCache {
    private var mutableHeightsByKeyForPortrait: [String: CGFloat] = [:]
    private var mutableHeightsByKeyForLandscape: [String: CGFloat] = [:]
    
    private var mutableHeightsByKeyForCurrentOrientation: [String: CGFloat] {
        return UIDeviceOrientationIsPortrait(UIDevice.current.orientation) ? mutableHeightsByKeyForPortrait : mutableHeightsByKeyForLandscape
    }
    
    func existsHeight(for key: String) -> Bool {
        guard let number = mutableHeightsByKeyForCurrentOrientation[key] else {
            return false
        }
        return number != -1
    }
    
    func cache(_ height: CGFloat, by key: String) {
        if UIDeviceOrientationIsPortrait(UIDevice.current.orientation) {
            mutableHeightsByKeyForPortrait[key] = height
        } else {
            mutableHeightsByKeyForLandscape[key] = height
        }
    }

    func height(for key: String) -> CGFloat {
        return mutableHeightsByKeyForCurrentOrientation[key] ?? 0
    }

    // Invalidation
    func invalidateHeight(for key: String) {
        mutableHeightsByKeyForPortrait.removeValue(forKey: key)
        mutableHeightsByKeyForLandscape.removeValue(forKey: key)
    }

    func invalidateAllHeightCache() {
        mutableHeightsByKeyForPortrait.removeAll(keepingCapacity: true)
        mutableHeightsByKeyForLandscape.removeAll(keepingCapacity: true)
    }
}
