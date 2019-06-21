//
//  QDUIViewLayoutViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/4/24.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

class QDUIViewLayoutViewController: QDCommonViewController {

    private var view1: UIView!
    private var view2: UIView!
    private var view3: UIView!
    
    override func initSubviews() {
        super.initSubviews()
        
        view1 = UIView()
        view1.backgroundColor = QDCommonUI.randomThemeColor()
        view.addSubview(view1)
        
        view2 = UIView()
        view2.backgroundColor = QDCommonUI.randomThemeColor()
        view.addSubview(view2)
        
        view3 = UIView()
        view3.backgroundColor = QDCommonUI.randomThemeColor()
        view.addSubview(view3)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let padding = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
        let contentWidth = view.bounds.width - padding.horizontalValue
        
        // 所有布局都需要在同一个坐标系里才有效
        
        view1.qmui_left = padding.left
        view1.qmui_top = qmui_navigationBarMaxYInViewCoordinator + padding.top
        view1.qmui_width = contentWidth
        view1.qmui_height = 40
        
        view2.qmui_left = view1.qmui_left
        view2.qmui_top = view1.qmui_bottom + 24
        view2.qmui_width = view1.qmui_width / 2
        view2.qmui_height = 40
        
        view3.qmui_width = view1.qmui_width / 2
        view3.qmui_height = 40
        view3.qmui_top = view2.qmui_bottom + 24
        view3.qmui_right = view1.qmui_right
    }
}
