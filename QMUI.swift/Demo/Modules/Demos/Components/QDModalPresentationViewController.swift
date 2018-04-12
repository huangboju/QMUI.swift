//
//  QDModalPresentationViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/4/12.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

private let kSectionTitleForUsing = "使用方式"
private let kSectionTitleForStyling = "内容及动画"

class QDModalPresentationViewController: QDCommonGroupListViewController {

    private var currentAnimationStyle: QMUIModalPresentationAnimationStyle = .fade
    
    private var modalViewControllerForAddSubview: QMUIModalPresentationViewController?
    
    override func initDataSource() {
        super.initDataSource()
        let od1 = QMUIOrderedDictionary(dictionaryLiteral:
            ("showWithAnimated", "以 UIWindow 的形式盖在当前界面上"),
            ("presentViewController", "以 presentViewController: 的方式显示"),
            ("showInView", "以 addSubview: 的方式直接将浮层添加到要显示的 UIView 上"))
        let od2 = QMUIOrderedDictionary(dictionaryLiteral:
            ("contentView", "直接显示一个UIView浮层"),
            ("contentViewController", "显示一个UIViewController"),
            ("animationStyle", "默认提供3种动画，可重复点击，依次展示"),
            ("dimmingView", "自带背景遮罩，也可自行制定一个遮罩的UIView"),
            ("layoutClosure", "利用layoutClosure、showingAnimationClosure、hidingAnimationClosure制作自定义的显示动画"),
            ("keyboard", "控件自带对keyboard的管理，并且能保证浮层和键盘同时升起，不会有跳动"))
        dataSource = QMUIOrderedDictionary(dictionaryLiteral: (kSectionTitleForUsing, od1), (kSectionTitleForStyling, od2))
    }
    
    override func didSelectCell(_ title: String) {
        if title == "contentView" {
            
        }
    }
}
