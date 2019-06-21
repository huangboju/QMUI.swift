//
//  QDAllAnimationViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/5/21.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

class QDAllAnimationViewController: QDCommonViewController {
    
    private var scrollView: UIScrollView!
    
    private var shapeView1: UIView!
    private var shapeView2: UIView!
    private var shapeView3: UIView!
    
    private var shapeView4: UIView!
    private var shapeView5: UIView!
    private var shapeView6: UIView!
    private var shapeView7: UIView!
    private var shapeView8: UIView!
    
    private var indicatorView: QDActivityIndicator!
    
    private var line1: CALayer!
    private var line2: CALayer!
    private var line3: CALayer!

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
        
        scrollView = UIScrollView()
        view.addSubview(scrollView)
        
        line1 = CALayer()
        line1.backgroundColor = UIColorSeparator.cgColor
        line1.qmui_removeDefaultAnimations()
        scrollView.layer.addSublayer(line1)
        
        line2 = CALayer()
        line2.backgroundColor = UIColorSeparator.cgColor
        line2.qmui_removeDefaultAnimations()
        scrollView.layer.addSublayer(line2)
        
        line3 = CALayer()
        line3.backgroundColor = UIColorSeparator.cgColor
        line3.qmui_removeDefaultAnimations()
        scrollView.layer.addSublayer(line3)
        
        shapeView1 = UIView()
        shapeView1.backgroundColor = UIColorGreen
        shapeView1.layer.cornerRadius = 10
        scrollView.addSubview(shapeView1)
        
        shapeView2 = UIView()
        shapeView2.backgroundColor = UIColorRed
        shapeView2.layer.cornerRadius = 10
        scrollView.addSubview(shapeView2)
        
        shapeView3 = UIView()
        shapeView3.backgroundColor = UIColorBlue
        shapeView3.layer.cornerRadius = 10
        scrollView.addSubview(shapeView3)
        
        shapeView4 = UIView()
        shapeView4.backgroundColor = UIColorBlue
        shapeView4.layer.cornerRadius = 2
        scrollView.addSubview(shapeView4)
        
        shapeView5 = UIView()
        shapeView5.backgroundColor = UIColorBlue
        shapeView5.layer.cornerRadius = 2
        scrollView.addSubview(shapeView5)
        
        shapeView6 = UIView()
        shapeView6.backgroundColor = UIColorBlue
        shapeView6.layer.cornerRadius = 2
        scrollView.addSubview(shapeView6)
        
        shapeView7 = UIView()
        shapeView7.backgroundColor = UIColorBlue
        shapeView7.layer.cornerRadius = 2
        scrollView.addSubview(shapeView7)
        
        shapeView8 = UIView()
        shapeView8.backgroundColor = UIColorBlue
        shapeView8.layer.cornerRadius = 2
        scrollView.addSubview(shapeView8)
        
        indicatorView = QDActivityIndicator(style: .normal)
        indicatorView.tintColor = UIColorGrayLighten
        indicatorView.sizeToFit()
        scrollView.addSubview(indicatorView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let bigSize: CGFloat = 20
        let smallSize: CGFloat = 4
        let lineSpace: CGFloat = 40
        var minY = lineSpace
        var minX = (view.bounds.width - 100) / 2
        
        scrollView.frame = view.bounds
        shapeView1.frame = CGRect(x: minX, y: minY, width: bigSize, height: bigSize)
        shapeView2.frame = CGRect(x: minX, y: minY, width: bigSize, height: bigSize)
        shapeView3.frame = CGRect(x: minX, y: minY, width: bigSize, height: bigSize)
        
        minY = shapeView1.frame.maxY + lineSpace
        line1.frame = CGRect(x: 0, y: minY, width: scrollView.bounds.width, height: PixelOne)
        
        minY = line1.frame.maxY + lineSpace
        minX = (view.bounds.width - 220) / 2
        
        shapeView4.frame = CGRect(x: minX, y: minY, width: smallSize, height: smallSize)
        shapeView5.frame = CGRect(x: minX, y: minY, width: smallSize, height: smallSize)
        shapeView6.frame = CGRect(x: minX, y: minY, width: smallSize, height: smallSize)
        shapeView7.frame = CGRect(x: minX, y: minY, width: smallSize, height: smallSize)
        shapeView8.frame = CGRect(x: minX, y: minY, width: smallSize, height: smallSize)
        
        minY = shapeView4.frame.maxY + lineSpace
        
        line2.frame = CGRect(x: 0, y: minY, width: scrollView.bounds.width, height: PixelOne)
        minY = line2.frame.maxY + lineSpace
        
        indicatorView.frame = CGRect(x: scrollView.bounds.width.center(indicatorView.bounds.width), y: minY, width: indicatorView.bounds.width, height: indicatorView.bounds.height)
        
        minY = indicatorView.frame.maxY + lineSpace
        
        line3.frame = CGRect(x: 0, y: minY, width: scrollView.bounds.width, height: PixelOne)
        minY = line3.frame.maxY + lineSpace
        
        scrollView.contentSize = CGSize(width: scrollView.bounds.width, height: minY)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        beginAnimation()
    }
    
