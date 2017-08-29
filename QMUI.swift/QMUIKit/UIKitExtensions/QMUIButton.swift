//
//  QMUIButton.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/1/17.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

import UIKit
import CoreGraphics

/// 控制图片在UIButton里的位置，默认为QMUIButtonImagePositionLeft
enum QMUIButtonImagePosition {
    case top // imageView在titleLabel上面
    case left // imageView在titleLabel左边
    case bottom // imageView在titleLabel下面
    case right // imageView在titleLabel右边
}

enum QMUIGhostButtonColor {
    case blue
    case red
    case green
    case gray
    case white
}

enum QMUIFillButtonColor {
    case blue
    case red
    case green
    case gray
    case white
}

enum QMUINavigationButtonType {
    case normal // 普通导航栏文字按钮
    case bold // 导航栏加粗按钮
    case image // 图标按钮
    case back // 自定义返回按钮(可以同时带有title)
    case close // 自定义关闭按钮(只显示icon不带title)
}

enum QMUIToolbarButtonType {
    case normal // 普通工具栏按钮
    case red // 工具栏红色按钮，用于删除等警告性操作
    case image // 图标类型的按钮
}

enum QMUINavigationButtonPosition: Int {
    case none = -1 // 不处于navigationBar最左（右）边的按钮，则使用None。用None则不会在alignmentRectInsets里调整位置
    case left // 用于leftBarButtonItem，如果用于leftBarButtonItems，则只对最左边的item使用，其他item使用QMUINavigationButtonPositionNone
    case right // 用于rightBarButtonItem，如果用于rightBarButtonItems，则只对最右边的item使用，其他item使用QMUINavigationButtonPositionNone
}

/**
 * 提供以下功能：
 * <ol>
 * <li>highlighted、disabled状态均通过改变整个按钮的alpha来表现，无需分别设置不同state下的titleColor、image</li>
 * <li>支持点击时改变背景色颜色（<i>highlightedBackgroundColor</i>）</li>
 * <li>支持点击时改变边框颜色（<i>highlightedBorderColor</i>）</li>
 * <li>支持设置图片在按钮内的位置，无需自行调整imageEdgeInsets（<i>imagePosition</i>）</li>
 * </ol>
 */
class QMUIButton: UIButton {
    /**
     * 让按钮的文字颜色自动跟随tintColor调整（系统默认titleColor是不跟随的）<br/>
     * 默认为NO
     */
    @IBInspectable var adjustsTitleTintColorAutomatically: Bool = false {
        didSet {
            self.updateTitleColorIfNeeded()
        }
    }

    /**
     * 让按钮的图片颜色自动跟随tintColor调整（系统默认image是需要更改renderingMode才可以达到这种效果）<br/>
     * 默认为NO
     */
    @IBInspectable var adjustsImageTintColorAutomatically: Bool = false {
        didSet {
            let valueDifference = adjustsImageTintColorAutomatically != oldValue
            if valueDifference {
                self.updateImageRenderingModeIfNeeded()
            }
        }
    }

    /**
     * 是否自动调整highlighted时的按钮样式，默认为YES。<br/>
     * 当值为YES时，按钮highlighted时会改变自身的alpha属性为<b>ButtonHighlightedAlpha</b>
     */
    @IBInspectable var adjustsButtonWhenHighlighted: Bool = true

    /**
     * 是否自动调整disabled时的按钮样式，默认为YES。<br/>
     * 当值为YES时，按钮disabled时会改变自身的alpha属性为<b>ButtonDisabledAlpha</b>
     */
    @IBInspectable var adjustsButtonWhenDisabled: Bool = true

    /**
     * 设置按钮点击时的背景色，默认为nil。
     * @warning 不支持带透明度的背景颜色。当设置<i>highlightedBackgroundColor</i>时，会强制把<i>adjustsButtonWhenHighlighted</i>设为NO，避免两者效果冲突。
     * @see adjustsButtonWhenHighlighted
     */
    @IBInspectable var highlightedBackgroundColor: UIColor?

    /**
     * 设置按钮点击时的边框颜色，默认为nil。
     * @warning 当设置<i>highlightedBorderColor</i>时，会强制把<i>adjustsButtonWhenHighlighted</i>设为NO，避免两者效果冲突。
     * @see adjustsButtonWhenHighlighted
     */
    @IBInspectable var highlightedBorderColor: UIColor? {
        didSet {
            if highlightedBorderColor != nil {
                // 只要开启了highlightedBorderColor，就默认不需要alpha的高亮
                adjustsButtonWhenHighlighted = false
            }
        }
    }

