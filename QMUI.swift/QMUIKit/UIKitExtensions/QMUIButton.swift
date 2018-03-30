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
 *  提供以下功能：
 *  1. highlighted、disabled 状态均通过改变整个按钮的alpha来表现，无需分别设置不同 state 下的 titleColor、image。alpha 的值可在配置表里修改 ButtonHighlightedAlpha、ButtonDisabledAlpha。
 *  2. 支持点击时改变背景色颜色（highlightedBackgroundColor）
 *  3. 支持点击时改变边框颜色（highlightedBorderColor）
 *  4. 支持设置图片相对于 titleLabel 的位置（imagePosition）
 *  5. 支持设置图片和 titleLabel 之间的间距，无需自行调整 titleEdgeInests、imageEdgeInsets（spacingBetweenImageAndTitle）
 *  @warning QMUIButton 重新定义了 UIButton.titleEdgeInests、imageEdgeInsets、contentEdgeInsets 这三者的布局逻辑，sizeThatFits: 里会把 titleEdgeInests 和 imageEdgeInsets 也考虑在内（UIButton 不会），以使这三个接口的使用更符合直觉。
 */
class QMUIButton: UIButton {
    /**
     * 让按钮的文字颜色自动跟随tintColor调整（系统默认titleColor是不跟随的）<br/>
     * 默认为 false
     */
    @IBInspectable var adjustsTitleTintColorAutomatically: Bool = false {
        didSet {
            updateTitleColorIfNeeded()
        }
    }

    /**
     * 让按钮的图片颜色自动跟随tintColor调整（系统默认image是需要更改renderingMode才可以达到这种效果）<br/>
     * 默认为 false
     */
    @IBInspectable var adjustsImageTintColorAutomatically: Bool = false {
        didSet {
            let valueDifference = adjustsImageTintColorAutomatically != oldValue
            if valueDifference {
                updateImageRenderingModeIfNeeded()
            }
        }
    }

    /**
     *  等价于 adjustsTitleTintColorAutomatically = YES & adjustsImageTintColorAutomatically = YES & tintColor = xxx
     *  @note 一般只使用这个属性的 setter，而 getter 永远返回 self.tintColor
     *  @warning 不支持传 nil
     */
    @IBInspectable var tintColorAdjustsTitleAndImage: UIColor! {
        set {
            tintColor = tintColorAdjustsTitleAndImage
            adjustsTitleTintColorAutomatically = true
            adjustsImageTintColorAutomatically = true
        }

        get {
            return tintColor
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
    @IBInspectable var highlightedBackgroundColor: UIColor? {
        didSet {
            if highlightedBackgroundColor != nil {
                // 只要开启了highlightedBackgroundColor，就默认不需要alpha的高亮
                adjustsButtonWhenHighlighted = false
            }
        }
    }

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
    var imagePosition: QMUIButtonImagePosition = .left {
        didSet {
            setNeedsLayout()
        }
    }
    
    /**
     * 设置按钮里图标和文字之间的间隔，会自动响应 imagePosition 的变化而变化，默认为0。<br/>
     * 系统默认实现需要同时设置 titleEdgeInsets 和 imageEdgeInsets，同时还需考虑 contentEdgeInsets 的增加（否则不会影响布局，可能会让图标或文字溢出或挤压），使用该属性可以避免以上情况。<br/>
     * @warning 会与 imageEdgeInsets、 imageEdgeInsets、 contentEdgeInsets 共同作用。
     */
    @IBInspectable var spacingBetweenImageAndTitle: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        didInitialized()
        
        tintColor = ButtonTintColor
        if !adjustsTitleTintColorAutomatically {
            setTitleColor(ButtonTintColor, for: .normal)
        }
        
        // iOS7以后的button，sizeToFit后默认会自带一个上下的contentInsets，为了保证按钮大小即为内容大小，这里直接去掉，改为一个最小的值。
        // 不能设为0，否则无效；也不能设置为小数点，否则无法像素对齐
        contentEdgeInsets = UIEdgeInsets(top: CGFloat.leastNormalMagnitude, left: 0, bottom: CGFloat.leastNormalMagnitude, right: 0)
    }

    convenience init(title: String?, image: UIImage?) {
        self.init()
        setImage(image, for: .normal)
        setTitle(title, for: .normal)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        didInitialized()
    }

    private var highlightedBackgroundLayer = CALayer()
    private var originBorderColor: UIColor?

    fileprivate func didInitialized() {
        
        // 默认接管highlighted和disabled的表现，去掉系统默认的表现
        adjustsImageWhenHighlighted = false
        adjustsImageWhenDisabled = false
    }

    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        var size = size
        // 如果调用 sizeToFit，那么传进来的 size 就是当前按钮的 size，此时的计算不要去限制宽高
        if bounds.size == size {
            size = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        }

        let isImageViewShowing = imageView != nil && !imageView!.isHidden
        let isTitleLabelShowing = titleLabel != nil && !titleLabel!.isHidden
        var imageTotalSize = CGSize.zero // 包含 imageEdgeInsets 那些空间
        var titleTotalSize = CGSize.zero // 包含 titleEdgeInsets 那些空间
        let spacingBetweenImageAndTitle = flat((isImageViewShowing && isTitleLabelShowing) ? self.spacingBetweenImageAndTitle : 0) // 如果图片或文字某一者没显示，则这个 spacing 不考虑进布局
        let contentEdgeInsets = self.contentEdgeInsets.removeFloatMin()
        var resultSize = CGSize.zero
        let contentLimitSize = CGSize(width: size.width - contentEdgeInsets.horizontalValue, height: size.height - contentEdgeInsets.verticalValue)
        
        switch imagePosition {
        case .bottom, .top:
            // 图片和文字上下排版时，宽度以文字或图片的最大宽度为最终宽度
            if isImageViewShowing {
                let imageLimitWidth = contentLimitSize.width - imageEdgeInsets.horizontalValue
                var imageSize = imageView!.sizeThatFits(CGSize(width: imageLimitWidth, height: .greatestFiniteMagnitude)) // 假设图片高度必定完整显示
                imageSize.width = fmin(imageSize.width, imageLimitWidth)
                imageTotalSize = CGSize(width: imageSize.width + imageEdgeInsets.horizontalValue, height: imageSize.height + imageEdgeInsets.verticalValue)
            }
            
            if isTitleLabelShowing {
                let titleLimitSize = CGSize(width: contentLimitSize.width - titleEdgeInsets.horizontalValue, height: contentLimitSize.height - imageTotalSize.height - spacingBetweenImageAndTitle - titleEdgeInsets.verticalValue)
                var titleSize = titleLabel!.sizeThatFits(titleLimitSize)
                titleSize.height = fmin(titleSize.height, titleLimitSize.height)
                titleTotalSize = CGSize(width: titleSize.width + titleEdgeInsets.horizontalValue, height: titleSize.height + titleEdgeInsets.verticalValue)
            }

            resultSize.width = contentEdgeInsets.horizontalValue
            resultSize.width += fmax(imageTotalSize.width, titleTotalSize.width)
            resultSize.height = contentEdgeInsets.verticalValue + imageTotalSize.height + spacingBetweenImageAndTitle + titleTotalSize.height

        case .right, .left:
            // 图片和文字水平排版时，高度以文字或图片的最大高度为最终高度
            // 注意这里有一个和系统不一致的行为：当 titleLabel 为多行时，系统的 sizeThatFits: 计算结果固定是单行的，所以当 QMUIButtonImagePositionLeft 并且titleLabel 多行的情况下，QMUIButton 计算的结果与系统不一致
            if isImageViewShowing {
                let imageLimitHeight = contentLimitSize.height - imageEdgeInsets.verticalValue
                var imageSize = imageView!.sizeThatFits(CGSize(width: .greatestFiniteMagnitude, height: imageLimitHeight)) // 假设图片高度必定完整显示
                imageSize.height = fmin(imageSize.height, imageLimitHeight)
                imageTotalSize = CGSize(width: imageSize.width + imageEdgeInsets.horizontalValue, height: imageSize.height + imageEdgeInsets.verticalValue)
            }
            
            if isTitleLabelShowing {
                let titleLimitSize = CGSize(width: contentLimitSize.width - titleEdgeInsets.horizontalValue - imageTotalSize.width - spacingBetweenImageAndTitle, height: contentLimitSize.height -  titleEdgeInsets.verticalValue)
                var titleSize = titleLabel!.sizeThatFits(titleLimitSize)
                titleSize.height = fmin(titleSize.height, titleLimitSize.height)
                titleTotalSize = CGSize(width: titleSize.width + titleEdgeInsets.horizontalValue, height: titleSize.height + titleEdgeInsets.verticalValue)
            }
            
            resultSize.width = contentEdgeInsets.horizontalValue + imageTotalSize.width + spacingBetweenImageAndTitle + titleTotalSize.width
            resultSize.height = contentEdgeInsets.verticalValue
            resultSize.height += fmax(imageTotalSize.height, titleTotalSize.height)
            
        }
        return resultSize
    }

