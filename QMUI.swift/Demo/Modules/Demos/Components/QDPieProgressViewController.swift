//
//  QDPieProgressViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/5/16.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

class QDPieProgressViewController: QDCommonViewController {
    
    private var section1: UIView!
    private var progressView1: QMUIPieProgressView!
    private var slider: QMUISlider!
    private var titleLabel1: UILabel!
    
    private var section2: UIView!
    private var progressView2: QMUIPieProgressView!
    private var progressView3: QMUIPieProgressView!
    private var progressView4: QMUIPieProgressView!
    private var titleLabel2: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColorWhite
    }

    override func initSubviews() {
        super.initSubviews()
        
        section1 = UIView()
        section1.qmui_borderColor = UIColorSeparator
        section1.qmui_borderPosition = .bottom
        section1.qmui_borderWidth = PixelOne
        view.addSubview(section1)
        
        progressView1 = QMUIPieProgressView(frame: CGRect(x: 0, y: 0, width: 75, height: 75))
        progressView1.tintColor = QDThemeManager.shared.currentTheme?.themeTintColor ?? UIColorBlue
        progressView1.addTarget(self, action: #selector(handleProgressViewValueChanged(_:)), for: .valueChanged)
        section1.addSubview(progressView1)
        
        titleLabel1 = UILabel(with: UIFontMake(13), textColor: progressView1.tintColor)
        titleLabel1.qmui_calculateHeightAfterSetAppearance()
        titleLabel1.textAlignment = .center
        section1.addSubview(titleLabel1)
        
        slider = QMUISlider()
        slider.tintColor = progressView1.tintColor
        slider.thumbSize = CGSize(width: 16, height: 16)
        slider.thumbColor = slider.tintColor
        slider.thumbShadowColor = slider.tintColor.withAlphaComponent(0.3)
        slider.thumbShadowOffset = CGSize(width: 0, height: 2)
        slider.thumbShadowRadius = 3
        slider.sizeToFit()
        slider.addTarget(self, action: #selector(handleSliderTouchUpInside(_:)), for: .touchUpInside)
        section1.addSubview(slider)
        
        section2 = UIView()
        section2.qmui_borderColor = UIColorSeparator
        section2.qmui_borderPosition = .bottom
        section2.qmui_borderWidth = PixelOne
        view.addSubview(section2)
        
        progressView2 = QMUIPieProgressView(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
        progressView2.tintColor = UIColorTheme3
        progressView2.setProgress(0.68, animated: false)
        section2.addSubview(progressView2)
        
        progressView3 = QMUIPieProgressView(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        progressView3.tintColor = UIColorTheme5
        progressView3.setProgress(0.1, animated: false)
        section2.addSubview(progressView3)
        
        progressView4 = QMUIPieProgressView(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        progressView4.tintColor = UIColorTheme5
        progressView4.backgroundColor = progressView4.tintColor.qmui_colorWithAlphaAddedToWhite(0.2)
        progressView4.setProgress(0.28, animated: false)
        section2.addSubview(progressView4)
        
        titleLabel2 = UILabel(with: UIFontMake(11), textColor: titleLabel1.textColor)
        titleLabel2.numberOfLines = 0
        titleLabel2.text = "通过 backgroundColor 或 tintColor 修改颜色"
        titleLabel2.sizeToFit()
        section2.addSubview(titleLabel2)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        progressView1.setProgress(0.3, animated: true)
        slider.setValue(progressView1.progress, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let horizontalInset: CGFloat = 25
        let sectionHeight: CGFloat = 145
        let progressView1MarginRight: CGFloat = 30
        
        section1.frame = CGRect(x: 0, y: qmui_navigationBarMaxYInViewCoordinator, width: view.bounds.width, height: sectionHeight)
        progressView1.frame = progressView1.frame.setXY(horizontalInset, progressView1.frame.minYVerticallyCenter(in: section1.frame) - 6)
        // 因为下面有个label，因此这里向上偏一点以让视觉上更平衡
        titleLabel1.frame = CGRect(x: progressView1.frame.minX, y: progressView1.frame.maxY + 9, width: progressView1.bounds.width, height: titleLabel1.bounds.height)
        slider.frame = CGRect(x: progressView1.frame.maxX + progressView1MarginRight, y: progressView1.frame.midY - slider.bounds.midY, width: view.bounds.width - progressView1.frame.maxX - progressView1MarginRight - horizontalInset, height: slider.bounds.height)
        
        section2.frame = CGRect(x: 0, y: section1.frame.maxY, width: view.bounds.width, height: sectionHeight)
        let referenceCenter = progressView1.center
        progressView2.center = CGPoint(x: referenceCenter.x - 20, y: referenceCenter.y - 15)
        progressView3.center = CGPoint(x: referenceCenter.x + 20, y: referenceCenter.y - 15)
        progressView4.center = CGPoint(x: referenceCenter.x + 10, y: referenceCenter.y + 22)
        titleLabel2.sizeToFit()
        titleLabel2.frame = titleLabel2.frame.setXY(slider.frame.minX, titleLabel2.frame.minYVerticallyCenter(in: section2.frame))
    }
    
    @objc private func handleProgressViewValueChanged(_ progressView: QMUIPieProgressView) {
        titleLabel1.text = "\(progressView.progress * 100)%"
    }
    
    @objc private func handleSliderTouchUpInside(_ sender: Any?) {
        progressView1.setProgress(slider.value, animated: true)
    }
}
