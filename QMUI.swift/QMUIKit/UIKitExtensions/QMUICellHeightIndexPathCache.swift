//
//  QMUICellHeightIndexPathCache.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/6/2.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

/**
 *  通过 NSIndexPath 来缓存 cell 的高度，需搭配 UITableView 或 UICollectionView 使用。
 */
class QMUICellHeightIndexPathCache {
    private var heightsBySectionForPortrait: [[CGFloat]] = []
    private var heightsBySectionForLandscape: [[CGFloat]] = []

    // Enable automatically if you're using index path driven height cache
    var automaticallyInvalidateEnabled = false

    private var heightsBySectionForCurrentOrientation: [[CGFloat]] {
        return UIDevice.current.orientation.isPortrait ? heightsBySectionForPortrait : heightsBySectionForLandscape
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
        var heightsBySection = heightsBySectionForCurrentOrientation[indexPath.section]
        heightsBySection[indexPath.row] = height
    }

    func height(for indexPath: IndexPath) -> CGFloat {
        buildCachesAtIndexPathsIfNeeded([indexPath])
        return heightsBySectionForCurrentOrientation[indexPath.section][indexPath.row]
    }

    // 使cache失效，多用在data更新之后
    func invalidateHeight(at indexPath: IndexPath) {
        buildCachesAtIndexPathsIfNeeded([indexPath])
        enumerateAllOrientations { heightsBySection in
            heightsBySection[indexPath.section][indexPath.row] = -1
        }
    }
    
    func invalidateAllHeightCache() {
        enumerateAllOrientations { heightsBySection in
            heightsBySection.removeAll()
        }
    }

    // 给 tableview 和 collectionview 调用的方法
    func enumerateAllOrientations(handle: ((_ heightsBySection: inout [[CGFloat]]) -> Void)?) {
        handle?(&heightsBySectionForPortrait)
        handle?(&heightsBySectionForLandscape)
    }

    func buildSectionsIfNeeded(_ targetSection: Int) {
        enumerateAllOrientations { heightsBySection in
            for section in 0...targetSection {
                if section >= heightsBySection.count {
                    heightsBySection[safe: section] = []
                }
            }
        }
    }
    
    func buildCachesAtIndexPathsIfNeeded(_ indexPaths: [IndexPath]) {
        // Build every section array or row array which is smaller than given index path.
        for indexPath in indexPaths {
            buildSectionsIfNeeded(indexPath.section)
            buildRowsIfNeeded(targetRow: indexPath.row, inExist: indexPath.section)
        }
    }

    private func buildRowsIfNeeded(targetRow: Int, inExist section: Int) {
        enumerateAllOrientations { heightsBySection in
            let heightsByRow = heightsBySection[section]
            for row in 0...targetRow {
                if row >= heightsByRow.count {
                    heightsBySection[safe: section][safe: row] = -1
                }
            }
        }
    }
    
    var description: String {
        return "heightsBySectionForPortrait = \(heightsBySectionForPortrait), heightsBySectionForLandscape = \(heightsBySectionForLandscape)"
    }
}