    override var intrinsicContentSize: CGSize {
        return sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        if bounds.isEmpty {
            return
        }
        
        let isImageViewShowing = imageView != nil && !imageView!.isHidden
        let isTitleLabelShowing = titleLabel != nil && !titleLabel!.isHidden
        var imageLimitSize = CGSize.zero
        var titleLimitSize = CGSize.zero
        var imageTotalSize = CGSize.zero // 包含 imageEdgeInsets 那些空间
        var titleTotalSize = CGSize.zero // 包含 titleEdgeInsets 那些空间
        let spacingBetweenImageAndTitle = flat((isImageViewShowing && isTitleLabelShowing) ? self.spacingBetweenImageAndTitle : 0) // 如果图片或文字某一者没显示，则这个 spacing 不考虑进布局
        var imageFrame = CGRect.zero;
        var titleFrame = CGRect.zero;
        let contentEdgeInsets = self.contentEdgeInsets.removeFloatMin()
        let contentSize = CGSize(width: bounds.width - contentEdgeInsets.horizontalValue, height: bounds.height - contentEdgeInsets.verticalValue)
        
        // 图片的布局原则都是尽量完整展示，所以不管 imagePosition 的值是什么，这个计算过程都是相同的
        if isImageViewShowing {
            imageLimitSize = CGSize(width: contentSize.width - imageEdgeInsets.horizontalValue, height: contentSize.height - imageEdgeInsets.verticalValue)
            var imageSize = imageView!.sizeThatFits(imageLimitSize)
            imageSize.width = fmin(imageSize.width, imageLimitSize.width)
            imageSize.height = fmin(imageSize.height, imageLimitSize.height)
            imageFrame = imageSize.rect
            imageTotalSize = CGSize(width: imageSize.width + imageEdgeInsets.horizontalValue, height: imageSize.height + imageEdgeInsets.verticalValue)
        }
        
        if imagePosition == .top || imagePosition == .bottom {
            if isTitleLabelShowing {
                titleLimitSize = CGSize(width: contentSize.width - titleEdgeInsets.horizontalValue, height: contentSize.height - imageTotalSize.height - spacingBetweenImageAndTitle - titleEdgeInsets.verticalValue)
                var titleSize = titleLabel!.sizeThatFits(titleLimitSize)
                titleSize.width = fmin(titleSize.width, titleLimitSize.width)
                titleSize.height = fmin(titleSize.height, titleLimitSize.height)
                titleFrame = titleSize.rect
                titleTotalSize = CGSize(width: titleSize.width + titleEdgeInsets.horizontalValue, height: titleSize.height + titleEdgeInsets.verticalValue)
            }
            
            switch contentHorizontalAlignment {
            case .left:
                imageFrame = isImageViewShowing ? imageFrame.setX(contentEdgeInsets.left + imageEdgeInsets.left) : imageFrame
                titleFrame = isTitleLabelShowing ? titleFrame.setX(contentEdgeInsets.left + self.titleEdgeInsets.left) : titleFrame
            case .center:
                imageFrame = isImageViewShowing ? imageFrame.setX(contentEdgeInsets.left + imageEdgeInsets.left + imageLimitSize.width.center(imageFrame.width)) : imageFrame
                titleFrame = isTitleLabelShowing ? titleFrame.setX(contentEdgeInsets.left + titleEdgeInsets.left + titleLimitSize.width.center(titleFrame.width)) : titleFrame
            case .right:
                imageFrame = isImageViewShowing ? imageFrame.setX(bounds.width - contentEdgeInsets.right - imageEdgeInsets.right - imageFrame.width) : imageFrame
                titleFrame = isTitleLabelShowing ? titleFrame.setX(bounds.width - contentEdgeInsets.right - titleEdgeInsets.right - titleFrame.width): titleFrame
            case .fill:
                if isImageViewShowing {
                    imageFrame = imageFrame.setX(contentEdgeInsets.left + imageEdgeInsets.left)
                    imageFrame = imageFrame.setWidth(imageLimitSize.width);
                }
                if isTitleLabelShowing {
                    titleFrame = titleFrame.setX(contentEdgeInsets.left + titleEdgeInsets.left);
                    titleFrame = titleFrame.setWidth(titleLimitSize.width);
                }
            default: break
            }
            
            if imagePosition == .top {
                switch contentVerticalAlignment {
                case .top:
                    imageFrame = isImageViewShowing ? imageFrame.setY(contentEdgeInsets.top + imageEdgeInsets.top) : imageFrame
                    titleFrame = isTitleLabelShowing ? titleFrame.setY(contentEdgeInsets.top + imageTotalSize.height + spacingBetweenImageAndTitle + titleEdgeInsets.top) : titleFrame
                case .center:
                    let contentHeight = imageTotalSize.height + spacingBetweenImageAndTitle + titleTotalSize.height
                    let minY = contentSize.height.center(contentHeight) + contentEdgeInsets.top
                    imageFrame = isImageViewShowing ? imageFrame.setY(minY + imageEdgeInsets.top) : imageFrame
                    titleFrame = isTitleLabelShowing ? titleFrame.setY(minY + imageTotalSize.height + spacingBetweenImageAndTitle + titleEdgeInsets.top) : titleFrame
                case .bottom:
                    titleFrame = isTitleLabelShowing ? titleFrame.setY(bounds.height - contentEdgeInsets.bottom - titleEdgeInsets.bottom - titleFrame.height) : titleFrame
                    imageFrame = isImageViewShowing ? imageFrame.setY(bounds.height - contentEdgeInsets.bottom - titleTotalSize.height - spacingBetweenImageAndTitle - imageEdgeInsets.bottom - imageFrame.height) : imageFrame
                case .fill:
                    if isImageViewShowing && isTitleLabelShowing {
                        // 同时显示图片和 label 的情况下，图片高度按本身大小显示，剩余空间留给 label
                        imageFrame = isImageViewShowing ? imageFrame.setY(contentEdgeInsets.top + imageEdgeInsets.top) : imageFrame
                        titleFrame = isTitleLabelShowing ? titleFrame.setY(contentEdgeInsets.top + imageTotalSize.height + spacingBetweenImageAndTitle + titleEdgeInsets.top) : titleFrame
                        titleFrame = isTitleLabelShowing ? titleFrame.setHeight(bounds.height - contentEdgeInsets.bottom - titleEdgeInsets.bottom - titleFrame.minY) : titleFrame
                    } else if isImageViewShowing {
                        imageFrame = imageFrame.setY(contentEdgeInsets.top + imageEdgeInsets.top)
                        imageFrame = imageFrame.setHeight(contentSize.height - imageEdgeInsets.verticalValue)
                    } else {
                        titleFrame = titleFrame.setY(contentEdgeInsets.top + titleEdgeInsets.top)
                        titleFrame = titleFrame.setHeight(contentSize.height - titleEdgeInsets.verticalValue)
                    }
                }
            } else {
                switch contentVerticalAlignment {
                case .top:
                    titleFrame = isTitleLabelShowing ? titleFrame.setY(contentEdgeInsets.top + titleEdgeInsets.top) : titleFrame
                    imageFrame = isImageViewShowing ? imageFrame.setY(contentEdgeInsets.top + titleTotalSize.height + spacingBetweenImageAndTitle + imageEdgeInsets.top) : imageFrame
                case .center:
                    let contentHeight = imageTotalSize.height + titleTotalSize.height + spacingBetweenImageAndTitle
                    let minY = contentSize.height.center(contentHeight) + contentEdgeInsets.top
                    titleFrame = isTitleLabelShowing ? titleFrame.setY(minY + titleEdgeInsets.top) : titleFrame
                    imageFrame = isImageViewShowing ? imageFrame.setY(minY + titleTotalSize.height + spacingBetweenImageAndTitle + imageEdgeInsets.top) : imageFrame
                case .bottom:
                    imageFrame = isImageViewShowing ? imageFrame.setY(bounds.height - contentEdgeInsets.bottom - self.imageEdgeInsets.bottom - imageFrame.height) : imageFrame
                    titleFrame = isTitleLabelShowing ? titleFrame.setY(bounds.height -  contentEdgeInsets.bottom - imageTotalSize.height - spacingBetweenImageAndTitle - titleEdgeInsets.bottom - titleFrame.height) : titleFrame
                case .fill:
                    if isImageViewShowing && isTitleLabelShowing {
                        // 同时显示图片和 label 的情况下，图片高度按本身大小显示，剩余空间留给 label
                        imageFrame = imageFrame.setY(bounds.height - contentEdgeInsets.bottom - imageEdgeInsets.bottom - imageFrame.height)
                        titleFrame = titleFrame.setY(contentEdgeInsets.top + titleEdgeInsets.top)
                        titleFrame = titleFrame.setHeight(bounds.height - contentEdgeInsets.bottom - imageTotalSize.height - spacingBetweenImageAndTitle - titleEdgeInsets.bottom - titleFrame.minY)
                    } else if isImageViewShowing {
                        imageFrame = imageFrame.setY(contentEdgeInsets.top + imageEdgeInsets.top)
                        imageFrame = imageFrame.setHeight(contentSize.height - imageEdgeInsets.verticalValue)
                    } else {
                        titleFrame = titleFrame.setY(contentEdgeInsets.top + titleEdgeInsets.top)
                        titleFrame = titleFrame.setHeight(contentSize.height - titleEdgeInsets.verticalValue)
                    }
                }
            }
            
            imageView?.frame = imageFrame.flatted
            titleLabel?.frame = titleFrame.flatted
        } else if imagePosition == .left || imagePosition == .right {
            
            if isTitleLabelShowing {
                titleLimitSize = CGSize(width: contentSize.width - titleEdgeInsets.horizontalValue - imageTotalSize.width - spacingBetweenImageAndTitle, height: contentSize.height - titleEdgeInsets.verticalValue)
                var titleSize = titleLabel!.sizeThatFits(titleLimitSize)
                titleSize.width = fmin(titleLimitSize.width, titleSize.width)
                titleSize.height = fmin(titleLimitSize.height, titleSize.height)
                titleFrame = titleSize.rect
                titleTotalSize = CGSize(width: titleSize.width + titleEdgeInsets.horizontalValue, height: titleSize.height + titleEdgeInsets.verticalValue)
            }
            
            switch contentVerticalAlignment {
            case .top:
                imageFrame = isImageViewShowing ? imageFrame.setY(contentEdgeInsets.top + imageEdgeInsets.top) : imageFrame
                titleFrame = isTitleLabelShowing ? titleFrame.setY(contentEdgeInsets.top + titleEdgeInsets.top) : titleFrame
            case .center:
                imageFrame = isImageViewShowing ? imageFrame.setY(contentEdgeInsets.top + contentSize.height.center(imageFrame.height) + imageEdgeInsets.top) : imageFrame
                titleFrame = isTitleLabelShowing ? titleFrame.setY(contentEdgeInsets.top + contentSize.height.center(titleFrame.height) + titleEdgeInsets.top) : titleFrame
            case .bottom:
                imageFrame = isImageViewShowing ? imageFrame.setY(bounds.height - contentEdgeInsets.bottom - imageEdgeInsets.bottom - imageFrame.height) : imageFrame
                titleFrame = isTitleLabelShowing ? titleFrame.setY(bounds.height -  contentEdgeInsets.bottom - titleEdgeInsets.bottom - titleFrame.height) : titleFrame
            case .fill:
                if isImageViewShowing {
                    imageFrame = imageFrame.setY(contentEdgeInsets.top + imageEdgeInsets.top)
                    imageFrame = imageFrame.setHeight(contentSize.height - imageEdgeInsets.verticalValue)
                }
                 if isTitleLabelShowing {
                    titleFrame = titleFrame.setY(contentEdgeInsets.top + titleEdgeInsets.top)
                    titleFrame = titleFrame.setHeight(contentSize.height - titleEdgeInsets.verticalValue)
                }
            }
            
            if imagePosition == .left {
                switch contentHorizontalAlignment {
                case .left:
                    imageFrame = isImageViewShowing ? imageFrame.setX(contentEdgeInsets.left + imageEdgeInsets.left) : imageFrame
                    titleFrame = isTitleLabelShowing ? titleFrame.setX(contentEdgeInsets.left + imageTotalSize.width + spacingBetweenImageAndTitle + titleEdgeInsets.left) : titleFrame
                case .center:
                    let contentWidth = imageTotalSize.width + spacingBetweenImageAndTitle + titleTotalSize.width
                    let minX = contentEdgeInsets.left + contentSize.width.center(contentWidth)
                    imageFrame = isImageViewShowing ? imageFrame.setX(minX + imageEdgeInsets.left) : imageFrame
                    titleFrame = isTitleLabelShowing ? titleFrame.setX(minX + imageTotalSize.width + spacingBetweenImageAndTitle + titleEdgeInsets.left) : titleFrame
                case .right:
                    if imageTotalSize.width + spacingBetweenImageAndTitle + titleTotalSize.width > contentSize.width {
                        // 图片和文字总宽超过按钮宽度，则优先完整显示图片
                        imageFrame = isImageViewShowing ? imageFrame.setX(contentEdgeInsets.left + imageEdgeInsets.left) : imageFrame
                        titleFrame = isTitleLabelShowing ? titleFrame.setX(contentEdgeInsets.left + imageTotalSize.width + spacingBetweenImageAndTitle + titleEdgeInsets.left) : titleFrame
                    } else {
                        // 内容不超过按钮宽度，则靠右布局即可
                        imageFrame = isImageViewShowing ? imageFrame.setX(bounds.width -  contentEdgeInsets.right - titleTotalSize.width - spacingBetweenImageAndTitle - imageTotalSize.width + imageEdgeInsets.left) : imageFrame
                        titleFrame = isTitleLabelShowing ? titleFrame.setX(bounds.width -  contentEdgeInsets.right - titleEdgeInsets.right - titleFrame.width) : titleFrame
                    }
                case .fill:
                    if isImageViewShowing && isTitleLabelShowing {
                        // 同时显示图片和 label 的情况下，图片按本身宽度显示，剩余空间留给 label
                        imageFrame = imageFrame.setX(contentEdgeInsets.left + imageEdgeInsets.left)
                        titleFrame = titleFrame.setX(contentEdgeInsets.left + imageTotalSize.width + spacingBetweenImageAndTitle + titleEdgeInsets.left)
                        titleFrame = titleFrame.setWidth(bounds.width - contentEdgeInsets.right - titleEdgeInsets.right - titleFrame.minX)
                    } else if isImageViewShowing {
                        imageFrame = imageFrame.setX(contentEdgeInsets.left + imageEdgeInsets.left)
                        imageFrame = imageFrame.setWidth(contentSize.width - imageEdgeInsets.horizontalValue)
                    } else {
                        titleFrame = titleFrame.setX(contentEdgeInsets.left + titleEdgeInsets.left)
                        titleFrame = titleFrame.setWidth(contentSize.width - titleEdgeInsets.horizontalValue)
                    }
                default: break
                }
            } else {
                switch contentHorizontalAlignment {
                case .left:
                    if imageTotalSize.width + spacingBetweenImageAndTitle + titleTotalSize.width > contentSize.width {
                        // 图片和文字总宽超过按钮宽度，则优先完整显示图片
                        imageFrame = isImageViewShowing ? imageFrame.setX(bounds.width - contentEdgeInsets.right - imageEdgeInsets.right - imageFrame.width) : imageFrame
                        titleFrame = isTitleLabelShowing ? titleFrame.setX(bounds.width - contentEdgeInsets.right - imageTotalSize.width - spacingBetweenImageAndTitle - titleTotalSize.width + titleEdgeInsets.left) : titleFrame
                    } else {
                        // 内容不超过按钮宽度，则靠左布局即可
                        imageFrame = isImageViewShowing ? imageFrame.setX(contentEdgeInsets.left + titleTotalSize.width + spacingBetweenImageAndTitle + imageEdgeInsets.left) : imageFrame
                        titleFrame = isTitleLabelShowing ? titleFrame.setX(contentEdgeInsets.left + titleEdgeInsets.left) : titleFrame
                    }
                    
                case .center:
                    let contentWidth = imageTotalSize.width + spacingBetweenImageAndTitle + titleTotalSize.width
                    let minX = contentEdgeInsets.left + contentSize.width.center(contentWidth)
                    imageFrame = isImageViewShowing ? imageFrame.setX(minX + titleTotalSize.width + spacingBetweenImageAndTitle + imageEdgeInsets.left) : imageFrame
                    titleFrame = isTitleLabelShowing ? titleFrame.setX(minX + titleEdgeInsets.left) : titleFrame
                case .right:
                    imageFrame = isImageViewShowing ? imageFrame.setX(bounds.width - contentEdgeInsets.right - imageEdgeInsets.right - imageFrame.width) : imageFrame
                    titleFrame = isTitleLabelShowing ? titleFrame.setX(bounds.width - contentEdgeInsets.right - imageTotalSize.width - spacingBetweenImageAndTitle - titleEdgeInsets.right - titleFrame.width) : titleFrame
                case .fill:
                    if isImageViewShowing && isTitleLabelShowing {
                        // 图片按自身大小显示，剩余空间由标题占满
                        imageFrame = imageFrame.setX(bounds.width - contentEdgeInsets.right - self.imageEdgeInsets.right - imageFrame.width)
                        titleFrame = titleFrame.setX(contentEdgeInsets.left + titleEdgeInsets.left)
                        titleFrame = titleFrame.setWidth(imageFrame.minX - imageEdgeInsets.left - spacingBetweenImageAndTitle - titleEdgeInsets.right - titleFrame.minX)
                    } else if isImageViewShowing {
                        imageFrame = imageFrame.setX(contentEdgeInsets.left + imageEdgeInsets.left)
                        imageFrame = imageFrame.setWidth(contentSize.width - imageEdgeInsets.horizontalValue)
                    } else {
                        titleFrame = titleFrame.setX(contentEdgeInsets.left + titleEdgeInsets.left)
                        titleFrame = titleFrame.setWidth(contentSize.width - titleEdgeInsets.horizontalValue)
                    }
                default: break
                }
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
                alpha = ButtonHighlightedAlpha
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
                alpha = ButtonDisabledAlpha
            } else {
                UIView.animate(withDuration: 0.25) {
                    self.alpha = 1
                }
            }
        }
    }

