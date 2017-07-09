//
//  QMUICellHeightIndexPathCache.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/6/2.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

typealias FDIndexPathHeightsBySection = [[CGFloat]]

class QMUICellHeightIndexPathCache {
    private lazy var heightsBySectionForPortrait: FDIndexPathHeightsBySection = []
    private lazy var heightsBySectionForLandscape: FDIndexPathHeightsBySection = []

    // Enable automatically if you're using index path driven height cache
    public var automaticallyInvalidateEnabled = false
    
    private var heightsBySectionForCurrentOrientation: FDIndexPathHeightsBySection {
        return UIDeviceOrientationIsPortrait(UIDevice.current.orientation) ? heightsBySectionForPortrait : heightsBySectionForLandscape
    }
    
    func enumerateAllOrientations(using handle: (inout FDIndexPathHeightsBySection) -> Void) {
        handle(&heightsBySectionForPortrait)
        handle(&heightsBySectionForLandscape)
    }
    
    // Height cache
    func existsHeight(at indexPath: IndexPath) -> Bool {
        buildCachesAtIndexPathsIfNeeded([indexPath])
        let number = heightsBySectionForCurrentOrientation[indexPath.section][indexPath.row]
        return number != -1
    }
    
    func cache(height: CGFloat, by indexPath: IndexPath) {
        automaticallyInvalidateEnabled = true
        buildCachesAtIndexPathsIfNeeded([indexPath])
        if UIDeviceOrientationIsPortrait(UIDevice.current.orientation) {
            heightsBySectionForPortrait[indexPath.section][indexPath.row] = height
        } else {
            heightsBySectionForLandscape[indexPath.section][indexPath.row] = height
        }
    }
    
    func height(for indexPath: IndexPath) -> CGFloat {
        buildCachesAtIndexPathsIfNeeded([indexPath])
        return heightsBySectionForCurrentOrientation[indexPath.section][indexPath.row]
    }
    
    func invalidateHeight(at indexPath: IndexPath) {
        buildCachesAtIndexPathsIfNeeded([indexPath])
        enumerateAllOrientations { heightsBySection in
            heightsBySection[indexPath.section][indexPath.row] = -1
        }
    }
    
    func buildCachesAtIndexPathsIfNeeded(_ indexPaths: [IndexPath]) {
        // Build every section array or row array which is smaller than given index path.
        for indexPath in indexPaths {
            buildSectionsIfNeeded(indexPath.section)
            buildRowsIfNeeded(targetRow: indexPath.row, inExist: indexPath.section)
        }
    }
    
    func invalidateAllHeightCache() {
        enumerateAllOrientations { heightsBySection in
            heightsBySection.removeAll()
        }
    }

    func buildSectionsIfNeeded(_ targetSection: Int) {
        enumerateAllOrientations { heightsBySection in
            for section in 0 ... targetSection where section >= heightsBySection.count {
                heightsBySection[safe: section] = []
            }
        }
    }

    func buildRowsIfNeeded(targetRow: Int, inExist section: Int) {
        enumerateAllOrientations { heightsBySection in
            let heightsByRow = heightsBySection[section]
            for row in 0 ... targetRow where row >= heightsByRow.count {
                heightsBySection[safe: section][safe: row] = -1
            }
        }
    }
}
