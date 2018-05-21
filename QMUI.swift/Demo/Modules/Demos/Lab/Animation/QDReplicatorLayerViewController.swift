//
//  QDReplicatorLayerViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/5/21.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

private let kAnimationDuration: CFTimeInterval = 0.9

private let kSubLayerWidth: CGFloat = 8
private let kSubLayerHeiht: CGFloat = 26
private let kSubLayerSpace: CGFloat = 4
private let kSubLayerCount: Int = 3

private let kCircleContainerSize: CGFloat = 80
private let kCircleCount: Int = 12
private let kCircleSize: CGFloat = 12

class QDReplicatorLayerViewController: QDCommonViewController {

    private var line1: CALayer!
    private var line2: CALayer!
    
    private var containerLayer1: CAReplicatorLayer!
    private var containerLayer2: CAReplicatorLayer!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleWillEnterForeground(_:)), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func initSubviews() {
        super.initSubviews()
        
        containerLayer1 = CAReplicatorLayer()
        containerLayer1.masksToBounds = true
        containerLayer1.instanceCount = kSubLayerCount
        containerLayer1.instanceDelay = kAnimationDuration / CFTimeInterval(containerLayer1.instanceCount)
        containerLayer1.instanceTransform = CATransform3DMakeTranslation(kSubLayerWidth + kSubLayerSpace, 0, 0)
        view.layer.addSublayer(containerLayer1)
        
        containerLayer2 = CAReplicatorLayer()
        containerLayer2.masksToBounds = true
        containerLayer2.instanceCount = kCircleCount
        containerLayer2.instanceDelay = kAnimationDuration / CFTimeInterval(containerLayer2.instanceCount)
        containerLayer2.instanceTransform = CATransform3DMakeRotation(AngleWithDegrees(CGFloat(360 / containerLayer2.instanceCount)), 0, 0, 1)
        view.layer.addSublayer(containerLayer2)
        
        line1 = CALayer()
        line1.backgroundColor = UIColorSeparator.cgColor
        line1.qmui_removeDefaultAnimations()
        view.layer.addSublayer(line1)
        
        line2 = CALayer()
        line2.backgroundColor = UIColorSeparator.cgColor
        line2.qmui_removeDefaultAnimations()
        view.layer.addSublayer(line2)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        beginAnimation()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let lineSpace: CGFloat = 60
        var minY = qmui_navigationBarMaxYInViewCoordinator + lineSpace
        let width1 = kSubLayerWidth * CGFloat(kSubLayerCount) + CGFloat(kSubLayerCount - 1) * kSubLayerSpace
        
        containerLayer1.frame = CGRect(x: view.bounds.width.center(width1), y: minY, width: width1, height: kSubLayerHeiht)
        
        minY = containerLayer1.frame.maxY + lineSpace
        
        line1.frame = CGRect(x: 0, y: minY, width: view.bounds.width, height: PixelOne)
        
        minY = line1.frame.maxY + lineSpace
        
        containerLayer2.frame = CGRect(x: view.bounds.width.center(kCircleContainerSize), y: minY, width: kCircleContainerSize, height: kCircleContainerSize)
        
        minY = containerLayer2.frame.maxY + lineSpace
        
        line2.frame = CGRect(x: 0, y: minY, width: view.bounds.width, height: PixelOne)
    }
    
    @objc private func handleWillEnterForeground(_ notification: NSNotification) {
        beginAnimation()
    }
    
    private func beginAnimation() {
        
        let subLayer1 = CALayer()
        subLayer1.backgroundColor = UIColorGreen.cgColor;
        subLayer1.frame = CGRect(x: 0, y: kSubLayerHeiht - 6, width: kSubLayerWidth, height: kSubLayerHeiht)
        subLayer1.cornerRadius = 2
        containerLayer1.addSublayer(subLayer1)
        
        let animation1 = CABasicAnimation(keyPath: "position.y")
        animation1.fromValue = kSubLayerHeiht * 1.5 - 6
        animation1.toValue = kSubLayerHeiht * 0.5
        animation1.repeatCount = Float.infinity
        animation1.duration = kAnimationDuration
        animation1.autoreverses = true
        subLayer1.add(animation1, forKey: nil)
        
        let subLayer2 = CALayer()
        subLayer2.backgroundColor = UIColorBlue.cgColor;
        subLayer2.frame = CGRect(x: (kCircleContainerSize - kCircleSize) / 2, y: 0, width: kCircleSize, height: kCircleSize)
        subLayer2.cornerRadius = kCircleSize / 2
        subLayer2.transform = CATransform3DMakeScale(0, 0, 0)
        containerLayer2.addSublayer(subLayer2)
        
        let animation2 = CABasicAnimation(keyPath: "transform.scale")
        animation2.fromValue = 1
        animation2.toValue = 0.1
        animation2.repeatCount = Float.infinity
        animation2.duration = kAnimationDuration
        subLayer2.add(animation2, forKey: nil)
    }
}