    fileprivate func adjustsButtonHighlighted() {
        guard let highlightedBackgroundColor = highlightedBackgroundColor else { return }

        highlightedBackgroundLayer.qmui_removeDefaultAnimations()
        layer.insertSublayer(highlightedBackgroundLayer, at: 0)

        highlightedBackgroundLayer.frame = bounds
        highlightedBackgroundLayer.cornerRadius = layer.cornerRadius
        highlightedBackgroundLayer.backgroundColor = isHighlighted ? highlightedBackgroundColor.cgColor : UIColorClear.cgColor

        if let highlightedBorderColor = highlightedBorderColor {
            layer.borderColor = isHighlighted ? highlightedBorderColor.cgColor : originBorderColor?.cgColor
        }
    }

    private func updateTitleColorIfNeeded() {
        if adjustsTitleTintColorAutomatically {
            setTitleColor(tintColor, for: .normal)
        }
        if adjustsTitleTintColorAutomatically, let currentAttributedTitle = currentAttributedTitle {
            let attributedString = NSMutableAttributedString(attributedString: currentAttributedTitle)
            let range = NSRange(location: 0, length: attributedString.length)
            attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: tintColor, range: range)
            setAttributedTitle(attributedString, for: .normal)
        }
    }

    private func updateImageRenderingModeIfNeeded() {
        // 实际上对于 UIButton 而言如果设置了 UIControlStateNormal 的 image，则其他所有 state 下的 image 默认都会返回 normal 这张图，所以这个判断只对 UIControlStateNormal 做就行了
        guard let _ = currentImage, let normalImage = image(for: .normal) else { return }
        let states: [UIControlState] = [.normal, .highlighted, .disabled]
        
        for state in states {
            guard let image = image(for: state) else {
                continue
            }
            
            if state.rawValue > 0 && image == normalImage {
                // 这个 state 下的 image 如果指针和 normal 一样，说明并没有对这个 state 设置特别的 image，所以不用处理
                continue
            }

            if adjustsImageTintColorAutomatically {
                // 这里的 setImage: 操作不需要使用 renderingMode 对 image 重新处理，而是放到重写的 setImage:forState 里去做就行了
                setImage(image, for: state)
            } else {
                // 如果不需要用template的模式渲染，并且之前是使用template的，则把renderingMode改回Original
                setImage(image.withRenderingMode(.alwaysOriginal), for: state)
            }
        }
    }

    override func setImage(_ image: UIImage?, for state: UIControlState) {
        var tmpImage = image
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
    var useForBarButtonItem: Bool = true {
        didSet {
            if useForBarButtonItem == oldValue || type != .back { return }
            // 只针对返回按钮，调整箭头和title之间的间距
            // @warning 这些数值都是每个iOS版本核对过没问题的，如果修改则要检查要每个版本里与系统UIBarButtonItem的布局是否一致
            if useForBarButtonItem {
                let titleOffsetBaseOnSystem = UIOffset(horizontal: IOS_VERSION >= 11.0 ? 6 : 7, vertical: 0) // 经过这些数值的调整后，自定义返回按钮的位置才能和系统默认返回按钮的位置对准，而配置表里设置的值是在这个调整的基础上再调整
                let configurationOffset = NavBarBarBackButtonTitlePositionAdjustment
                titleEdgeInsets = UIEdgeInsets(
                    top: titleOffsetBaseOnSystem.vertical + configurationOffset.vertical,
                    left: titleOffsetBaseOnSystem.horizontal + configurationOffset.horizontal,
                    bottom: -titleOffsetBaseOnSystem.vertical - configurationOffset.vertical,
                    right: -titleOffsetBaseOnSystem.horizontal - configurationOffset.horizontal)
                contentEdgeInsets = UIEdgeInsetsMake(
                    IOS_VERSION >= 11.0 ? 0 : 1, // iOS 11 以前的自定义返回按钮要特地往下偏移一点才会和系统的一模一样
                    IOS_VERSION >= 11.0 ? -8 : 0, // iOS 11 使用了自定义按钮后整个按钮都会强制被往右边挪 8pt，所以这里要通过 contentEdgeInsets.left 偏移回来
                    0,
                    titleEdgeInsets.left) // 保证 button 有足够的宽度
            }
            // 由于contentEdgeInsets会影响frame的大小，所以更新数值后需要重新计算size
            sizeToFit()
        }
    }
    
    private var buttonPosition: QMUINavigationButtonPosition = .none

    convenience init() {
        self.init(type: .normal)
    }

    /**
     *  导航栏按钮的初始化函数，指定的初始化方法
     *  @param type 按钮类型
     *  @param title 按钮的title
     */
    init(_ type: QMUINavigationButtonType, title: String?) {
        super.init(frame: .zero)
        self.type = type
        setTitle(title, for: .normal)
        renderButtonStyle()
        sizeToFit()
    }

    /**
     *  导航栏按钮的初始化函数
     *  @param type 按钮类型
     */
    convenience init(type: QMUINavigationButtonType) {
        self.init(type, title: nil)
    }

    /**
     *  导航栏按钮的初始化函数
     *  @param image 按钮的image
     */
    convenience init(image: UIImage) {
        self.init(type: .image)
        setImage(image, for: .normal)
        // 系统在iOS8及以后的版本默认对image的UIBarButtonItem加了上下3、左右11的padding，所以这里统一一下
        contentEdgeInsets = UIEdgeInsetsMake(3, 11, 3, 11)
        sizeToFit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // 修复系统的UIBarButtonItem里的图片无法跟着tintColor走
    override func setImage(_ image: UIImage?, for state: UIControlState) {
        var newImage = image
        if newImage != nil && newImage!.renderingMode == .automatic {
            // 由于 QMUINavigationButton 是用于 UIBarButtonItem 的，所以默认的行为应该是尽量去跟随 tintColor，所以做了这个优化
            newImage = newImage!.withRenderingMode(.alwaysTemplate)
        }

        super.setImage(newImage, for: state)
    }

    // 自定义nav按钮，需要根据这个来修改title的三态颜色
    override func tintColorDidChange() {
        super.tintColorDidChange()

        setTitleColor(tintColor, for: .normal)
        setTitleColor(tintColor.withAlphaComponent(NavBarHighlightedAlpha), for: .highlighted)
        setTitleColor(tintColor.withAlphaComponent(NavBarDisabledAlpha), for: .disabled)
    }

    // 对按钮内容添加偏移，让UIBarButtonItem适配最新设备的系统行为，统一位置
    override var alignmentRectInsets: UIEdgeInsets {
        var insets = super.alignmentRectInsets

        if !useForBarButtonItem || buttonPosition == .none {
            return insets
        }

        if buttonPosition == .left {
            // 正值表示往左偏移
            if type == .image {
                insets.setLeft(11)
            } else {
                insets.setLeft(8)
            }
        } else if buttonPosition == .right  {
            // 正值表示往右偏移
            if type == .image {
                insets.setRight(11)
            } else {
                insets.setRight(8)
            }
        }

        let isBackOrImageType = type == .back || type == .image
        if isBackOrImageType {
            insets.setTop(PixelOne)
        } else {
            insets.setTop(1)
        }

        return insets
    }

    private func renderButtonStyle() {
        if let font = NavBarButtonFont {
            titleLabel?.font = font
        }
        titleLabel?.backgroundColor = UIColorClear
        titleLabel?.lineBreakMode = .byTruncatingTail
        contentMode = .center
        contentHorizontalAlignment = .center
        contentVerticalAlignment = .center
        adjustsImageWhenHighlighted = false
        adjustsImageWhenDisabled = false

        switch type {
        case .bold:
            if let font = NavBarButtonFontBold{
                titleLabel?.font = font
            }
        case .back:
            contentHorizontalAlignment = .left
            
            guard let backIndicatorImage = NavBarBackIndicatorImage else {
                print("NavBarBackIndicatorImage 为 nil，无法创建正确的 QMUINavigationButtonTypeBack 按钮")
                return
            }
            setImage(backIndicatorImage, for: .normal)
            setImage(backIndicatorImage.qmui_image(alpha: NavBarHighlightedAlpha), for: .highlighted)
            setImage(backIndicatorImage.qmui_image(alpha: NavBarDisabledAlpha), for: .disabled)
        default:
            break
        }
    }

    /**
     *  创建一个 type 为 QMUINavigationButtonTypeBack 的 button 并作为 customView 用于生成一个 UIBarButtonItem，返回按钮的图片由配置表里的宏 NavBarBackIndicatorImage 决定。
     *  @param target 按钮点击事件的接收者
     *  @param Selector 按钮点击事件的方法
     *  @param tintColor 按钮要显示的颜色，如果为 nil，则表示跟随当前 UINavigationBar 的 tintColor
     */
    static func backBarButtonItem(target: Any?, action: Selector?, tintColor: UIColor?) -> UIBarButtonItem? {
        var backTitle: String?
        if NeedsBackBarButtonItemTitle {
            backTitle = "返回" // 默认文字用返回
            if let viewController = target as? UIViewController {
                let previousViewController = viewController.qmui_previousViewController
                if let item = previousViewController?.navigationItem.backBarButtonItem {
                    // 如果前一个界面有
                    backTitle = item.title
                } else if previousViewController?.title != nil {
                    backTitle = previousViewController!.title
                }
            }
        } else {
            backTitle = " "
        }
        
        return systemBarButtonItem(.back, title: backTitle, tintColor: tintColor, position: .left, target: target, action: action)
    }

    /**
     *  创建一个 type 为 QMUINavigationButtonTypeBack 的 button 并作为 customView 用于生成一个 UIBarButtonItem，返回按钮的图片由配置表里的宏 NavBarBackIndicatorImage 决定，按钮颜色跟随 UINavigationBar 的 tintColor。
     *  @param target 按钮点击事件的接收者
     *  @param Selector 按钮点击事件的方法
     */
    static func backBarButtonItem(target: Any?, action: Selector?) -> UIBarButtonItem? {
        return backBarButtonItem(target: target, action: action, tintColor: nil)
    }

    /**
     *  创建一个以 “×” 为图标的关闭按钮，图片由配置表里的宏 NavBarCloseButtonImage 决定。
     *  @param target 按钮点击事件的接收者
     *  @param Selector 按钮点击事件的方法
     *  @param tintColor 按钮要显示的颜色，如果为 nil，则表示跟随当前 UINavigationBar 的 tintColor
     */
    static func closeBarButtonItem(target: Any?, action: Selector?, tintColor: UIColor?)
        -> UIBarButtonItem {
            let item = UIBarButtonItem(image: NavBarCloseButtonImage, style: .plain, target: target, action: action)
            item.tintColor = tintColor
            return item
    }

    /**
     *  创建一个以 “×” 为图标的关闭按钮，图片由配置表里的宏 NavBarCloseButtonImage 决定，图片颜色跟随 UINavigationBar.tintColor。
     *  @param target 按钮点击事件的接收者
     *  @param Selector 按钮点击事件的方法
     */
    static func closeBarButtonItem(target: Any?, action: Selector?)
        -> UIBarButtonItem {
            return closeBarButtonItem(target: target, action: action, tintColor: nil)
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

    static func barButtonItem(type: QMUINavigationButtonType, title: String?, tintColor: UIColor?, position: QMUINavigationButtonPosition, target: Any?, action: Selector?) -> UIBarButtonItem? {
        let barButtonItem = systemBarButtonItem(type, title: title, tintColor: tintColor, position: position, target: target, action: action)
        return barButtonItem
    }

    /**
     *  创建一个 UIBarButtonItem
     *  @param type 按钮的类型
     *  @param title 按钮的标题
     *  @param position 按钮在 UINavigationBar 上的左右位置，如果某一边的按钮有多个，则只有最左边（最右边）的按钮需要设置为 QMUINavigationButtonPositionLeft（QMUINavigationButtonPositionRight），靠里的按钮使用 QMUINavigationButtonPositionNone 即可
     *  @param target 按钮点击事件的接收者
     *  @param Selector 按钮点击事件的方法
     */
    static func barButtonItem(type: QMUINavigationButtonType, title: String?, position: QMUINavigationButtonPosition, target: Any?, action: Selector?) -> UIBarButtonItem? {
        return barButtonItem(type: type, title: title, tintColor: nil, position: position, target: target, action: action)
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
    static func barButtonItem(navigationButton: QMUINavigationButton, tintColor: UIColor?, position: QMUINavigationButtonPosition, target: Any?, action: Selector?) -> UIBarButtonItem? {
        if let target = target, let action = action {
            navigationButton.addTarget(target, action: action, for: .touchUpInside)
        }
        navigationButton.tintColor = tintColor
        navigationButton.buttonPosition = position
        let barButtonItem = UIBarButtonItem(customView: navigationButton)
        return barButtonItem
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
    static func barButtonItem(navigationButton: QMUINavigationButton, position: QMUINavigationButtonPosition, target: Any?, action: Selector?) -> UIBarButtonItem? {
        return barButtonItem(navigationButton: navigationButton, tintColor: nil, position: position, target: target, action: action)
    }

    /**
     *  创建一个图片类型的 UIBarButtonItem
     *  @param image 按钮的图标
     *  @param tintColor 按钮的颜色，如果为 nil，则表示跟随当前 UINavigationBar 的 tintColor
     *  @param position 按钮在 UINavigationBar 上的左右位置，如果某一边的按钮有多个，则只有最左边（最右边）的按钮需要设置为 QMUINavigationButtonPositionLeft（QMUINavigationButtonPositionRight），靠里的按钮使用 QMUINavigationButtonPositionNone 即可
     *  @param target 按钮点击事件的接收者
     *  @param Selector 按钮点击事件的方法
     */
    static func barButtonItem(image: UIImage?, tintColor: UIColor?, position: QMUINavigationButtonPosition, target: Any?, action: Selector?) -> UIBarButtonItem? {
        let barButtonItem = UIBarButtonItem(image: image, style: .plain, target: target, action: action)
        barButtonItem.tintColor = tintColor
        return barButtonItem
    }

    /**
     *  创建一个图片类型的 UIBarButtonItem
     *  @param image 按钮的图标
     *  @param position 按钮在 UINavigationBar 上的左右位置，如果某一边的按钮有多个，则只有最左边（最右边）的按钮需要设置为 QMUINavigationButtonPositionLeft（QMUINavigationButtonPositionRight），靠里的按钮使用 QMUINavigationButtonPositionNone 即可
     *  @param target 按钮点击事件的接收者
     *  @param Selector 按钮点击事件的方法
     */
    static func barButtonItem(image: UIImage?, position: QMUINavigationButtonPosition, target: Any?, action: Selector?) -> UIBarButtonItem? {
        return barButtonItem(image: image, tintColor: nil, position: position, target: target, action: action)
    }
    
    static private func systemBarButtonItem(_ type: QMUINavigationButtonType, title: String?, tintColor: UIColor?, position: QMUINavigationButtonPosition, target: Any?, action: Selector?) -> UIBarButtonItem?  {
        
        switch type {
        case .back:
            // 因为有可能出现有箭头图片又有title的情况，所以这里不适合用barButtonItemWithImage:target:action:的那个接口
            let button = QMUINavigationButton(.back, title: title)
            button.buttonPosition = position
            if let action = action {
                button.addTarget(target, action: action, for: .touchUpInside)
            }
            button.tintColor = tintColor
            let barButtonItem = UIBarButtonItem(customView: button)
            return barButtonItem
        case .bold:
            let barButtonItem = UIBarButtonItem(title: title, style: .done, target: target, action: action)
            barButtonItem.tintColor = tintColor
            if let font = NavBarButtonFontBold {
                barButtonItem.setTitleTextAttributes([NSAttributedStringKey.font: font], for: .normal)

                if let tempAttributes = barButtonItem.titleTextAttributes(for: .normal) {
                    let attributes = Dictionary(uniqueKeysWithValues: tempAttributes.map {
                        key, value in (NSAttributedStringKey(key), value)
                    })
                    barButtonItem.setTitleTextAttributes(attributes, for: .highlighted)// iOS 11 如果不显式设置 highlighted 的样式，点击时字体会从加粗变成默认，导致抖动
                }
            }
            return barButtonItem
        case .image:
            // icon - 这种类型请通过barButtonItemWithImage:position:target:action:来定义
            return nil
        default:
            let barButtonItem = UIBarButtonItem(title: title, style: .plain, target: target, action: action)
            barButtonItem.tintColor = tintColor
            return barButtonItem
        }
    }
}

/**
 *  `QMUIToolbarButton`是用于底部工具栏的按钮
 */
class QMUIToolbarButton: UIButton {
    /// 获取当前按钮的type
    private(set) var type: QMUIToolbarButtonType = .normal
    
    convenience init() {
        self.init(type: .normal)
    }

    /**
     *  工具栏按钮的初始化函数
     *  @param type  按钮类型
     */
    convenience init(type: QMUIToolbarButtonType) {
        self.init(type: type, title: nil)
    }

    /**
     *  工具栏按钮的初始化函数
     *  @param type 按钮类型
     *  @param title 按钮的title
     */
    init(type: QMUIToolbarButtonType, title: String?) {
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
    convenience init(image: UIImage) {
        self.init(type: .image)
        self.setImage(image, for: .normal)
        self.setImage(image.qmui_image(alpha: ToolBarHighlightedAlpha), for: .highlighted)
        self.setImage(image.qmui_image(alpha: ToolBarDisabledAlpha), for: .disabled)
        self.sizeToFit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func renderButtonStyle() {
        imageView?.contentMode = .center
        imageView?.tintColor = nil // 重置默认值，nil表示跟随父元素
        titleLabel?.font = ToolBarButtonFont
        switch type {
        case .normal:
            setTitleColor(ToolBarTintColor, for: .normal)
            setTitleColor(ToolBarTintColorHighlighted, for: .highlighted)
            setTitleColor(ToolBarTintColorDisabled, for: .disabled)
        case .red:
            setTitleColor(UIColorRed, for: .normal)
            setTitleColor(UIColorRed.withAlphaComponent(ToolBarHighlightedAlpha), for: .highlighted)
            setTitleColor(UIColorRed.withAlphaComponent(ToolBarDisabledAlpha), for: .disabled)
            imageView?.tintColor = UIColorRed; // 修改为红色
        default: break
        }
        
    }

    /// 在原有的QMUIToolbarButton上创建一个UIBarButtonItem
    static func barButtonItem(toolbarButton: QMUIToolbarButton, target: Any?, action: Selector?) -> UIBarButtonItem? {
        if let action = action {
            toolbarButton.addTarget(target, action: action, for: .touchUpInside)
        }
        let buttonItem = UIBarButtonItem(customView: toolbarButton)
        return buttonItem
    }

    /// 创建一个特定type的UIBarButtonItem
    static func barButtonItem(type: QMUIToolbarButtonType, title: String?, target: Any?, action: Selector?) -> UIBarButtonItem? {
        let buttonItem = UIBarButtonItem(title: title, style: .plain, target: target, action: action)
        if type == .red {
            // 默认继承toolBar的tintColor，红色需要重置
            buttonItem.tintColor = UIColorRed
        }
        return buttonItem
    }

    /// 创建一个图标类型的UIBarButtonItem
    static func barButtonItem(image: UIImage?, target: Any?, action: Selector?) -> UIBarButtonItem? {
        let buttonItem = UIBarButtonItem(image: image, style: .plain, target: target, action: action)
        return buttonItem
    }
}

/**
 *  支持显示下划线的按钮，可用于需要链接的场景。下划线默认和按钮宽度一样，可通过 `underlineInsets` 调整。
 */
class QMUILinkButton: QMUIButton {

    /// 控制下划线隐藏或显示，默认为NO，也即显示下划线
    @IBInspectable var underlineHidden: Bool = false {
        didSet {
            underlineLayer.isHidden = underlineHidden
        }
    }

    /// 设置下划线的宽度，默认为 1
    @IBInspectable var underlineWidth: CGFloat = 1 {
        didSet {
            setNeedsLayout()
        }
    }

    /// 控制下划线颜色，若设置为nil，则使用当前按钮的titleColor的颜色作为下划线的颜色。默认为 nil。
    @IBInspectable var underlineColor: UIColor? {
        didSet {
            updateUnderlineColor()
        }
    }

    /// 下划线的位置是基于 titleLabel 的位置来计算的，默认x、width均和titleLabel一致，而可以通过这个属性来调整下划线的偏移值。默认为UIEdgeInsetsZero。
    @IBInspectable var underlineInsets: UIEdgeInsets = .zero {
        didSet {
            setNeedsLayout()
        }
    }

    private var underlineLayer: CALayer = CALayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        didInitialized()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        didInitialized()
    }

    override func didInitialized() {
        super.didInitialized()
        underlineLayer.qmui_removeDefaultAnimations()
        layer.addSublayer(underlineLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if underlineLayer.isHidden {
            return
        }
        underlineLayer.frame = CGRect(x: underlineInsets.left, y: (titleLabel?.frame.maxY ?? 0) +  underlineInsets.top - underlineInsets.bottom, width: bounds.width - underlineInsets.horizontalValue, height: underlineWidth)
    }
    
    override func setTitleColor(_ color: UIColor?, for state: UIControlState) {
        super.setTitleColor(color, for: state)
        updateUnderlineColor()
    }
    
    private func updateUnderlineColor() {
        var color = underlineColor
        if color == nil {
            color = titleColor(for: .normal)
        }
        underlineLayer.backgroundColor = color?.cgColor
    }
}

/**
 *  用于 `QMUIGhostButton.cornerRadius` 属性，当 `cornerRadius` 为 `QMUIGhostButtonCornerRadiusAdjustsBounds` 时，`QMUIGhostButton` 会在高度变化时自动调整 `cornerRadius`，使其始终保持为高度的 1/2。
 */
fileprivate let QMUIGhostButtonCornerRadiusAdjustsBounds: CGFloat = -1

/**
 *  “幽灵”按钮，也即背景透明、带圆角边框的按钮
 *
 *  可通过 `QMUIGhostButtonColor` 设置几种预设的颜色，也可以用 `ghostColor` 设置自定义颜色。
 *
 *  @warning 默认情况下，`ghostColor` 只会修改文字和边框的颜色，如果需要让 image 也跟随 `ghostColor` 的颜色，则可将 `adjustsImageWithGhostColor` 设为 `YES`
 */
class QMUIGhostButton: QMUIButton {
    @IBInspectable var ghostColor: UIColor = GhostButtonColorBlue { // 默认为 GhostButtonColorBlue
        didSet {
            setTitleColor(ghostColor, for: .normal)
            layer.borderColor = ghostColor.cgColor
            if adjustsImageWithGhostColor {
                updateImageColor()
            }
        }
    }

    @IBInspectable var borderWidth: CGFloat = 1 { // 默认为 1pt
        didSet {
            layer.borderWidth = borderWidth
        }
    }

    @IBInspectable var cornerRadius: CGFloat = QMUIGhostButtonCornerRadiusAdjustsBounds / 2 { // 默认为 QMUIGhostButtonCornerRadiusAdjustsBounds，也即固定保持按钮高度的一半。
        didSet {
            setNeedsLayout()
        }
    }

    /**
     *  控制按钮里面的图片是否也要跟随 `ghostColor` 一起变化，默认为 `NO`
     */
    var adjustsImageWithGhostColor: Bool = false {
        didSet {
            updateImageColor()
        }
    }

    init(ghostColor: UIColor, frame: CGRect) {
        super.init(frame: frame)
        self.ghostColor = ghostColor
    }
    
    convenience init(ghostColor: UIColor) {
        self.init(ghostColor: ghostColor, frame: .zero)
    }

    convenience init(ghostType: QMUIGhostButtonColor, frame: CGRect) {
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
        self.init(ghostColor: ghostColor ?? .blue, frame: frame)
    }

    convenience init(ghostType: QMUIGhostButtonColor) {
        self.init(ghostType: ghostType, frame: .zero)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.ghostColor = GhostButtonColorBlue
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.ghostColor = GhostButtonColorBlue
    }

    private func updateImageColor() {
        imageView?.tintColor = adjustsImageWithGhostColor ? ghostColor : nil
        guard let _ = currentImage else { return }
        let states: [UIControlState] = [.normal, .highlighted, .disabled]
        for state in states {
            if let image = image(for: state) {
                if adjustsImageWithGhostColor {
                    // 这里的image不用做renderingMode的处理，而是放到重写的setImage:forState里去做
                    setImage(image, for: state)
                } else {
                    // 如果不需要用template的模式渲染，并且之前是使用template的，则把renderingMode改回Original
                    setImage(image.withRenderingMode(.alwaysOriginal), for: state)
                }
            }
        }
    }

    override func setImage(_ image: UIImage?, for state: UIControlState) {
        var newImage = image
        if adjustsImageWithGhostColor {
            newImage = image?.withRenderingMode(.alwaysTemplate)
        }
        super.setImage(newImage, for: state)
    }

    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        if cornerRadius != QMUIGhostButtonCornerRadiusAdjustsBounds {
            layer.cornerRadius = cornerRadius
        } else {
            layer.cornerRadius = flat(bounds.height / 2)
        }
    }
}

extension QMUIGhostButton {
    
    public override static func appearance() -> QMUIGhostButton {
        
        return QMUIGhostButton(ghostType: .blue)
    }
    
    static func setDefaultAppearance() {
        let appearance = QMUIGhostButton.appearance()
        appearance.borderWidth = 1
        appearance.cornerRadius = QMUIGhostButtonCornerRadiusAdjustsBounds
        appearance.adjustsImageWithGhostColor = false
    }
}

/**
 *  用于 `QMUIFillButton.cornerRadius` 属性，当 `cornerRadius` 为 `QMUIFillButtonCornerRadiusAdjustsBounds` 时，`QMUIFillButton` 会在高度变化时自动调整 `cornerRadius`，使其始终保持为高度的 1/2。
 */
fileprivate let QMUIFillButtonCornerRadiusAdjustsBounds: CGFloat = -1

/**
 *  QMUIFillButton
 *  实心填充颜色的按钮，支持预定义的几个色值
 */

class QMUIFillButton: QMUIButton {
    @IBInspectable var fillColor: UIColor = .blue { // 默认为 FillButtonColorBlue
        didSet {
            backgroundColor = fillColor
        }
    }

    @IBInspectable var titleTextColor: UIColor = UIColorWhite { // 默认为 UIColorWhite
        didSet {
            if adjustsImageWithTitleTextColor {
                updateImageColor()
            }
        }
    }

    @IBInspectable var cornerRadius: CGFloat = QMUIFillButtonCornerRadiusAdjustsBounds / 2 { // 默认为 QMUIFillButtonCornerRadiusAdjustsBounds，也即固定保持按钮高度的一半。
        didSet {
            setNeedsLayout()
        }
    }

    /**
     *  控制按钮里面的图片是否也要跟随 `titleTextColor` 一起变化，默认为 `NO`
     */
    var adjustsImageWithTitleTextColor: Bool = false {
        didSet {
            if adjustsImageWithTitleTextColor {
                self.updateImageColor()
            }
        }
    }

    convenience init() {
        self.init(with: .blue)
    }

    convenience override init(frame: CGRect) {
        self.init(with: .blue, frame: frame)
    }

    convenience init(with _: QMUIFillButtonColor) {
        self.init(with: .blue, frame: .zero)
    }

    convenience init(with fillType: QMUIFillButtonColor, frame: CGRect) {
        var fillColor = FillButtonColorBlue
        let textColor = UIColorWhite
        switch fillType {
        case .blue:
            fillColor = FillButtonColorBlue
        case .red:
            fillColor = FillButtonColorRed
        case .green:
            fillColor = FillButtonColorGreen
        case .gray:
            fillColor = FillButtonColorGray
        case .white:
            fillColor = FillButtonColorWhite
        }

        self.init(with: fillColor ?? .blue, titleTextColor: textColor, frame: frame)
    }

    convenience init(with fillColor: UIColor, titleTextColor: UIColor) {
        self.init(with: fillColor, titleTextColor: titleTextColor, frame: .zero)
    }

    init(with fillColor: UIColor, titleTextColor: UIColor, frame: CGRect) {
        super.init(frame: frame)

        self.fillColor = fillColor
        self.titleTextColor = titleTextColor
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.fillColor = FillButtonColorBlue ?? .blue
        self.titleTextColor = UIColorWhite
    }

    override func setImage(_ image: UIImage?, for state: UIControlState) {
        var image = image
        if adjustsImageWithTitleTextColor {
            image = image?.withRenderingMode(.alwaysTemplate)
        }
        super.setImage(image, for: state)
    }

    private func updateImageColor() {
        self.imageView?.tintColor = adjustsImageWithTitleTextColor ? self.titleTextColor : nil
        if self.currentImage != nil {
            let states: [UIControlState] = [.normal, .highlighted, .disabled]
            for state in states {
                if let image = self.image(for: state) {
                    if self.adjustsImageWithTitleTextColor {
                        // 这里的image不用做renderingMode的处理，而是放到重写的setImage:forState里去做
                        self.setImage(image, for: state)
                    } else {
                        // 如果不需要用template的模式渲染，并且之前是使用template的，则把renderingMode改回Original
                        self.setImage(image.withRenderingMode(.alwaysOriginal), for: state)
                    }
                }
            }
        }
    }

    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        if self.cornerRadius != QMUIGhostButtonCornerRadiusAdjustsBounds {
            self.layer.cornerRadius = self.cornerRadius
        } else {
            self.layer.cornerRadius = flat(self.bounds.height / 2)
        }
    }
}