    /**
     * 设置按钮里图标和文字的相对位置，默认为QMUIButtonImagePositionLeft<br/>
     * 可配合imageEdgeInsets、titleEdgeInsets、contentHorizontalAlignment、contentVerticalAlignment使用
     */
    @IBInspectable var imagePosition: QMUIButtonImagePosition = .left {
        didSet {
            self.setNeedsLayout()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        didInitialized()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        didInitialized()
    }

    private var highlightedBackgroundLayer = CALayer()
    private var originBorderColor: UIColor?

    private func didInitialized() {
        adjustsTitleTintColorAutomatically = false
        adjustsImageTintColorAutomatically = false
        tintColor = ButtonTintColor
        if !adjustsTitleTintColorAutomatically {
            setTitleColor(ButtonTintColor, for: .normal)
        }

        // 默认接管highlighted和disabled的表现，去掉系统默认的表现
        adjustsImageWhenHighlighted = false
        adjustsImageWhenDisabled = false
        adjustsButtonWhenHighlighted = true
        adjustsButtonWhenDisabled = true

        // iOS7以后的button，sizeToFit后默认会自带一个上下的contentInsets，为了保证按钮大小即为内容大小，这里直接去掉，改为一个最小的值。
        // 不能设为0，否则无效；也不能设置为小数点，否则无法像素对齐
        contentEdgeInsets = UIEdgeInsetsMake(1, 0, 1, 0)

        // 图片默认在按钮左边，与系统UIButton保持一致
        imagePosition = .left
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var size = size
        // 如果调用 sizeToFit，那么传进来的 size 就是当前按钮的 size，此时的计算不要去限制宽高
        if bounds.size.equalTo(size) {
            size = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        }

        var resultSize = CGSize.zero
        let contentLimitSize = CGSize(width: size.width - contentEdgeInsets.horizontalValue, height: size.height - contentEdgeInsets.verticalValue)
        switch imagePosition {
        case .bottom, .top:
            // 图片和文字上下排版时，宽度以文字或图片的最大宽度为最终宽度
            let imageLimitWidth = contentLimitSize.width - imageEdgeInsets.horizontalValue
            let imageSize = imageView?.sizeThatFits(CGSize(width: imageLimitWidth, height: CGFloat.greatestFiniteMagnitude)) // 假设图片高度必定完整显示

            let titleLimitSize = CGSize(width: contentLimitSize.width - titleEdgeInsets.horizontalValue, height: contentLimitSize.height - imageEdgeInsets.verticalValue - (imageSize?.height ?? 0) - titleEdgeInsets.verticalValue)
            var titleSize = titleLabel?.sizeThatFits(titleLimitSize)
            titleSize?.height = CGFloat(fminf(Float(titleSize?.height ?? 0), Float(titleLimitSize.height)))

            resultSize.width = contentEdgeInsets.horizontalValue
            resultSize.width += CGFloat(fmaxf(Float(imageEdgeInsets.horizontalValue) + Float(imageSize?.width ?? 0), Float(titleEdgeInsets.horizontalValue) + Float(titleSize?.width ?? 0)))
            resultSize.height = contentEdgeInsets.verticalValue + imageEdgeInsets.verticalValue + (imageSize?.height ?? 0) + titleEdgeInsets.verticalValue + (titleSize?.height ?? 0)

        case .right, .left:
            if imagePosition == .left && titleLabel?.numberOfLines == 1 {

                // QMUIButtonImagePositionLeft使用系统默认布局
                resultSize = super.sizeThatFits(size)

            } else {
                // 图片和文字水平排版时，高度以文字或图片的最大高度为最终高度
                // titleLabel为多行时，系统的sizeThatFits计算结果依然为单行的，所以当QMUIButtonImagePositionLeft并且titleLabel多行的情况下，使用自己计算的结果

                let imageLimitHeight = contentLimitSize.height - imageEdgeInsets.verticalValue
                let imageSize = imageView?.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: imageLimitHeight)) // 假设图片宽度必定完整显示，高度不超过按钮内容

                let titleLimitSize = CGSize(width: contentLimitSize.width - titleEdgeInsets.horizontalValue - (imageSize?.width ?? 0) - imageEdgeInsets.horizontalValue, height: contentLimitSize.height - titleEdgeInsets.verticalValue)
                var titleSize = titleLabel?.sizeThatFits(titleLimitSize)
                titleSize?.height = CGFloat(fminf(Float(titleSize?.height ?? 0), Float(titleLimitSize.height)))

                resultSize.width = contentEdgeInsets.horizontalValue + imageEdgeInsets.horizontalValue + (imageSize?.width ?? 0) + titleEdgeInsets.horizontalValue + (titleSize?.width ?? 0)
                resultSize.height = contentEdgeInsets.verticalValue
                resultSize.height += CGFloat(fmaxf(Float(imageEdgeInsets.verticalValue) + Float(imageSize?.height ?? 0), Float(titleEdgeInsets.verticalValue) + Float(titleSize?.height ?? 0)))
            }
        }
        return resultSize
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if bounds.isEmpty {
            return
        }

        if imagePosition == .left {
            return
        }

