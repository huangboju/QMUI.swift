//
//  QMUITableViewHeaderFooterView.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/4/12.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

enum QMUITableViewHeaderFooterViewType {
    case unknow
    case header
    case footer
}

/**
 *  适用于 UITableView 的 sectionHeaderFooterView，提供的特性包括：
 *  1. 支持单个 UILabel，该 label 支持多行文字。
 *  2. 支持右边添加一个 accessoryView（注意，设置 accessoryView 之前请先保证自身大小正确）。
 *  3. 支持调整 headerFooterView 的 padding。
 *  4. 支持应用配置表的样式。
 *
 *  使用方式：
 *  基本与系统的 UITableViewHeaderFooterView 使用方式一致，额外需要做的事情有：
 *  1. 如果要支持高度自动根据内容变化，则需要重写 tableView:heightForHeaderInSection:、tableView:heightForFooterInSection:，在里面调用 headerFooterView 的 sizeThatFits:。
 *  2. 如果要应用配置表样式，则设置 parentTableView 和 type 这两个属性即可。
 */
class QMUITableViewHeaderFooterView: UITableViewHeaderFooterView {

    weak var parentTableView: UITableView? {
        didSet {
            updateStyleIfCan()
        }
    }
    var type: QMUITableViewHeaderFooterViewType {
        didSet {
            updateStyleIfCan()
        }
    }
    
    private(set) var titleLabel: UILabel
    
    private var _accessoryView: UIView?
    var accessoryView: UIView? {
        get {
            return _accessoryView
        }
        set {
            if _accessoryView != nil && _accessoryView != newValue {
                _accessoryView!.removeFromSuperview()
            }
            _accessoryView = newValue
            if let accessoryView = _accessoryView {
                contentView.addSubview(accessoryView)
            }
        }
    }
    
    var contentEdgeInsets: UIEdgeInsets = .zero {
        didSet {
            setNeedsLayout()
        }
    }
    var accessoryViewMargins: UIEdgeInsets  = .zero {
        didSet {
            setNeedsLayout()
        }
    }
    
    override init(reuseIdentifier: String?) {
        type = .unknow
        titleLabel = UILabel()
        titleLabel.numberOfLines = 0
        super.init(reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(titleLabel)
        // remove system subviews
        textLabel?.isHidden = true
        detailTextLabel?.isHidden = true
        backgroundView = UIView() // 去掉默认的背景，以使 self.backgroundColor 生效
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateStyleIfCan() {
        guard let parentTableView = parentTableView, type != .unknow else { return }
        let isPlainStyleTableView = parentTableView.style == .plain
        if type == .header {
            titleLabel.font = isPlainStyleTableView ? TableViewSectionHeaderFont : TableViewGroupedSectionHeaderFont
            titleLabel.textColor = isPlainStyleTableView ? TableViewSectionHeaderTextColor : TableViewGroupedSectionHeaderTextColor
            contentEdgeInsets = isPlainStyleTableView ? TableViewSectionHeaderContentInset : TableViewGroupedSectionHeaderContentInset
            accessoryViewMargins = isPlainStyleTableView ? TableViewSectionHeaderAccessoryMargins : TableViewGroupedSectionHeaderAccessoryMargins
            backgroundView?.backgroundColor = isPlainStyleTableView ? TableViewSectionHeaderBackgroundColor : UIColorClear
        } else {
            titleLabel.font = isPlainStyleTableView ? TableViewSectionFooterFont : TableViewGroupedSectionFooterFont
            titleLabel.textColor = isPlainStyleTableView ? TableViewSectionFooterTextColor : TableViewGroupedSectionFooterTextColor
            contentEdgeInsets = isPlainStyleTableView ? TableViewSectionFooterContentInset : TableViewGroupedSectionFooterContentInset
            accessoryViewMargins = isPlainStyleTableView ? TableViewSectionFooterAccessoryMargins : TableViewGroupedSectionFooterAccessoryMargins
            backgroundView?.backgroundColor = isPlainStyleTableView ? TableViewSectionFooterBackgroundColor : UIColorClear
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let accessoryView = accessoryView {
            accessoryView.frame = accessoryView.frame.setX(contentView.qmui_width - contentEdgeInsets.right - accessoryViewMargins.right - accessoryView.qmui_width)
            accessoryView.frame = accessoryView.frame.setY(contentEdgeInsets.top + (contentView.qmui_height - contentEdgeInsets.verticalValue).center(accessoryView.qmui_height) + accessoryViewMargins.top - accessoryViewMargins.bottom)
        }
        
        titleLabel.sizeToFit()
        titleLabel.frame = titleLabel.frame.setX(contentEdgeInsets.left)
        titleLabel.qmui_extendToRight = accessoryView != nil ? accessoryView!.qmui_left - accessoryViewMargins.left : contentView.qmui_width - contentEdgeInsets.right
        titleLabel.frame = titleLabel.frame.setY(contentEdgeInsets.top)
        titleLabel.qmui_extendToBottom = contentView.qmui_height - contentEdgeInsets.bottom
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var resultSize = size
        var accessoryViewSize = accessoryView != nil ? accessoryView!.frame.size : .zero
        if accessoryView != nil {
            accessoryViewSize.width = accessoryViewSize.width + accessoryViewMargins.horizontalValue
            accessoryViewSize.height = accessoryViewSize.height + accessoryViewMargins.verticalValue
        }
        let titleLabelWidth = size.width - contentEdgeInsets.horizontalValue - accessoryViewSize.width
        let titleLabelSize = titleLabel.sizeThatFits(CGSize(width: titleLabelWidth, height: CGFloat.greatestFiniteMagnitude))
        resultSize.height = fmax(titleLabelSize.height, accessoryViewSize.height) + contentEdgeInsets.verticalValue
        return resultSize
    }
}
