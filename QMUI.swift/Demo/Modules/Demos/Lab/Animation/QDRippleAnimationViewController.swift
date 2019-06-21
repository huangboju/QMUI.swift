//
//  QDRippleAnimationViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/5/21.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

private let RippleAnimationAvatarSize: CGSize = CGSize(width: 100, height: 100)
private let RippleAnimationExpandSizeValue: CGFloat = 40
private let RippleAnimationDuration: CFTimeInterval = 2
private let RippleAnimationLineWidth: CGFloat = 1

class QDRippleAnimationViewController: QDCommonViewController {

    private var scrollView: UIScrollView!
    
    private var textLabel: UILabel!
    
    private var avatarWrapView1: UIView!
    private var avatarImageView1: UIImageView!
    private var avatarWrapView2: UIView!
    private var avatarImageView2: UIImageView!
    private var initPath: UIBezierPath!
    private var finalPath: UIBezierPath!
    
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
        
        textLabel = UILabel()
        textLabel.numberOfLines = 0
        textLabel.textAlignment = .center
        textLabel.textColor = UIColorGray4
        textLabel.font = UIFontMake(16)
        textLabel.text = "第一个动画使用CAAnimationGroup来实现，第二个动画使用CAReplicatorLayer来实现。"
        scrollView.addSubview(textLabel)
        
        avatarWrapView1 = UIView()
        scrollView.addSubview(avatarWrapView1)
        
        avatarImageView1 = UIImageView(image: UIImageMake("image0"))
        avatarImageView1.contentMode = .scaleAspectFill;
        avatarImageView1.clipsToBounds = true
        avatarWrapView1.addSubview(avatarImageView1)
        
        avatarWrapView2 = UIView()
        scrollView.addSubview(avatarWrapView2)
        
        avatarImageView2 = UIImageView(image: UIImageMake("image0"))
        avatarImageView2.contentMode = .scaleAspectFill;
        avatarImageView2.clipsToBounds = true
        avatarWrapView2.addSubview(avatarImageView2)
        