        let contentSize = CGSize(width: bounds.width - contentEdgeInsets.horizontalValue, height: bounds.height - contentEdgeInsets.verticalValue)
        if imagePosition == .top || imagePosition == .bottom {
            let imageLimitWidth = contentSize.width - imageEdgeInsets.horizontalValue
            let imageSize = imageView?.sizeThatFits(CGSize(width: imageLimitWidth, height: CGFloat.greatestFiniteMagnitude)) ?? CGSize.zero /// 假设图片的高度必定完整显示
            var imageFrame = imageSize.rect

            let titleLimitSize = CGSize(width: contentSize.width - titleEdgeInsets.horizontalValue, height: contentSize.height - imageEdgeInsets.verticalValue - imageSize.height - titleEdgeInsets.verticalValue)
            var titleSize = titleLabel?.sizeThatFits(titleLimitSize) ?? CGSize.zero
            titleSize.height = CGFloat(fminf(Float(titleSize.height), Float(titleLimitSize.height)))
            var titleFrame = titleSize.rect

            switch contentHorizontalAlignment {
            case .left:
                imageFrame = imageFrame.setX(contentEdgeInsets.left + imageEdgeInsets.left)
                titleFrame = titleFrame.setX(contentEdgeInsets.left + titleEdgeInsets.left)
            case .center:
                imageFrame = imageFrame.setX(contentEdgeInsets.left + imageEdgeInsets.left + imageLimitWidth.center(with: imageSize.width))
                titleFrame = titleFrame.setX(contentEdgeInsets.left + titleEdgeInsets.left + titleLimitSize.width.center(with: titleSize.width))
            case .right:
                imageFrame = imageFrame.setX(bounds.width - contentEdgeInsets.right - imageEdgeInsets.right - imageSize.width)
                titleFrame = titleFrame.setX(bounds.width - contentEdgeInsets.right - imageEdgeInsets.right - titleSize.width)
            case .fill:
                imageFrame = imageFrame.setX(contentEdgeInsets.left + imageEdgeInsets.left)
                imageFrame = imageFrame.setWidth(imageLimitWidth)
                titleFrame = imageFrame.setX(contentEdgeInsets.left + titleEdgeInsets.left)
                titleFrame = titleFrame.setWidth(titleLimitSize.width)
            }

            if imagePosition == .top {
                switch contentVerticalAlignment {
                case .top:
                    imageFrame = imageFrame.setY(contentEdgeInsets.top + imageEdgeInsets.top)
                    titleFrame = titleFrame.setY(imageFrame.maxY + imageEdgeInsets.bottom + titleEdgeInsets.top)
                case .center:
                    let contentHeight = imageFrame.height + imageEdgeInsets.verticalValue + titleFrame.height + titleEdgeInsets.verticalValue
                    let minY = contentSize.height.center(with: contentHeight) + contentEdgeInsets.top
                    imageFrame = imageFrame.setY(minY + imageEdgeInsets.top)
                    titleFrame = titleFrame.setY(imageFrame.maxY + imageEdgeInsets.bottom + titleEdgeInsets.top)
                case .bottom:
                    titleFrame = titleFrame.setY(bounds.height - contentEdgeInsets.bottom - titleEdgeInsets.bottom - titleFrame.height)
                    imageFrame = imageFrame.setY(titleFrame.minY - titleEdgeInsets.top - imageEdgeInsets.bottom - imageFrame.height)
                case .fill:
                    // 图片按自身大小显示，剩余空间由标题占满
                    imageFrame = imageFrame.setY(contentEdgeInsets.top + imageEdgeInsets.top)
                    titleFrame = titleFrame.setY(imageFrame.maxY + imageEdgeInsets.bottom + titleEdgeInsets.top)
                    titleFrame = titleFrame.setHeight(bounds.height - contentEdgeInsets.bottom - titleEdgeInsets.bottom - titleFrame.minY)
                }
            } else {
                switch contentVerticalAlignment {
                case .top:
                    titleFrame = titleFrame.setY(contentEdgeInsets.top + imageEdgeInsets.top)
                    imageFrame = imageFrame.setY(imageFrame.maxY + imageEdgeInsets.bottom + titleEdgeInsets.top)
                case .center:
                    let contentHeight = titleFrame.height + titleEdgeInsets.verticalValue + imageFrame.height + imageEdgeInsets.verticalValue
                    let minY = contentSize.height.center(with: contentHeight) + contentEdgeInsets.top
                    titleFrame = titleFrame.setY(minY + titleEdgeInsets.top)
                    imageFrame = imageFrame.setY(titleFrame.maxY + titleEdgeInsets.bottom + imageEdgeInsets.top)
                case .bottom:
                    imageFrame = imageFrame.setY(bounds.height - contentEdgeInsets.bottom - imageEdgeInsets.bottom - imageFrame.height)
                    titleFrame = titleFrame.setY(imageFrame.minY - imageEdgeInsets.top - titleEdgeInsets.bottom - titleFrame.height)
                case .fill:
                    // 图片按自身大小显示，剩余空间由标题占满
                    imageFrame = imageFrame.setY(bounds.height - contentEdgeInsets.bottom - imageEdgeInsets.bottom - imageFrame.height)
                    titleFrame = titleFrame.setY(contentEdgeInsets.top + titleEdgeInsets.top)
                    titleFrame = titleFrame.setHeight(imageFrame.minY - imageEdgeInsets.top - titleEdgeInsets.bottom - titleFrame.minY)
                }
            }

            imageView?.frame = imageFrame.flatted
            titleLabel?.frame = titleFrame.flatted

        } else if imagePosition == .right {
            let imageLimitHeight = contentSize.height - imageEdgeInsets.verticalValue
            let imageSize = imageView?.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: imageLimitHeight)) ?? .zero // 假设图片宽度必定完整显示，高度不超过按钮内容
            var imageFrame = imageSize.rect

            let titleLimitSize = CGSize(width: contentSize.width - titleEdgeInsets.horizontalValue - imageFrame.width - imageEdgeInsets.horizontalValue, height: contentSize.height - titleEdgeInsets.verticalValue)
            var titleSize = titleLabel?.sizeThatFits(titleLimitSize) ?? .zero
            titleSize.height = min(titleSize.height, titleLimitSize.height)
            var titleFrame = titleSize.rect

            switch contentHorizontalAlignment {
            case .left:
                titleFrame = titleFrame.setX(contentEdgeInsets.left + titleEdgeInsets.left)
                imageFrame = imageFrame.setX(titleFrame.maxX + titleEdgeInsets.right + imageEdgeInsets.left)
            case .center:
                let contentWidth = titleFrame.width + titleEdgeInsets.horizontalValue + imageFrame.width + imageEdgeInsets.horizontalValue
                let minX = contentEdgeInsets.left + contentSize.width.center(with: contentWidth)
                titleFrame = titleFrame.setX(minX + titleEdgeInsets.left)
                imageFrame = imageFrame.setX(titleFrame.maxX + titleEdgeInsets.right + imageEdgeInsets.left)
            case .right:
                imageFrame = imageFrame.setX(bounds.width - contentEdgeInsets.right - imageEdgeInsets.right - imageFrame.width)
                titleFrame = titleFrame.setX(imageFrame.minX - imageEdgeInsets.left - titleEdgeInsets.right - titleFrame.width)
            case .fill:
                // 图片按自身大小显示，剩余空间由标题占满
                imageFrame = imageFrame.setX(bounds.width - contentEdgeInsets.right - imageEdgeInsets.right - imageFrame.width)
                titleFrame = titleFrame.setX(contentEdgeInsets.left + titleEdgeInsets.left)
                titleFrame = titleFrame.setX(imageFrame.minX - imageEdgeInsets.left - titleEdgeInsets.right - titleFrame.minX)
            }

            switch contentVerticalAlignment {
            case .top:
                titleFrame = titleFrame.setY(contentEdgeInsets.top + titleEdgeInsets.top)
                imageFrame = imageFrame.setY(contentEdgeInsets.top + imageEdgeInsets.top)
            case .center:
                titleFrame = titleFrame.setY(contentEdgeInsets.top + titleEdgeInsets.top + contentSize.height.center(with: titleFrame.height + titleEdgeInsets.verticalValue))

                imageFrame = imageFrame.setY(contentEdgeInsets.top + imageEdgeInsets.top + contentSize.height.center(with: imageFrame.height + imageEdgeInsets.verticalValue))
            case .bottom:
                titleFrame = titleFrame.setY(bounds.height - contentEdgeInsets.bottom - titleEdgeInsets.bottom - titleFrame.height)
                imageFrame = imageFrame.setY(bounds.height - contentEdgeInsets.bottom - imageEdgeInsets.bottom - imageFrame.height)
            case .fill:
                titleFrame = titleFrame.setY(contentEdgeInsets.top + titleEdgeInsets.top)
                titleFrame = titleFrame.setHeight(bounds.height - contentEdgeInsets.bottom - titleEdgeInsets.bottom - titleFrame.minY)
                imageFrame = imageFrame.setY(contentEdgeInsets.top + imageEdgeInsets.top)
                imageFrame = imageFrame.setHeight(bounds.height - contentEdgeInsets.bottom - imageEdgeInsets.bottom - imageFrame.minY)
            }
            imageView?.frame = imageFrame.flatted
            titleLabel?.frame = titleFrame.flatted
        }
    }

    override var isHighlighted: Bool {
        didSet {
            if isHighlighted && originBorderColor == nil {
                // 手指按在按钮上会不断触发setHighlighted:，所以这里做了保护，设置过一次就不用再设置了
                originBorderColor = UIColor(cgColor: layer.borderColor!)
            }
            // 渲染背景色
            if highlightedBackgroundColor != nil || highlightedBorderColor != nil {
                adjustsButtonHighlighted()
            }

            // 如果此时是disabled，则disabled的样式优先
            if !isEnabled {
                return
            }
            // 自定义highlighted样式
            guard adjustsButtonWhenHighlighted else { return }
            if isHighlighted {
                alpha = ButtonHighlightedAlpha!
            } else {
                UIView.animate(withDuration: 0.25) {
                    self.alpha = 1
                }
            }
        }
    }

    override var isEnabled: Bool {
        didSet {
            if !isEnabled && adjustsButtonWhenDisabled {
                alpha = ButtonDisabledAlpha!
            } else {
                UIView.animate(withDuration: 0.25) {
                    self.alpha = 1
                }
            }
        }
    }

    private func adjustsButtonHighlighted() {
        guard let  highlightedBackgroundColor = highlightedBackgroundColor else { return }

        // TODO: 翻译CALayer+QMUI
        // highlightedBackgroundLayer.qmui_removeDefaultAnimations()
        layer.insertSublayer(highlightedBackgroundLayer, at: 0)

        highlightedBackgroundLayer.frame = bounds
        highlightedBackgroundLayer.cornerRadius = layer.cornerRadius
        highlightedBackgroundLayer.backgroundColor = isHighlighted ? highlightedBackgroundColor.cgColor : UIColorClear.cgColor

        if highlightedBorderColor != nil {
            layer.borderColor = isHighlighted ? highlightedBorderColor?.cgColor : originBorderColor?.cgColor
        }
    }

    private func updateTitleColorIfNeeded() {
        if adjustsTitleTintColorAutomatically {
            setTitleColor(tintColor, for: .normal)
        }
        if adjustsTitleTintColorAutomatically, let currentAttributedTitle = currentAttributedTitle {
            let attributedString = NSMutableAttributedString(attributedString: currentAttributedTitle)
            let range = NSRange(location: 0, length: attributedString.length)
            attributedString.addAttribute(NSForegroundColorAttributeName, value: tintColor, range: range)
            self.setAttributedTitle(attributedString, for: .normal)
        }
    }

    private func updateImageRenderingModeIfNeeded() {
        guard currentImage != nil else { return }
        let states: [UIControlState] = [.normal, .highlighted, .disabled]
        for state in states {
            guard let image = image(for: state) else {
                continue
            }

            if adjustsImageTintColorAutomatically {
                // 这里的image不用做renderingMode的处理，而是放到重写的setImage:forState里去做
                setImage(image, for: state)
            } else {
                // 如果不需要用template的模式渲染，并且之前是使用template的，则把renderingMode改回Original
                setImage(image.withRenderingMode(.alwaysOriginal), for: state)
            }
        }
    }

    override func setImage(_ image: UIImage?, for state: UIControlState) {
        var tmpImage: UIImage?
        if adjustsImageTintColorAutomatically {
            tmpImage = image?.withRenderingMode(.alwaysTemplate)
        }
        super.setImage(tmpImage, for: state)
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()

        updateTitleColorIfNeeded()

        if adjustsImageTintColorAutomatically {
            updateImageRenderingModeIfNeeded()
        }
    }
}

