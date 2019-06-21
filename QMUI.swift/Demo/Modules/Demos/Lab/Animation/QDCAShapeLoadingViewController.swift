//
//  QDCAShapeLoadingViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/5/21.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

private let kLayerSizeValue: CGFloat = 60
private let kPathLineWidth: CGFloat = 6
private let kAnimationDuration: CFTimeInterval = 1.5

class QDCAShapeLoadingViewController: QDCommonViewController {

    private var line1: CALayer!
    private var line2: CALayer!
    
    private var shapeLayer1: CAShapeLayer!
    private var shapeLayer2: CAShapeLayer!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleWillEnterForeground(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func initSubviews() {
        super.initSubviews()
        
        line1 = CALayer()
        line1.backgroundColor = UIColorSeparator.cgColor
        line1.qmui_removeDefaultAnimations()
        view.layer.addSublayer(line1)
        
        line2 = CALayer()
        line2.backgroundColor = UIColorSeparator.cgColor
        line2.qmui_removeDefaultAnimations()
        view.layer.addSublayer(line2)
        
        let path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: kLayerSizeValue, height: kLayerSizeValue))
        shapeLayer1 = CAShapeLayer()
        shapeLayer1.strokeColor = UIColorTheme1.cgColor
        shapeLayer1.fillColor = UIColorClear.cgColor
        shapeLayer1.lineCap = CAShapeLayerLineCap.round
        shapeLayer1.strokeStart = 0
        shapeLayer1.strokeEnd = 0.4
        shapeLayer1.lineWidth = kPathLineWidth
        shapeLayer1.path = path.cgPath
        view.layer.addSublayer(shapeLayer1)
        
        shapeLayer2 = CAShapeLayer()
        shapeLayer2.strokeColor = UIColorTheme3.cgColor
        shapeLayer2.fillColor = UIColorClear.cgColor
        shapeLayer2.lineCap = CAShapeLayerLineCap.round
        shapeLayer2.strokeStart = -0.5
        shapeLayer2.strokeEnd = 0
        shapeLayer2.lineWidth = kPathLineWidth
        shapeLayer2.path = path.cgPath
        view.layer.addSublayer(shapeLayer2)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        beginAnimation()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let lineSpace: CGFloat = 40
        var minY: CGFloat = lineSpace
        
        shapeLayer1.frame = CGRect(x: view.bounds.width.center(kLayerSizeValue), y: qmui_navigationBarMaxYInViewCoordinator + minY, width: kLayerSizeValue, height: kLayerSizeValue)
        
        minY = shapeLayer1.frame.maxY + lineSpace
        
        line1.frame = CGRect(x: 0, y: minY, width: view.bounds.width, height: PixelOne)
        
        minY = line1.frame.maxY + lineSpace
        
        shapeLayer2.frame = CGRect(x: view.bounds.width.center(kLayerSizeValue), y: minY, width: kLayerSizeValue, height: kLayerSizeValue)
        
        minY = shapeLayer2.frame.maxY + lineSpace
        
        line2.frame = CGRect(x: 0, y: minY, width: view.bounds.width, height: PixelOne)
    }
    
    @objc private func handleWillEnterForeground(_ notification: NSNotification) {
        beginAnimation()
    }
    
    private func beginAnimation() {
        
        // layer1
        
        let animation1 = CABasicAnimation(keyPath: "transform.rotation")
        animation1.duration = kAnimationDuration
        animation1.fromValue = 0
        animation1.toValue = Double.pi * 2
        animation1.repeatCount = Float.infinity
        shapeLayer1.add(animation1, forKey: nil)
        
        // layer2
        
        let startAnimation = CABasicAnimation(keyPath: "strokeStart")
        startAnimation.fromValue = -0.5
        startAnimation.toValue = 1
        let endAnimation = CABasicAnimation(keyPath: "strokeEnd")
        endAnimation.fromValue = 0
        endAnimation.toValue = 1
        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [startAnimation, endAnimation]
        groupAnimation.duration = kAnimationDuration
        groupAnimation.repeatCount = Float.infinity
        shapeLayer2.add(groupAnimation, forKey: nil)
    }
}
