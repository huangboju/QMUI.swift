//
//  QDSliderViewController.swift
//  QMUI.swift
//
//  Created by TonyHan on 2018/3/6.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

class QDSliderViewController: QDCommonViewController {
    
    private lazy var slider: QMUISlider = {
        let slider = QMUISlider()
        slider.value = 0.3
        slider.minimumTrackTintColor = QDThemeManager.shared.currentTheme?.themeTintColor
        slider.maximumTrackTintColor = UIColorGray9
        slider.trackHeight = 1 // 支持修改背后导轨的高度
        slider.thumbColor = slider.minimumTrackTintColor
        slider.thumbSize = CGSize(width: 14, height: 14) // 支持修改拖拽圆点的大小
        
        // 支持修改圆点的阴影样式
        slider.thumbShadowColor = slider.minimumTrackTintColor?.withAlphaComponent(0.3)
        slider.thumbShadowColor = .red
        slider.thumbShadowOffset = CGSize(width: 0, height: 2)
        slider.thumbShadowRadius = 3
        return slider
    }()
    
    private lazy var systemSlider: UISlider = {
        let systemSlider = UISlider()
        systemSlider.minimumTrackTintColor = slider.minimumTrackTintColor
        systemSlider.maximumTrackTintColor = slider.maximumTrackTintColor
        systemSlider.thumbTintColor = slider.minimumTrackTintColor
        systemSlider.value = slider.value
        return systemSlider
    }()
    
    private lazy var label1: UILabel = {
        let label = UILabel(with: UIFontMake(14), textColor: TableViewSectionHeaderTextColor)
        label.text = "QMUISlider"
        label.sizeToFit()
        return label
    }()
    
    private lazy var label2: UILabel = {
        let label = UILabel()
        label.qmui_setTheSameAppearance(as: label1)
        label.text = "UISlider"
        label.sizeToFit()
        return label
    }()
    
    override func initSubviews() {
        super.initSubviews()
        
        view.addSubview(slider)
        view.addSubview(systemSlider)
        view.addSubview(label1)
        view.addSubview(label2)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.slider.thumbShadowColor = .green
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let padding = UIEdgeInsets(top: qmui_navigationBarMaxYInViewCoordinator + 32, left: 24, bottom: 24, right: 24)
        
        label1.frame = label1.frame.setXY(padding.left, padding.top)
        
        slider.sizeToFit()
        slider.frame = CGRect(x: padding.left, y: label1.frame.maxY + 16, width: view.bounds.width - padding.horizontalValue, height: slider.frame.height)
        
        label2.frame = label2.frame.setXY(padding.left, slider.frame.maxY + 64)
        
        systemSlider.sizeToFit()
        var frame = slider.frame
        systemSlider.frame = frame.setY(label2.frame.maxY + 16)
    }
}