/**
 *  QMUINavigationButton 是用于 UINavigationItem 的按钮，有两种使用方式：
 *  1. 利用类方法，快速生成所需的 UIBarButtonItem，其中大部分 UIBarButtonItem 均使用系统的 initWithBarButtonSystemItem 或 initWithImage 接口创建，仅有返回按钮利用了 customView 来创建 UIBarButtonItem。
 *  2. 利用 init 方法生成一个 QMUINavigationButton 实例，再通过类方法 + barButtonItemWithNavigationButton:position:target:action: 来生成一个对应的 UIBarButtonItem，此时 QMUINavigationButton 将作为 UIBarButtonItem 的 customView。
 *  若能满足需求，建议优先使用第 1 种方式。
 *  @note 关于 tintColor：UIBarButtonItem 如果使用了 customView，则需要修改 customView.tintColor，如果没使用 customView，则直接修改 UIBarButtonItem.tintColor。
 */
class QMUINavigationButton: UIButton {

    /**
     *  获取当前按钮的`QMUINavigationButtonType`
     */
    private(set) var type: QMUINavigationButtonType = .normal

    /**
     *  设置按钮是否用于UINavigationBar上的UIBarButtonItem。若为YES，则会参照系统的按钮布局去更改QMUINavigationButton的内容布局，若为NO，则内容布局与普通按钮没差别。默认为YES。
     */
    var useForBarButtonItem: Bool = true

