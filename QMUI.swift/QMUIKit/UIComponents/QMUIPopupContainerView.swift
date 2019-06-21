//
//  QMUIPopupContainerView.swift
//  QMUI.swift
//
//  Created by 黄伯驹 on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

enum QMUIPopupContainerViewLayoutDirection {
    case above
    case below
}

/**
 * 带箭头的小tips浮层，自带 imageView 和 textLabel，可展示简单的图文信息。
 * QMUIPopupContainerView 支持以两种方式显示在界面上：
 * 1. 添加到某个 UIView 上（适合于 viewController 切换时浮层跟着一起切换的场景），这种场景只能手动隐藏浮层。
 * 2. 在 QMUIPopupContainerView 自带的 UIWindow 里显示（适合于用完就消失的场景，不要涉及界面切换），这种场景支持点击空白地方自动隐藏浮层。
 *
 * 使用步骤：
 * 1. 调用 init 方法初始化。
 * 2. 选择一种显示方式：
 * 2.1 如果要添加到某个 UIView 上，则先设置浮层 hidden = YES，然后调用 addSubview: 把浮层添加到目标 UIView 上。
 * 2.2 如果是轻量的场景用完即走，则 init 完浮层即可，无需设置 hidden，也无需调用 addSubview:，在后面第 4 步里会自动把浮层添加到 UIWindow 上显示出来。
 * 3. 在适当的时机（例如 layoutSubviews: 或 viewDidLayoutSubviews: 或在 show 之前）调用 layoutWithTargetView: 让浮层参考目标 view 布局，或者调用 layoutWithTargetRectInScreenCoordinate: 让浮层参考基于屏幕坐标系里的一个 rect 来布局。
 * 4. 调用 showWithAnimated: 或 showWithAnimated:completion: 显示浮层。
 * 5. 调用 hideWithAnimated: 或 hideWithAnimated:completion: 隐藏浮层。
 *
 * @warning 如果使用方法 2.2，并且没有打开 automaticallyHidesWhenUserTap 属性，则记得在适当的时机（例如 viewWillDisappear:）隐藏浮层。
 *
 * 如果默认功能无法满足需求，可继承它重写一个子类，继承要点：
 * 1. 初始化时要做的事情请放在 didInitialized 里。
 * 2. 所有 subviews 请加到 contentView 上。
 * 3. 通过重写 sizeThatFitsInContentView:，在里面返回当前 subviews 的大小，控件最终会被布局为这个大小。
 * 4. 在 layoutSubviews: 里，所有 subviews 请相对于 contentView 布局。
 */
class QMUIPopupContainerView: UIControl {
    
    var backgroundLayer: CAShapeLayer!

    var arrowMinX: CGFloat = 0

    var isDebug: Bool = false

    /// 在浮层显示时，点击空白地方是否要自动隐藏浮层，仅在用方法 2 显示时有效。
    /// 默认为 false，也即需要手动调用代码去隐藏浮层。
    var automaticallyHidesWhenUserTap: Bool = false

    /// 所有subview都应该添加到contentView上，默认contentView.userInteractionEnabled = NO，需要事件操作时自行打开
    private(set) var contentView: UIView!

