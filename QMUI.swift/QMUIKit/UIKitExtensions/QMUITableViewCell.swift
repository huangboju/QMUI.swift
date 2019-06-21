//
//  QMUITableViewCell.swift
//  QMUI.swift
//
//  Created by xnxin on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

import UIKit

class QMUITableViewCell: UITableViewCell {

    private(set) var style: UITableViewCell.CellStyle = .default

    /**
     *  imageEdgeInsets，这个属性用来调整imageView里面图片的位置，有些情况titleLabel前面是一个icon，但是icon与titleLabel的间距不是你想要的。<br/>
     *  @warning 目前只对UITableViewCellStyleDefault和UITableViewCellStyleSubtitle类型的cell开放
     */
    var imageEdgeInsets: UIEdgeInsets = .zero

    /**
     *  textLabelEdgeInsets，这个属性和imageEdgeInsets合作使用，用来调整titleLabel的位置，默认为 UIEdgeInsetsZero。<br/>
     *  @warning 目前只对UITableViewCellStyleDefault和UITableViewCellStyleSubtitle类型的cell开放。
     */
    var textLabelEdgeInsets: UIEdgeInsets = .zero

    /// 与textLabelEdgeInsets一致，作用目标为detailTextLabel，默认为 UIEdgeInsetsZero。
    var detailTextLabelEdgeInsets: UIEdgeInsets = .zero

    /// 用于调整右边 accessoryView 的布局偏移，默认为 UIEdgeInsetsZero。
    var accessoryEdgeInsets: UIEdgeInsets = .zero

    /// 用于调整accessoryView的点击响应区域，可用负值扩大点击范围，默认为(-12, -12, -12, -12)
    var accessoryHitTestEdgeInsets: UIEdgeInsets = UIEdgeInsets(top: -12, left: -12, bottom: -12, right: -12)

    /// 设置当前cell是否enabled，setter方法里面会修改当前的subviews样式。
    var isEnabled: Bool = true {
        willSet {
            if newValue {
                isUserInteractionEnabled = true
                textLabel?.textColor = TableViewCellTitleLabelColor
                detailTextLabel?.textColor = TableViewCellDetailLabelColor
            } else {
                isUserInteractionEnabled = false
                textLabel?.textColor = UIColorDisabled
                detailTextLabel?.textColor = UIColorDisabled
            }
        }
    }

    /// 保存对tableView的弱引用，在布局时可能会使用到tableView的一些属性例如separatorColor等。只有使用下面两个 initForTableView: 的接口初始化时这个属性才有值，否则就只能自己初始化后赋值
    weak var parentTableView: UITableView?

    /**
     *  cell 处于 section 中的位置，要求：
     *  1. cell 使用 initForTableViewXxx 方法初始化，或者初始化完后为 parentTableView 属性赋值。
     *  2. 在 cellForRow 里调用 [cell updateCellAppearanceWithIndexPath:] 方法。
     *  3. 之后即可通过 cellPosition 获取到正确的位置。
     */
    fileprivate(set) var cellPosition: QMUITableViewCellPosition = .none

    private var defaultAccessoryImageView: UIImageView?

    private var defaultAccessoryButton: UIButton?

    private var defaultDetailDisclosureView: UIView?
    
    override var backgroundColor: UIColor? {
        get {
            return super.backgroundColor
        }
        set {
            super.backgroundColor = newValue
            if let backgroundView = self.backgroundView {
                backgroundView.backgroundColor = newValue
            }
        }
    }

    /**
     *  首选初始化方法
     *
     *  @param tableView       cell所在的tableView
     *  @param style           tableView的style
     *  @param reuseIdentifier tableView的reuseIdentifier
     *
     *  @return 一个QMUITableViewCell实例
     */
    required convenience init(tableView: UITableView, style: UITableViewCell.CellStyle = .default, reuseIdentifier: String?) {
        self.init(style: style, reuseIdentifier: reuseIdentifier)
        parentTableView = tableView
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        didInitialized(style)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        didInitialized(.default)
    }

    deinit {
        parentTableView = nil
    }