    convenience init() {
        self.init(with: .normal)
    }

    /**
     *  导航栏按钮的初始化函数，指定的初始化方法
     *  @param type 按钮类型
     *  @param title 按钮的title
     */
    init(with type: QMUINavigationButtonType, title: String?) {
        super.init(frame: .zero)
        self.type = type
        buttonPosition = .none
        useForBarButtonItem = true
        setTitle(title, for: .normal)
        renderButtonStyle()
        sizeToFit()
    }

    /**
     *  导航栏按钮的初始化函数
     *  @param type 按钮类型
     */
    convenience init(with type: QMUINavigationButtonType) {
        self.init(with: type, title: nil)
    }

    /**
     *  导航栏按钮的初始化函数
     *  @param image 按钮的image
     */
    convenience init(with image: UIImage) {
        self.init(with: .image)
        setImage(image, for: .normal)
        // 系统在iOS8及以后的版本默认对image的UIBarButtonItem加了上下3、左右11的padding，所以这里统一一下
        contentEdgeInsets = UIEdgeInsetsMake(3, 11, 3, 11)
        sizeToFit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    /**
     *  创建一个 type 为 QMUINavigationButtonTypeBack 的 button 并作为 customView 用于生成一个 UIBarButtonItem，返回按钮的图片由配置表里的宏 NavBarBackIndicatorImage 决定。
     *  @param target 按钮点击事件的接收者
     *  @param Selector 按钮点击事件的方法
     *  @param tintColor 按钮要显示的颜色，如果为 nil，则表示跟随当前 UINavigationBar 的 tintColor
     */
    class func backBarButtonItem(with _: Any?, action _: Selector?, tintColor _: UIColor) -> UIBarButtonItem {
        fatalError()
    }

    /**
     *  创建一个 type 为 QMUINavigationButtonTypeBack 的 button 并作为 customView 用于生成一个 UIBarButtonItem，返回按钮的图片由配置表里的宏 NavBarBackIndicatorImage 决定，按钮颜色跟随 UINavigationBar 的 tintColor。
     *  @param target 按钮点击事件的接收者
     *  @param Selector 按钮点击事件的方法
     */
    class func backBarButtonItem(with _: Any?, action _: Selector?) -> UIBarButtonItem {
        fatalError()
    }

    /**
     *  创建一个以 “×” 为图标的关闭按钮，图片由配置表里的宏 NavBarCloseButtonImage 决定。
     *  @param target 按钮点击事件的接收者
     *  @param Selector 按钮点击事件的方法
     *  @param tintColor 按钮要显示的颜色，如果为 nil，则表示跟随当前 UINavigationBar 的 tintColor
     */
    class func closeBarButtonItem(with _: Any?, action _: Selector?, tintColor _: UIColor)
        -> UIBarButtonItem {
        fatalError()
    }

    /**
     *  创建一个以 “×” 为图标的关闭按钮，图片由配置表里的宏 NavBarCloseButtonImage 决定，图片颜色跟随 UINavigationBar.tintColor。
     *  @param target 按钮点击事件的接收者
     *  @param Selector 按钮点击事件的方法
     */
    class func closeBarButtonItem(with _: Any?, action _: Selector?)
        -> UIBarButtonItem {
        fatalError()
    }

    /**
     *  创建一个 UIBarButtonItem
     *  @param type 按钮的类型
     *  @param title 按钮的标题
     *  @param tintColor 按钮的颜色，如果为 nil，则表示跟随当前 UINavigationBar 的 tintColor
     *  @param position 按钮在 UINavigationBar 上的左右位置，如果某一边的按钮有多个，则只有最左边（最右边）的按钮需要设置为 QMUINavigationButtonPositionLeft（QMUINavigationButtonPositionRight），靠里的按钮使用 QMUINavigationButtonPositionNone 即可
     *  @param target 按钮点击事件的接收者
     *  @param Selector 按钮点击事件的方法
     */
    
    class func barButtonItem(with _: QMUINavigationButtonType, title _: String, tintColor _: UIColor, position _: QMUINavigationButtonPosition, target _: Any?, action _: Selector?) -> UIBarButtonItem {
        fatalError()
    }

    /**
     *  创建一个 UIBarButtonItem
     *  @param type 按钮的类型
     *  @param title 按钮的标题
     *  @param position 按钮在 UINavigationBar 上的左右位置，如果某一边的按钮有多个，则只有最左边（最右边）的按钮需要设置为 QMUINavigationButtonPositionLeft（QMUINavigationButtonPositionRight），靠里的按钮使用 QMUINavigationButtonPositionNone 即可
     *  @param target 按钮点击事件的接收者
     *  @param Selector 按钮点击事件的方法
     */
    class func barButtonItem(with _: QMUINavigationButtonType, title _: String, position _: QMUINavigationButtonPosition, target _: Any?, action _: Selector?) -> UIBarButtonItem {
        fatalError()
    }

    /**
     *  将参数传进来的 button 作为 customView 用于生成一个 UIBarButtonItem。
     *  @param button 要作为 customView 的 QMUINavigationButton
     *  @param tintColor 按钮的颜色，如果为 nil，则表示跟随当前 UINavigationBar 的 tintColor
     *  @param position 按钮在 UINavigationBar 上的左右位置，如果某一边的按钮有多个，则只有最左边（最右边）的按钮需要设置为 QMUINavigationButtonPositionLeft（QMUINavigationButtonPositionRight），靠里的按钮使用 QMUINavigationButtonPositionNone 即可
     *  @param target 按钮点击事件的接收者
     *  @param Selector 按钮点击事件的方法
     *
     *  @note tintColor、position、target、Selector? 等参数不需要对 QMUINavigationButton 设置，通过参数传进来就可以了，就算设置了也会在这个方法里被覆盖。
     */
    class func barButtonItem(with _: QMUINavigationButton, tintColor _: UIColor, position _: QMUINavigationButtonPosition, target _: Any?, action _: Selector?) -> UIBarButtonItem {
        fatalError()
    }

    /**
     *  将参数传进来的 button 作为 customView 用于生成一个 UIBarButtonItem。
     *  @param button 要作为 customView 的 QMUINavigationButton
     *  @param position 按钮在 UINavigationBar 上的左右位置，如果某一边的按钮有多个，则只有最左边（最右边）的按钮需要设置为 QMUINavigationButtonPositionLeft（QMUINavigationButtonPositionRight），靠里的按钮使用 QMUINavigationButtonPositionNone 即可
     *  @param target 按钮点击事件的接收者
     *  @param Selector 按钮点击事件的方法
     *
     *  @note position、target、Selector? 等参数不需要对 QMUINavigationButton 设置，通过参数传进来就可以了，就算设置了也会在这个方法里被覆盖。
     */
    class func barButtonItem(with _: QMUINavigationButton, position _: QMUINavigationButtonPosition, target _: Any?, action _: Selector?) -> UIBarButtonItem {
        fatalError()
    }

    /**
     *  创建一个图片类型的 UIBarButtonItem
     *  @param image 按钮的图标
     *  @param tintColor 按钮的颜色，如果为 nil，则表示跟随当前 UINavigationBar 的 tintColor
     *  @param position 按钮在 UINavigationBar 上的左右位置，如果某一边的按钮有多个，则只有最左边（最右边）的按钮需要设置为 QMUINavigationButtonPositionLeft（QMUINavigationButtonPositionRight），靠里的按钮使用 QMUINavigationButtonPositionNone 即可
     *  @param target 按钮点击事件的接收者
     *  @param Selector 按钮点击事件的方法
     */
    class func barButtonItem(with _: UIImage, tintColor _: UIColor, position _: QMUINavigationButtonPosition, target _: Any?, action _: Selector?) -> UIBarButtonItem {
        fatalError()
    }

    /**
     *  创建一个图片类型的 UIBarButtonItem
     *  @param image 按钮的图标
     *  @param position 按钮在 UINavigationBar 上的左右位置，如果某一边的按钮有多个，则只有最左边（最右边）的按钮需要设置为 QMUINavigationButtonPositionLeft（QMUINavigationButtonPositionRight），靠里的按钮使用 QMUINavigationButtonPositionNone 即可
     *  @param target 按钮点击事件的接收者
     *  @param Selector 按钮点击事件的方法
     */
    class func barButtonItem(with _: UIImage, position _: QMUINavigationButtonPosition, target _: Any?, action _: Selector?) -> UIBarButtonItem {
        fatalError()
    }

    class func renderNavigationButtonAppearanceStyle() {
    }

    class func barButtonItem(with _: QMUINavigationButtonType, title _: String, position _: QMUINavigationButtonPosition, target _: Any??, action _: Selector?) -> UIBarButtonItem {
        return UIBarButtonItem()
    }

    private var buttonPosition: QMUINavigationButtonPosition = .none

    private func renderButtonStyle() {
    }
}

/**
 *  `QMUIToolbarButton`是用于底部工具栏的按钮
 */
class QMUIToolbarButton: UIButton {
    /// 获取当前按钮的type
    private(set) var type: QMUIToolbarButtonType = .normal

