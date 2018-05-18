//
//  QMUIPopupMenuView.swift
//  QMUI.swift
//
//  Created by 黄伯驹 on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

/**
 *  用于弹出浮层里显示一行一行的菜单的控件。
 *  使用方式：
 *  1. 调用 init 方法初始化。
 *  2. 按需设置分隔线、item 高度等样式。
 *  3. 设置完样式后再通过 items 或 itemSections 添加菜单项。
 *  4. 调用 layoutWithTargetView: 或 layoutWithTargetRectInScreenCoordinate: 来布局菜单（参考父类）。
 *  5. 调用 showWithAnimated: 即可显示（参考父类）。
 */
class QMUIPopupMenuView: QMUIPopupContainerView {
    var shouldShowItemSeparator: Bool = false
    var shouldShowSectionSeparatorOnly: Bool = false
    var separatorColor: UIColor = UIColorSeparator

    var itemTitleFont: UIFont = UIFontMake(16)
    var itemHighlightedBackgroundColor: UIColor = TableViewCellSelectedBackgroundColor

    var padding: UIEdgeInsets = .zero
    var itemHeight: CGFloat = 44
    var imageMarginRight: CGFloat = 6
    var separatorInset: UIEdgeInsets = .zero

    var items: [QMUIPopupMenuItem] = [] {
        didSet {
            itemSections = [items]
        }
    }

    var itemSections: [[QMUIPopupMenuItem]] = [] {
        didSet {
            configureItems()
        }
    }
    
    private var scrollView: UIScrollView!
    
    private var itemSeparatorLayers: [CALayer] = []

    private func shouldShowSeparator(at row: Int, rowCount: Int, in section: Int, sectionCount: Int) -> Bool {
        return (!shouldShowSectionSeparatorOnly && shouldShowItemSeparator && row < rowCount - 1) || (shouldShowSectionSeparatorOnly && row == rowCount - 1 && section < sectionCount - 1)
    }

    private func configureItems() {
        var globalItemIndex = 0

        // 移除所有 item
        scrollView.qmui_removeAllSubviews()
        let sectionCount = itemSections.count
        for section in 0 ..< sectionCount {
            let items = itemSections[section]
            let rowCount = items.count
            for row in 0 ..< rowCount {
                let item = items[row]
                item.button.titleLabel?.font = itemTitleFont
                item.button.highlightedBackgroundColor = itemHighlightedBackgroundColor
                item.button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -imageMarginRight, bottom: 0, right: imageMarginRight)
                item.button.contentEdgeInsets = UIEdgeInsets(top: 0, left: padding.left - item.button.imageEdgeInsets.left, bottom: 0, right: padding.right)
                scrollView.addSubview(item.button)

                // 配置分隔线，注意每一个 section 里的最后一行是不显示分隔线的
                let shouldShowSeparatorAtRow = shouldShowSeparator(at: row, rowCount: rowCount, in: section, sectionCount: sectionCount)
                if globalItemIndex < itemSeparatorLayers.count {
                    let separatorLayer = itemSeparatorLayers[globalItemIndex]
                    if shouldShowSeparatorAtRow {
                        separatorLayer.isHidden = false
                        separatorLayer.backgroundColor = separatorColor.cgColor
                    } else {
                        separatorLayer.isHidden = true
                    }
                } else if shouldShowSeparatorAtRow {
                    let separatorLayer = CALayer()
                    separatorLayer.qmui_removeDefaultAnimations()
                    separatorLayer.backgroundColor = separatorColor.cgColor
                    scrollView.layer.addSublayer(separatorLayer)
                    itemSeparatorLayers.append(separatorLayer)
                }

                globalItemIndex += 1
            }
        }
    }

    override func didInitialized() {
        super.didInitialized()
        contentEdgeInsets = .zero

        scrollView = UIScrollView()
        scrollView.scrollsToTop = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        if #available(iOS 11, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        contentView.addSubview(scrollView)
        
        updateAppearanceForPopupMenuView()
    }

    override func sizeThatFitsInContentView(_ size: CGSize) -> CGSize {
        var result = size
        var height = padding.verticalValue
        for section in itemSections {
            height += CGFloat(section.count) * itemHeight
        }
        result.height = min(height, size.height)
        return result
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        scrollView.frame = contentView.bounds

        var minY = padding.top
        let contentWidth = scrollView.bounds.width
        var separatorIndex = 0
        let sectionCount = itemSections.count
        for section in 0 ..< sectionCount {
            let items = itemSections[section]
            let rowCount = items.count
            for row in 0 ..< rowCount {
                let button = items[row].button
                button!.frame = CGRect(x: 0, y: minY, width: contentWidth, height: itemHeight)
                minY = button!.frame.maxY

                let shouldShowSeparatorAtRow = shouldShowSeparator(at: row, rowCount: rowCount, in: section, sectionCount: sectionCount)
                if shouldShowSeparatorAtRow {
                    itemSeparatorLayers[separatorIndex].frame = CGRect(x: separatorInset.left,
                                                                       y: minY - PixelOne + separatorInset.top - separatorInset.bottom,
                                                                       width: contentWidth - separatorInset.horizontalValue,
                                                                       height: PixelOne)
                    separatorIndex += 1
                }
            }
        }
        minY += padding.bottom
        scrollView.contentSize = CGSize(width: contentWidth, height: minY)
    }
}

extension QMUIPopupMenuView {
    fileprivate func updateAppearanceForPopupMenuView() {
        separatorColor = UIColorSeparator
        itemTitleFont = UIFontMake(16)
        itemHighlightedBackgroundColor = TableViewCellSelectedBackgroundColor
        padding = UIEdgeInsets(top: cornerRadius / 2, left: 16, bottom: cornerRadius / 2, right: 16)
        itemHeight = 44
        imageMarginRight = 6
        separatorInset = .zero
    }
}

/**
 *  配合 QMUIPopupMenuView 使用，用于表示一项菜单项。
 *  支持显示图片和标题，以及点击事件的回调。
 *  可在 QMUIPopupMenuView 里统一修改菜单项的样式，如果某个菜单项需要特殊调整，可获取到对应的 QMUIPopupMenuItem.button 并进行调整。
 */
class QMUIPopupMenuItem: NSObject {
    var image: UIImage? {
        didSet {
            button.setImage(image, for: .normal)
        }
    }

    var title: String? {
        didSet {
            button.setTitle(title, for: .normal)
        }
    }

    var handler: (() -> Void)?

    fileprivate(set) var button: QMUIButton!

    init(image: UIImage?, title: String?, handler: (() -> Void)?) {
        super.init()
        self.image = image
        self.title = title
        self.handler = handler

        button = QMUIButton(title: title, image: image)
        button.contentHorizontalAlignment = .left
        button.qmui_automaticallyAdjustTouchHighlightedInScrollView = true
        button.addTarget(self, action: #selector(handleButtonEvent), for: .touchUpInside)
    }

    @objc
    private func handleButtonEvent(_: QMUIButton) {
        handler?()
    }
}
