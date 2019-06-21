//
//  QDAlertController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/4/18.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

private let kSectionTitleForAlert = "Alert"
private let kSectionTitleForActionSheet = "ActionSheet"
private let kSectionTitleForSystem = "系统原生 UIAlertController 对比"

class QDAlertController: QDCommonGroupListViewController {
    
    override func initDataSource() {
        let od1 = QMUIOrderedDictionary(
            dictionaryLiteral:
            ("显示一个 alert 弹窗", ""),
            ("支持自定义 alert 样式", "支持以 UIAppearance 方式设置全局统一样式"),
            ("支持自定义内容", "可以将一个 UIView 作为 QMUIAlertController 的 contentView"))
        let od2 = QMUIOrderedDictionary(
            dictionaryLiteral:
            ("显示一个 actionSheet 菜单", ""),
            ("支持自定义 actionSheet 样式", "支持以 UIAppearance 方式设置全局统一样式支持以 UIAppearance 方式设置全局统一样式"))
        let od3 = QMUIOrderedDictionary(
            dictionaryLiteral:
            ("显示一个系统的 alert 弹窗", ""),
            ("显示一个系统的 actionSheet 菜单", ""))
        dataSource = QMUIOrderedDictionary(
            dictionaryLiteral:
            (kSectionTitleForAlert, od1),
            (kSectionTitleForActionSheet, od2),
            (kSectionTitleForSystem, od3))
    }

