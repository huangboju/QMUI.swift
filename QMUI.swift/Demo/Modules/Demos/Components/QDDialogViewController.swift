//
//  QDDialogViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/4/26.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

private let kSectionTitleForNormal = "QMUIDialogViewController"
private let kSectionTitleForSelection = "QMUIDialogSelectionViewController"
private let kSectionTitleForTextField = "QMUIDialogTextFieldViewController"

class QDDialogViewController: QDCommonGroupListViewController {

    private weak var currentTextFieldDialogViewController: QMUIDialogTextFieldViewController?
    
    override func initDataSource() {
        super.initDataSource()
        let od1 = QMUIOrderedDictionary(
            dictionaryLiteral:
            ("普通弹窗", ""),
            ("支持自定义样式", "可通过 appearance 方式来统一修改全局样式"))
        let od2 = QMUIOrderedDictionary(
            dictionaryLiteral:
            ("列表弹窗", "支持显示一个列表"),
            ("支持单选", "最多只能勾选一个 item，不可不选"),
            ("支持多选", "可同时勾选多个 item，可全部取消勾选"))
        let od3 = QMUIOrderedDictionary(
            dictionaryLiteral:
            ("输入框弹窗", ""),
            ("支持通过键盘 Return 按键触发弹窗提交按钮事件", "默认开启，当需要自己管理输入框 shouldReturn 事件时请将其关闭"),
            ("支持自动控制提交按钮的 enable 状态", "默认开启，只要文字不为空则允许点击"),
            ("支持自定义提交按钮的 enable 状态", "通过 block 来控制状态"))
        dataSource = QMUIOrderedDictionary(
            dictionaryLiteral:
            (kSectionTitleForNormal, od1),
            (kSectionTitleForSelection, od2),
            (kSectionTitleForTextField, od3))
    }
    
    override func didSelectCell(_ title: String) {
        tableView.qmui_clearsSelection()
        
        if title == "普通弹窗" {
            showNormalDialogViewController()
            return
        }
        
        if title == "支持自定义样式" {
            showAppearanceDialogViewController()
            return
        }
        
        if title == "列表弹窗" {
            showNormalSelectionDialogViewController()
            return
        }
        
        if title == "支持单选" {
            showRadioSelectionDialogViewController()
            return
        }
        
        if title == "支持多选" {
            showMultipleSelectionDialogViewController()
            return
        }
        
        if title == "输入框弹窗" {
            showNormalTextFieldDialogViewController()
            return
        }
        
        if title == "支持通过键盘 Return 按键触发弹窗提交按钮事件" {
            showReturnKeyDialogViewController()
            return
        }
        
        if title == "支持自动控制提交按钮的 enable 状态" {
            showSubmitButtonEnablesDialogViewController()
            return
        }
        
        if title == "支持自定义提交按钮的 enable 状态" {
            showCustomSubmitButtonEnablesDialogViewController()
            return
        }
    }
    
