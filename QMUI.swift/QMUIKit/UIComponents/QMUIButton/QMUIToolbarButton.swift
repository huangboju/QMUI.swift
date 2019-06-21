//
//  QMUIToolbarButton.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/5/3.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

enum QMUIToolbarButtonType {
    case normal // 普通工具栏按钮
    case red // 工具栏红色按钮，用于删除等警告性操作
    case image // 图标类型的按钮
}

/**
 *  `QMUIToolbarButton`是用于底部工具栏的按钮
 */
class QMUIToolbarButton: UIButton {
    /// 获取当前按钮的type
    private(set) var type: QMUIToolbarButtonType = .normal
    
    convenience init() {
        self.init(type: .normal)
    }
    
    /**
     *  工具栏按钮的初始化函数
     *  @param type  按钮类型
     */
    convenience init(type: QMUIToolbarButtonType) {
        self.init(type: type, title: nil)
    }
    
    /**
     *  工具栏按钮的初始化函数
     *  @param type 按钮类型
     *  @param title 按钮的title
     */
    init(type: QMUIToolbarButtonType, title: String?) {
        self.type = type
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        renderButtonStyle()
        sizeToFit()
    }
    
    /**
     *  工具栏按钮的初始化函数
     *  @param image 按钮的image
     */
    convenience init(image: UIImage) {
        self.init(type: .image)
        self.setImage(image, for: .normal)
        self.setImage(image.qmui_image(alpha: ToolBarHighlightedAlpha), for: .highlighted)
        self.setImage(image.qmui_image(alpha: ToolBarDisabledAlpha), for: .disabled)
        self.sizeToFit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func renderButtonStyle() {
        imageView?.contentMode = .center
        imageView?.tintColor = nil // 重置默认值，nil表示跟随父元素
        titleLabel?.font = ToolBarButtonFont
        switch type {
        case .normal:
            setTitleColor(ToolBarTintColor, for: .normal)
            setTitleColor(ToolBarTintColorHighlighted, for: .highlighted)
            setTitleColor(ToolBarTintColorDisabled, for: .disabled)
        case .red:
            setTitleColor(UIColorRed, for: .normal)
            setTitleColor(UIColorRed.withAlphaComponent(ToolBarHighlightedAlpha), for: .highlighted)
            setTitleColor(UIColorRed.withAlphaComponent(ToolBarDisabledAlpha), for: .disabled)
            imageView?.tintColor = UIColorRed; // 修改为红色
        default: break
        }
        
    }
    
    /// 在原有的QMUIToolbarButton上创建一个UIBarButtonItem
    static func barButtonItem(toolbarButton: QMUIToolbarButton, target: Any?, action: Selector?) -> UIBarButtonItem? {
        if let action = action {
            toolbarButton.addTarget(target, action: action, for: .touchUpInside)
        }
        let buttonItem = UIBarButtonItem(customView: toolbarButton)
        return buttonItem
    }
    
    /// 创建一个特定type的UIBarButtonItem
    static func barButtonItem(type: QMUIToolbarButtonType, title: String?, target: Any?, action: Selector?) -> UIBarButtonItem? {
        let buttonItem = UIBarButtonItem(title: title, style: .plain, target: target, action: action)
        if type == .red {
            // 默认继承toolBar的tintColor，红色需要重置
            buttonItem.tintColor = UIColorRed
        }
        return buttonItem
    }
    
    /// 创建一个图标类型的UIBarButtonItem
    static func barButtonItem(image: UIImage?, target: Any?, action: Selector?) -> UIBarButtonItem? {
        let buttonItem = UIBarButtonItem(image: image, style: .plain, target: target, action: action)
        return buttonItem
    }
}
