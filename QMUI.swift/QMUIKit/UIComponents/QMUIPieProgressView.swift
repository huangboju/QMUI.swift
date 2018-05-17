//
//  QMUIPieProgressView.swift
//  QMUI.swift
//
//  Created by 黄伯驹 on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

/**
 * 饼状进度条控件
 *
 * 使用 `tintColor` 更改进度条饼状部分和边框部分的颜色
 *
 * 使用 `backgroundColor` 更改圆形背景色
 *
 * 通过 `UIControlEventValueChanged` 来监听进度变化
 */
class QMUIPieProgressView: UIControl {

    /**
     进度动画的时长，默认为 0.5
     */
    @IBInspectable
    var progressAnimationDuration: CFTimeInterval = 0.5 {
        didSet {
            progressLayer?.progressAnimationDuration = progressAnimationDuration
        }
    }

    /**
     当前进度值，默认为 0.0。调用 `setProgress:` 相当于调用 `setProgress:animated:NO`
     */
    @IBInspectable
    var progress: Float {
        get {
            return _progress
        }
        set {
            setProgress(progress, animated: false)
        }
    }
    private var _progress: Float = 0

    override class var layerClass: AnyClass {
        return QMUIPieProgressLayer.self
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColorClear
        tintColor = UIColorBlue

        didInitialized()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // 从 xib 初始化的话，在 IB 里设置了 tintColor 也不会触发 tintColorDidChange，所以这里手动调用一下
        tintColorDidChange()
        didInitialized()
    }

    private func didInitialized() {
        progress = 0.0
        progressAnimationDuration = 0.5

        layer.contentsScale = ScreenScale // 要显示指定一个倍数
        layer.borderWidth = 1.0
        layer.setNeedsDisplay()
    }

    /**
     修改当前的进度，会触发 UIControlEventValueChanged 事件
     
     @param progress 当前的进度，取值范围 [0.0-1.0]
     @param animated 是否以动画来表现
     */
    func setProgress(_ progress: Float, animated: Bool) {
        _progress = max(0.0, min(1.0, progress))
        let layer = self.layer as? QMUIPieProgressLayer
        layer?.shouldChangeProgressWithAnimation = animated
        layer?.progress = progress

        sendActions(for: .valueChanged)
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()
        progressLayer?.fillColor = tintColor
        progressLayer?.borderColor = tintColor.cgColor
    }

    private var progressLayer: QMUIPieProgressLayer? {
        return layer as? QMUIPieProgressLayer
    }
}

class QMUIPieProgressLayer: CALayer {
    @NSManaged var fillColor: UIColor?
    @NSManaged var progress: Float
    var progressAnimationDuration: CFTimeInterval = 0
    var shouldChangeProgressWithAnimation = true // default is YES

    override class func needsDisplay(forKey key: String) -> Bool {
        return key == "progress" || super.needsDisplay(forKey: key)
    }

    override func action(forKey event: String) -> CAAction? {
        if event == "progress" && shouldChangeProgressWithAnimation {
            let animation = CABasicAnimation(keyPath: event)
            animation.fromValue = presentation()?.value(forKey: event)
            animation.duration = progressAnimationDuration
            return animation
        }
        return super.action(forKey: event)
    }

    override func draw(in ctx: CGContext) {
        if bounds.isEmpty {
            return
        }

        // 绘制扇形进度区域
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(center.x, center.y)
        let startAngle = -Float.pi / 2
        let endAngle = .pi * 2 * progress + startAngle
        if let cgColor = fillColor?.cgColor {
            ctx.setFillColor(cgColor)
        }
        ctx.move(to: center)
        ctx.addArc(center: center, radius: radius, startAngle: CGFloat(startAngle), endAngle: CGFloat(endAngle), clockwise: false)
        ctx.closePath()
        ctx.fillPath()

        super.draw(in: ctx)
    }

    override var frame: CGRect {
        didSet {
            cornerRadius = flat(frame.height / 2)
        }
    }
}