    override func didSelectCell(_ title: String) {
        tableView.qmui_clearsSelection()
        
        if title == "显示一个 alert 弹窗" {
            let action1 = QMUIAlertAction(title: "取消", style: .cancel) { (_) in
                
            }
            let action2 = QMUIAlertAction(title: "删除", style: .destructive) { (_) in
                
            }
            let alertController = QMUIAlertController(title: "确定删除？", message: "删除后将无法恢复，请慎重考虑", preferredStyle: .alert)
            alertController.add(action: action1)
            alertController.add(action: action2)
            alertController.show(true)
            return
        }
        
        if title == "支持自定义 alert 样式" {
            // 底部按钮
            let action1 = QMUIAlertAction(title: "取消", style: .cancel) { (_) in
                
            }
            let action2 = QMUIAlertAction(title: "删除", style: .destructive) { (_) in
                
            }
            action2.button.setImage(UIImageMake("icon_emotion")?.qmui_imageResized(in: CGSize(width: 18, height: 18), contentMode: .scaleToFill)?.qmui_image(tintColor: QDThemeManager.shared.currentTheme?.themeTintColor ?? UIColorRed), for: .normal)
            action2.button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            
            // 弹窗
            let alertController = QMUIAlertController(title: "确定删除？", message: "删除后将无法恢复，请慎重考虑", preferredStyle: .alert)
            var titleAttributs = alertController.alertTitleAttributes
            titleAttributs[.foregroundColor] = UIColorWhite
            alertController.alertTitleAttributes = titleAttributs
            var messageAttributs = alertController.alertMessageAttributes
            messageAttributs[.foregroundColor] = UIColorMakeWithRGBA(255, 255, 255, 0.75)
            alertController.alertMessageAttributes = messageAttributs
            if let themeTintColor = QDThemeManager.shared.currentTheme?.themeTintColor {
                alertController.alertHeaderBackgroundColor = themeTintColor
            }
            alertController.alertSeperatorColor = alertController.alertButtonBackgroundColor
            alertController.alertTitleMessageSpacing = 7
            
            var buttonAttributes = alertController.alertButtonAttributes
            buttonAttributes[.foregroundColor] = alertController.alertHeaderBackgroundColor
            alertController.alertButtonAttributes = buttonAttributes
            
            var cancelButtonAttributes = alertController.alertCancelButtonAttributes
            cancelButtonAttributes[.foregroundColor] = buttonAttributes[NSAttributedString.Key.foregroundColor]
            alertController.alertCancelButtonAttributes = cancelButtonAttributes
            
            alertController.add(action: action1)
            alertController.add(action: action2)
            alertController.show(true)
            return
        }
        
        if title == "支持自定义内容" {
            let action1 = QMUIAlertAction(title: "取消", style: .cancel) { (_) in
                
            }
            let action2 = QMUIAlertAction(title: "删除", style: .destructive) { (_) in
                
            }
            action2.button.setImage(UIImageMake("icon_emotion")?.qmui_imageResized(in: CGSize(width: 18, height: 18), contentMode: .scaleToFill)?.qmui_image(tintColor: QDThemeManager.shared.currentTheme?.themeTintColor ?? UIColorRed), for: .normal)
            action2.button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            
            let customView = animationView
            let alertController = QMUIAlertController(title: "确定删除？", message: "删除后将无法恢复，请慎重考虑", preferredStyle: .alert)
            alertController.add(action: action1)
            alertController.add(action: action2)
            alertController.addCustomView(customView)
            alertController.show(true)
            return
        }
        
        if title == "显示一个 actionSheet 菜单" {
            let action1 = QMUIAlertAction(title: "取消", style: .cancel) { (_) in
                
            }
            let action2 = QMUIAlertAction(title: "删除", style: .destructive) { (_) in
                
            }
            let action3 = QMUIAlertAction(title: "置灰按钮", style: .default) { (_) in
                
            }
            action3.isEnabled = false
            
            let alertController = QMUIAlertController(title: "确定删除？", message: "删除后将无法恢复，请慎重考虑", preferredStyle: .sheet)
            alertController.add(action: action1)
            alertController.add(action: action2)
            alertController.add(action: action3)
            alertController.show(true)
            return
        }
        
        if title == "支持自定义 actionSheet 样式" {
            let action1 = QMUIAlertAction(title: "取消", style: .cancel) { (_) in
                
            }
            let action2 = QMUIAlertAction(title: "删除", style: .destructive) { (_) in
                
            }
            action2.button.setImage(UIImageMake("icon_emotion")?.qmui_imageResized(in: CGSize(width: 22, height: 22), contentMode: .scaleToFill)?.qmui_image(tintColor: QDThemeManager.shared.currentTheme?.themeTintColor ?? UIColorRed), for: .normal)
            action2.button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
            
            let alertController = QMUIAlertController(title: "确定删除？", message: "删除后将无法恢复，请慎重考虑", preferredStyle: .sheet)
            var titleAttributs = alertController.sheetTitleAttributes
            titleAttributs[.foregroundColor] = UIColorWhite
            alertController.sheetTitleAttributes = titleAttributs
            var messageAttributs = alertController.sheetMessageAttributes
            messageAttributs[.foregroundColor] = UIColorWhite
            alertController.sheetMessageAttributes = messageAttributs
            if let themeTintColor = QDThemeManager.shared.currentTheme?.themeTintColor {
                alertController.sheetHeaderBackgroundColor = themeTintColor
            }
            alertController.sheetSeperatorColor = alertController.sheetButtonBackgroundColor
            
            var buttonAttributes = alertController.sheetButtonAttributes
            buttonAttributes[.foregroundColor] = alertController.sheetHeaderBackgroundColor
            alertController.sheetButtonAttributes = buttonAttributes
            
            var cancelButtonAttributes = alertController.sheetCancelButtonAttributes
            cancelButtonAttributes[.foregroundColor] = buttonAttributes[.foregroundColor]
            alertController.sheetCancelButtonAttributes = cancelButtonAttributes
            
            alertController.add(action: action1)
            alertController.add(action: action2)
            alertController.show(true)
            return
        }
        
        // 展示系统的效果
        guard let _ = NSClassFromString("UIAlertController") else {
            QMUITips.showInfo(text: "iOS 版本过低，不支持 UIAlertController", in: view, hideAfterDelay: 2)
            return
        }
        
        if title == "显示一个系统的 alert 弹窗" {
            let action1 = UIAlertAction(title: "取消", style: .cancel) { (_) in
                
            }
            let action2 = UIAlertAction(title: "删除", style: .destructive) { (_) in
                
            }

            let alertController = UIAlertController(title: "确定删除？", message: "删除后将无法恢复，请慎重考虑", preferredStyle: .alert)
            alertController.addAction(action1)
            alertController.addAction(action2)
            present(alertController, animated: true, completion: nil)
            return
        }
        
        if title == "显示一个系统的 actionSheet 菜单" {
            let action1 = UIAlertAction(title: "取消", style: .cancel) { (_) in
                
            }
            let action2 = UIAlertAction(title: "删除", style: .destructive) { (_) in
                
            }
            
            let alertController = UIAlertController(title: "确定删除？", message: "删除后将无法恢复，请慎重考虑", preferredStyle: .actionSheet)
            alertController.addAction(action1)
            alertController.addAction(action2)
            
            if IS_IPAD {
                let indexPath = IndexPath(row: 1, section: 2)
                let cellRect = tableView.rectForRow(at: indexPath)
                let cellRectInSelfView = view.convert(cellRect, from: tableView)
                alertController.popoverPresentationController?.sourceView = view;
                alertController.popoverPresentationController?.sourceRect = cellRectInSelfView
            }
            
            present(alertController, animated: true, completion: nil)
            return
        }
    }
    
