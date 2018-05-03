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
            showNormalDialogViewController()
            return
        }
        
        if title == "普通弹窗" {
            showNormalDialogViewController()
            return
        }
        
        if title == "普通弹窗" {
            showNormalDialogViewController()
            return
        }
        
        if title == "普通弹窗" {
            showNormalDialogViewController()
            return
        }
        
        if title == "普通弹窗" {
            showNormalDialogViewController()
            return
        }
        
        if title == "普通弹窗" {
            showNormalDialogViewController()
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
        buttonTitleAttributes[NSAttributedStringKey.foregroundColor] = dialogViewController.headerViewBackgroundColor
        dialogViewController.buttonTitleAttributes = buttonTitleAttributes
        dialogViewController.submitButton?.setImage(
            UIImageMake("icon_emotion")?.qmui_imageResized(in: CGSize(width: 18, height: 18), contentMode: .scaleToFill)?.qmui_image(tintColor: buttonTitleAttributes[NSAttributedStringKey.foregroundColor] as! UIColor), for: .normal)
        dialogViewController.submitButton?.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        dialogViewController.show()
    }
}
