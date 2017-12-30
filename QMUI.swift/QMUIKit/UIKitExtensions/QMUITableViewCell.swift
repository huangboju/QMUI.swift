//
//  QMUITableViewCell.swift
//  QMUI.swift
//
//  Created by xnxin on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

import UIKit

class QMUITableViewCell: UITableViewCell {

    public private(set) var style: UITableViewCellStyle = .default

    /**
     *  imageEdgeInsets，这个属性用来调整imageView里面图片的位置，有些情况titleLabel前面是一个icon，但是icon与titleLabel的间距不是你想要的。<br/>
     *  @warning 目前只对UITableViewCellStyleDefault和UITableViewCellStyleSubtitle类型的cell开放
     */
    public var imageEdgeInsets: UIEdgeInsets = .zero

    /**
     *  textLabelEdgeInsets，这个属性和imageEdgeInsets合作使用，用来调整titleLabel的位置，默认为 UIEdgeInsetsZero。<br/>
     *  @warning 目前只对UITableViewCellStyleDefault和UITableViewCellStyleSubtitle类型的cell开放。
     */
    public var textLabelEdgeInsets: UIEdgeInsets = .zero

    /// 与textLabelEdgeInsets一致，作用目标为detailTextLabel，默认为 UIEdgeInsetsZero。
    public var detailTextLabelEdgeInsets: UIEdgeInsets = .zero

    /// 用于调整右边 accessoryView 的布局偏移，默认为 UIEdgeInsetsZero。
    public var accessoryEdgeInsets: UIEdgeInsets = .zero

    /// 用于调整accessoryView的点击响应区域，可用负值扩大点击范围，默认为(-12, -12, -12, -12)
    public var accessoryHitTestEdgeInsets: UIEdgeInsets = UIEdgeInsets(top: -12, left: -12, bottom: -12, right: -12)

    /// 设置当前cell是否enabled，setter方法里面会修改当前的subviews样式。
    public var isEnabled: Bool = true {
        willSet {
            if newValue {
                self.isUserInteractionEnabled = true
                self.textLabel?.textColor = TableViewCellTitleLabelColor
                self.detailTextLabel?.textColor = TableViewCellDetailLabelColor
            } else {
                self.isUserInteractionEnabled = false
                self.textLabel?.textColor = UIColorDisabled
                self.detailTextLabel?.textColor = UIColorDisabled
            }
        }
    }

    /// 保存对tableView的弱引用，在布局时可能会使用到tableView的一些属性例如separatorColor等。只有使用下面两个 initForTableView: 的接口初始化时这个属性才有值，否则就只能自己初始化后赋值
    public weak var parentTableView: UITableView?

    /**
     *  cell 处于 section 中的位置，要求：
     *  1. cell 使用 initForTableViewXxx 方法初始化，或者初始化完后为 parentTableView 属性赋值。
     *  2. 在 cellForRow 里调用 [cell updateCellAppearanceWithIndexPath:] 方法。
     *  3. 之后即可通过 cellPosition 获取到正确的位置。
     */
    public fileprivate(set) var cellPosition: QMUITableViewCellPosition = .none

