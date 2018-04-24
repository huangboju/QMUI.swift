//
//  QMUIGridView.swift
//  QMUI.swift
//
//  Created by 黄伯驹 on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

/**
 *  用于做九宫格布局，会将内部所有的 subview 根据指定的列数和行高，把每个 item（也即 subview） 拉伸到相同的大小。
 *
 *  支持在 item 和 item 之间显示分隔线，分隔线支持虚线。
 *
 *  @warning 注意分隔线是占位的，把 item 隔开，而不是盖在某个 item 上。
 */
class QMUIGridView: UIView {

    /// 指定要显示的列数，默认为 0
    @IBInspectable
    var columnCount = 0

    /// 指定每一行的高度，默认为 0
    @IBInspectable
    var rowHeight: CGFloat = 0

    /// 指定 item 之间的分隔线宽度，默认为 0
    @IBInspectable
    var separatorWidth: CGFloat = 0 {
        didSet {
            separatorLayer.lineWidth = separatorWidth
            separatorLayer.isHidden = separatorWidth <= 0
        }
    }

    /// 指定 item 之间的分隔线颜色，默认为 UIColorSeparator
    @IBInspectable
    var separatorColor = UIColorSeparator {
        didSet {
            separatorLayer.strokeColor = separatorColor.cgColor
        }
    }

    /// item 之间的分隔线是否要用虚线显示，默认为 false
    @IBInspectable
    var separatorDashed = false

    private let separatorLayer = CAShapeLayer()

    /// 候选的初始化方法，亦可通过 initWithFrame:、init 来初始化。
    init(frame: CGRect = .zero, column: Int = 0, rowHeight: CGFloat = 0) {
        super.init(frame: frame)
        didInitialized()
        columnCount = column
        self.rowHeight = rowHeight
    }

    func didInitialized() {
        separatorLayer.qmui_removeDefaultAnimations()
        separatorLayer.isHidden = true
        layer.addSublayer(separatorLayer)
        separatorColor = UIColorSeparator
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        didInitialized()
    }

    // 返回最接近平均列宽的值，保证其为整数，因此所有columnWidth加起来可能比总宽度要小
    private var stretchColumnWidth: CGFloat {
        let columnCount = CGFloat(self.columnCount)
        return floor((bounds.width - separatorWidth * (columnCount - 1)) / columnCount)
    }

    private var rowCount: Int {
        let subviewCount = subviews.count
        return subviewCount / columnCount + (subviewCount % columnCount > 0 ? 1 : 0)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var newSize = size
        let rowCount = CGFloat(self.rowCount)
        let totalHeight = rowCount * rowHeight + (rowCount - 1) * separatorWidth
        newSize.height = totalHeight
        return newSize
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let subviewCount = subviews.count
        if subviewCount == 0 { return }

        let size = bounds.size
        if size.isEmpty { return }

        let columnWidth = stretchColumnWidth
        let rowHeight = CGFloat(self.rowHeight)
        let rowCount = CGFloat(self.rowCount)

        let shouldShowSeparator = separatorWidth > 0
        let lineOffset = shouldShowSeparator ? separatorWidth / 2.0 : 0
        let separatorPath: UIBezierPath? = shouldShowSeparator ? UIBezierPath() : nil

        for row in 0 ..< self.rowCount {
            for column in 0 ..< columnCount {
                let index = row * columnCount + column
                guard index < subviewCount else {
                    continue
                }
                let isLastColumn = column == columnCount - 1
                let isLastRow = row == self.rowCount - 1

                let subview = subviews[index]
                var subviewFrame = CGRect(x: columnWidth * CGFloat(column) + separatorWidth * CGFloat(column), y: rowHeight * CGFloat(row) + separatorWidth * CGFloat(row), width: columnWidth, height: rowHeight)

                if isLastColumn {
                    // 每行最后一个item要占满剩余空间，否则可能因为strecthColumnWidth不精确导致右边漏空白
                    let v = CGFloat(columnCount - 1)
                    subviewFrame.size.width = size.width - columnWidth * v - separatorWidth * v
                }
                if isLastRow {
                    // 最后一行的item要占满剩余空间，避免一些计算偏差
                    subviewFrame.size.height = size.height - rowHeight * (rowCount - 1) - separatorWidth * (rowCount - 1)
                }

                subview.frame = subviewFrame
                subview.setNeedsLayout()

                guard shouldShowSeparator else {
                    continue
                }
                // 每个 item 都画右边和下边这两条分隔线
                let rightTopPoint = CGPoint(x: subviewFrame.maxX + lineOffset, y: subviewFrame.minY)
                let rightBottomPoint = CGPoint(x: rightTopPoint.x - (isLastColumn ? lineOffset : 0), y: subviewFrame.maxY + (!isLastRow ? lineOffset : 0))
                let leftBottomPoint = CGPoint(x: subviewFrame.minX, y: rightBottomPoint.y)

                if !isLastColumn {
                    separatorPath?.move(to: rightTopPoint)
                    separatorPath?.addLine(to: rightBottomPoint)
                }
                if !isLastRow {
                    separatorPath?.move(to: rightBottomPoint)
                    separatorPath?.addLine(to: leftBottomPoint)
                }
            }
        }

        if shouldShowSeparator {
            separatorLayer.path = separatorPath?.cgPath
        }
    }
}