    /**
     *  工具栏按钮的初始化函数
     *  @param type  按钮类型
     */
    convenience init(with type: QMUIToolbarButtonType) {
        self.init(with: type, title: nil)
    }

    /**
     *  工具栏按钮的初始化函数
     *  @param type 按钮类型
     *  @param title 按钮的title
     */
    init(with type: QMUIToolbarButtonType, title: String?) {
        self.type = type
        super.init(frame: .zero)

        setTitle(title, for: .normal)
        renderButtonStyle()
        sizeToFit()
    }

    /**
     *  工具栏按钮的初始化函数
     *  @param image 按钮的image
     */
    convenience init(with _: UIImage) {
        self.init(with: .image)
        // TODO: -
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func renderButtonStyle() {
    }

    /// 在原有的QMUIToolbarButton上创建一个UIBarButtonItem
    class func barButtonItem(with _: QMUIToolbarButton, target _: Any?, action _: Selector?) -> UIBarButtonItem {
        fatalError()
    }

    /// 创建一个特定type的UIBarButtonItem
    class func barButtonItem(with _: QMUIToolbarButton, title _: String, target _: Any?, action _: Selector?) -> UIBarButtonItem {
        fatalError()
    }

    /// 创建一个图标类型的UIBarButtonItem
    /*
     class func barButtonItem(with image: UIImage, target: Any?, action: Selector?) -> UIBarButtonItem {

     }
     */

    /// 对UIToolbar上的UIBarButtonItem做统一的样式调整
    class func renderToolbarButtonAppearanceStyle() {
    }
}

/**
 *  支持显示下划线的按钮，可用于需要链接的场景。下划线默认和按钮宽度一样，可通过 `underlineInsets` 调整。
 */
class QMUILinkButton: QMUIButton {

