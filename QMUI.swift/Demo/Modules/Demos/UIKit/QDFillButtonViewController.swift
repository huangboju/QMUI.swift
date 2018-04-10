//
//  QDFillButtonViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/4/10.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

class QDFillButtonViewController: QDCommonViewController {

    private lazy var fillButton1: QMUIFillButton = {
        let fillButton = QMUIFillButton(fillType: .blue)
        fillButton.titleLabel?.font = UIFontMake(14)
        fillButton.setTitle("QMUIFillButtonColorBlue", for: .normal)
        return fillButton
    }()
    
    private lazy var separatorLayer1: CALayer = {
        let separatorLayer = QDCommonUI.generateSeparatorLayer()
        return separatorLayer
    }()
    
    private lazy var fillButton2: QMUIFillButton = {
        let fillButton = QMUIFillButton(fillType: .red)
        fillButton.titleLabel?.font = UIFontMake(14)
        // 默认点击态是半透明处理，如果需要点击态是其他颜色，修改下面两个属性
        // fillButton2.adjustsButtonWhenHighlighted = false
        // fillButton2.highlightedBackgroundColor = UIColorMake(70, 160, 242)
        fillButton.setTitle("QMUIFillButtonColorRed", for: .normal)
        return fillButton
    }()
    
    private lazy var separatorLayer2: CALayer = {
        let separatorLayer = QDCommonUI.generateSeparatorLayer()
        return separatorLayer
    }()
    
    private lazy var fillButton3: QMUIFillButton = {
        let fillButton = QMUIFillButton(fillType: .green)
        fillButton.titleLabel?.font = UIFontMake(14)
        fillButton.setTitle("点击修改fillColor", for: .normal)
        fillButton.setImage(UIImageMake("icon_emotion"), for: .normal)
        fillButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 6)
        fillButton.adjustsImageWithTitleTextColor = true
        fillButton.addTarget(self, action:#selector(handleFillButtonEvent(_:)), for: .touchUpInside)
        return fillButton
    }()
    
    private lazy var separatorLayer3: CALayer = {
        let separatorLayer = QDCommonUI.generateSeparatorLayer()
        return separatorLayer
    }()
    
    override func initSubviews() {
        super.initSubviews()
        
        view.addSubview(fillButton1)
        view.layer.addSublayer(separatorLayer1)
        view.addSubview(fillButton2)
        view.layer.addSublayer(separatorLayer2)
        view.addSubview(fillButton3)
        view.layer.addSublayer(separatorLayer3)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let contentMinY = qmui_navigationBarMaxYInViewCoordinator
        let buttonSpacingHeight = QDButtonSpacingHeight
        let buttonSize = CGSize(width: 260, height: 40)
        let buttonMinX = view.bounds.width.center(buttonSize.width)
        let buttonOffsetY = buttonSpacingHeight.center(buttonSize.height)
        
        fillButton1.frame = CGRectFlat(buttonMinX, contentMinY + buttonOffsetY, buttonSize.width, buttonSize.height)
        fillButton2.frame = CGRectFlat(buttonMinX, contentMinY + buttonSpacingHeight + buttonOffsetY, buttonSize.width, buttonSize.height)
        fillButton3.frame = CGRectFlat(buttonMinX, contentMinY + buttonSpacingHeight * 2 + buttonOffsetY, buttonSize.width, buttonSize.height)
        
        separatorLayer1.frame = CGRect(x: 0, y: contentMinY + buttonSpacingHeight - PixelOne, width: view.bounds.width, height: PixelOne)
        
        var farme = separatorLayer1.frame
        separatorLayer2.frame = farme.setY(contentMinY + buttonSpacingHeight * 2 - PixelOne)
        
        farme = separatorLayer1.frame
        separatorLayer3.frame = farme.setY(contentMinY + buttonSpacingHeight * 3 - PixelOne)
    }
    
    @objc private func handleFillButtonEvent(_ sender: AnyObject) {
        let color = QDCommonUI.randomThemeColor()
        fillButton3.fillColor = color;
        fillButton3.titleTextColor = UIColorWhite
    }

}
