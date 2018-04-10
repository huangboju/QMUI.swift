//
//  QDGhostButtonViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/4/10.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

class QDGhostButtonViewController: QDCommonViewController {

    private lazy var ghostButton1: QMUIGhostButton = {
        let ghostButton = QMUIGhostButton(ghostType: .blue)
        ghostButton.titleLabel?.font = UIFontMake(14)
        ghostButton.setTitle("QMUIGhostButtonColorBlue", for: .normal)
        return ghostButton
    }()
    
    private lazy var separatorLayer1: CALayer = {
        let separatorLayer = QDCommonUI.generateSeparatorLayer()
        return separatorLayer
    }()
    
    private lazy var ghostButton2: QMUIGhostButton = {
        let ghostButton = QMUIGhostButton(ghostType: .red)
        ghostButton.titleLabel?.font = UIFontMake(14)
        ghostButton.setTitle("QMUIGhostButtonColorRed", for: .normal)
        return ghostButton
    }()
    
    private lazy var separatorLayer2: CALayer = {
        let separatorLayer = QDCommonUI.generateSeparatorLayer()
        return separatorLayer
    }()
    
    private lazy var ghostButton3: QMUIGhostButton = {
        let ghostButton = QMUIGhostButton(ghostType: .green)
        ghostButton.titleLabel?.font = UIFontMake(14)
        ghostButton.setTitle("点击修改ghostColor", for: .normal)
        ghostButton.setImage(UIImageMake("icon_emotion"), for: .normal)
        ghostButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 6)
        ghostButton.adjustsImageWithGhostColor = true
        ghostButton.addTarget(self, action:#selector(handleGhostButtonColorEvent), for: .touchUpInside)
        return ghostButton
    }()
    
    private lazy var separatorLayer3: CALayer = {
        let separatorLayer = QDCommonUI.generateSeparatorLayer()
        return separatorLayer
    }()
    
    override func initSubviews() {
        super.initSubviews()
        
        view.addSubview(ghostButton1)
        view.layer.addSublayer(separatorLayer1)
        view.addSubview(ghostButton2)
        view.layer.addSublayer(separatorLayer2)
        view.addSubview(ghostButton3)
        view.layer.addSublayer(separatorLayer3)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let contentMinY = qmui_navigationBarMaxYInViewCoordinator
        let buttonSpacingHeight = QDButtonSpacingHeight
        let buttonSize = CGSize(width: 260, height: 40)
        let buttonMinX = view.bounds.width.center(buttonSize.width)
        let buttonOffsetY = buttonSpacingHeight.center(buttonSize.height)
        
        ghostButton1.frame = CGRectFlat(buttonMinX, contentMinY + buttonOffsetY, buttonSize.width, buttonSize.height)
        ghostButton2.frame = CGRectFlat(buttonMinX, contentMinY + buttonSpacingHeight + buttonOffsetY, buttonSize.width, buttonSize.height)
        ghostButton3.frame = CGRectFlat(buttonMinX, contentMinY + buttonSpacingHeight * 2 + buttonOffsetY, buttonSize.width, buttonSize.height)
        
        separatorLayer1.frame = CGRect(x: 0, y: contentMinY + buttonSpacingHeight - PixelOne, width: view.bounds.width, height: PixelOne)
        
        var farme = separatorLayer1.frame
        separatorLayer2.frame = farme.setY(contentMinY + buttonSpacingHeight * 2 - PixelOne)
        
        farme = separatorLayer1.frame
        separatorLayer3.frame = farme.setY(contentMinY + buttonSpacingHeight * 3 - PixelOne)
    }

    @objc private func handleGhostButtonColorEvent() {
        let color = QDCommonUI.randomThemeColor()
        ghostButton3.ghostColor = color
    }
}
