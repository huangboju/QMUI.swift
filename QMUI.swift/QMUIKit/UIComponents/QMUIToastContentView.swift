//
//  QMUIToastContentView.swift
//  QMUI.swift
//
//  Created by 黄伯驹 on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

/**
 * `QMUIToastView`默认使用的contentView。其结构是：customView->textLabel->detailTextLabel等三个view依次往下排列。其中customView可以赋值任意的UIView或者自定义的view。
 *
 * @TODO: 增加多种类型的progressView的支持。
 */
class QMUIToastContentView: UIView {
    /**
     * 设置一个UIView，可以是：菊花、图片等等
     */
    var customView: UIView? {
        willSet {
            guard let notNilCustomView = customView else {
                return
            }
            notNilCustomView.removeFromSuperview()
        }
        didSet {
            guard let notNilCustomView = customView else {
                return
            }
            addSubview(notNilCustomView)
            updateCustomViewTintColor()
            setNeedsLayout()
        }
    }

    /**
     * 设置第一行大文字label
     */
    var textLabel: UILabel = UILabel()

    /**
     * 通过textLabelText设置可以应用textLabelAttributes的样式，如果通过textLabel.text设置则可能导致一些样式失效。
     */
    var textLabelText: String = "" {
        didSet {
            textLabel.attributedText = NSAttributedString(string: textLabelText, attributes: textLabelAttributes)
            textLabel.textAlignment = .center
            setNeedsDisplay()
        }
    }

    /**
     * 设置第二行小文字label
     */
    var detailTextLabel: UILabel = UILabel()

    /**
     * 通过detailTextLabelText设置可以应用detailTextLabelAttributes的样式，如果通过detailTextLabel.text设置则可能导致一些样式失效。
     */
    var detailTextLabelText: String = "" {
        didSet {
            detailTextLabel.attributedText = NSAttributedString(string: detailTextLabelText, attributes: detailTextLabelAttributes)
            detailTextLabel.textAlignment = .center
            setNeedsDisplay()
        }
    }

