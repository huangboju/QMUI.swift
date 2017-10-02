//
//  UICollectionView+QMUI.swift
//  QMUI.swift
//
//  Created by xnxin on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

extension UICollectionView {
    /**
     *  判断当前 indexPath 的 item 是否为可视的 item
     */
    func qmui_itemVisible(at indexPath: IndexPath) -> Bool {
        for visibleIndexPath in indexPathsForVisibleItems {
            if indexPath == visibleIndexPath {
                return true
            }
        }
        return false
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
    
    /// 递归找到view在哪个cell里，不存在则返回nil
    private func parentCell(for view: UIView) -> UICollectionViewCell? {
        guard let cell = view.superview as? UICollectionViewCell else {
            return parentCell(for: view)
        }
        return cell
    }
}