    /// 控制下划线隐藏或显示，默认为NO，也即显示下划线
    @IBInspectable var underlineHidden: Bool = false

    /// 设置下划线的宽度，默认为 1
    @IBInspectable var underlineWidth: CGFloat = 1

    /// 控制下划线颜色，若设置为nil，则使用当前按钮的titleColor的颜色作为下划线的颜色。默认为 nil。
    @IBInspectable var underlineColor: UIColor?

    /// 下划线的位置是基于 titleLabel 的位置来计算的，默认x、width均和titleLabel一致，而可以通过这个属性来调整下划线的偏移值。默认为UIEdgeInsetsZero。
    @IBInspectable var underlineInsets: UIEdgeInsets = .zero

    override init(frame: CGRect) {
        super.init(frame: frame)
        didInitialized()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func didInitialized() {
        // TODO: -
    }
}

/**
 *  用于 `QMUIGhostButton.cornerRadius` 属性，当 `cornerRadius` 为 `QMUIGhostButtonCornerRadiusAdjustsBounds` 时，`QMUIGhostButton` 会在高度变化时自动调整 `cornerRadius`，使其始终保持为高度的 1/2。
 */
public let QMUIGhostButtonCornerRadiusAdjustsBounds = -1

/**
 *  “幽灵”按钮，也即背景透明、带圆角边框的按钮
 *
 *  可通过 `QMUIGhostButtonColor` 设置几种预设的颜色，也可以用 `ghostColor` 设置自定义颜色。
 *
 *  @warning 默认情况下，`ghostColor` 只会修改文字和边框的颜色，如果需要让 image 也跟随 `ghostColor` 的颜色，则可将 `adjustsImageWithGhostColor` 设为 `YES`
 */
class QMUIGhostButton: QMUIButton {
    // TODO: -  UI_APPEARANCE_Selector? 这个宏没有翻译
    @IBInspectable var ghostColor: UIColor = .blue // 默认为 GhostButtonColorBlue
    @IBInspectable var borderWidth: CGFloat = 1 // 默认为 1pt
    @IBInspectable var cornerRadius: CGFloat = CGFloat(QMUIGhostButtonCornerRadiusAdjustsBounds) // 默认为 QMUIGhostButtonCornerRadiusAdjustsBounds，也即固定保持按钮高度的一半。

