//
//  QDNormalButtonViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/4/9.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

class QDNormalButtonViewController: QDCommonViewController {
    
    // 普通按钮
    private lazy var normalButton: QMUIButton = {
        let normalButton = QDUIHelper.generateDarkFilledButton()
        normalButton.setTitle("按钮，支持高亮背景色", for: .normal)
        return normalButton
    }()
    
    // 边框按钮
    private lazy var borderedButton: QMUIButton = {
        let normalButton = QDUIHelper.generateLightBorderedButton()
        normalButton.setTitle("边框支持高亮的按钮", for: .normal)
        return normalButton
    }()
    
    // 图片+文字按钮
    private lazy var imagePositionButton1: QMUIButton = {
        let imagePositionButton = QMUIButton()
        imagePositionButton.tintColorAdjustsTitleAndImage = QDThemeManager.shared.currentTheme?.themeTintColor
        imagePositionButton.imagePosition = .top // 将图片位置改为在文字上方
        imagePositionButton.spacingBetweenImageAndTitle = 8
        imagePositionButton.setImage(UIImageMake("icon_emotion"), for: .normal)
        imagePositionButton.setTitle("图片在上方的按钮", for: .normal)
        imagePositionButton.titleLabel?.font = UIFontMake(11)
        imagePositionButton.qmui_borderPosition = [.top, .bottom]
        return imagePositionButton
    }()
    
    private lazy var imagePositionButton2: QMUIButton = {
        let imagePositionButton = QMUIButton()
        imagePositionButton.tintColorAdjustsTitleAndImage = QDThemeManager.shared.currentTheme?.themeTintColor
        imagePositionButton.imagePosition = .bottom // 将图片位置改为在文字下方
        imagePositionButton.spacingBetweenImageAndTitle = 8
        imagePositionButton.setImage(UIImageMake("icon_emotion"), for: .normal)
        imagePositionButton.setTitle("图片在下方的按钮", for: .normal)
        imagePositionButton.titleLabel?.font = UIFontMake(11)
        imagePositionButton.qmui_borderPosition = [.top, .bottom]
        return imagePositionButton
    }()
    
    private lazy var separatorLayer: CALayer = {
        let separatorLayer = CALayer.qmui_separatorLayer()
        return separatorLayer
    }()
    
    private lazy var imageButtonSeparatorLayer: CAShapeLayer = {
        let imageButtonSeparatorLayer = CAShapeLayer.qmui_seperatorDashLayer(3, lineSpacing: 2, lineWidth: PixelOne, lineColor: UIColorSeparator.cgColor, isHorizontal: false)
        return imageButtonSeparatorLayer
    }()

    override func initSubviews() {
        super.initSubviews()
        
        view.addSubview(normalButton)
        view.addSubview(borderedButton)
        view.layer.addSublayer(separatorLayer)
        view.addSubview(imagePositionButton1)
        view.addSubview(imagePositionButton2)
        view.layer.addSublayer(imageButtonSeparatorLayer)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let contentMinY = qmui_navigationBarMaxYInViewCoordinator
        let buttonSpacingHeight = QDButtonSpacingHeight
        
        // 普通按钮
        normalButton.frame = normalButton.frame.setXY(view.bounds.width.center(normalButton.frame.width), contentMinY + buttonSpacingHeight.center(normalButton.frame.height))
        
        separatorLayer.frame = CGRectFlat(0, contentMinY + buttonSpacingHeight - PixelOne, view.bounds.width, PixelOne)
        
        // 边框按钮
        var tmpFrame = normalButton.frame
        borderedButton.frame = tmpFrame.setY(separatorLayer.frame.maxY + buttonSpacingHeight.center(normalButton.frame.height))
        
        // 图片+文字按钮
        imagePositionButton1.frame = CGRectFlat(0, contentMinY + buttonSpacingHeight * 2, view.bounds.width / 2, buttonSpacingHeight)
        tmpFrame = imagePositionButton1.frame
        imagePositionButton2.frame = tmpFrame.setX(imagePositionButton1.frame.maxX)
        
        imageButtonSeparatorLayer.frame = CGRectFlat(imagePositionButton1.frame.maxX, imagePositionButton1.frame.minY, PixelOne, buttonSpacingHeight)
    }
}
