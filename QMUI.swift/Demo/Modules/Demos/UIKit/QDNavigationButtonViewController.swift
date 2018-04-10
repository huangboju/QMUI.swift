//
//  QDNavigationButtonViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/4/10.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

class QDNavigationButtonViewController: QDCommonListViewController {

    private var forceEnableBackGesture: Bool = false
    
    override func initDataSource() {
        dataSource = ["普通导航栏按钮",
                      "加粗导航栏按钮",
                      "图标导航栏按钮",
                      "关闭导航栏按钮(支持手势返回)",
                      "自定义返回按钮(支持手势返回)"]
    }
    
    override func didSelectCell(_ title: String) {
        if title == "普通导航栏按钮" {
            // 最右边的按钮，position 为 Right
            
            // 支持用 tintColor 参数指定不一样的颜色
            // 不是最右边的按钮，position 为 None
            if let normalItem = QMUINavigationButton.barButtonItem(type: .normal, title: "默认", position: .right, target: nil, action: nil),
                
                let colorfulItem = QMUINavigationButton.barButtonItem(type: .normal, title: "颜色", tintColor: QDCommonUI.randomThemeColor(), position: .none, target: nil, action: nil) {
                navigationItem.rightBarButtonItems = [normalItem, colorfulItem]
            }
        } else if title == "加粗导航栏按钮" {
            if let item = QMUINavigationButton.barButtonItem(type: .bold, title: "完成(5)", position: .right, target: nil, action: nil) {
                navigationItem.rightBarButtonItems = [item]
            }
        } else if title == "图标导航栏按钮" {
            let image = UIImage.qmui_image(strokeColor: UIColorWhite, size: CGSize(width: 20, height: 20), lineWidth: 3, cornerRadius: 10)
            if let item = QMUINavigationButton.barButtonItem(image: image, position: .right, target: nil, action: nil) {
                navigationItem.rightBarButtonItems = [item]
            }
        } else if title == "关闭导航栏按钮(支持手势返回)" {
            forceEnableBackGesture = true
            navigationItem.leftBarButtonItem = QMUINavigationButton.closeBarButtonItem(target: self, action: #selector(handleCloseButtonEvent(_:)))
        } else if title == "自定义返回按钮(支持手势返回)" {
            forceEnableBackGesture = true
            navigationItem.leftBarButtonItem = QMUINavigationButton.backBarButtonItem(target: self, action: #selector(handleBackButtonEvent(_:)))
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
