//
//  QDNavigationListViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/4/23.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

class QDNavigationListViewController: QDCommonListViewController {

    override func initDataSource() {
        super.initDataSource()
        
        dataSourceWithDetailText = QMUIOrderedDictionary(
            dictionaryLiteral:
            ("拦截系统navBar返回按钮事件", "例如询问已输入的内容要不要保存"),
            ("感知系统的手势返回", "可感知到是否成功手势返回或者中断了"),
            ("方便控制界面导航栏样式", "方便控制前后两个界面的导航栏和状态栏样式"),
            ("优化导航栏在转场时的样式", "优化系统navController只有一个navBar带来的问题"))
    }
    
    override func didSelectCell(_ title: String) {
        var viewController: UIViewController?
        if title == "拦截系统navBar返回按钮事件" {
            viewController = QDInterceptBackButtonEventViewController()
        }
        if title == "感知系统的手势返回" {
            viewController = QDNavigationTransitionViewController()
        }
        if title == "方便控制界面导航栏样式" {
            viewController = QDChangeNavBarStyleViewController()
        }
        if title == "优化导航栏在转场时的样式" {
            viewController = QDChangeNavBarStyleViewController()
            if let viewController = viewController as? QDChangeNavBarStyleViewController {
                viewController.customNavBarTransition = true
            }
        }
        
        if let viewController = viewController {
            viewController.title = title
            navigationController?.pushViewController(viewController, animated: true)
        }
    }

}