    @objc private func handleWillEnterForeground(_ notification: NSNotification) {
        beginAnimation()
    }
    
    private func beginAnimation() {
        let positionAnimation = CAKeyframeAnimation()
        positionAnimation.keyPath = "position.x"
        positionAnimation.values = [-5, 0, 10, 40, 70, 80, 75]
        positionAnimation.keyTimes = [0, (5 / 90.0), (15 / 90.0), (45 / 90.0), (75 / 90.0), (85 / 90.0), 1] as [NSNumber]
        positionAnimation.isAdditive = true
        
        let scaleAnimation = CAKeyframeAnimation()
        scaleAnimation.keyPath = "transform.scale"
        scaleAnimation.values = [ 0.7, 0.9, 1, 0.9, 0.7 ]
        scaleAnimation.keyTimes = [0, (15 / 90.0), (45 / 90.0), (75 / 90.0), 1] as [NSNumber]
        
        let alphaAnimation = CAKeyframeAnimation()
        alphaAnimation.keyPath = "opacity"
        alphaAnimation.values = [0, 1, 1, 1, 0]
        alphaAnimation.keyTimes = [0, (1 / 6.0), (3 / 6.0), (5 / 6.0), 1]  as [NSNumber]
        
        let group = CAAnimationGroup()
        group.animations = [positionAnimation, scaleAnimation, alphaAnimation]
        group.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        group.repeatCount = Float.infinity
        group.duration = 1.3
        
        shapeView1.layer.add(group, forKey: "basic1")
        group.timeOffset = 0.43
        shapeView2.layer.add(group, forKey: "basic2")
        group.timeOffset = 0.86
        shapeView3.layer.add(group, forKey: "basic3")
        
        let position2Animation = CAKeyframeAnimation()
        position2Animation.keyPath = "position.x"
        position2Animation.duration = 2.4
        position2Animation.values = [0, 100, 120, 220]
        position2Animation.keyTimes = [0, 0.35, 0.65, 1]
        position2Animation.timingFunctions = [
            CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut),
            CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear),
            CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)]
        position2Animation.isAdditive = true
        
        let alpha2Animation = CAKeyframeAnimation()
        alpha2Animation.keyPath = "opacity"
        alpha2Animation.fillMode = CAMediaTimingFillMode.forwards
        alpha2Animation.isRemovedOnCompletion = false
        alpha2Animation.duration = 2.4
        alpha2Animation.values = [0, 1, 1, 1, 0]
        alpha2Animation.keyTimes = [0, (0.5 / 6.0), (3 / 6.0), (5.5 / 6.0), 1] as [NSNumber]
        
        let group2 = CAAnimationGroup()
        group2.animations = [position2Animation, alpha2Animation]
        group2.repeatCount = Float.infinity
        group2.duration = 3.2
        
        shapeView4.layer.add(group2, forKey: nil)
        group2.timeOffset = 0.2
        shapeView5.layer.add(group2, forKey: nil)
        group2.timeOffset = 0.4
        shapeView6.layer.add(group2, forKey: nil)
        group2.timeOffset = 0.6
        shapeView7.layer.add(group2, forKey: nil)
        group2.timeOffset = 0.8
        shapeView8.layer.add(group2, forKey: nil)
        
        indicatorView.startAnimating()
    }
}