    private var animationView: UIView {
        let animationView = UIView(frame: CGRect(x: 0, y: 0, width: 95, height: 30))
        
        let shapeView1 = UIView(frame: CGRect(x: 0, y: 7, width: 16, height: 16))
        shapeView1.backgroundColor = UIColorGreen
        shapeView1.layer.cornerRadius = 8
        animationView.addSubview(shapeView1)
        
        let shapeView2 = UIView(frame: CGRect(x: 0, y: 7, width: 16, height: 16))
        shapeView2.backgroundColor = UIColorRed
        shapeView2.layer.cornerRadius = 8
        animationView.addSubview(shapeView2)
        
        let shapeView3 = UIView(frame: CGRect(x: 0, y: 7, width: 16, height: 16))
        shapeView3.backgroundColor = UIColorBlue
        shapeView3.layer.cornerRadius = 8
        animationView.addSubview(shapeView3)

        let positionAnimation = CAKeyframeAnimation()
        positionAnimation.keyPath = "position.x"
        positionAnimation.values = [-5, 0, 10, 40, 70, 80, 75]
        positionAnimation.keyTimes = [0, 5/90.0, 15/90.0, 45/90.0, 75/90.0, 85/90.0, 1] as [NSNumber]
        positionAnimation.isAdditive = true
        
        let scaleAnimation = CAKeyframeAnimation()
        scaleAnimation.keyPath = "transform.scale"
        scaleAnimation.values = [0.7, 0.9, 1, 0.9, 0.7]
        scaleAnimation.keyTimes = [0, 15/90.0, 45/90.0, 75/90.0, 1] as [NSNumber]
        
        let alphaAnimation = CAKeyframeAnimation()
        scaleAnimation.keyPath = "opacity"
        scaleAnimation.values = [0, 1, 1, 1, 0]
        scaleAnimation.keyTimes = [0, 1/6.0, 3/6.0, 5/6.0, 1] as [NSNumber]
        
        let group = CAAnimationGroup()
        group.animations = [positionAnimation, scaleAnimation, alphaAnimation]
        group.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        group.repeatCount = Float.infinity
        group.duration = 1.3
        
        shapeView1.layer.add(group, forKey:"basic1")
        group.timeOffset = 0.43
        shapeView2.layer.add(group, forKey:"basic2")
        group.timeOffset = 0.86
        shapeView3.layer.add(group, forKey:"basic3")
        
        return animationView
    }
}