    /// 预提供的UIImageView，默认为nil，调用到的时候才初始化
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        contentView.addSubview(imageView)
        return imageView
    }()

    /// 预提供的UILabel，默认为nil，调用到的时候才初始化。默认支持多行。
    lazy var textLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.font = UIFontMake(12)
        textLabel.textColor = UIColorBlack
        textLabel.numberOfLines = 0
        contentView.addSubview(textLabel)
        return textLabel
    }()

    /// 圆角矩形气泡内的padding（不包括三角箭头），默认是(8, 8, 8, 8)
    var contentEdgeInsets: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

    /// 调整imageView的位置，默认为UIEdgeInsetsZero。top/left正值表示往下/右方偏移，bottom/right仅在对应位置存在下一个子View时生效（例如只有同时存在imageView和textLabel时，imageEdgeInsets.right才会生效）。
    var imageEdgeInsets: UIEdgeInsets = .zero

    /// 调整textLabel的位置，默认为UIEdgeInsetsZero。top/left/bottom/right的作用同<i>imageEdgeInsets</i>
    var textEdgeInsets: UIEdgeInsets = .zero

    /// 三角箭头的大小，默认为 CGSizeMake(18, 9)
    var arrowSize = CGSize(width: 18, height: 9)

    /// 最大宽度（指整个控件的宽度，而不是contentView部分），默认为CGFLOAT_MAX
    var maximumWidth: CGFloat = 0

    /// 最小宽度（指整个控件的宽度，而不是contentView部分），默认为0
    var minimumWidth: CGFloat = 0

    /// 最大高度（指整个控件的高度，而不是contentView部分），默认为CGFLOAT_MAX
    var maximumHeight: CGFloat = .infinity

    /// 最小高度（指整个控件的高度，而不是contentView部分），默认为0
    var minimumHeight: CGFloat = 0

    /// 计算布局时期望的默认位置，默认为QMUIPopupContainerViewLayoutDirectionAbove，也即在目标的上方
    var preferLayoutDirection: QMUIPopupContainerViewLayoutDirection = .above

    /// 最终的布局方向（preferLayoutDirection只是期望的方向，但有可能那个方向已经没有剩余空间可摆放控件了，所以会自动变换）
    private(set) var currentLayoutDirection: QMUIPopupContainerViewLayoutDirection = .above

    /// 最终布局时箭头距离目标边缘的距离，默认为5
    var distanceBetweenTargetRect: CGFloat = 5

    /// 最终布局时与父节点的边缘的临界点，默认为(10, 10, 10, 10)
    var safetyMarginsOfSuperview = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

    override var backgroundColor: UIColor? {
        get {
            return super.backgroundColor
        }
        set {
            super.backgroundColor = UIColorClear
            backgroundLayer.fillColor = newValue?.cgColor
        }
    }

    var highlightedBackgroundColor: UIColor?

    /// 当使用方法 2 显示并且打开了 automaticallyHidesWhenUserTap 时，可修改背景遮罩的颜色，默认为 UIColorMask，若非使用方法 2，或者没有打开 automaticallyHidesWhenUserTap，则背景遮罩为透明（可视为不存在背景遮罩）
    var maskViewBackgroundColor: UIColor? {
        didSet {
            if let popupWindow = popupWindow {
                popupWindow.rootViewController?.view.backgroundColor = maskViewBackgroundColor
            }
        }
    }

    var shadowColor: UIColor? {
        didSet {
            backgroundLayer.shadowColor = shadowColor?.cgColor
        }
    }

    var borderColor: UIColor? {
        didSet {
            backgroundLayer.strokeColor = borderColor?.cgColor
        }
    }

    var borderWidth: CGFloat = 0 {
        didSet {
            backgroundLayer.lineWidth = borderWidth
        }
    }

    var cornerRadius: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }

    override var isHighlighted: Bool {
        didSet {
            if let highlightedBackgroundColor = highlightedBackgroundColor {
                backgroundLayer.fillColor = isHighlighted ? highlightedBackgroundColor.cgColor : backgroundColor?.cgColor
            }
        }
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {

        var _size = size

        _size.width = min(size.width, superviewIfExist!.bounds.width - safetyMarginsOfSuperview.horizontalValue)
        _size.height = min(size.height, superviewIfExist!.bounds.height - safetyMarginsOfSuperview.verticalValue)

        let contentLimitSize = self.contentSize(in: _size)
        let contentSize = sizeThatFitsInContentView(contentLimitSize)
        let resultSize = sizeWithContentSize(contentSize, sizeThatFits: size)
        return resultSize
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let arrowSize = self.arrowSize
        let roundedRect = CGRect(x: borderWidth / 2.0,
                                 y: borderWidth / 2.0 + (currentLayoutDirection == .above ? 0 : arrowSize.height),
                                 width: bounds.width - borderWidth,
                                 height: bounds.height - arrowSize.height - borderWidth)
        let cornerRadius = self.cornerRadius

        let leftTopArcCenter = CGPoint(x: roundedRect.minX + cornerRadius, y: roundedRect.minY + cornerRadius)
        let leftBottomArcCenter = CGPoint(x: leftTopArcCenter.x, y: roundedRect.maxY - cornerRadius)
        let rightTopArcCenter = CGPoint(x: roundedRect.maxX - cornerRadius, y: leftTopArcCenter.y)
        let rightBottomArcCenter = CGPoint(x: rightTopArcCenter.x, y: leftBottomArcCenter.y)

        let path = UIBezierPath()
        path.move(to: CGPoint(x: leftTopArcCenter.x, y: roundedRect.minY))
        path.addArc(withCenter: leftTopArcCenter, radius: cornerRadius, startAngle: .pi * 1.5, endAngle: .pi, clockwise: false)
        path.addLine(to: CGPoint(x: roundedRect.minX, y: leftBottomArcCenter.y))
        path.addArc(withCenter: leftBottomArcCenter, radius: cornerRadius, startAngle: .pi, endAngle: .pi * 0.5, clockwise: false)

        if currentLayoutDirection == .above {
            // 让开，我要开始开始画三角形了，箭头向下
            path.addLine(to: CGPoint(x: arrowMinX, y: roundedRect.maxY))
            path.addLine(to: CGPoint(x: arrowMinX + arrowSize.width / 2, y: roundedRect.maxY + arrowSize.height))
            path.addLine(to: CGPoint(x: arrowMinX + arrowSize.width, y: roundedRect.maxY))
        }

        path.addLine(to: CGPoint(x: rightBottomArcCenter.x, y: roundedRect.maxY))
        path.addArc(withCenter: rightBottomArcCenter, radius: cornerRadius, startAngle: .pi * 0.5, endAngle: 0, clockwise: false)
        path.addLine(to: CGPoint(x: roundedRect.maxX, y: rightTopArcCenter.y))
        path.addArc(withCenter: rightTopArcCenter, radius: cornerRadius, startAngle: 0.0, endAngle: .pi * 1.5, clockwise: false)

        if currentLayoutDirection == .below {
            // 箭头向上
            path.addLine(to: CGPoint(x: arrowMinX + arrowSize.width, y: roundedRect.minY))
            path.addLine(to: CGPoint(x: arrowMinX + arrowSize.width / 2, y: roundedRect.minY - arrowSize.height))
            path.addLine(to: CGPoint(x: arrowMinX, y: roundedRect.minY))
        }
        path.close()

        backgroundLayer.path = path.cgPath
        backgroundLayer.shadowPath = path.cgPath
        backgroundLayer.frame = bounds

        layoutDefaultSubviews()
    }

    private func layoutDefaultSubviews() {
        contentView.frame = CGRect(x: borderWidth + contentEdgeInsets.left,
                                   y: (currentLayoutDirection == .above ? borderWidth : arrowSize.height + borderWidth) + contentEdgeInsets.top,
                                   width: bounds.width - borderWidth * 2 - contentEdgeInsets.horizontalValue,
                                   height: bounds.height - arrowSize.height - borderWidth * 2 - contentEdgeInsets.verticalValue)
        // contentView的圆角取一个比整个path的圆角小的最大值（极限情况下如果self.contentEdgeInsets.left比self.cornerRadius还大，那就意味着contentView不需要圆角了）
        // 这么做是为了尽量去掉contentView对内容不必要的裁剪，以免有些东西被裁剪了看不到
        let contentViewCornerRadius = abs(fmin(contentView.frame.minX - cornerRadius, 0))
        contentView.layer.cornerRadius = contentViewCornerRadius

        let isImageViewShowing = isSubviewShowing(imageView)
        let isTextLabelShowing = isSubviewShowing(textLabel)
        if isImageViewShowing {
            imageView.sizeToFit()
            imageView.frame = imageView.frame.setXY(imageEdgeInsets.left, flat(contentView.bounds.height.center(imageView.frame.height) + imageEdgeInsets.top))
        }
        if isTextLabelShowing {
            let textLabelMinX = (isImageViewShowing ? ceil(imageView.frame.maxX + imageEdgeInsets.right) : 0) + textEdgeInsets.left
            let textLabelLimitSize = CGSize(width: ceil(contentView.bounds.width - textLabelMinX),
                                            height: ceil(contentView.bounds.height - textEdgeInsets.top - textEdgeInsets.bottom))

            let textLabelSize = textLabel.sizeThatFits(textLabelLimitSize)
            let textLabelOrigin = CGPoint(x: textLabelMinX,
                                          y: flat(contentView.bounds.height.center(ceil(textLabelSize.height)) + textEdgeInsets.top))
            textLabel.frame = CGRect(x: textLabelOrigin.x, y: textLabelOrigin.y, width: textLabelLimitSize.width, height: ceil(textLabelSize.height))
        }
    }

    // MARK: - Private Tools

    private func isSubviewShowing(_ subview: UIView?) -> Bool {
        guard let subview = subview, !subview.isHidden, subview.superview != nil else {
            return false
        }
        return true
    }

    private func initPopupContainerViewWindowIfNeeded() {
        if popupWindow == nil {
            popupWindow = QMUIPopupContainerViewWindow()
            popupWindow?.backgroundColor = UIColorClear
            popupWindow?.windowLevel = UIWindow.Level(rawValue: UIWindowLevelQMUIAlertView)
            let viewController = QMUIPopContainerViewController()
            (viewController.view as? QMUIPopContainerMaskControl)?.popupContainerView = self
            if automaticallyHidesWhenUserTap {
                viewController.view.backgroundColor = maskViewBackgroundColor
            } else {
                viewController.view.backgroundColor = UIColorClear
            }
            viewController.supportedOrientationMask = QMUIHelper.visibleViewController?.supportedInterfaceOrientations
            popupWindow?.rootViewController = viewController // 利用 rootViewController 来管理横竖屏
            popupWindow?.rootViewController?.view.addSubview(self)
        }
    }

    /// 根据一个给定的大小，计算出符合这个大小的内容大小
    private func contentSize(in size: CGSize) -> CGSize {
        let contentSize = CGSize(width: size.width - contentEdgeInsets.horizontalValue - borderWidth * 2, height: size.height - arrowSize.height - borderWidth * 2)
        return contentSize
    }

    /// 根据内容大小和外部限制的大小，计算出合适的self size（包含箭头）
    private func sizeWithContentSize(_ contentSize: CGSize, sizeThatFits: CGSize) -> CGSize {
        var resultWidth = contentSize.width + contentEdgeInsets.horizontalValue + borderWidth * 2

        resultWidth = min(resultWidth, sizeThatFits.width) // 宽度不能超过传进来的size.width
        resultWidth = max(fmin(resultWidth, maximumWidth), minimumWidth) // 宽度必须在最小值和最大值之间
        resultWidth = ceil(resultWidth)

        var resultHeight = contentSize.height + contentEdgeInsets.verticalValue + arrowSize.height + borderWidth * 2
        resultHeight = min(resultHeight, sizeThatFits.height)
        resultHeight = max(fmin(resultHeight, maximumHeight), minimumHeight)
        resultHeight = ceil(resultHeight)

        return CGSize(width: resultWidth, height: resultHeight)
    }

    var isShowing: Bool {
        let isShowingIfAddedToView = superview != nil && !isHidden && popupWindow == nil
        let isShowingIfInWindow = superview != nil && popupWindow != nil && !popupWindow!.isHidden
        return isShowingIfAddedToView || isShowingIfInWindow
    }

    /**
     *  即将显示时的回调
     *  注：如果需要使用例如 didShowBlock 的时机，请使用 @showWithAnimated:completion: 的 completion 参数来实现。
     *  @argv animated 是否需要动画
     */
    var willShowClosure: ((_ animated: Bool) -> Void)?
    
    /**
     *  即将隐藏时的回调
     *  @argv hidesByUserTap 用于区分此次隐藏是否因为用户手动点击空白区域导致浮层被隐藏
     *  @argv animated 是否需要动画
     */
    var willHideClosure: ((_ hidesByUserTap: Bool, _ animated: Bool) -> Void)?

    /**
     *  已经隐藏后的回调
     *  @argv hidesByUserTap 用于区分此次隐藏是否因为用户手动点击空白区域导致浮层被隐藏
     */
    var didHideClosure: ((_ hidesByUserTap: Bool) -> Void)?

    private var popupWindow: QMUIPopupContainerViewWindow?
    private weak var previousKeyWindow: UIWindow?
    fileprivate var hidesByUserTap = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        didInitialized()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        didInitialized()
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let result = super.hitTest(point, with: event)
        if result == contentView {
            return self
        }
        return result
    }

    /**
     *  相对于某个 view 布局（布局后箭头不一定会水平居中）
     *  @param targetView 注意如果这个 targetView 自身的布局发生变化，需要重新调用 layoutWithTargetView:，否则浮层的布局不会自动更新。
     */
    func layout(with targetView: UIView) {
        var targetViewFrameInMainWindow = CGRect.zero
        let mainWindow = (UIApplication.shared.delegate!.window!)!
        if targetView.window == mainWindow {
            targetViewFrameInMainWindow = targetView.convert(targetView.bounds, to: targetView.window)
        } else {
            let targetViewFrameInLocalWindow = targetView.convert(targetView.bounds, to: targetView.window)
            targetViewFrameInMainWindow = mainWindow.convert(targetViewFrameInLocalWindow, to: targetView.window)
        }

        layout(with: targetViewFrameInMainWindow, inReferenceWindow: targetView.window)
    }

    /**
     * 相对于给定的 itemRect 布局（布局后箭头不一定会水平居中）
     * @param targetRect 注意这个 rect 应该是处于屏幕坐标系里的 rect，所以请自行做坐标系转换。
     */
    func layoutWithTargetRectInScreenCoordinate(_ targetRect: CGRect) {
        layout(with: targetRect, inReferenceWindow: (UIApplication.shared.delegate!.window)!)
    }

    private func layout(with targetRect: CGRect, inReferenceWindow window: UIWindow?) {
        let superview = superviewIfExist
        let isLayoutInWindowMode = !(superview != nil && popupWindow == nil)
        let superviewBoundsInWindow = isLayoutInWindowMode ? window!.bounds : superview!.convert(superview!.bounds, to: window)

        var tipSize = sizeThatFits(CGSize(width: maximumWidth, height: maximumHeight))
        let preferredTipWidth = tipSize.width

        // 保护tips最往左只能到达self.safetyMarginsOfSuperview.left
        let a = targetRect.midX - tipSize.width / 2
        var tipMinX = fmax(superviewBoundsInWindow.minX + safetyMarginsOfSuperview.left, a)

        var tipMaxX = tipMinX + tipSize.width
        if tipMaxX + safetyMarginsOfSuperview.right > superviewBoundsInWindow.maxX {
            // 右边超出了
            // 先尝试把右边超出的部分往左边挪，看是否会令左边到达临界点
            let distanceCanMoveToLeft = tipMaxX - (superviewBoundsInWindow.maxX - safetyMarginsOfSuperview.right)
            if tipMinX - distanceCanMoveToLeft >= superviewBoundsInWindow.minX + safetyMarginsOfSuperview.left {
                // 可以往左边挪
                tipMinX -= distanceCanMoveToLeft
            } else {
                // 不可以往左边挪，那么让左边靠到临界点，然后再把宽度减小，以让右边处于临界点以内
                tipMinX = superviewBoundsInWindow.minX + safetyMarginsOfSuperview.left
                tipMaxX = superviewBoundsInWindow.maxX - safetyMarginsOfSuperview.right
                tipSize.width = fmin(tipSize.width, tipMaxX - tipMinX)
            }
        }

        // 经过上面一番调整，可能tipSize.width发生变化，一旦宽度变化，高度要重新计算，所以重新调用一次sizeThatFits
        let tipWidthChanged = tipSize.width != preferredTipWidth
        if tipWidthChanged {
            tipSize = sizeThatFits(tipSize)
        }

        currentLayoutDirection = preferLayoutDirection

        // 检查当前的最大高度是否超过任一方向的剩余空间，如果是，则强制减小最大高度，避免后面计算布局选择方向时死循环

        let canShowAtAbove = canTipShowAtSpecifiedLayoutDirect(.above, targetRect: targetRect, tipSize: tipSize)
        let canShowAtBelow = canTipShowAtSpecifiedLayoutDirect(.below, targetRect: targetRect, tipSize: tipSize)

        if !canShowAtAbove && !canShowAtBelow {
            // 上下都没有足够的空间，所以要调整maximumHeight
            let maximumHeightAbove = targetRect.minY - superviewBoundsInWindow.minY - distanceBetweenTargetRect - safetyMarginsOfSuperview.top
            let maximumHeightBelow = superviewBoundsInWindow.maxY - safetyMarginsOfSuperview.bottom - distanceBetweenTargetRect - targetRect.maxY
            maximumHeight = max(minimumHeight, max(maximumHeightAbove, maximumHeightBelow))
            tipSize.height = maximumHeight
            currentLayoutDirection = maximumHeightAbove > maximumHeightBelow ? .above : .below

            print("\(self), 因为上下都不够空间，所以最大高度被强制改为\(maximumHeight), 位于目标的\(maximumHeightAbove > maximumHeightBelow ? "上方" : "下方")")

        } else if currentLayoutDirection == .above && !canShowAtAbove {
            currentLayoutDirection = .below
        } else if currentLayoutDirection == .below && !canShowAtBelow {
            currentLayoutDirection = .above
        }

        var tipMinY = tipMinYWithTargetRect(targetRect, tipSize: tipSize, preferLayoutDirection: currentLayoutDirection)

        // 当上下的剩余空间都比最小高度要小的时候，tip会靠在safetyMargins范围内的上（下）边缘
        if currentLayoutDirection == .above {
            let tipMinYIfAlignSafetyMarginTop = superviewBoundsInWindow.minY + safetyMarginsOfSuperview.top
            tipMinY = max(tipMinY, tipMinYIfAlignSafetyMarginTop)
        } else if currentLayoutDirection == .below {
            let tipMinYIfAlignSafetyMarginBottom = superviewBoundsInWindow.maxY - safetyMarginsOfSuperview.bottom - tipSize.height
            tipMinY = min(tipMinY, tipMinYIfAlignSafetyMarginBottom)
        }

        // 上面计算得出的 tipMinX、tipMinY 是处于 window 坐标系里的，而浮层可能是以 addSubview: 的方式显示在某个 superview 上，所以要做一次坐标系转换
        var origin = CGPoint(x: tipMinX, y: tipMinY)
        origin = window!.convert(origin, to: superview)
        tipMinX = origin.x
        tipMinY = origin.y

        frame = CGRectFlat(tipMinX, tipMinY, tipSize.width, tipSize.height)

        // 调整浮层里的箭头的位置
        let targetRectCenter = CGPoint(x: targetRect.midX, y: targetRect.midY)
        let selfMidX = targetRectCenter.x - (superviewBoundsInWindow.minX + frame.minX)
        arrowMinX = selfMidX - arrowSize.width / 2
        setNeedsLayout()

        if isDebug {
            contentView.backgroundColor = UIColorTestGreen
            borderColor = UIColorRed
            borderWidth = PixelOne
            imageView.backgroundColor = UIColorTestRed
            textLabel.backgroundColor = UIColorTestBlue
        }
    }

    private func canTipShowAtSpecifiedLayoutDirect(_ direction: QMUIPopupContainerViewLayoutDirection, targetRect itemRect: CGRect, tipSize: CGSize) -> Bool {
        var canShow = false
        let tipMinY = tipMinYWithTargetRect(itemRect, tipSize: tipSize, preferLayoutDirection: direction)
        if direction == .above {
            canShow = tipMinY >= safetyMarginsOfSuperview.top
        } else if direction == .below {
            canShow = tipMinY + tipSize.height + safetyMarginsOfSuperview.bottom <= superviewIfExist!.bounds.height
        }
        return canShow
    }

    private func tipMinYWithTargetRect(_ itemRect: CGRect, tipSize: CGSize, preferLayoutDirection direction: QMUIPopupContainerViewLayoutDirection) -> CGFloat {
        var tipMinY: CGFloat = 0
        if direction == .above {
            tipMinY = itemRect.minY - tipSize.height - distanceBetweenTargetRect
        } else if direction == .below {
            tipMinY = itemRect.maxY + distanceBetweenTargetRect
        }
        return tipMinY
    }

    func show(with animated: Bool, completion: ((Bool) -> Void)? = nil) {
        var isShowingByWindowMode = false
        if superview == nil {
            initPopupContainerViewWindowIfNeeded()

            let viewController = popupWindow?.rootViewController as? QMUICommonViewController

            viewController?.supportedOrientationMask = QMUIHelper.visibleViewController?.supportedInterfaceOrientations

            previousKeyWindow = UIApplication.shared.keyWindow
            popupWindow?.makeKeyAndVisible()

            isShowingByWindowMode = true
        } else {
            isHidden = false
        }
        
        willShowClosure?(animated)

        if animated {
            if isShowingByWindowMode {
                popupWindow?.alpha = 0
            } else {
                alpha = 0
            }
            layer.transform = CATransform3DMakeScale(0.98, 0.98, 1)
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 12, options: .curveLinear, animations: {
                self.layer.transform = CATransform3DMakeScale(1, 1, 1)
            }, completion: {
                completion?($0)
            })

            UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
                if isShowingByWindowMode {
                    self.popupWindow?.alpha = 1
                } else {
                    self.alpha = 1
                }
            }, completion: nil)

        } else {
            if isShowingByWindowMode {
                popupWindow?.alpha = 1
            } else {
                alpha = 1
            }
            completion?(true)
        }
    }

    func hide(with animated: Bool, completion: ((Bool) -> Void)? = nil) {
        willHideClosure?(hidesByUserTap, animated)

        let isShowingByWindowMode = popupWindow != nil

        if animated {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
                if isShowingByWindowMode {
                    self.popupWindow?.alpha = 0
                } else {
                    self.alpha = 0
                }
            }, completion: { _ in
                self.hideCompletion(with: isShowingByWindowMode, completion: completion)
            })
        } else {
            hideCompletion(with: isShowingByWindowMode, completion: completion)
        }
    }

    private func hideCompletion(with windowMode: Bool, completion: ((Bool) -> Void)? = nil) {
        if windowMode {
            // 恢复 keyWindow 之前做一下检查，避免类似问题 https://github.com/QMUI/QMUI_iOS/issues/90

            if UIApplication.shared.keyWindow == popupWindow {
                previousKeyWindow?.makeKey()
            }

            // iOS 9 下（iOS 8 和 10 都没问题）需要主动移除，才能令 rootViewController 和 popupWindow 立即释放，不影响后续的 layout 判断，如果不加这两句，虽然 popupWindow 指针被置为 nil，但其实对象还存在，View 层级关系也还在
            // https://github.com/QMUI/QMUI_iOS/issues/75
            removeFromSuperview()
            popupWindow?.rootViewController = nil

            popupWindow?.isHidden = true
            popupWindow = nil
        } else {
            isHidden = true
        }
        completion?(true)
        didHideClosure?(hidesByUserTap)
        hidesByUserTap = false
    }

    var superviewIfExist: UIView? {
        let isAddedToCustomView = superview != nil && popupWindow == nil
        if isAddedToCustomView {
            return superview!
        }

        // https://github.com/QMUI/QMUI_iOS/issues/76
        let window = (UIApplication.shared.delegate!.window!)!
        
        let shouldLayoutBaseOnPopupWindow = popupWindow != nil && popupWindow!.bounds.size == window.bounds.size

        let result = shouldLayoutBaseOnPopupWindow ? popupWindow : window

        return result?.rootViewController?.view
    }

    // MARK: - UISubclassingHooks

    /// 子类重写，在初始化时做一些操作
    open func didInitialized() {
        backgroundLayer = CAShapeLayer()
        backgroundLayer.shadowOffset = CGSize(width: 0, height: 2)
        backgroundLayer.shadowOpacity = 1
        backgroundLayer.shadowRadius = 10
        layer.addSublayer(backgroundLayer)

        contentView = UIView()
        contentView.clipsToBounds = true
        addSubview(contentView)
        
        // 由于浮层是在调用 showWithAnimated: 时才会被添加到 window 上，所以 appearance 也是在 showWithAnimated: 后才生效，这太晚了，会导致 showWithAnimated: 之前用到那些支持 appearance 的属性值都不准确，所以这里手动提前触发。
        updateAppearance()
    }

    /// 子类重写，告诉父类subviews的合适大小
    open func sizeThatFitsInContentView(_ size: CGSize) -> CGSize {
        // 如果没内容则返回自身大小
        if !isSubviewShowing(imageView) && !isSubviewShowing(textLabel) {
            let selfSize = contentSize(in: bounds.size)
            return selfSize
        }

        var resultSize = CGSize.zero

        let isImageViewShowing = isSubviewShowing(imageView)
        if isImageViewShowing {
            let imageViewSize = imageView.sizeThatFits(size)
            resultSize.width += ceil(imageViewSize.width) + imageEdgeInsets.left
            resultSize.height += ceil(imageViewSize.height) + imageEdgeInsets.top
        }

        let isTextLabelShowing = isSubviewShowing(textLabel)
        if isTextLabelShowing {
            let textLabelLimitSize = CGSize(width: size.width - resultSize.width - imageEdgeInsets.right, height: size.height)
            let textLabelSize = textLabel.sizeThatFits(textLabelLimitSize)
            resultSize.width += (isImageViewShowing ? imageEdgeInsets.right : 0) + ceil(textLabelSize.width) + textEdgeInsets.left
            resultSize.height = max(resultSize.height, ceil(textLabelSize.height) + textEdgeInsets.top)
        }
        resultSize.width = min(size.width, resultSize.width)
        resultSize.height = min(size.height, resultSize.height)
        return resultSize
    }
}