    private func showNormalDialogViewController() {
        let dialogViewController = QMUIDialogViewController()
        dialogViewController.title = "标题"
        let contentView = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 100))
        contentView.backgroundColor = UIColorWhite
        let label = UILabel(with: UIFontMake(14), textColor: UIColorBlack)
        label.text = "自定义contentView"
        label.sizeToFit()
        label.center = CGPoint(x: contentView.bounds.width / 2, y: contentView.bounds.height / 2)
        contentView.addSubview(label)
        dialogViewController.contentView = contentView
        dialogViewController.addCancelButton(with: "取消", handler: nil)
        dialogViewController.addSubmitButton(with: "确定") {
            $0.hide()
        }
        dialogViewController.show()
    }
    
    private func showAppearanceDialogViewController() {
        let dialogViewController = QMUIDialogViewController()
        dialogViewController.title = "标题"
        let contentView = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 50))
        contentView.backgroundColor = QDThemeManager.shared.currentTheme?.themeTintColor
        let label = UILabel(with: UIFontMake(14), textColor: UIColorWhite)
        label.text = "自定义contentView"
        label.sizeToFit()
        label.center = CGPoint(x: contentView.bounds.width / 2, y: contentView.bounds.height / 2)
        contentView.addSubview(label)
        dialogViewController.contentView = contentView
        
        dialogViewController.addCancelButton(with: "取消", handler: nil)
        dialogViewController.addSubmitButton(with: "确定") {
            $0.hide()
        }
        
        // 自定义样式
        dialogViewController.headerViewBackgroundColor = (QDThemeManager.shared.currentTheme?.themeTintColor)!
        dialogViewController.headerSeparatorColor = nil
        dialogViewController.footerSeparatorColor = nil
        dialogViewController.titleTintColor = UIColorWhite
        dialogViewController.titleView.horizontalTitleFont = UIFontBoldMake(17)
        dialogViewController.buttonHighlightedBackgroundColor = dialogViewController.headerViewBackgroundColor.qmui_colorWithAlphaAddedToWhite(0.3)
        var buttonTitleAttributes = dialogViewController.buttonTitleAttributes
        buttonTitleAttributes[.foregroundColor] = dialogViewController.headerViewBackgroundColor
        dialogViewController.buttonTitleAttributes = buttonTitleAttributes
        dialogViewController.submitButton?.setImage(
            UIImageMake("icon_emotion")?.qmui_imageResized(in: CGSize(width: 18, height: 18), contentMode: .scaleToFill)?.qmui_image(tintColor: buttonTitleAttributes[.foregroundColor] as? UIColor), for: .normal)
        dialogViewController.submitButton?.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        
        dialogViewController.show()
    }
    
    private func showNormalSelectionDialogViewController() {
        let dialogViewController = QMUIDialogSelectionViewController()
        dialogViewController.title = "支持的语言"
        dialogViewController.items = ["简体中文", "繁体中文", "英语（美国）", "英语（英国）"]
        dialogViewController.cellForItemClosure = { (aDialogViewController, cell, itemIndex) in
            cell.accessoryType = .none // 移除点击时默认加上右边的checkbox
        }
        dialogViewController.heightForItemClosure = { (aDialogViewController, itemIndex) -> CGFloat in
            return 54 // 修改默认的行高，默认为 TableViewCellNormalHeight
        }
        dialogViewController.didSelectItemClosure = { (aDialogViewController, itemIndex) in
            aDialogViewController.hide()
        }
        dialogViewController.show()
    }
    
    private func showRadioSelectionDialogViewController() {
        let citys = QMUIOrderedDictionary(dictionaryLiteral:
            ("北京", "吃到的第一个菜肯定是烤鸭吧！"),
            ("广东", "听说那里的人一日三餐都吃🐍🐸🐛🦂😋"),
            ("上海", "好像现在全世界的蟹都叫大闸蟹？"),
            ("成都", "你分得清冒菜和麻辣烫、龙抄手和馄饨吗？"))
        
        let dialogViewController = QMUIDialogSelectionViewController()
        dialogViewController.title = "你去过哪里？"
        dialogViewController.items = citys.allKeys
        dialogViewController.addCancelButton(with: "取消", handler: nil)
        dialogViewController.addSubmitButton(with: "确定") {
            if let d = $0 as? QMUIDialogSelectionViewController {
                if d.selectedItemIndex == QMUIDialogSelectionViewControllerSelectedItemIndexNone {
                    QMUITips.showError(text: "请至少选一个", in: d.qmui_modalPresentationViewController!.view, hideAfterDelay: 1.2)
                    return
                }
                let city = d.items[d.selectedItemIndex]
                let resultString = citys[city]
                $0.hide(with: true, completion: { (finished) in
                    let alertController = QMUIAlertController(title: resultString, preferredStyle: .alert)
                    let action = QMUIAlertAction(title: "好", style: .cancel, handler: nil)
                    alertController.add(action: action)
                    alertController.show(true)
                })
            }
        }
        dialogViewController.show()
    }
    
    private func showMultipleSelectionDialogViewController() {
        let dialogViewController = QMUIDialogSelectionViewController()
        dialogViewController.titleView.style = .subTitleVertical
        dialogViewController.title = "你常用的编程语言"
        dialogViewController.titleView.subtitle = "可多选"
        dialogViewController.allowsMultipleSelection = true// 打开多选
        dialogViewController.items = ["Objective-C", "Swift", "Java", "JavaScript", "Python", "PHP"]
        dialogViewController.cellForItemClosure = { (aDialogViewController, cell, itemIndex) in
            if aDialogViewController.items[itemIndex] == "JavaScript" {
                cell.detailTextLabel?.text = "包含前后端"
            } else {
                cell.detailTextLabel?.text = nil
            }
        }
        dialogViewController.addCancelButton(with: "取消", handler: nil)
        dialogViewController.addSubmitButton(with: "确定") { [weak self] (aDialogViewController) in
            if let d = aDialogViewController as? QMUIDialogSelectionViewController, let strongSelf = self {
                d.hide()
                if d.selectedItemIndexes.contains(5) {
                    QMUITips.showInfo(text: "PHP 是世界上最好的编程语言", in: strongSelf.view, hideAfterDelay: 1.8)
                    return
                }
                if d.selectedItemIndexes.contains(4) {
                    QMUITips.showInfo(text: "你代码缩进用 Tab 还是 Space？", in: strongSelf.view, hideAfterDelay: 1.8)
                    return
                }
                if d.selectedItemIndexes.contains(3) {
                    QMUITips.showInfo(text: "JavaScript 即将一统江湖", in: strongSelf.view, hideAfterDelay: 1.8)
                    return
                }
                if d.selectedItemIndexes.contains(2) {
                    QMUITips.showInfo(text: "Android 7 都出了，我还在兼容 Android 4", in: strongSelf.view, hideAfterDelay: 1.8)
                    return
                }
                if d.selectedItemIndexes.contains(1) || d.selectedItemIndexes.contains(0) {
                    QMUITips.showInfo(text: "iOS 找不到工作啦", in: strongSelf.view, hideAfterDelay: 1.8)
                    return
                }
            }
        }
        dialogViewController.show()
    }
    
    private func showNormalTextFieldDialogViewController() {
        let dialogViewController = QMUIDialogTextFieldViewController()
        dialogViewController.title = "请输入昵称"
        dialogViewController.textField.placeholder = "昵称"
        dialogViewController.enablesSubmitButtonAutomatically = false// 为了演示效果与第二个 cell 的区分开，这里手动置为 false
        dialogViewController.addCancelButton(with: "取消", handler: nil)
        dialogViewController.addSubmitButton(with: "确定") { [weak self] (aDialogViewController) in
            if let d = aDialogViewController as? QMUIDialogTextFieldViewController, let strongSelf = self {
                if d.textField.text?.length ?? 0 > 0 {
                    QMUITips.showSucceed(text: "提交成功", in: strongSelf.view, hideAfterDelay: 1.2)
                } else {
                    QMUITips.showInfo(text: "请填写内容", in: strongSelf.view, hideAfterDelay: 1.2)
                }
                d.hide()
            }
        }
        dialogViewController.show()
        currentTextFieldDialogViewController = dialogViewController
    }
    
    private func showReturnKeyDialogViewController() {
        let dialogViewController = QMUIDialogTextFieldViewController()
        dialogViewController.title = "请输入别名"
        dialogViewController.textField.placeholder = "点击键盘 Return 键视为点击确定按钮"
        dialogViewController.textField.maximumTextLength = 10
        dialogViewController.shouldManageTextFieldsReturnEventAutomatically = true // 让键盘的 Return 键也能触发确定按钮的事件。这个属性默认就是 YES，这里为写出来只是为了演示
        dialogViewController.addCancelButton(with: "取消", handler: nil)
        dialogViewController.addSubmitButton(with: "确定") { [weak self] (aDialogViewController) in
            if let d = aDialogViewController as? QMUIDialogTextFieldViewController, let strongSelf = self {
                QMUITips.showSucceed(text: "提交成功", in: strongSelf.view, hideAfterDelay: 1.2)
                d.hide()
            }
        }
        dialogViewController.show()
        currentTextFieldDialogViewController = dialogViewController
    }
    
    private func showSubmitButtonEnablesDialogViewController() {
        let dialogViewController = QMUIDialogTextFieldViewController()
        dialogViewController.title = "请输入签名"
        dialogViewController.textField.placeholder = "不超过10个字"
        dialogViewController.textField.maximumTextLength = 10
        dialogViewController.enablesSubmitButtonAutomatically = true // 自动根据输入框的内容是否为空来控制 submitButton.enabled 状态。这个属性默认就是 YES，这里为写出来只是为了演示
        dialogViewController.addCancelButton(with: "取消", handler: nil)
        dialogViewController.addSubmitButton(with: "确定") { [weak self] (aDialogViewController) in
            if let d = aDialogViewController as? QMUIDialogTextFieldViewController, let strongSelf = self {
                QMUITips.showSucceed(text: "提交成功", in: strongSelf.view, hideAfterDelay: 1.2)
                d.hide()
            }
        }
        dialogViewController.show()
        currentTextFieldDialogViewController = dialogViewController
    }
    
    private func showCustomSubmitButtonEnablesDialogViewController() {
        let dialogViewController = QMUIDialogTextFieldViewController()
        dialogViewController.title = "请输入手机号码"
        dialogViewController.textField.placeholder = "11位手机号码"
        dialogViewController.textField.keyboardType = .phonePad
        dialogViewController.textField.maximumTextLength = 11
        dialogViewController.enablesSubmitButtonAutomatically = true // 自动根据输入框的内容是否为空来控制 submitButton.enabled 状态。这个属性默认就是 YES，这里为写出来只是为了演示
        dialogViewController.shouldEnableSubmitButtonClosure = { (aDialogViewController) -> Bool in
            // 条件改为一定要写满11位才允许提交
            return aDialogViewController.textField.text!.length == aDialogViewController.textField.maximumTextLength
        }
        dialogViewController.addCancelButton(with: "取消", handler: nil)
        dialogViewController.addSubmitButton(with: "确定") { [weak self] (aDialogViewController) in
            if let d = aDialogViewController as? QMUIDialogTextFieldViewController, let strongSelf = self {
                QMUITips.showSucceed(text: "提交成功", in: strongSelf.view, hideAfterDelay: 1.2)
                d.hide()
            }
        }
        dialogViewController.show()
        currentTextFieldDialogViewController = dialogViewController
    }
}
