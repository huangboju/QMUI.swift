//
//  QMUIMarqueeLabel.swift
//  QMUI.swift
//
//  Created by 黄伯驹 on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

/**
 *  简易的跑马灯 label 控件，在文字超过 label 可视区域时会自动开启跑马灯效果展示文字，文字滚动时是首尾连接的效果（参考播放音乐时系统锁屏界面顶部的音乐标题）。
 *  @warning lineBreakMode 默认为 NSLineBreakByClipping（UILabel 默认值为 NSLineBreakByTruncatingTail）。
 *  @warning textAlignment 暂不支持 NSTextAlignmentJustified 和 NSTextAlignmentNatural。
 *  @warning 会忽略 numberOfLines 属性，强制以 1 来展示。
 */
class QMUIMarqueeLabel: UILabel {

    /// 控制滚动的速度，1 表示一帧滚动 1pt，10 表示一帧滚动 10pt，默认为 .5，与系统一致。
    var speed: CGFloat = 0.5

    /// 当文字第一次显示在界面上，以及重复滚动到开头时都要停顿一下，这个属性控制停顿的时长，默认为 2.5（也是与系统一致），单位为秒。
    var pauseDurationWhenMoveToEdge: TimeInterval = 2.5

    /// 用于控制首尾连接的文字之间的间距，默认为 40pt。
    var spacingBetweenHeadToTail: CGFloat = 40

    /**
     *  自动判断 label 的 frame 是否超出当前的 UIWindow 可视范围，超出则自动停止动画。默认为 YES。
     *  @warning 某些场景并无法触发这个自动检测（例如直接调整 label.superview 的 frame 而不是 label 自身的 frame），这种情况暂不处理。
     */
    var automaticallyValidateVisibleFrame = true

    /// 在文字滚动到左右边缘时，是否要显示一个阴影渐变遮罩，默认为 true。
    var shouldFadeAtEdge = true {
        didSet {
            if shouldFadeAtEdge {
                initFadeLayersIfNeeded()
            }
            updateFadeLayersHidden()
        }
    }

    /// 渐变遮罩的宽度，默认为 20。
    var fadeWidth: CGFloat = 20

    /// 渐变遮罩外边缘的颜色，请使用带 Alpha 通道的颜色
    var fadeStartColor: UIColor? = UIColor(r: 255, g: 255, b: 255) {
        didSet {
            updateFadeLayerColors()
        }
    }

    /// 渐变遮罩内边缘的颜色，一般是 fadeStartColor 的 alpha 通道为 0 的色值
    var fadeEndColor: UIColor? = UIColor(r: 255, g: 255, b: 255, a: 1) {
        didSet {
            updateFadeLayerColors()
        }
    }

    /// YES 表示文字会在打开 shouldFadeAtEdge 的情况下，从左边的渐隐区域之后显示，NO 表示不管有没有打开 shouldFadeAtEdge，都会从 label 的边缘开始显示。默认为 NO。
    /// @note 如果文字宽度本身就没超过 label 宽度（也即无需滚动），此时必定不会显示渐隐，则这个属性不会影响文字的显示位置。
    var textStartAfterFade = false

    private var displayLink: CADisplayLink?
    private var offsetX: CGFloat = 0 {
        didSet {
            updateFadeLayersHidden()
        }
    }

    private var textWidth: CGFloat = 0

    private var fadeLeftLayer: CAGradientLayer?
    private var fadeRightLayer: CAGradientLayer?

    private var isFirstDisplay: Bool = true

    /// 绘制文本时重复绘制的次数，用于实现首尾连接的滚动效果，1 表示不首尾连接，大于 1 表示首尾连接。
    private var textRepeatCount: Int = 2

    override init(frame: CGRect) {
        super.init(frame: frame)

        lineBreakMode = .byClipping
        clipsToBounds = true // 显示非英文字符时，滚动的时候字符会稍微露出两端，所以这里直接裁剪掉
    }

    deinit {
        displayLink?.invalidate()
        displayLink = nil
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil {
            displayLink = CADisplayLink(target: self, selector: #selector(handleDisplayLink))
            displayLink?.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
        } else {
            displayLink?.invalidate()
            displayLink = nil
        }
        offsetX = 0
        displayLink?.isPaused = !shouldPlayDisplayLink
    }

    override var text: String? {
        didSet {
            offsetX = 0
            textWidth = sizeThatFits(CGSize(width: .max, height: .max)).width
            displayLink?.isPaused = !shouldPlayDisplayLink
        }
    }

    override var attributedText: NSAttributedString? {
        didSet {
            offsetX = 0
            textWidth = sizeThatFits(CGSize(width: .max, height: .max)).width
            displayLink?.isPaused = !shouldPlayDisplayLink
        }
    }

    override var frame: CGRect {
        didSet {
            let isSizeChanged = frame.size != oldValue.size
            if isSizeChanged {
                offsetX = 0
                displayLink?.isPaused = !shouldPlayDisplayLink
            }
        }
    }

    override func drawText(in rect: CGRect) {
        var textInitialX: CGFloat = 0
        if textAlignment == .left {
            textInitialX = 0
        } else if textAlignment == .center {
            textInitialX = fmax(0, bounds.width.center(textWidth))
        } else if textAlignment == .right {
            textInitialX = fmax(0, bounds.width - textWidth)
        }

        // 考虑渐变遮罩的偏移
        var textOffsetXByFade: CGFloat = 0
        let shouldTextStartAfterFade = shouldFadeAtEdge && textStartAfterFade && textWidth > bounds.width
        if shouldTextStartAfterFade && textInitialX < fadeWidth {
            textOffsetXByFade = fadeWidth
        }
        textInitialX += textOffsetXByFade

        for i in 0 ..< textRepeatCountConsiderTextWidth {
            attributedText?.draw(in: CGRect(x: offsetX + (textWidth + spacingBetweenHeadToTail) * CGFloat(i) + textInitialX, y: 0, width: textWidth, height: rect.height))
        }
        
        // 自定义绘制就不需要调用 super
        //    [super drawTextInRect:rectToDrawAfterAnimated];
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let fadeLeftLayer = fadeLeftLayer {
            fadeLeftLayer.frame = CGSize(width: fadeWidth, height: bounds.height).rect
            layer.qmui_bringSublayerToFront(fadeLeftLayer) // 显示非英文字符时，UILabel 内部会额外多出一层 layer 盖住了这里的 fadeLayer，所以要手动提到最前面
        }

        if let fadeRightLayer = fadeRightLayer {
            fadeRightLayer.frame = CGRect(x: bounds.width - fadeWidth, y: 0, width: fadeWidth, height: bounds.height)
            layer.qmui_bringSublayerToFront(fadeRightLayer) // 显示非英文字符时，UILabel 内部会额外多出一层 layer 盖住了这里的 fadeLayer，所以要手动提到最前面
        }
    }

    private var textRepeatCountConsiderTextWidth: Int {
        if textWidth < bounds.width {
            return 1
        }
        return textRepeatCount
    }

    @objc func handleDisplayLink(_ displayLink: CADisplayLink) {
        if offsetX == 0 {
            displayLink.isPaused = true
            setNeedsDisplay()

            let delay = (isFirstDisplay || textRepeatCount <= 1) ? pauseDurationWhenMoveToEdge : 0

            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                displayLink.isPaused = !self.shouldPlayDisplayLink
                if !displayLink.isPaused {
                    self.offsetX -= self.speed
                }
            })

            if delay > 0 && textRepeatCount > 1 {
                isFirstDisplay = false
            }
            return
        }