    private lazy var defaultAccessoryImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        return imageView
    }()

    private lazy var defaultAccessoryButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(handleAccessoryButtonEvent(_:)), for: .touchUpInside)
        return button
    }()

    private var defaultDetailDisclosureView: UIView = {
        UIView()
    }()

    /**
     *  首选初始化方法
     *
     *  @param tableView       cell所在的tableView
     *  @param style           tableView的style
     *  @param reuseIdentifier tableView的reuseIdentifier
     *
     *  @return 一个QMUITableViewCell实例
     */
    convenience init(for tableView: UITableView, withStyle style: UITableViewCellStyle, reuseIdentifier: String?) {
        self.init(style: style, reuseIdentifier: reuseIdentifier)
        parentTableView = tableView
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        didInitialized(with: style)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        didInitialized(with: .default)
    }

    deinit {
        parentTableView = nil
    }

    override var layoutMargins: UIEdgeInsets {
        get {
            return .zero
        }
        set {
            self.layoutMargins = newValue
        }
    }

    override var accessoryType: UITableViewCellAccessoryType {
        didSet {
            if accessoryType == .disclosureIndicator {
                self.defaultAccessoryImageView.image = TableViewCellDisclosureIndicatorImage
                self.defaultAccessoryImageView.sizeToFit()
                self.accessoryView = self.defaultAccessoryImageView
                return
            }

            if accessoryType == .checkmark {

                self.defaultAccessoryImageView.image = TableViewCellCheckmarkImage
                self.defaultAccessoryImageView.sizeToFit()
                self.accessoryView = self.defaultAccessoryImageView
                return
            }

            if accessoryType == .detailButton {
                defaultAccessoryButton.setImage(TableViewCellDetailButtonImage, for: .normal)
                self.defaultAccessoryButton.sizeToFit()
                self.accessoryView = self.defaultAccessoryButton
                return
            }

            if accessoryType == .detailDisclosureButton {

                defaultAccessoryButton.setImage(TableViewCellDetailButtonImage, for: .normal)
                defaultAccessoryButton.sizeToFit()
                if self.accessoryView == self.defaultAccessoryButton {
                    self.accessoryView = nil
                }
                defaultDetailDisclosureView.addSubview(defaultAccessoryButton)

                self.defaultAccessoryImageView.image = TableViewCellDisclosureIndicatorImage
                self.defaultAccessoryImageView.sizeToFit()
                if self.accessoryView == self.defaultAccessoryImageView {
                    self.accessoryView = nil
                }
                defaultDetailDisclosureView.addSubview(defaultAccessoryImageView)

                let spacingBetweenDetailButtonAndIndicatorImage = TableViewCellSpacingBetweenDetailButtonAndDisclosureIndicator
                self.defaultDetailDisclosureView.frame = CGRectFlat(self.defaultDetailDisclosureView.frame.minX,
                                                                    self.defaultDetailDisclosureView.frame.minY,
                                                                    self.defaultAccessoryButton.frame.width + spacingBetweenDetailButtonAndIndicatorImage + self.defaultAccessoryImageView.frame.width,
                                                                    fmax(self.defaultAccessoryButton.frame.height, self.defaultAccessoryImageView.frame.height))

                self.defaultAccessoryButton.frame = self.defaultAccessoryButton.frame.setXY(0, self.defaultDetailDisclosureView.frame.minYVerticallyCenter(self.defaultAccessoryButton.frame))

                self.defaultAccessoryImageView.frame = self.defaultAccessoryImageView.frame.setXY(self.defaultAccessoryButton.frame.maxX + spacingBetweenDetailButtonAndIndicatorImage, self.defaultDetailDisclosureView.frame.minYVerticallyCenter(self.defaultAccessoryImageView.frame))
                self.accessoryView = self.defaultDetailDisclosureView
                return
            }

            self.accessoryView = nil
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let hasCustomAccessoryEdgeInset = accessoryView?.superview != nil && (accessoryEdgeInsets != .zero)
        if hasCustomAccessoryEdgeInset {
            var accessoryViewOldFrame = accessoryView?.frame ?? .zero
            accessoryViewOldFrame = accessoryViewOldFrame.setX(accessoryViewOldFrame.minX - accessoryEdgeInsets.right)
            accessoryViewOldFrame = accessoryViewOldFrame.setY(accessoryViewOldFrame.minY + accessoryEdgeInsets.top - accessoryEdgeInsets.bottom)
            accessoryView?.frame = accessoryViewOldFrame

            var contentViewOldFrame = contentView.frame
            contentViewOldFrame = contentViewOldFrame.setWidth(accessoryViewOldFrame.minX - accessoryEdgeInsets.left)
            contentView.frame = contentViewOldFrame
        }

        if style == .default || style == .subtitle {

            let hasCustomImageEdgeInsets = imageView?.image != nil && imageEdgeInsets != .zero

            let hasCustomTextLabelEdgeInsets = textLabel?.text?.length ?? 0 > 0 && textLabelEdgeInsets != .zero

            let shouldChangeDetailTextLabelFrame = style == .subtitle
            let hasCustomDetailLabelEdgeInsets = shouldChangeDetailTextLabelFrame && detailTextLabel?.text?.length ?? 0 > 0 && detailTextLabelEdgeInsets != .zero

            var imageViewFrame = imageView?.frame ?? .zero
            var textLabelFrame = textLabel?.frame ?? .zero
            var detailTextLabelFrame = detailTextLabel?.frame ?? .zero

            if hasCustomImageEdgeInsets {
                imageViewFrame.origin.x += imageEdgeInsets.left - imageEdgeInsets.right
                imageViewFrame.origin.y += imageEdgeInsets.top - imageEdgeInsets.bottom

                textLabelFrame.origin.x += imageEdgeInsets.left
                textLabelFrame.size.width = min(textLabelFrame.width, contentView.bounds.width - textLabelFrame.minX)

                if shouldChangeDetailTextLabelFrame {
                    detailTextLabelFrame.origin.x += imageEdgeInsets.left
                    detailTextLabelFrame.size.width = min(detailTextLabelFrame.width, contentView.bounds.width - detailTextLabelFrame.minX)
                }
            }
            if hasCustomTextLabelEdgeInsets {
                textLabelFrame.origin.x += textLabelEdgeInsets.left - imageEdgeInsets.right
                textLabelFrame.origin.y += textLabelEdgeInsets.top - textLabelEdgeInsets.bottom
                textLabelFrame.size.width = min(textLabelFrame.width, contentView.bounds.width - textLabelFrame.minX)
            }
            if hasCustomDetailLabelEdgeInsets {
                detailTextLabelFrame.origin.x += detailTextLabelEdgeInsets.left - detailTextLabelEdgeInsets.right
                detailTextLabelFrame.origin.y += detailTextLabelEdgeInsets.top - detailTextLabelEdgeInsets.bottom
                detailTextLabelFrame.size.width = min(detailTextLabelFrame.width, contentView.bounds.width - detailTextLabelFrame.minX)
            }

            imageView?.frame = imageViewFrame
            textLabel?.frame = textLabelFrame
            detailTextLabel?.frame = detailTextLabelFrame

            // `layoutSubviews`这里不可以拿textLabel的minX来设置separatorInset，如果要设置只能写死一个值
            // 否则会导致textLabel的minX逐渐叠加从而使textLabel被移出屏幕外
        }

        // 由于调整 accessoryEdgeInsets 可能会影响 contentView 的宽度，所以几个 subviews 的布局也要保护一下
        if hasCustomAccessoryEdgeInset {
            if textLabel?.frame.maxX ?? 0 > contentView.bounds.width {
                textLabel?.frame = textLabel?.frame.setWidth(contentView.bounds.width - (textLabel?.frame.minX ?? 0)) ?? .zero
            }
            if detailTextLabel?.frame.maxX ?? 0 > contentView.bounds.width {
                detailTextLabel?.frame = detailTextLabel?.frame.setWidth(contentView.bounds.width - (detailTextLabel?.frame.minX ?? 0)) ?? .zero
            }
        }
    }

    @objc private func handleAccessoryButtonEvent(_ detailButton: UIButton) {
        if let tableView = self.parentTableView, let indexPath = tableView.qmui_indexPathForRow(at: detailButton) {
            tableView.delegate?.tableView?(tableView, accessoryButtonTappedForRowWith: indexPath)
        }
    }

    private func didInitialized(with _: UITableViewCellStyle) {
        textLabel?.font = UIFontMake(16)
        textLabel?.backgroundColor = UIColorClear
        textLabel?.textColor = TableViewCellTitleLabelColor

        detailTextLabel?.font = UIFontMake(15)
        detailTextLabel?.backgroundColor = UIColorClear
        detailTextLabel?.textColor = TableViewCellDetailLabelColor

        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = TableViewCellSelectedBackgroundColor
        self.selectedBackgroundView = selectedBackgroundView

        // 因为在hitTest里扩大了accessoryView的响应范围，因此提高了系统一个与此相关的bug的出现几率，所以又在scrollView.delegate里做一些补丁性质的东西来修复
        if let scrollView = self.subviews.first as? UIScrollView {
            scrollView.delegate = self
        }
    }
}

