//
//  QMUILabel.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/3/17.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

/**
 * `QMUILabel`支持通过`contentEdgeInsets`属性来实现类似padding的效果。
 *
 * 同时通过将`canPerformCopyAction`置为`YES`来开启长按复制文本的功能，长按时label的背景色默认为`highlightedBackgroundColor`
 */
class QMUILabel: UILabel {
    /// 控制label内容的padding，默认为UIEdgeInsetsZero
    public var contentEdgeInsets: UIEdgeInsets = .zero

    /// 是否需要长按复制的功能，默认为 false。
    /// 长按时的背景色通过`highlightedBackgroundColor`设置。
    @IBInspectable
    public var canPerformCopyAction = false {
        didSet {
            setCanPerformCopyAction()
        }
    }

    /// 如果打开了`canPerformCopyAction`，则长按时背景色将会被改为`highlightedBackgroundColor`
    @IBInspectable
    public var highlightedBackgroundColor: UIColor? {
        didSet {
            tempBackgroundColor = backgroundColor
        }
    }

    private var tempBackgroundColor: UIColor?
    private var longGestureRecognizer: UILongPressGestureRecognizer?

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let targetSize = CGSize(width: size.width - contentEdgeInsets.horizontalValue,
                                height: size.height - contentEdgeInsets.verticalValue)
        var retulet = super.sizeThatFits(targetSize)
        retulet.width += contentEdgeInsets.horizontalValue
        retulet.height += contentEdgeInsets.verticalValue
        return retulet
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: contentEdgeInsets))
    }

    override var isHighlighted: Bool {
        didSet {
            if let highlightedBackgroundColor = highlightedBackgroundColor {
                backgroundColor = isHighlighted ? highlightedBackgroundColor : tempBackgroundColor
            }
        }
    }

    // MARK: - 长按复制功能
    private func setCanPerformCopyAction() {
        if canPerformCopyAction && longGestureRecognizer == nil {
            isUserInteractionEnabled = true
            longGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGestureRecognizer))
            addGestureRecognizer(longGestureRecognizer!)

            NotificationCenter.default.addObserver(self, selector: #selector(handleMenuWillHideNotification), name: UIMenuController.willHideMenuNotification, object: nil)

            if !(highlightedBackgroundColor != nil) {
                highlightedBackgroundColor = TableViewCellSelectedBackgroundColor // 设置个默认值
            }
        } else if let longGestureRecognizer = longGestureRecognizer, !canPerformCopyAction {
            removeGestureRecognizer(longGestureRecognizer)
            self.longGestureRecognizer = nil
            isUserInteractionEnabled = false

            NotificationCenter.default.removeObserver(self)
        }
    }

    override var canBecomeFirstResponder: Bool {
        return canPerformCopyAction
    }

    override func canPerformAction(_ action: Selector, withSender _: Any?) -> Bool {
        if canBecomeFirstResponder {
            return action == #selector(copyString)
        }
        return false
    }

    @objc
    private func copyString() {
        if canPerformCopyAction {
            let pasteboard = UIPasteboard.general
            if let text = text {
                pasteboard.string = text
            }
        }
    }

    @objc
    private func handleLongPressGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        if !canPerformCopyAction {
            return
        }
        if gestureRecognizer.state == .began {
            becomeFirstResponder()
            let menuController = UIMenuController.shared
            let copyMenuItem = UIMenuItem(title: "复制", action: #selector(copyString))
            menuController.menuItems = [copyMenuItem]
            menuController.setTargetRect(frame, in: superview!)
            menuController.setMenuVisible(true, animated: true)

            // 默认背景色
            tempBackgroundColor = backgroundColor
            backgroundColor = highlightedBackgroundColor
        }
    }

    @objc
    private func handleMenuWillHideNotification(_: NSNotification) {
        if !canPerformCopyAction {
            return
        }
        if let tempBackgroundColor = tempBackgroundColor {
            backgroundColor = tempBackgroundColor
        }
    }
}