        offsetX -= speed
        setNeedsDisplay()

        if -offsetX >= textWidth + (textRepeatCountConsiderTextWidth > 1 ? spacingBetweenHeadToTail : 0) {
            displayLink.isPaused = true
            let delay = textRepeatCount > 1 ? pauseDurationWhenMoveToEdge : 0
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                self.offsetX = 0
                self.handleDisplayLink(displayLink)
            })
        }
    }

    private var shouldPlayDisplayLink: Bool {
        let result = window != nil && bounds.width > 0 && textWidth > (bounds.width - ((shouldFadeAtEdge && textStartAfterFade) ? fadeWidth : 0))

        // 如果 label.frame 在 window 可视区域之外，也视为不可见，暂停掉 displayLink
        if result && automaticallyValidateVisibleFrame {
            let rectInWindow = window?.convert(frame, from: superview) ?? .zero
            let bounds = window?.bounds ?? .zero
            if !bounds.intersects(rectInWindow) {
                return false
            }
        }

        return result
    }

    private func updateFadeLayerColors() {
        func setColor(with layer: CAGradientLayer?) {
            guard let layer = layer else {
                return
            }
            if let fadeStartColor = fadeStartColor, let fadeEndColor = fadeEndColor {
                layer.colors = [
                    fadeStartColor.cgColor,
                    fadeEndColor.cgColor,
                ]
            } else {
                layer.colors = nil
            }
        }

        setColor(with: fadeLeftLayer)
        setColor(with: fadeRightLayer)
    }

    private func updateFadeLayersHidden() {
        if fadeLeftLayer == nil || fadeRightLayer == nil {
            return
        }

        let shouldShowFadeLeftLayer = shouldFadeAtEdge && (offsetX < 0 || (offsetX == 0 && !isFirstDisplay))
        fadeLeftLayer?.isHidden = !shouldShowFadeLeftLayer

        let shouldShowFadeRightLayer = shouldFadeAtEdge && (textWidth > bounds.width && offsetX != textWidth - bounds.width)
        fadeRightLayer?.isHidden = !shouldShowFadeRightLayer
    }

    private func initFadeLayersIfNeeded() {
        if fadeLeftLayer == nil {
            fadeLeftLayer = CAGradientLayer() // 请保留自带的 hidden 动画
            fadeLeftLayer?.startPoint = CGPoint(x: 0, y: 0.5)
            fadeLeftLayer?.endPoint = CGPoint(x: 1, y: 0.5)
            layer.addSublayer(fadeLeftLayer!)
            setNeedsLayout()
        }

        if fadeRightLayer == nil {
            fadeRightLayer = CAGradientLayer() // 请保留自带的 hidden 动画
            fadeRightLayer?.startPoint = CGPoint(x: 1, y: 0.5)
            fadeRightLayer?.endPoint = CGPoint(x: 0, y: 0.5)
            layer.addSublayer(fadeRightLayer!)
            setNeedsLayout()
        }

        updateFadeLayerColors()
    }

    // MARK: - Superclass
    override var numberOfLines: Int {
        didSet {
            numberOfLines = 1
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - ReusableView
/// 如果在可复用的 UIView 里使用（例如 UITableViewCell、UICollectionViewCell），由于 UIView 可能重复被使用，因此需要在某些显示/隐藏的时机去手动开启/关闭 label 的动画。如果在普通的 UIView 里使用则无需关注这一部分的代码。
extension QMUIMarqueeLabel {
    /**
     *  尝试开启 label 的滚动动画
     *  @return 是否成功开启
     */
    var requestToStartAnimation: Bool {
        automaticallyValidateVisibleFrame = false
        if shouldPlayDisplayLink {
            displayLink?.isPaused = false
        }
        return shouldPlayDisplayLink
    }

    /**
     *  尝试停止 label 的滚动动画
     *  @return 是否成功停止
     */
    var requestToStopAnimation: Bool {
        displayLink?.isPaused = true
        return true
    }
}