extension QMUITableViewCell {
    @objc func updateCellAppearance(with indexPath: IndexPath) {
        // 子类继承
        if let parentTableView = parentTableView {
            cellPosition = parentTableView.qmui_positionForRow(at: indexPath)
        }
    }
}

extension QMUITableViewCell: UIScrollViewDelegate {
    // 为了修复因优化accessoryView导致的向左滑动cell容易触发accessoryView事件 a little dirty by molice
    func scrollViewWillBeginDragging(_: UIScrollView) {
        accessoryView?.isUserInteractionEnabled = false
    }

    func scrollViewDidEndDragging(_: UIScrollView, willDecelerate _: Bool) {
        accessoryView?.isUserInteractionEnabled = true
    }
}

// MARK: - Touch Event

extension QMUITableViewCell {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let view = super.hitTest(point, with: event) else {
            return nil
        }

        // 对于使用自定义的accessoryView的情况，扩大其响应范围。最小范围至少是一个靠在屏幕右边缘的“宽高都为cell高度”的正方形区域
        if let accessoryView = self.accessoryView,
            accessoryView.isHidden,
            accessoryView.isUserInteractionEnabled,
            !self.isEditing,
            // UISwitch被点击时，[super hitTest:point withEvent:event]返回的不是UISwitch，而是它的一个subview，如果这里直接返回UISwitch会导致控件无法使用，因此对UISwitch做特殊屏蔽
            !accessoryView.isKind(of: UISwitch.self) {

            let accessoryViewFrame = accessoryView.frame
            var responseEventFrame: CGRect = .zero
            responseEventFrame.origin.x = accessoryViewFrame.minX + accessoryHitTestEdgeInsets.left
            responseEventFrame.origin.y = accessoryViewFrame.minY + accessoryHitTestEdgeInsets.top
            responseEventFrame.size.width = accessoryViewFrame.width + accessoryHitTestEdgeInsets.horizontalValue
            responseEventFrame.size.height = accessoryViewFrame.height + accessoryHitTestEdgeInsets.verticalValue
            if responseEventFrame.contains(point) {
                return self.accessoryView
            }
        }
        return view
    }
}
