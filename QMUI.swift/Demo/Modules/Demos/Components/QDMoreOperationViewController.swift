//
//  QDMoreOperationViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/4/20.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

enum MoreOperationTag {
    case shareWechat
    case shareMoment
    case shareQzone
    case shareWeibo
    case shareMail
    case bookMark
    case safari
    case report
}

class QDMoreOperationViewController: QDCommonListViewController {
    
    override func initDataSource() {
        super.initDataSource()
        
        dataSourceWithDetailText = QMUIOrderedDictionary(
            dictionaryLiteral:
            ("支持 item 多行显示", "每个 item 可通过 selected 来切换不同状态"),
            ("支持动态修改 item 位置", "点击第二行 item 来修改第一行 item"),
            ("支持修改皮肤样式（例如夜间模式）", "通过 appearance 设置全局样式"))
    }

    override func didSelectCell(_ title: String) {
        tableView.qmui_clearsSelection()
        
        if title == "支持 item 多行显示" {
            let moreOperationController = QMUIMoreOperationController()
            // 如果你的 item 是确定的，则可以直接通过 items 属性来显示，如果 item 需要经过一些判断才能确定下来，请看第二个示例
            moreOperationController.items = [
                // 第一行
                [QMUIMoreOperationItemView(image: UIImageMake("icon_moreOperation_shareFriend")!, title: "分享给微信好友", handler: { (moreOperationController, itemView) in
                    moreOperationController.hideToBottom()
                    // 如果嫌每次都在 handler 里写 hideToBottom 烦，也可以直接把这句写到 moreOperationController:didSelectItemView: 里，它可与 handler 共存
                    }),
                 QMUIMoreOperationItemView(image: UIImageMake("icon_moreOperation_shareMoment")!, title: "分享到朋友圈", handler: { (moreOperationController, itemView) in
                    moreOperationController.hideToBottom()
                 }),
                 QMUIMoreOperationItemView(image: UIImageMake("icon_moreOperation_shareWeibo")!, title: "分享到微博", handler: { (moreOperationController, itemView) in
                    moreOperationController.hideToBottom()
                 }),
                 QMUIMoreOperationItemView(image: UIImageMake("icon_moreOperation_shareQzone")!, title: "分享到QQ空间", handler: { (moreOperationController, itemView) in
                    moreOperationController.hideToBottom()
                 }),
                 QMUIMoreOperationItemView(image: UIImageMake("icon_moreOperation_shareChat")!, title: "分享到私信", handler: { (moreOperationController, itemView) in
                    moreOperationController.hideToBottom()
                 })],
                // 第二行
                [QMUIMoreOperationItemView(image: UIImageMake("icon_moreOperation_collect")!, selectedImage:UIImageMake("icon_moreOperation_notCollect"), title: "分享到私信", selectedTitle:"取消收藏", handler: { (moreOperationController, itemView) in
                    itemView.isSelected = !itemView.isSelected// 通过 selected 切换 itemView 的状态
                }),
                 QMUIMoreOperationItemView(image: UIImageMake("icon_moreOperation_report")!, title: "反馈", handler: { (moreOperationController, itemView) in
                    moreOperationController.hideToBottom()
                 }),
                 QMUIMoreOperationItemView(image: UIImageMake("icon_moreOperation_openInSafari")!, title: "在Safari中打开", handler: { (moreOperationController, itemView) in
                    moreOperationController.hideToBottom()
                 })]
            ]
            moreOperationController.showFromBottom()
            
        } else if title == "支持动态修改 item 位置" {
            let moreOperationController = QMUIMoreOperationController()
            moreOperationController.items = [
                // 第一行
                [QMUIMoreOperationItemView(image: UIImageMake("icon_moreOperation_shareFriend")!, title: "分享给微信好友", handler: { (moreOperationController, itemView) in
                    moreOperationController.hideToBottom()
                    // 如果嫌每次都在 handler 里写 hideToBottom 烦，也可以直接把这句写到 moreOperationController:didSelectItemView: 里，它可与 handler 共存
                }),
                 QMUIMoreOperationItemView(image: UIImageMake("icon_moreOperation_shareMoment")!, title: "分享到朋友圈", handler: { (moreOperationController, itemView) in
                    moreOperationController.hideToBottom()
                 }),
                 QMUIMoreOperationItemView(image: UIImageMake("icon_moreOperation_shareWeibo")!, title: "分享到微博", handler: { (moreOperationController, itemView) in
                    moreOperationController.hideToBottom()
                 })]
            ]
            
            // 动态给第二行插入一个 item
            moreOperationController.add(QMUIMoreOperationItemView(image: UIImageMake("icon_moreOperation_add")!, title: "添加", handler: { (moreOperationController, itemView) in
                // 动态添加 item
                var sectionToAdd = 0
                if (itemView.indexPath != nil && itemView.indexPath!.section == 0) {
                    sectionToAdd = 1
                }
                moreOperationController.add(QMUIMoreOperationItemView(image: UIImageMake("icon_moreOperation_shareQzone")!, title: "分享到QQ空间", handler:nil), in: sectionToAdd)
            }), in: 1)
            
            // 再给第二行插入一个 item
            moreOperationController.add(QMUIMoreOperationItemView(image: UIImageMake("icon_moreOperation_remove")!, title: "删除", handler: { (moreOperationController, itemView) in
                // 动态减少 item
                var sectionToRemove = 0
                if (itemView.indexPath != nil && itemView.indexPath!.section == 0) {
                    sectionToRemove = 1
                }
                if moreOperationController.items.count > 1 {
                    moreOperationController.removeItemView(at: IndexPath(item: moreOperationController.items[sectionToRemove].count - 1, section: sectionToRemove))
                }
            }), in: 1)
            
            moreOperationController.cancelButton.isHidden = true// 通过控制 cancelButton.hidden 的值来控制取消按钮的显示、隐藏
            moreOperationController.showFromBottom()
        } else if title == "支持修改皮肤样式（例如夜间模式）" {
            let moreOperationController = QMUIMoreOperationController()
            moreOperationController.delegate = self
            moreOperationController.contentBackgroundColor = UIColorMake(34, 34, 34)
            moreOperationController.cancelButtonSeparatorColor = UIColorMake(51, 51, 51)
            moreOperationController.cancelButtonBackgroundColor = UIColorMake(34, 34, 34)
            moreOperationController.cancelButtonTitleColor = UIColorMake(102, 102, 102)
            moreOperationController.itemTitleColor = UIColorMake(102, 102, 102)
            moreOperationController.items = [
                // 第一行
                [QMUIMoreOperationItemView(image: UIImageMake("icon_moreOperation_shareFriend")!, title: "分享给微信好友", handler: nil),
                 QMUIMoreOperationItemView(image: UIImageMake("icon_moreOperation_shareMoment")!, title: "分享到朋友圈", handler: nil),
                 QMUIMoreOperationItemView(image: UIImageMake("icon_moreOperation_shareWeibo")!, title: "分享到微博", handler: nil)]
            ]
            for section in moreOperationController.items {
                for itemView in section {
                    itemView.setImage(itemView.image(for: .normal)?.qmui_image(alpha: 0.4), for: .normal)
                }
            }
            moreOperationController.showFromBottom()
        }
    }
}

extension QDMoreOperationViewController: QMUIMoreOperationControllerDelegate {
    func moreOperationController(_ moreOperationController: QMUIMoreOperationController, didSelect itemView: QMUIMoreOperationItemView) {
        moreOperationController.hideToBottom()
    }
}
