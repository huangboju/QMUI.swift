//
//  QDFontPointSizeAndLineHeightViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/5/21.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

class QDFontPointSizeAndLineHeightViewController: QDCommonViewController {
    
    private var fontPointSizeLabel: UILabel!
    private var lineHeightLabel: UILabel!
    private var fontPointSizeSlider: QMUISlider!
    private var exampleLabel: UILabel!
    
    private var oldFontPointSize: Float!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        oldFontPointSize = 16
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func initSubviews() {
        super.initSubviews()
        
        fontPointSizeLabel = UILabel(with: UIFontMake(18), textColor: UIColorGray1)
        fontPointSizeLabel.qmui_calculateHeightAfterSetAppearance()
        view.addSubview(fontPointSizeLabel)
        
        lineHeightLabel = UILabel()
        lineHeightLabel.qmui_setTheSameAppearance(as: fontPointSizeLabel)
        lineHeightLabel.qmui_calculateHeightAfterSetAppearance()
        view.addSubview(lineHeightLabel)
        
        fontPointSizeSlider = QMUISlider()
        fontPointSizeSlider.tintColor = QDThemeManager.shared.currentTheme?.themeCodeColor
        fontPointSizeSlider.thumbSize = CGSize(width: 16, height: 16)
        fontPointSizeSlider.thumbColor = fontPointSizeSlider.tintColor
        fontPointSizeSlider.thumbShadowColor = fontPointSizeSlider.tintColor.withAlphaComponent(0.3)
        fontPointSizeSlider.thumbShadowOffset = CGSize(width: 0, height: 2)
        fontPointSizeSlider.thumbShadowRadius = 3
        fontPointSizeSlider.minimumValue = 8
        fontPointSizeSlider.maximumValue = 50
        fontPointSizeSlider.value = oldFontPointSize
        fontPointSizeSlider.sizeToFit()
        fontPointSizeSlider.addTarget(self, action: #selector(handleSliderEvent(_:)), for: .valueChanged)
        view.addSubview(fontPointSizeSlider)
        
        exampleLabel = UILabel()
        exampleLabel.backgroundColor = QDThemeManager.shared.currentTheme?.themeCodeColor
        exampleLabel.textColor = UIColorWhite
        exampleLabel.text = "字体大小与其对应的默认行高"
        view.addSubview(exampleLabel)
        
        updateLabelsBaseOnSliderForce(true)
    }
    
    @objc private func handleSliderEvent(_ sender: Any?) {
        updateLabelsBaseOnSliderForce(false)
    }
    
    private func updateLabelsBaseOnSliderForce(_ force: Bool) {
        let fontPointSize = fontPointSizeSlider.value
        
        if force || fontPointSize != oldFontPointSize {
            exampleLabel.font = UIFontMake(CGFloat(fontPointSize))
            exampleLabel.sizeToFit()
            let lineHeight = exampleLabel.frame.height
            fontPointSizeLabel.text = "字号：\(fontPointSize)"
            lineHeightLabel.text = "行高：\(lineHeight)"
            oldFontPointSize = fontPointSize
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let padding = UIEdgeInsets(top: qmui_navigationBarMaxYInViewCoordinator + 24, left: 24, bottom: 24, right: 24)
        let contentWidth = view.bounds.width - padding.horizontalValue
        fontPointSizeLabel.frame = CGRectFlat(padding.left, padding.top, contentWidth, fontPointSizeLabel.frame.height)
        lineHeightLabel.frame = CGRectFlat(padding.left, fontPointSizeLabel.frame.maxY + 16, contentWidth, lineHeightLabel.frame.height)
        fontPointSizeSlider.frame = CGRectFlat(padding.left, lineHeightLabel.frame.maxY + 16, contentWidth, fontPointSizeSlider.frame.height)
        
        let exampleLabelSize = exampleLabel.sizeThatFits(CGSize.max)
        exampleLabel.frame = CGRectFlat(padding.left, fontPointSizeSlider.frame.maxY + 40, contentWidth, exampleLabelSize.height)
    }

}