extension QMUIPopupContainerView {
    fileprivate func updateAppearance() {
        contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        arrowSize = CGSize(width: 18, height: 9)
        maximumWidth = CGFloat.greatestFiniteMagnitude
        minimumWidth = 0
        maximumHeight = CGFloat.greatestFiniteMagnitude
        minimumHeight = 0
        preferLayoutDirection = .above
        distanceBetweenTargetRect = 5
        safetyMarginsOfSuperview = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        backgroundColor = UIColorWhite
        maskViewBackgroundColor = UIColorMask
        highlightedBackgroundColor = nil
        shadowColor = UIColor(r: 0, g: 0, b: 0, a: 0.1)
        borderColor = UIColorGrayLighten
        borderWidth = PixelOne
        cornerRadius = 10
        qmui_outsideEdge = .zero
    }
}

class QMUIPopupContainerViewWindow: UIWindow {
    // 避免 UIWindow 拦截掉事件，保证让事件继续往背后传递
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let result = super.hitTest(point, with: event)
        if result == self {
            return nil
        }
        return result
    }
}

class QMUIPopContainerViewController: QMUICommonViewController {
    override func loadView() {
        let maskControl = QMUIPopContainerMaskControl()
        view = maskControl
    }
}

class QMUIPopContainerMaskControl: UIControl {
    weak var popupContainerView: QMUIPopupContainerView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        addTarget(self, action: #selector(handleMaskEvent), for: .touchUpInside)
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let result = super.hitTest(point, with: event)
        if result == self {
            if popupContainerView != nil && !popupContainerView!.automaticallyHidesWhenUserTap {
                return nil
            }
        }
        return result
    }

    // 把点击遮罩的事件放在 addTarget: 里而不直接在 hitTest:withEvent: 里处理是因为 hitTest:withEvent: 总是会走两遍
    @objc
    private func handleMaskEvent(_: UIControl) {
        if popupContainerView != nil && popupContainerView!.automaticallyHidesWhenUserTap {
            popupContainerView!.hidesByUserTap = true
            popupContainerView!.hide(with: true)
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
