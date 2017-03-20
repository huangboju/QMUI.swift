//
//  QMUIButton.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/1/17.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

enum QMUINavigationButtonType {
    case normal // 普通导航栏文字按钮
    case bold // 导航栏加粗按钮
    case image // 图标按钮
    case back // 自定义返回按钮(可以同时带有title)
    case close // 自定义关闭按钮(只显示icon不带title)
}

enum QMUINavigationButtonPosition: Int {
    case none = -1 // 不处于navigationBar最左（右）边的按钮，则使用None。用None则不会在alignmentRectInsets里调整位置
    case left // 用于leftBarButtonItem，如果用于leftBarButtonItems，则只对最左边的item使用，其他item使用QMUINavigationButtonPositionNone
    case right // 用于rightBarButtonItem，如果用于rightBarButtonItems，则只对最右边的item使用，其他item使用QMUINavigationButtonPositionNone
}

class QMUINavigationButton: UIButton {
    static func renderNavigationButtonAppearanceStyle() {
    }

    static func barButtonItem(with _: QMUINavigationButtonType, title _: String, position _: QMUINavigationButtonPosition, target _: Any?, action _: Selector?) -> UIBarButtonItem {
        return UIBarButtonItem()
    }
}

class QMUIToolbarButton: UIButton {
    static func renderToolbarButtonAppearanceStyle() {
    }
}
