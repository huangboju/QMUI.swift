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
