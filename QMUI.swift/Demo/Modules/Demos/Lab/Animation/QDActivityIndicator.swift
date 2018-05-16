//
//  QDActivityIndicator.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/5/15.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

let QDActivityIndicatorColorDefault = UIColorSeparator

private let QDActivityIndicatorAnimationKey = "lineAnimations"
private let AnimationDuration: CGFloat = 1.5

enum QDActivityIndicatorStyle {
    case normal // 默认大小
    case small // 小一点的，用于想法圈的下拉刷新
}


class QDActivityIndicator: UIView, CAAnimationDelegate {
    
    private(set) var style: QDActivityIndicatorStyle!

    var hidesWhenStopped: Bool = true
    
    private var _line1: CALayer!
    
    private var _line2: CALayer!
    
    private var _line3: CALayer!
    
    private var _line4: CALayer!
    
    private var _line5: CALayer!
    
    private var _line6: CALayer!
    
    private var _lines: [CALayer]!
    
    private var _originImage: UIImage!
    
    private var _image: UIImage!
    
    private var _currentOffsetTime: TimeInterval = 0
    
    private var _isStartAnimating: Bool  = false
    
    convenience init() {
        self.init(frame: .zero)
        self.style = .normal
    }
    
    convenience init(style: QDActivityIndicatorStyle) {
        self.init(frame: .zero)
        self.style = style

        _originImage = style == .normal ? UIImageMake("loading") : UIImageMake("loading_small")
        _image = _originImage
        
        sizeToFit()
        
        _line1 = CALayer()
        _line2 = CALayer()
        _line3 = CALayer()
        _line4 = CALayer()
        _line5 = CALayer()
        _line6 = CALayer()
        
        _lines = [_line1, _line2, _line3, _line4, _line5, _line6]
        
        _lines.forEach {
            layer.addSublayer($0)
        }
        
        backgroundColor = UIColorClear
        tintColor = UIColorGray
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var tintColor: UIColor! {
        didSet {
            _image = _originImage.qmui_image(tintColor: tintColor)
            _lines.forEach {
                $0.backgroundColor = tintColor.cgColor
            }
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        _image.draw(in: rect)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return _originImage.size
    }
}

extension QDActivityIndicator: QMUIEmptyViewLoadingViewProtocol {
    
    func startAnimating() {
        _isStartAnimating = true
        for (i, line) in _lines.enumerated() {
            line.speed = 1
            line.removeAnimation(forKey: QDActivityIndicatorAnimationKey)
            line.add(groupAnimation(with: i), forKey: QDActivityIndicatorAnimationKey)
        }
        
    }
    
    private func groupAnimation(with index: Int) -> CAAnimationGroup {
        if hidesWhenStopped {
            isHidden = false
        }
        
        var lineBaseY: CGFloat = 0 // 第一条线的顶部y值
        var lineSpacing: CGFloat = 0 // 线与线在垂直方向上的间距
        var lineWidth: CGFloat = 0 // 横线的宽度
        var lineHeight: CGFloat = 0 // 横线的高度
        
        if style == .normal {
            lineBaseY = 12
            lineSpacing = 7
            lineWidth = 15
            lineHeight = 1 + PixelOne
        } else {
            lineBaseY = 9
            lineSpacing = 5
            lineWidth = 11
            lineHeight = 1
        }
        
        // 关键帧对应的时间点（0.0-1.0），分别是从无到有、从有到完整显示、完整显示状态hold住、开始往右边缩小、缩小到0、0hold住
        let keyTimesForLines = [
            [0.0, 0.0, (15.0 / 90.0), (54.0 / 90.0), (70.0 / 90.0), 1.0],
            [0.0, (7.0 / 90.0), (21.0 / 90.0), (50.0 / 90.0), (65.0 / 90.0), 1.0],
            [0.0, (10.0 / 90.0), (25.0 / 90.0), (45.0 / 90.0), (60.0 / 90.0), 1.0],
            [0.0, (10.0 / 90.0), (25.0 / 90.0), (65.0 / 90.0), (80.0 / 90.0), 1.0],
            [0.0, (15.0 / 90.0), (30.0 / 90.0), (58.0 / 90.0), (75.0 / 90.0), 1.0],
            [0.0, (20.0 / 90.0), (35.0 / 90.0), (54.0 / 90.0), (70.0 / 90.0), 1.0],
        ]
        
        let line = _lines[index]
        var x = (bounds.width / 2 - lineWidth) / 2 + bounds.width / 2 * (CGFloat(index) / 3)
        if index / 3 <= 0 {
            x += 1
        }
        x = floor(x)
        let y = floor(lineBaseY + (lineHeight + lineSpacing) * CGFloat(index % 3))
        line.frame = CGRect(x: x, y: y, width: 0, height: lineHeight)
        
        let keyTimes = keyTimesForLines[index]
        
        let widthAnimation = CAKeyframeAnimation(keyPath: "bounds")
        widthAnimation.values = [
            CGRect(x: 0, y: 0, width: 0, height: lineHeight),
            CGRect(x: 0, y: 0, width: 0, height: lineHeight),
            CGRect(x: 0, y: 0, width: lineWidth, height: lineHeight),
            CGRect(x: 0, y: 0, width: lineWidth, height: lineHeight),
            CGRect(x: 0, y: 0, width: 0, height: lineHeight),
            CGRect(x: 0, y: 0, width: 0, height: lineHeight)]
        widthAnimation.keyTimes = keyTimes as [NSNumber]
        
        let positionAnimation = CAKeyframeAnimation(keyPath: "position")
        positionAnimation.values = [
            CGPoint(x: x, y: y),
            CGPoint(x: x, y: y),
            CGPoint(x: x + lineWidth / 2, y: y),
            CGPoint(x: x + lineWidth / 2, y: y),
            CGPoint(x: x + lineWidth, y: y),
            CGPoint(x: x + lineWidth, y: y)]
        positionAnimation.keyTimes = keyTimes as [NSNumber]
        
        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [widthAnimation, positionAnimation]
        groupAnimation.duration = CFTimeInterval(AnimationDuration)
        groupAnimation.repeatCount = Float.infinity
        if _currentOffsetTime > 0 {
            groupAnimation.timeOffset = _currentOffsetTime
        }
        groupAnimation.delegate = self
        
        return groupAnimation
    }
    
    /**
     * 手动控制动画进度（也即配合下拉刷新使用时下拉过程的动画）
     * @param currentOffsetY 当前列表的contentOffset，已经除去contentInset.top的影响，所以0就表示列表处于顶部
     * @param distanceForStartRefresh 整个下拉刷新要拉动多少距离才会真正触发下拉刷新，这个距离也是manualAnimation刚好完成的位置
     * @param distanceForCompleteAnimation 下拉到开始做动画的时候，一直到动画完全走完，这个过程要经历的距离。值越大表示动画的步进越小，值越小表示步进越大，也即拉一点点就能让动画从头走到尾了
     * @warning distanceForCompleteAnimation的值要比distanceForStartRefresh小
     */
    func manualAnimation(with currentOffsetY: CGFloat, distanceForStartRefresh: CGFloat, distanceForCompleteAnimation: CGFloat) {
        if _isStartAnimating {
            return
        }
        
        let beginAnimationOffset = -(distanceForStartRefresh - distanceForCompleteAnimation)
        if currentOffsetY > beginAnimationOffset || currentOffsetY < -distanceForStartRefresh {
            // 还没到开始动画的临界点，或者已经超过完整走完动画的距离，则什么都不用做
            //        NSLog(@"还没到，继续拉！！！currentOffsetY = %.2f, beginAnimationOffset = %.2f", currentOffsetY, beginAnimationOffset);
            return
        }
        
        print("开始了！！！currentOffsetY = \(currentOffsetY), beginAnimationOffset = \(beginAnimationOffset)")
        for (i, line) in _lines.enumerated() {
            line.speed = 0
            if line.animation(forKey: QDActivityIndicatorAnimationKey) == nil {
                line.add(groupAnimation(with: i), forKey: QDActivityIndicatorAnimationKey)
            }
            _currentOffsetTime = TimeInterval(((-currentOffsetY + beginAnimationOffset) / distanceForCompleteAnimation) * AnimationDuration * 0.4) // timeOffset为0.6时loading刚好走完一轮，所以这里按总时间 * 0.4，从而保证loading停靠在顶部时，timeOffset刚好为0.6
            
            print("_currentOffsetTime = \(_currentOffsetTime), currentOffsetY = \(currentOffsetY), distanceForStartRefresh = \(distanceForStartRefresh), distanceForCompleteAnimation = \(distanceForCompleteAnimation)")
            line.timeOffset = _currentOffsetTime
        }
    }
    
    func stopAnimating() {
        _isStartAnimating = false
        _lines.forEach {
            self._currentOffsetTime = 0
            $0.removeAnimation(forKey: QDActivityIndicatorAnimationKey)
        }
        if hidesWhenStopped {
            isHidden = true
        }
    }
    
    var isAnimating: Bool {
        //这里偶然会返回NO，打印_line1.animationKeys会为nil，动画确实能出现，具体原因找不到,暂且先返回_isStartAnimating
        //return [_line1 animationForKey:QDActivityIndicatorAnimationKey] != nil;
        return _isStartAnimating
    }
}