    // 解决 iOS 8 以后的 cell 中 separatorInset 受 layoutMargins 影响的问题
    override var layoutMargins: UIEdgeInsets {
        get {
            return .zero
        }
        set {
            super.layoutMargins = newValue
        }
    }

    // 重写accessoryType，如果是UITableViewCellAccessoryDisclosureIndicator类型的，则使用 QMUIConfigurationTemplate.m 配置表里的图片
    override var accessoryType: UITableViewCell.AccessoryType {
        didSet {
            if accessoryType == .disclosureIndicator {
                if let indicatorImage = TableViewCellDisclosureIndicatorImage {
                    initDefaultAccessoryImageViewIfNeeded()
                    defaultAccessoryImageView!.image = indicatorImage
                    defaultAccessoryImageView!.sizeToFit()
                    accessoryView = defaultAccessoryImageView
                    return
                }
            }

            if accessoryType == .checkmark {
                if let checkmarkImage = TableViewCellCheckmarkImage {
                    initDefaultAccessoryImageViewIfNeeded()
                    defaultAccessoryImageView!.image = checkmarkImage
                    defaultAccessoryImageView!.sizeToFit()
                    accessoryView = defaultAccessoryImageView
                    return
                }
            }

            if accessoryType == .detailButton {
                if let detailButtonImage = TableViewCellDetailButtonImage {
                    initDefaultAccessoryButtonIfNeeded()
                    defaultAccessoryButton!.setImage(detailButtonImage, for: .normal)
                    defaultAccessoryButton!.sizeToFit()
                    accessoryView = defaultAccessoryButton
                    return
                }
            }

            if accessoryType == .detailDisclosureButton {
                if let detailButtonImage = TableViewCellDetailButtonImage {
                    assert(TableViewCellDisclosureIndicatorImage != nil, "TableViewCellDetailButtonImage 和 TableViewCellDisclosureIndicatorImage 必须同时使用，但目前后者为 nil")
                    initDefaultDetailDisclosureViewIfNeeded()
                    initDefaultAccessoryButtonIfNeeded()
                    defaultAccessoryButton!.setImage(detailButtonImage, for: .normal)
                    defaultAccessoryButton!.sizeToFit()
                    if accessoryView == defaultAccessoryButton {
                        accessoryView = nil
                    }
                    defaultDetailDisclosureView!.addSubview(defaultAccessoryButton!)
                }
                
                if let indicatorImage = TableViewCellDisclosureIndicatorImage {
                    assert(TableViewCellDetailButtonImage != nil, "TableViewCellDetailButtonImage 和 TableViewCellDisclosureIndicatorImage 必须同时使用，但目前前者为 nil")
                    initDefaultDetailDisclosureViewIfNeeded()
                    initDefaultAccessoryImageViewIfNeeded()
                    defaultAccessoryImageView!.image = indicatorImage
                    defaultAccessoryImageView!.sizeToFit()
                    if accessoryView == defaultAccessoryImageView {
                        accessoryView = nil
                    }
                    defaultDetailDisclosureView!.addSubview(defaultAccessoryImageView!)
                }
                
                if let _ = TableViewCellDetailButtonImage, let _ = TableViewCellDisclosureIndicatorImage {
                    
                    let spacingBetweenDetailButtonAndIndicatorImage = TableViewCellSpacingBetweenDetailButtonAndDisclosureIndicator
                    defaultDetailDisclosureView!.frame = CGRectFlat(
                        defaultDetailDisclosureView!.frame.minX,
                        defaultDetailDisclosureView!.frame.minY,
                        defaultAccessoryButton!.frame.width + spacingBetweenDetailButtonAndIndicatorImage + defaultAccessoryImageView!.frame.width,
                        fmax(defaultAccessoryButton!.frame.height, defaultAccessoryImageView!.frame.height))
                    
                    defaultAccessoryButton!.frame = defaultAccessoryButton!.frame.setXY(0, defaultDetailDisclosureView!.frame.minYVerticallyCenter(defaultAccessoryButton!.frame))
                    
                    defaultAccessoryImageView!.frame = defaultAccessoryImageView!.frame.setXY(defaultAccessoryButton!.frame.maxX + spacingBetweenDetailButtonAndIndicatorImage, defaultAccessoryImageView!.frame.minYVerticallyCenter(defaultDetailDisclosureView!.frame))
                    accessoryView = defaultDetailDisclosureView
                    return
                }
            }
            accessoryView = nil
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let hasCustomAccessoryEdgeInset = accessoryView?.superview != nil && (accessoryEdgeInsets != .zero)
        if hasCustomAccessoryEdgeInset {
            var accessoryViewOldFrame = accessoryView!.frame
            accessoryViewOldFrame = accessoryViewOldFrame.setX(accessoryViewOldFrame.minX - accessoryEdgeInsets.right)
            accessoryViewOldFrame = accessoryViewOldFrame.setY(accessoryViewOldFrame.minY + accessoryEdgeInsets.top - accessoryEdgeInsets.bottom)
            accessoryView!.frame = accessoryViewOldFrame

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

    func didInitialized(_ style: UITableViewCell.CellStyle) {
        self.style = style
        
        textLabel?.font = UIFontMake(16)
        textLabel?.backgroundColor = UIColorClear
        if let color = TableViewCellTitleLabelColor {
            textLabel?.textColor = color
        }
        
        detailTextLabel?.font = UIFontMake(15)
        detailTextLabel?.backgroundColor = UIColorClear
        if let color = TableViewCellDetailLabelColor {
            detailTextLabel?.textColor = color
        }

        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = TableViewCellSelectedBackgroundColor
        self.selectedBackgroundView = selectedBackgroundView
        
        // 因为在hitTest里扩大了accessoryView的响应范围，因此提高了系统一个与此相关的bug的出现几率，所以又在scrollView.delegate里做一些补丁性质的东西来修复
        if let scrollView = subviews.first as? UIScrollView {
            scrollView.delegate = self
        }
    }
    
    /// 用于继承的接口，设置一些cell相关的UI，需要自 cellForRowAtIndexPath 里面调用。默认实现是设置当前cell在哪个position。
    func updateCellAppearance(_ indexPath: IndexPath) {
        // 子类继承
        if let parentTableView = parentTableView {
            cellPosition = parentTableView.qmui_positionForRow(at: indexPath)
        }
    }
    
    private func initDefaultAccessoryImageViewIfNeeded() {
        if defaultAccessoryImageView == nil {
            defaultAccessoryImageView = UIImageView()
            defaultAccessoryImageView!.contentMode = .center
        }
    }
    
    private func initDefaultAccessoryButtonIfNeeded() {
        if defaultAccessoryButton == nil {
            defaultAccessoryButton = QMUIButton()
            defaultAccessoryButton!.addTarget(self, action: #selector(handleAccessoryButtonEvent(_:)), for: .touchUpInside)
        }
    }
    
    private func initDefaultDetailDisclosureViewIfNeeded() {
        if defaultDetailDisclosureView == nil {
            defaultDetailDisclosureView = UIView()
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
            !isEditing,
            // UISwitch被点击时，[super hitTest:point withEvent:event]返回的不是UISwitch，而是它的一个subview，如果这里直接返回UISwitch会导致控件无法使用，因此对UISwitch做特殊屏蔽
            !accessoryView.isKind(of: UISwitch.self) {

            let accessoryViewFrame = accessoryView.frame
            var responseEventFrame: CGRect = .zero
            responseEventFrame.origin.x = accessoryViewFrame.minX + accessoryHitTestEdgeInsets.left
            responseEventFrame.origin.y = accessoryViewFrame.minY + accessoryHitTestEdgeInsets.top
            responseEventFrame.size.width = accessoryViewFrame.width + accessoryHitTestEdgeInsets.horizontalValue
            responseEventFrame.size.height = accessoryViewFrame.height + accessoryHitTestEdgeInsets.verticalValue
            if responseEventFrame.contains(point) {
                return accessoryView
            }
        }
        return view
    }
}
