//
//  QDNavigationButtonViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/4/10.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

private let kSectionTitleForNormalButton = "文本按钮"
private let kSectionTitleForBoldButton = "加粗文本按钮"
private let kSectionTitleForImageButton = "图片按钮"
private let kSectionTitleForBackButton = "返回按钮"
private let kSectionTitleForCloseButton = "关闭按钮"


class QDNavigationButtonViewController: QDCommonGroupListViewController {

    // MARK: TODO 这里有bug，返回按钮和关闭按钮交替点击会崩溃。
    
    private var forceEnableBackGesture: Bool = false
    
    override func initDataSource() {
        let od1 = QMUIOrderedDictionary(
            dictionaryLiteral:
            ("[系统]文本按钮", ""),
            ("[QMUI]文本按钮", "")
        )
        let od2 = QMUIOrderedDictionary(
            dictionaryLiteral:
            ("[系统]加粗文本按钮", ""),
            ("[QMUI]加粗文本按钮", "")
        )
        let od3 = QMUIOrderedDictionary(
            dictionaryLiteral:
            ("[系统]图片按钮", ""),
            ("[QMUI]图片按钮", "")
        )
        let od4 = QMUIOrderedDictionary(
            dictionaryLiteral:
            ("[系统]返回按钮", ""),
            ("[QMUI]返回按钮", "")
        )
        let od5 = QMUIOrderedDictionary(
            dictionaryLiteral:
            ("[QMUI]关闭按钮", "在 present 的场景经常使用这种关闭按钮")
        )
        dataSource = QMUIOrderedDictionary(
            dictionaryLiteral:
            (kSectionTitleForNormalButton, od1),
            (kSectionTitleForBoldButton, od2),
            (kSectionTitleForImageButton, od3),
            (kSectionTitleForBackButton, od4),
            (kSectionTitleForCloseButton, od5)
        )
    }
    
    override func didSelectCell(_ title: String) {
        if title == "[系统]文本按钮" {
            let item = UIBarButtonItem.item(title: "文字", target: nil, action: nil)
            navigationItem.rightBarButtonItem = item
        } else if title == "[QMUI]文本按钮" {
            let item = UIBarButtonItem.item(button: QMUINavigationButton(type: .normal, title: "文字"), target: nil, action: nil)
            navigationItem.rightBarButtonItem = item
        } else if title == "[系统]加粗文本按钮" {
            let item = UIBarButtonItem.item(boldTitle: "加粗", target: nil, action: nil)
            navigationItem.rightBarButtonItem = item
        } else if title == "[QMUI]加粗文本按钮" {
            let item = UIBarButtonItem.item(button: QMUINavigationButton(type: .bold, title: "加粗"), target: nil, action: nil)
            navigationItem.rightBarButtonItem = item
        } else if title == "[系统]图片按钮" {
            let item = UIBarButtonItem.item(image: UIImageMake("icon_nav_about"), target: nil, action: nil)
            navigationItem.rightBarButtonItem = item
        } else if title == "[QMUI]图片按钮" {
            let item = UIBarButtonItem.item(button: QMUINavigationButton(image: UIImageMake("icon_nav_about")!), target: nil, action: nil)
            navigationItem.rightBarButtonItem = item
        } else if title == "[系统]返回按钮" {
            navigationItem.leftBarButtonItem = nil // 只要不设置 leftBarButtonItem，就会显示系统的返回按钮
        } else if title == "[QMUI]返回按钮" {
            let item = UIBarButtonItem.backItem(target: self, action: #selector(handleBackButtonEvent(_:))) // 自定义返回按钮要自己写代码去 pop 界面
            navigationItem.leftBarButtonItem = item
            forceEnableBackGesture = true // 当系统的返回按钮被屏蔽的时候，系统的手势返回也会跟着失效，所以这里要手动强制打开手势返回
            navigationItem.rightBarButtonItem = nil
        } else if title == "[QMUI]关闭按钮" {
            let item = UIBarButtonItem.closeItem(target: self, action: #selector(handleCloseButtonEvent(_:)))
            navigationItem.leftBarButtonItem = item
            forceEnableBackGesture = true
            navigationItem.rightBarButtonItem = nil
        }
        
        tableView.qmui_clearsSelection()
    }

    private func forceEnableInteractivePopGestureRecognizer() -> Bool {
        return forceEnableBackGesture
    }
    
    @objc private func handleCloseButtonEvent(_ sender: AnyObject) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func handleBackButtonEvent(_ sender: AnyObject) {
        navigationController?.popViewController(animated: true)
    }
}