        avatarImageView1.layer.cornerRadius = RippleAnimationAvatarSize.height / 2
        avatarImageView2.layer.cornerRadius = RippleAnimationAvatarSize.height / 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        initPath = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: RippleAnimationAvatarSize.width, height: RippleAnimationAvatarSize.height).insetBy(dx: RippleAnimationLineWidth, dy: RippleAnimationLineWidth))
        finalPath = UIBezierPath(ovalIn: CGRect(x: -RippleAnimationExpandSizeValue, y: -RippleAnimationExpandSizeValue, width: RippleAnimationAvatarSize.width + RippleAnimationExpandSizeValue * 2, height: RippleAnimationAvatarSize.height + RippleAnimationExpandSizeValue * 2).insetBy(dx: RippleAnimationLineWidth, dy: RippleAnimationLineWidth))
        
        beginAnimation()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = view.bounds
        let insetLeft: CGFloat = 20
        let labelWidth: CGFloat = view.bounds.width - insetLeft * 2
        let labelSize = textLabel.sizeThatFits(CGSize(width: labelWidth, height: CGFloat.greatestFiniteMagnitude))
        textLabel.frame = CGRectFlat(insetLeft, 40, labelWidth, labelSize.height)
        
        avatarWrapView1.frame = CGRect(x: view.bounds.width.center(RippleAnimationAvatarSize.width), y: textLabel.frame.maxY + 70, width: RippleAnimationAvatarSize.width, height: RippleAnimationAvatarSize.height)
        avatarWrapView2.frame = CGRect(x: avatarWrapView1.frame.minX, y: avatarWrapView1.frame.maxY + 100, width: RippleAnimationAvatarSize.width, height: RippleAnimationAvatarSize.height)
        avatarImageView1.frame = avatarWrapView1.bounds
        avatarImageView2.frame = avatarWrapView2.bounds
        
        scrollView.contentSize = CGSize(width: scrollView.bounds.width, height: avatarWrapView2.frame.maxY + 50)
    }

    private func beginAnimation() {
        animationAvatar(in: avatarWrapView1, animated: true)
        avatarWrapView1.bringSubviewToFront(avatarImageView1)
        animationAvatar(in: avatarWrapView2, animated: true)
        avatarWrapView2.bringSubviewToFront(avatarImageView2)
    }
    
    private func animationAvatar(in view: UIView, animated: Bool) {
        var layers = [CAShapeLayer]()
        for layer in view.layer.sublayers ?? [] {
            if let layer = layer as? CAShapeLayer {
                layers.append(layer)
                layer.isHidden = true
            }
        }
        
        for layer in layers {
            layer.removeFromSuperlayer()
        }
        
        if (!animated) {
            return
        }
        
        let layer1 = animationLayer(with: initPath)
        layer1.frame = CGRect(x: 0, y: 0, width: RippleAnimationAvatarSize.width, height: RippleAnimationAvatarSize.height)
        view.layer.addSublayer(layer1)
        
        let layer2 = animationLayer(with: initPath)
        layer2.frame = layer1.frame
        view.layer.addSublayer(layer2)
        
        let layer3 = animationLayer(with: initPath)
        layer3.frame = layer1.frame
        view.layer.addSublayer(layer3)
        
        let pathAnimation = CABasicAnimation(keyPath: "path")
        pathAnimation.fromValue = initPath.cgPath
        pathAnimation.toValue = finalPath.cgPath
        
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 1
        opacityAnimation.toValue = 0
        
        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [pathAnimation, opacityAnimation]
        groupAnimation.duration = RippleAnimationDuration
        groupAnimation.repeatCount = Float.infinity
        
        layer1.add(groupAnimation, forKey: nil)
        groupAnimation.beginTime = CACurrentMediaTime() + RippleAnimationDuration / 3
        layer2.add(groupAnimation, forKey: nil)
        groupAnimation.beginTime = CACurrentMediaTime() + 2 * RippleAnimationDuration / 3
        layer3.add(groupAnimation, forKey: nil)
    }
    
    private func animationReplicatorAvatar(in view: UIView, animated: Bool) {
        var layers = [CAReplicatorLayer]()
        for layer in view.layer.sublayers ?? [] {
            if let layer = layer as? CAReplicatorLayer {
                layers.append(layer)
                layer.isHidden = true
            }
        }
        
        for layer in layers {
            layer.removeFromSuperlayer()
        }
        
        if (!animated) {
            return
        }
        
        let replicatorLayer = CAReplicatorLayer()
        replicatorLayer.instanceCount = 3
        replicatorLayer.instanceDelay = RippleAnimationDuration / 3
        replicatorLayer.backgroundColor = UIColorClear.cgColor
        view.layer.addSublayer(replicatorLayer)
        
        let layer = animationLayer(with: initPath)
        layer.frame = CGRect(x: 0, y: 0, width: RippleAnimationAvatarSize.width, height: RippleAnimationAvatarSize.height)
        replicatorLayer.addSublayer(layer)
        
        let pathAnimation = CABasicAnimation(keyPath: "path")
        pathAnimation.fromValue = initPath.cgPath
        pathAnimation.toValue = finalPath.cgPath
        
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 1
        opacityAnimation.toValue = 0
        
        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [pathAnimation, opacityAnimation]
        groupAnimation.duration = RippleAnimationDuration
        groupAnimation.repeatCount = Float.infinity
        
        layer.add(groupAnimation, forKey: nil)
    }
    
    private func animationLayer(with path: UIBezierPath) -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.strokeColor = UIColorBlue.cgColor
        layer.fillColor = UIColorClear.cgColor
        layer.lineWidth = RippleAnimationLineWidth
        return layer
    }
    
    @objc private func handleWillEnterForeground(_ notification: NSNotification) {
        beginAnimation()
    }
}
