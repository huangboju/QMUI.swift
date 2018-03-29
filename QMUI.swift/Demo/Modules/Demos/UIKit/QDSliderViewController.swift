//
//  QDSliderViewController.swift
//  QMUI.swift
//
//  Created by TonyHan on 2018/3/6.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

class QDSliderViewController: QDCommonViewController {
    
    lazy var slider: QMUISlider = {
        let slider = QMUISlider()
        slider.value = 0.3
        slider.minimumTrackTintColor = QDThemeManager.shared.currentTheme!.themeTintColor
        slider.maximumTrackTintColor = UIColorGray9
        slider.trackHeight = 1 // 支持修改背后导轨的高度
        slider.thumbColor = slider.minimumTrackTintColor
        slider.thumbSize = CGSize(width: 14, height: 14) // 支持修改拖拽圆点的大小
        
        
        return slider
    }()
    private var systemSlider: UISlider?
    private var label1: UILabel?
    private var label2: UILabel?
    
    override func initSubviews() {
        super.initSubviews()
        view.addSubview(slider)
    }
}
