//
//  QDLinkButtonViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/4/10.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

class QDLinkButtonViewController: QDCommonViewController {

    private lazy var linkButton1: QMUILinkButton = {
        let linkButton = generateLinkButton("带下划线的按钮")
        return linkButton
    }()
    
    private lazy var separatorLayer1: CALayer = {
        let separatorLayer = QDCommonUI.generateSeparatorLayer()
        return separatorLayer
    }()
    
    private lazy var linkButton2: QMUILinkButton = {
        let linkButton = generateLinkButton("修改下划线颜色")
        linkButton.underlineColor = UIColorTheme8
        return linkButton
    }()
    
    private lazy var separatorLayer2: CALayer = {
        let separatorLayer = QDCommonUI.generateSeparatorLayer()
        return separatorLayer
    }()
    
    private lazy var linkButton3: QMUILinkButton = {
        let linkButton = generateLinkButton("修改下划线的位置")
        linkButton.underlineInsets = UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 46);
        return linkButton
    }()

    private lazy var separatorLayer3: CALayer = {
        let separatorLayer = QDCommonUI.generateSeparatorLayer()
        return separatorLayer
    }()
    
    override func initSubviews() {
        super.initSubviews()
        
        view.addSubview(linkButton1)
        view.layer.addSublayer(separatorLayer1)
        view.addSubview(linkButton2)
        view.layer.addSublayer(separatorLayer2)
        view.addSubview(linkButton3)
        view.layer.addSublayer(separatorLayer3)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let contentMinY = qmui_navigationBarMaxYInViewCoordinator
        let buttonSpacingHeight: CGFloat = 64
        
        separatorLayer1.frame = CGRect(x: 0, y: contentMinY + buttonSpacingHeight - PixelOne, width: view.bounds.width, height: PixelOne)
        
        separatorLayer2.frame = separatorLayer1.frame.setY(contentMinY + buttonSpacingHeight * 2 - PixelOne)
        
        separatorLayer3.frame = separatorLayer1.frame.setY(contentMinY + buttonSpacingHeight * 3 - PixelOne)
        
        linkButton1.frame = linkButton1.frame.setXY(linkButton1.frame.minXHorizontallyCenter(in: view.bounds), contentMinY + buttonSpacingHeight.center(linkButton1.frame.height))
        
        linkButton2.frame = linkButton2.frame.setXY(linkButton2.frame.minXHorizontallyCenter(in: view.bounds), contentMinY + buttonSpacingHeight +  buttonSpacingHeight.center(linkButton2.frame.height))
        
        linkButton3.frame = linkButton3.frame.setXY(linkButton3.frame.minXHorizontallyCenter(in: view.bounds), contentMinY + buttonSpacingHeight * 2 +  buttonSpacingHeight.center(linkButton2.frame.height))
    }
    
    private func generateLinkButton(_ title: String) -> QMUILinkButton {
        let linkButton = QMUILinkButton()
        linkButton.adjustsTitleTintColorAutomatically = true
        linkButton.tintColor = QDThemeManager.shared.currentTheme?.themeTintColor
        linkButton.titleLabel?.font = UIFontMake(15)
        linkButton.setTitle(title, for: .normal)
        linkButton.sizeToFit()
        return linkButton
    }
}
