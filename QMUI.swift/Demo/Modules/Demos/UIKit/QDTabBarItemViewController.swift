//
//  QDTabBarItemViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/4/24.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

class QDTabBarItemViewController: QDCommonListViewController {

    private var tabBar: UITabBar!
    
    override func initSubviews() {
        super.initSubviews()
        
        // 双击 tabBarItem 的回调
        let tabBarItemDoubleTapHandler = { [weak self] (tabBarItem: UITabBarItem, index: Int) in
            guard let strongSelf = self else {
                return
            }
            QMUITips.showInfo(text: "双击了第 \(index + 1) 个 tab", in: strongSelf.view, hideAfterDelay: 1.2)
        }
        
        tabBar = UITabBar()
        tabBar.tintColor = TabBarTintColor
        
        let item1 = QDUIHelper.tabBarItem(title: "QMUIKit", image: UIImageMake("icon_tabbar_uikit")?.withRenderingMode(.alwaysOriginal), selectedImage: UIImageMake("icon_tabbar_uikit_selected"), tag: 0)
        item1.qmui_doubleTapClosure = tabBarItemDoubleTapHandler
        
        let item2 = QDUIHelper.tabBarItem(title: "Components", image: UIImageMake("icon_tabbar_component")?.withRenderingMode(.alwaysOriginal), selectedImage: UIImageMake("icon_tabbar_component_selected"), tag: 1)
        item2.qmui_doubleTapClosure = tabBarItemDoubleTapHandler
        
        let item3 = QDUIHelper.tabBarItem(title: "Lab", image: UIImageMake("icon_tabbar_lab")?.withRenderingMode(.alwaysOriginal), selectedImage: UIImageMake("icon_tabbar_lab_selected"), tag: 2)
        item3.qmui_doubleTapClosure = tabBarItemDoubleTapHandler
        
        tabBar.items = [item1, item2, item3]
        tabBar.selectedItem = item1
        tabBar.sizeToFit()
        view.addSubview(tabBar)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let tabBarHeight = TabBarHeight
        tabBar.frame = CGRect(x: 0, y: view.bounds.height - tabBarHeight, width: view.bounds.width, height: tabBarHeight)
    }
    
    override func initDataSource() {
        dataSource = ["在屏幕底部的 UITabBarItem 上显示未读数",
                      "去掉屏幕底部 UITabBarItem 上的未读数",
                      "双击 UITabBarItem 可触发双击事件"]
    }
    
    override func didSelectCell(_ title: String) {
        // 利用 [UITabBarItem imageView] 方法获取到某个 UITabBarItem 内的图片容器
        if let imageViewInTabBarItem = tabBar.items?.first?.qmui_imageView() {
            if title == "在屏幕底部的 UITabBarItem 上显示未读数" {
                let messageNumberLabel = generateMessageNumberLabel(8, in: imageViewInTabBarItem)
                messageNumberLabel.frame = messageNumberLabel.frame.setXY(imageViewInTabBarItem.frame.width - 8, -5)
                messageNumberLabel.isHidden = false
            } else if title == "去掉屏幕底部 UITabBarItem 上的未读数" {
                let messageNumberLabel = messageNumberLabelInView(imageViewInTabBarItem)
                messageNumberLabel?.isHidden = true
            }
        }
        
        tableView.qmui_clearsSelection()
    }
    
    private func generateMessageNumberLabel(_ intNum: Int, in view: UIView) -> QMUILabel {
        let labelTag = 1024
        var numberLabel = view.viewWithTag(labelTag) as? QMUILabel
        if numberLabel == nil {
            numberLabel = QMUILabel(with: UIFontBoldMake(14), textColor: UIColorWhite)
            numberLabel?.backgroundColor = UIColorRed
            numberLabel?.textAlignment = .center
            numberLabel?.contentEdgeInsets = UIEdgeInsets(top: 2, left: 5, bottom: 2, right: 5)
            numberLabel?.clipsToBounds = true
            numberLabel?.tag = labelTag
            view.addSubview(numberLabel!)
        }
        
        numberLabel?.text = "\(intNum)"
        numberLabel?.sizeToFit()
        if let numberLabel = numberLabel, numberLabel.text?.length ?? 0 == 1 {
            // 一位数字时，保证宽高相等（因为有些字符可能宽度比较窄）
            let diameter = fmax(numberLabel.bounds.width, numberLabel.bounds.height)
            numberLabel.frame = CGRect(x: numberLabel.frame.minX, y: numberLabel.frame.minY, width: diameter, height: diameter)
            numberLabel.layer.cornerRadius = flat(numberLabel.bounds.height / 2.0)
        }

        return numberLabel!
    }
    
    private func messageNumberLabelInView(_ view: UIView) -> QMUILabel? {
        let labelTag = 1024
        let numberLabel = view.viewWithTag(labelTag) as? QMUILabel
        return numberLabel
    }
}