    /**
     *  控制按钮里面的图片是否也要跟随 `ghostColor` 一起变化，默认为 `NO`
     */
    var adjustsImageWithGhostColor: Bool = false

    init(with ghostColor: UIColor, frame: CGRect) {
        super.init(frame: frame)
        initialize(with: ghostColor)
    }

    convenience init(with ghostType: QMUIGhostButtonColor) {
        self.init(with: ghostType, frame: .zero)
    }

    convenience init(with ghostType: QMUIGhostButtonColor, frame: CGRect) {
        var ghostColor: UIColor?
        switch ghostType {
        case .blue:
            ghostColor = GhostButtonColorBlue
        case .red:
            ghostColor = GhostButtonColorRed
        case .green:
            ghostColor = GhostButtonColorGreen
        case .gray:
            ghostColor = GhostButtonColorGray
        case .white:
            ghostColor = GhostButtonColorWhite
        }
        self.init(with: ghostColor ?? .blue, frame: frame)
    }

    convenience init(with ghostColor: UIColor) {
        self.init(with: ghostColor, frame: .zero)
    }

    convenience override init(frame: CGRect) {
        self.init(with: GhostButtonColorBlue ?? .blue, frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize(with: GhostButtonColorBlue ?? .blue)
    }

    private func initialize(with ghostColor: UIColor) {
        self.ghostColor = ghostColor
    }
}

/**
 *  用于 `QMUIFillButton.cornerRadius` 属性，当 `cornerRadius` 为 `QMUIFillButtonCornerRadiusAdjustsBounds` 时，`QMUIFillButton` 会在高度变化时自动调整 `cornerRadius`，使其始终保持为高度的 1/2。
 */
public let QMUIFillButtonCornerRadiusAdjustsBounds = -1

/**
 *  QMUIFillButton
 *  实心填充颜色的按钮，支持预定义的几个色值
 */
/*
 class QMUIFillButton: QMUIButton {
 // TODO: - UI_APPEARANCE_Selector?的宏没有写
 @IBInspectable var fillColor: UIColor               // 默认为 FillButtonColorBlue
 @IBInspectable var titleTextColor: UIColor          // 默认为 UIColorWhite
 @IBInspectable var cornerRadius: CGFloat              // 默认为 QMUIFillButtonCornerRadiusAdjustsBounds，也即固定保持按钮高度的一半。

 /**
  *  控制按钮里面的图片是否也要跟随 `titleTextColor` 一起变化，默认为 `NO`
  */
 var adjustsImageWithTitleTextColor: Bool

 init(with fillType: QMUIFillButtonColor) {

 }

 init(with fillType: QMUIFillButtonColor, frame: CGRect) {

 }

 init(with fillColor: UIColor, titleColor: UIColor) {

 }

 init(with fillColor: UIColor, titleColor: UIColor, frame: CGRect) {

 }

 required init?(coder aDecoder: NSCoder) {
 fatalError("init(coder:) has not been implemented")
 }
 }
 */
