//
//  QDColorViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/4/4.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

private let spaceBetweenIconAndCircle: CGFloat = 30

class QDColorViewController: QDCommonTableViewController {

    @objc override func initTableView() {
        super.initTableView()
        tableView.separatorStyle = .none
        
        let topInset: CGFloat = 32
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: topInset))
    }
    
    // MARK: TableView Delegate & DataSource
    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return 7
    }
    
    override func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 1 {
            return 300
        }
        return 130
    }
    
    override func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: QDColorTableViewCell?
        switch indexPath.row {
        case 0:
            cell = QDColorCellThatGenerateFromHex()
        case 1:
            cell = QDColorCellThatGetColorInfo()
        case 2:
            cell = QDColorCellThatResetAlpha()
        case 3:
            cell = QDColorCellThatInverseColor()
        case 4:
            cell = QDColorCellThatNeutralizeColors()
        case 5:
            cell = QDColorCellThatBlendColors()
        case 6:
            cell = QDColorCellThatAdjustAlphaAndBlend()
        default:
            cell = QDColorCellThatAdjustAlphaAndBlend()
        }
        cell?.selectionStyle = .none
        cell?.contentViewInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        return cell ?? QDColorTableViewCell()
    }
}

// 通过HEX创建
fileprivate class QDColorTableViewCell: QMUITableViewCell {
    
    fileprivate var titleLabel: QMUILabel!
    
    fileprivate var contentViewInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) {
        didSet {
            setNeedsLayout()
        }
    }
    
    fileprivate var titleLabelMarginBottom: CGFloat = 12
    
    convenience init() {
        self.init(style: .default, reuseIdentifier: "\(type(of: self))")
        titleLabelMarginBottom = 12
        initSubviews()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required convenience init(tableView: UITableView, style: UITableViewCellStyle, reuseIdentifier: String?) {
        fatalError("init(tableView:style:reuseIdentifier:) has not been implemented")
    }
    
    fileprivate func initSubviews() {
        titleLabel = QMUILabel()
        titleLabel.font = UIFontMake(14)
        titleLabel.qmui_calculateHeightAfterSetAppearance()
        contentView.addSubview(titleLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.frame = CGRect(x: contentViewInsets.left, y: 0, width: contentView.bounds.width - contentViewInsets.left - contentViewInsets.right, height: titleLabel.bounds.height)
    }
    
    // 生成一个圆形的view
    fileprivate func generateCircle(with color: UIColor) -> UIView {
        let diameter: CGFloat = 44
        let circle = UIView()
        circle.backgroundColor = color
        circle.frame = CGRect(x: 0, y: 0, width: diameter, height: diameter)
        circle.layer.cornerRadius = diameter / 2
        
        return circle
    }
    
    // 生成一个向右的箭头imageView
    fileprivate func generateArrowIcon() -> UIImageView {
        let imageView = UIImageView(image: UIImageMake("arrowRight"))
        return imageView
    }
    
    fileprivate func generatePlusIcon() -> UIImageView {
        let imageView = UIImageView(image: UIImageMake("plus"))
        return imageView
    }
}

// 通过HEX创建
fileprivate class QDColorCellThatGenerateFromHex: QDColorTableViewCell {
    private var circle: UIView!
    private var label: QMUILabel!
    
    override func initSubviews() {
        super.initSubviews()
        titleLabel.text = "通过HEX创建"
        
        let resultColor = UIColor(hexStr: "#cddc39") // 关键方法
        circle = generateCircle(with: resultColor)
        contentView.addSubview(circle)
        
        label = QMUILabel()
        label.text = "[UIColor qmui_colorWithHexString:@\"#cddc39\"]"
        label.font = UIFontMake(12)
        label.sizeToFit()
        label.textColor = UIColorGray7
        contentView.addSubview(label)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        circle.frame = circle.frame.setXY(contentViewInsets.left, titleLabel.frame.maxY + titleLabelMarginBottom)
        label.frame = label.frame.setXY(contentViewInsets.left, circle.frame.maxY + 5)
    }
}

// 获取颜色信息
fileprivate class QDColorCellThatGetColorInfo: QDColorTableViewCell {
    private var gridView: QMUIGridView!
    private var circle: UIView!
    private var labels: [QMUILabel] = []
    
    override func initSubviews() {
        super.initSubviews()
        
        titleLabel.text = "获取颜色信息"
        
        let rawColor = UIColor(hexStr: "#e69832").withAlphaComponent(0.75)
        // 关键方法
        let alpha = rawColor.qmui_alpha
        let red = rawColor.qmui_red
        let green = rawColor.qmui_green
        let blue = rawColor.qmui_blue
        let hue = rawColor.qmui_hue
        let saturation = rawColor.qmui_saturation
        let brightness = rawColor.qmui_brightness
        let hex = rawColor.qmui_hexString
        let isDark = rawColor.qmui_colorIsDark
        
        circle = generateCircle(with: rawColor)
        contentView.addSubview(circle)
        
        gridView = QMUIGridView(column: 4, rowHeight: 60)
        let infos = [
            ["title": "ALPHA", "content": String(format:"%.3f", alpha)],
            ["title": "RED", "content": String(format:"%.3f", red)],
            ["title": "GREEN", "content": String(format:"%.3f", green)],
            ["title": "BLUE", "content": String(format:"%.3f", blue)],
            ["title": "色相", "content": String(format:"%.3f", hue)],
            ["title": "饱和度", "content": String(format:"%.3f", saturation)],
            ["title": "亮度", "content": String(format:"%.3f", brightness)],
            ["title": "HEX", "content": hex],
            ["title": "是否是深色系", "content": isDark ? "true" : "false"],
        ]
        
        infos.forEach {
            let wrapperView = UIView()
            
            let titleLabel = QMUILabel()
            titleLabel.text = $0["title"]
            titleLabel.font = UIFontMake(12)
            titleLabel.textColor = UIColorGray7
            titleLabel.textAlignment = .center
            titleLabel.sizeToFit()
            labels.append(titleLabel)
            wrapperView.addSubview(titleLabel)
            
            let contentLabel = QMUILabel()
            contentLabel.text = $0["content"]
            contentLabel.font = UIFontMake(12)
            contentLabel.textColor = UIColorGray3
            contentLabel.textAlignment = .center
            contentLabel.sizeToFit()
            contentLabel.frame = contentLabel.frame.setY(titleLabel.frame.maxY + 3)
            labels.append(contentLabel)
            wrapperView.addSubview(contentLabel)
            
            gridView.addSubview(wrapperView)
        }
        
        contentView.addSubview(gridView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        circle.frame = circle.frame.setXY(contentViewInsets.left, titleLabel.frame.maxY + titleLabelMarginBottom)
        
        let gridViewSize = gridView.sizeThatFits(CGSize(width: contentView.bounds.width - contentViewInsets.left - contentViewInsets.right, height: CGFloat.greatestFiniteMagnitude))
        gridView.frame = CGRect(x: contentViewInsets.left, y: circle.frame.maxY + 25, width: gridViewSize.width, height: gridViewSize.height)
        labels.forEach {
            $0.frame = $0.frame.setWidth(gridViewSize.width / 4)
        }
    }
}

// 去除alpha通道
fileprivate class QDColorCellThatResetAlpha: QDColorTableViewCell {
    private var arrow: UIView!
    private var circle1: UIView!
    private var circle2: UIView!
    private var label1: QMUILabel!
    private var label2: QMUILabel!
    
    override func initSubviews() {
        super.initSubviews()
        
        titleLabel.text = "去除alpha通道"
        
        let rawColor = UIColorMakeWithHex("#e91e63").withAlphaComponent(0.6)
        let resultColor = rawColor.qmui_colorWithoutAlpha  // 关键方法
        
        circle1 = generateCircle(with: rawColor)
        contentView.addSubview(circle1)
        
        arrow = generateArrowIcon()
        contentView.addSubview(arrow)
        
        circle2 = generateCircle(with: resultColor!)
        contentView.addSubview(circle2)
        
        label1 = QMUILabel()
        label1.text = "0.5 ALPHA"
        label1.font = UIFontMake(12)
        label1.textColor = UIColorGray7
        label1.sizeToFit()
        contentView.addSubview(label1)
        
        label2 = QMUILabel()
        label2.text = "1.0 ALPHA"
        label2.qmui_setTheSameAppearance(as: label1)
        label2.sizeToFit()
        contentView.addSubview(label2)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        circle1.frame = circle1.frame.setXY(contentViewInsets.left, titleLabel.frame.maxY + titleLabelMarginBottom)
        arrow.frame = arrow.frame.setXY(circle1.frame.maxX + spaceBetweenIconAndCircle, circle1.frame.maxY - circle1.bounds.midY - arrow.bounds.midY)
        circle2.frame = circle2.frame.setXY(arrow.frame.maxX + spaceBetweenIconAndCircle, circle1.frame.minY)
        label1.frame = label1.frame.setXY(circle1.frame.midX - label1.bounds.midX, circle1.frame.maxY + 6)
        label2.frame = label2.frame.setXY(circle2.frame.midX - label2.bounds.midX, circle2.frame.maxY + 6)
    }
}

// 计算反色
fileprivate class QDColorCellThatInverseColor: QDColorTableViewCell {
    private var arrow: UIView!
    private var circle1: UIView!
    private var circle2: UIView!
    
    override func initSubviews() {
        super.initSubviews()
        
        titleLabel.text = "计算反色"
        
        let rawColor = UIColorMakeWithHex("#ff9800")
        let resultColor = rawColor.qmui_inverseColor  // 关键方法
        
        circle1 = generateCircle(with: rawColor)
        contentView.addSubview(circle1)
        
        arrow = generateArrowIcon()
        contentView.addSubview(arrow)
        
        circle2 = generateCircle(with: resultColor)
        contentView.addSubview(circle2)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        circle1.frame = circle1.frame.setXY(contentViewInsets.left, titleLabel.frame.maxY + titleLabelMarginBottom)
        arrow.frame = arrow.frame.setXY(circle1.frame.maxX + spaceBetweenIconAndCircle, circle1.frame.maxY - circle1.bounds.midY - arrow.bounds.midY)
        circle2.frame = circle2.frame.setXY(arrow.frame.maxX + spaceBetweenIconAndCircle, circle1.frame.minY)
    }
}

// 计算中间色
fileprivate class QDColorCellThatNeutralizeColors: QDColorTableViewCell {
    private var arrow: UIView!
    private var circle1: UIView!
    private var circle2: UIView!
    private var circle3: UIView!
    private var plus: UIView!
    
    override func initSubviews() {
        super.initSubviews()
        
        titleLabel.text = "计算过渡色"
        
        let rawColor1 = UIColorMakeWithHex("#b1dcff")
        let rawColor2 = UIColorMakeWithHex("#0e4068")
        let resultColor = UIColor.qmui_color(from: rawColor1, to: rawColor2, progress: 0.5)  // 关键方法
        
        circle1 = generateCircle(with: rawColor1)
        contentView.addSubview(circle1)
        
        plus = generatePlusIcon()
        contentView.addSubview(plus)
        
        circle2 = generateCircle(with: rawColor2)
        contentView.addSubview(circle2)
        
        arrow = generateArrowIcon()
        contentView.addSubview(arrow)
        
        circle3 = generateCircle(with: resultColor)
        contentView.addSubview(circle3)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        circle1.frame = circle1.frame.setXY(contentViewInsets.left, titleLabel.frame.maxY + titleLabelMarginBottom)
        plus.frame = plus.frame.setXY(circle1.frame.maxX + spaceBetweenIconAndCircle, circle1.frame.minYVerticallyCenter(plus.frame))
        circle2.frame = circle2.frame.setXY(plus.frame.maxX + spaceBetweenIconAndCircle, circle1.frame.minY)
        arrow.frame = arrow.frame.setXY(circle2.frame.maxX + spaceBetweenIconAndCircle, circle2.frame.minYVerticallyCenter(arrow.frame))
        circle3.frame = circle3.frame.setXY(arrow.frame.maxX + spaceBetweenIconAndCircle, circle2.frame.minY)
    }
}

// 计算叠加色
fileprivate class QDColorCellThatBlendColors: QDColorTableViewCell {
    private var arrow: UIView!
    private var circle1: UIView!
    private var circle2: UIView!
    private var circle3: UIView!
    
    override func initSubviews() {
        super.initSubviews()
        
        titleLabel.text = "计算叠加色"
        
        let rawColor1 = UIColorMakeWithHex("#68a0ce")
        let rawColor2 = UIColorMakeWithHex("#e91e63").withAlphaComponent(0.5)
        let resultColor = UIColor.qmui_colorWithBackendColor(rawColor1, frontColor: rawColor2)  // 关键方法
        
        circle1 = generateCircle(with: rawColor1)
        contentView.addSubview(circle1)
        
        circle2 = generateCircle(with: rawColor2)
        contentView.addSubview(circle2)
        
        arrow = generateArrowIcon()
        contentView.addSubview(arrow)
        
        circle3 = generateCircle(with: resultColor)
        contentView.addSubview(circle3)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        circle1.frame = circle1.frame.setXY(contentViewInsets.left, titleLabel.frame.maxY + titleLabelMarginBottom)
        circle2.frame = circle2.frame.setXY(circle1.frame.midX, circle1.frame.minY)
        arrow.frame = arrow.frame.setXY(circle2.frame.maxX + spaceBetweenIconAndCircle, circle2.frame.minYVerticallyCenter(arrow.frame))
        circle3.frame = circle3.frame.setXY(arrow.frame.maxX + spaceBetweenIconAndCircle, circle2.frame.minY)
    }
}

fileprivate class QDColorCellThatAdjustAlphaAndBlend: QDColorTableViewCell {
    private var arrow: UIView!
    private var circle1: UIView!
    private var circle2: UIView!
    private var circle3: UIView!
    private var plus1: UIView!
    private var plus2: UIView!
    private var label: QMUILabel!
    
    override func initSubviews() {
        super.initSubviews()
        
        titleLabel.text = "先更改alpha，再与另一个颜色叠加"
        
        let rawColor1 = UIColorMakeWithHex("#795548")
        let rawColor2 = UIColorMakeWithHex("#cddc39")
        let resultColor = rawColor1.qmui_color(with: 0.5, backgroundColor: rawColor2)  // 关键方法
        
        circle1 = generateCircle(with: rawColor1)
        contentView.addSubview(circle1)
        
        plus1 = generatePlusIcon()
        contentView.addSubview(plus1)
        
        label = QMUILabel()
        label.text = "0.5 ALPHA"
        label.textColor = UIColorGray7
        label.font = UIFontMake(12)
        label.sizeToFit()
        contentView.addSubview(label)
        
        plus2 = generatePlusIcon()
        contentView.addSubview(plus2)
        
        circle2 = generateCircle(with: rawColor2)
        contentView.addSubview(circle2)
        
        arrow = generateArrowIcon()
        contentView.addSubview(arrow)
        
        circle3 = generateCircle(with: resultColor)
        contentView.addSubview(circle3)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let spacingBetweenIconAndCircle: CGFloat = 8
        
        circle1.frame = circle1.frame.setXY(contentViewInsets.left, titleLabel.frame.maxY + titleLabelMarginBottom)
        plus1.frame = plus1.frame.setXY(circle1.frame.maxX + spacingBetweenIconAndCircle, circle1.frame.minYVerticallyCenter(plus1.frame))
        label.frame = label.frame.setXY(plus1.frame.maxX + spacingBetweenIconAndCircle, plus1.frame.minYVerticallyCenter(label.frame))
        plus2.frame = plus1.frame.setXY(label.frame.maxX + spacingBetweenIconAndCircle, plus1.frame.minY)
        circle2.frame = circle2.frame.setXY(plus2.frame.maxX + spacingBetweenIconAndCircle, circle1.frame.minY)
        arrow.frame = arrow.frame.setXY(circle2.frame.maxX + spacingBetweenIconAndCircle, circle2.frame.minYVerticallyCenter(arrow.frame))
        circle3.frame = circle3.frame.setXY(arrow.frame.maxX + spacingBetweenIconAndCircle, circle2.frame.minY)
    }
}
