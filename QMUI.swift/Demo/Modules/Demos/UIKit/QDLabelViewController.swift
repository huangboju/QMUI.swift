//
//  QDLabelViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/4/10.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

class QDLabelViewController: QDCommonViewController {

    private lazy var label1: QMUILabel = {
        let label = QMUILabel()
        label.text = "可长按复制"
        label.font = UIFontMake(15)
        label.textColor = UIColorGray5
        label.canPerformCopyAction = true
        label.sizeToFit()
        return label
    }()
    
    private lazy var label2: QMUILabel = {
        let label = QMUILabel()
        label.text = "可设置 contentInsets"
        label.font = UIFontMake(15)
        label.textColor = UIColorWhite
        label.backgroundColor = UIColorGray8
        label.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        label.sizeToFit()
        return label
    }()
    
    private lazy var label3: QMUILabel = {
        let label = QMUILabel()
        label.text = "复制上面第二个label的样式"
        label.qmui_setTheSameAppearance(as: label2)
        label.sizeToFit()
        return label
    }()
    
    private lazy var separatorLayer1: CALayer = {
        let separatorLayer = QDCommonUI.generateSeparatorLayer()
        return separatorLayer
    }()
    
    private lazy var separatorLayer2: CALayer = {
        let separatorLayer = QDCommonUI.generateSeparatorLayer()
        return separatorLayer
    }()
    
    private lazy var separatorLayer3: CALayer = {
        let separatorLayer = QDCommonUI.generateSeparatorLayer()
        return separatorLayer
    }()
    
    override func initSubviews() {
        super.initSubviews()
        
        view.addSubview(label1)
        view.layer.addSublayer(separatorLayer1)
        view.addSubview(label2)
        view.layer.addSublayer(separatorLayer2)
        view.addSubview(label3)
        view.layer.addSublayer(separatorLayer3)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    
        let contentMinY = self.qmui_navigationBarMaxYInViewCoordinator
        let buttonSpacingHeight = QDButtonSpacingHeight
        
        label1.frame = label1.frame.setXY(view.bounds.width.center(label1.bounds.width), contentMinY + buttonSpacingHeight.center(label1.bounds.height))
        
        separatorLayer1.frame = CGRect(x: 0, y: contentMinY + buttonSpacingHeight * 1, width: view.bounds.width, height: PixelOne)
        
        label2.frame = label2.frame.setXY(view.bounds.width.center(label2.bounds.width), separatorLayer1.frame.maxY + buttonSpacingHeight.center(label2.bounds.height))
        
        separatorLayer2.frame = CGRect(x: 0, y: contentMinY + buttonSpacingHeight * 2, width: view.bounds.width, height: PixelOne)
        
        label3.frame = label3.frame.setXY(view.bounds.width.center(label3.bounds.width), separatorLayer2.frame.maxY + buttonSpacingHeight.center(label3.bounds.height))
        
        separatorLayer3.frame = CGRect(x: 0, y: contentMinY + buttonSpacingHeight * 3, width: view.bounds.width, height: PixelOne)
    }

}
