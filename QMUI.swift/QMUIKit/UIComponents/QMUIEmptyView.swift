//
//  QMUIEmptyView.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/1/23.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

class QMUIEmptyView: UIView {

    var actionButton: UIButton?

    // 显示或隐藏loading图标
    func setLoadingView(_: Bool) {
    }

    /**
     * 设置要显示的图片
     * @param image 要显示的图片，为nil则不显示
     */
    func set(image _: UIImage?) {
    }

    /**
     * 设置提示语
     * @param text 提示语文本，若为nil则隐藏textLabel
     */
    func setTextLabel(_: String?) {
    }

    /**
     * 设置详细提示语的文本
     * @param text 详细提示语文本，若为nil则隐藏detailTextLabel
     */
    func setDetailTextLabel(_: String?) {
    }

    /**
     * 设置操作按钮的文本
     * @param title 操作按钮的文本，若为nil则隐藏actionButton
     */
    func setActionButtonTitle(_: String?) {
    }
}