    /**
     * 设置上下左右的padding。
     */
    var insets: UIEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16) {
        didSet {
            setNeedsLayout()
        }
    }

    /**
     * 设置最小size。
     */
    var minimumSize: CGSize = .zero {
        didSet {
            setNeedsLayout()
        }
    }

    /**
     * 设置customView的marginBottom
     */
    var customViewMarginBottom: CGFloat = 8 {
        didSet {
            setNeedsLayout()
        }
    }

    /**
     * 设置textLabel的marginBottom
     */
    var textLabelMarginBottom: CGFloat = 4 {
        didSet {
            setNeedsLayout()
        }
    }

    /**
     * 设置detailTextLabel的marginBottom
     */
    var detailTextLabelMarginBottom: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }

    /**
     * 设置textLabel的attributes
     */
    var textLabelAttributes = [NSAttributedString.Key.font: UIFontBoldMake(16), NSAttributedString.Key.foregroundColor: UIColorWhite, NSAttributedString.Key.paragraphStyle: NSMutableParagraphStyle(lineHeight: 22)] {
        didSet {
            if textLabelText.length > 0 {
                // 刷新label的Attributes
                let tmpStr = textLabelText
                textLabelText = tmpStr
            }
        }
    }

    /**
     * 设置detailTextLabel的attributes
     */
    var detailTextLabelAttributes = [NSAttributedString.Key.font: UIFontBoldMake(12), NSAttributedString.Key.foregroundColor: UIColorWhite, NSAttributedString.Key.paragraphStyle: NSMutableParagraphStyle(lineHeight: 18)] {
        didSet {
            if detailTextLabelText.length > 0 {
                // 刷新label的Attributes
                let tmpStr = detailTextLabelText
                detailTextLabelText = tmpStr
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        initSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        initSubviews()
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let hasCustomeView = customView != nil
        let hasTextLabel = textLabel.text?.length ?? 0 > 0
        let hasDetailTextLabel = detailTextLabel.text?.length ?? 0 > 0

        var width: CGFloat = 0
        var height: CGFloat = 0

        let maxContentWidth = size.width - insets.horizontalValue
        let maxContentHeight = size.height - insets.verticalValue

        if hasCustomeView {
            width = max(width, customView?.bounds.width ?? 0)
            height += (customView?.bounds.height ?? 0 + ((hasTextLabel || hasDetailTextLabel) ? customViewMarginBottom : 0))
        }

        if hasTextLabel {
            let textLabelSize = textLabel.sizeThatFits(CGSize(width: maxContentWidth, height: maxContentHeight))
            width = max(width, textLabelSize.width)
            height += textLabelSize.height + (hasDetailTextLabel ? textLabelMarginBottom : 0)
        }

        if hasDetailTextLabel {
            let detailTextLabelSize = detailTextLabel.sizeThatFits(CGSize(width: maxContentWidth, height: maxContentHeight))
            width = max(width, detailTextLabelSize.width)
            height += (detailTextLabelSize.height + detailTextLabelMarginBottom)
        }

        width += insets.horizontalValue
        height += insets.verticalValue

        if minimumSize != .zero {
            width = max(width, minimumSize.width)
            height = max(height, minimumSize.height)
        }

        return CGSize(width: min(size.width, width),
                      height: min(size.height, height))
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let hasCustomView = customView != nil
        let hasTextLabel = textLabel.text?.length ?? 0 > 0
        let hasDetailTextLabel = detailTextLabel.text?.length ?? 0 > 0

        let contentWidth = bounds.width
        let maxContentWidth = contentWidth - insets.horizontalValue

        var minY = insets.top

        if hasCustomView {
            if !hasTextLabel && !hasDetailTextLabel {
                // 处理有minimumSize的情况
                minY = bounds.height.center(customView?.bounds.height ?? 0)
            }
            customView?.frame = CGRectFlat(contentWidth.center(customView?.bounds.width ?? 0),
                                           minY,
                                           customView?.bounds.width ?? 0,
                                           customView?.bounds.height ?? 0)
            minY = customView?.frame.maxY ?? 0 + customViewMarginBottom
        }

        if hasTextLabel {
            let textLabelSize = textLabel.sizeThatFits(CGSize(width: maxContentWidth, height: .greatestFiniteMagnitude))
            if !hasCustomView && !hasDetailTextLabel {
                // 处理有minimumSize的情况
                minY = bounds.height.center(textLabelSize.height)
            }
            textLabel.frame = CGRectFlat(contentWidth.center(maxContentWidth),
                                         minY,
                                         maxContentWidth,
                                         textLabelSize.height)
            minY = textLabel.frame.maxY + textLabelMarginBottom
        }

        if hasDetailTextLabel {
            // 暂时没考虑剩余高度不够用的情况
            let detailTextLabelSize = detailTextLabel.sizeThatFits(CGSize(width: maxContentWidth, height: .greatestFiniteMagnitude))
            if !hasCustomView && !hasTextLabel {
                // 处理有minimumSize的情况
                minY = bounds.height.center(detailTextLabelSize.height)
            }
            detailTextLabel.frame = CGRectFlat(contentWidth.center(maxContentWidth),
                                               minY,
                                               maxContentWidth,
                                               detailTextLabelSize.height)
        }
    }

    override func tintColorDidChange() {
        if customView != nil {
            updateCustomViewTintColor()
        }

        textLabelAttributes[.foregroundColor] = tintColor
        let tmpStr = textLabelText
        textLabelText = tmpStr

        detailTextLabelAttributes[.foregroundColor] = tintColor
        let detailTmpStr = detailTextLabelText
        detailTextLabelText = detailTmpStr
    }

    private func initSubviews() {
        textLabel.numberOfLines = 0
        textLabel.textAlignment = .center
        textLabel.textColor = UIColorWhite
        textLabel.font = UIFontBoldMake(16)
        textLabel.isOpaque = false
        addSubview(textLabel)

        detailTextLabel.numberOfLines = 0
        detailTextLabel.textAlignment = .center
        detailTextLabel.textColor = UIColorWhite
        detailTextLabel.font = UIFontBoldMake(12)
        detailTextLabel.isOpaque = false
        addSubview(detailTextLabel)
    }

    private func updateCustomViewTintColor() {
        guard let notNilCustomView = customView else {
            return
        }

        notNilCustomView.tintColor = tintColor
        if let imageView = notNilCustomView as? UIImageView {
            imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
        }
        if let activityView = notNilCustomView as? UIActivityIndicatorView {
            activityView.color = tintColor
        }
    }
}
