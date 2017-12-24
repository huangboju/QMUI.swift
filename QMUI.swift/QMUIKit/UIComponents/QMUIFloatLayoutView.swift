//
//  QMUIFloatLayoutView.swift
//  QMUI.swift
//
//  Created by 黄伯驹 on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

/**
 *  做类似 CSS 里的 float:left 的布局，自行使用 addSubview: 将子 View 添加进来即可。
 *
 *  支持通过 `contentMode` 属性修改子 View 的对齐方式，目前仅支持 `UIViewContentModeLeft` 和 `UIViewContentModeRight`，默认为 `UIViewContentModeLeft`。
 */
class QMUIFloatLayoutView: UIView {
    /**
     *  QMUIFloatLayoutView 内部的间距，默认为 UIEdgeInsetsZero
     */
    public var padding: UIEdgeInsets = .zero

    /**
     *  item 的最小宽高，默认为 CGSizeZero，也即不限制。
     */
    @IBInspectable
    public var minimumItemSize: CGSize = .zero

    /**
     *  item 的最大宽高，默认为 CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)，也即不限制
     */
    @IBInspectable
    public var maximumItemSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)

    /**
     *  item 之间的间距，默认为 UIEdgeInsetsZero。
     *
     *  @warning 上、下、左、右四个边缘的 item 布局时不会考虑 itemMargins.left/bottom/left/right。
     */
    public var itemMargins: UIEdgeInsets = .zero

    override init(frame: CGRect) {
        super.init(frame: frame)
        didInitialized()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        didInitialized()
    }

    private func didInitialized() {
        contentMode = .left
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return layoutSubviews(with: size)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutSubviews(with: bounds.size, shouldLayout: true)
    }

    private func ValueSwitchAlignLeftOrRight<T>(_ valueLeft: T, _ valueRight: T) -> T {
        return shouldAlignRight ? valueRight : valueLeft
    }

    @discardableResult
    func layoutSubviews(with size: CGSize, shouldLayout: Bool = false) -> CGSize {
        let visibleItemViews = visibleSubviews

        if visibleItemViews.isEmpty {
            return CGSize(width: padding.horizontalValue, height: padding.verticalValue)
        }

        // 如果是左对齐，则代表 item 左上角的坐标，如果是右对齐，则代表 item 右上角的坐标
        var itemViewOrigin = CGPoint(x: ValueSwitchAlignLeftOrRight(padding.left, size.width - padding.right), y: padding.top)
        var currentRowMaxY = itemViewOrigin.y

        for (i, itemView) in visibleItemViews.enumerated() {

            var itemViewSize = itemView.sizeThatFits(maximumItemSize)
            itemViewSize.width = max(minimumItemSize.width, itemViewSize.width)
            itemViewSize.height = max(minimumItemSize.height, itemViewSize.height)

            let shouldBreakline = i == 0 ? true : ValueSwitchAlignLeftOrRight(itemViewOrigin.x + itemMargins.left + itemViewSize.width + padding.right > size.width,
                                                                              itemViewOrigin.x - itemMargins.right - itemViewSize.width - padding.left < 0)
            if shouldBreakline {
                // 换行，每一行第一个 item 是不考虑 itemMargins 的
                if shouldLayout {
                    itemView.frame = CGRect(x: ValueSwitchAlignLeftOrRight(padding.left, size.width - padding.right - itemViewSize.width), y: currentRowMaxY + itemMargins.top, width: itemViewSize.width, height: itemViewSize.height)
                }

                itemViewOrigin.x = ValueSwitchAlignLeftOrRight(padding.left + itemViewSize.width + itemMargins.right, size.width - padding.right - itemViewSize.width - itemMargins.left)
                itemViewOrigin.y = currentRowMaxY
            } else {
                // 当前行放得下
                if shouldLayout {
                    itemView.frame = CGRect(x: ValueSwitchAlignLeftOrRight(itemViewOrigin.x + itemMargins.left, itemViewOrigin.x - itemMargins.right - itemViewSize.width), y: itemViewOrigin.y + itemMargins.top, width: itemViewSize.width, height: itemViewSize.height)
                }

                itemViewOrigin.x = ValueSwitchAlignLeftOrRight(itemViewOrigin.x + itemMargins.horizontalValue + itemViewSize.width, itemViewOrigin.x - itemViewSize.width - itemMargins.horizontalValue)
            }

            currentRowMaxY = max(currentRowMaxY, itemViewOrigin.y + itemMargins.verticalValue + itemViewSize.height)
        }

        // 最后一行不需要考虑 itemMarins.bottom，所以这里减掉
        currentRowMaxY -= itemMargins.bottom

        let resultSize = CGSize(width: size.width, height: currentRowMaxY + padding.bottom)
        return resultSize
    }

    private var visibleSubviews: [UIView] {
        return subviews.filter { !$0.isHidden }
    }

    private var shouldAlignRight: Bool {
        return contentMode == .right
    }
}
