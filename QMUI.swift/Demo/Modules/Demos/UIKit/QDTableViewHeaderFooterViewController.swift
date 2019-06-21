//
//  QDTableViewHeaderFooterViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/4/18.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

/// 展示 QMUITableViewHeaderFooterView 以及 UITableView (QMUI) 里与 section header 相关运算的 demo
class QDTableViewHeaderFooterViewController: QDCommonTableViewController {

    private lazy var debugView: QDTableViewInsetDebugPanelView = {
        return QDTableViewInsetDebugPanelView()
    }()
    
    override func initSubviews() {
        super.initSubviews()
        
        view.addSubview(debugView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let margins = UIEdgeInsets.zero
        let debugViewWidth = fmin(view.qmui_width, QMUIHelper.screenSizeFor55Inch.width) - margins.horizontalValue
        let debugViewHeight: CGFloat = 126
        let debugViewMinX = view.qmui_width.center(debugViewWidth)
        debugView.frame = CGRect(x: debugViewMinX, y: view.qmui_height - margins.bottom - debugViewHeight, width: debugViewWidth, height: debugViewHeight)
    }
    
}

extension QDTableViewHeaderFooterViewController {
    
    @objc func handleButtonEvent(_ view: UIView) {
        // 通过这个方法获取到点击的按钮所处的 sectionHeader，可兼容 sectionHeader 停靠在列表顶部的场景
        let sectionIndexForView = tableView.qmui_indexForSectionHeader(at: view)
        if sectionIndexForView != -1 {
            QMUITips.show(text: "点击了 section\(sectionIndexForView) 上的按钮", in: view, hideAfterDelay: 1.2)
        } else {
            QMUITips.showError(text: "无法定位被点击的按钮所处的 section", in: view, hideAfterDelay: 1.2)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        debugView.render(tableView: tableView)
    }
    
    override func numberOfSections(in _: UITableView) -> Int {
        return 10
    }
    
    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "cell"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? QMUITableViewCell
        if cell == nil {
            cell = QMUITableViewCell(tableView: tableView, reuseIdentifier: identifier)
            cell?.selectionStyle = .none
        }
        cell?.textLabel?.text = "\(indexPath.row)"
        cell?.updateCellAppearance(indexPath)
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Section\(section)"
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let headerView = super.tableView(tableView, viewForHeaderInSection: section) as? QMUITableViewHeaderFooterView {
            var button = headerView.accessoryView as? QMUIButton
            if button == nil {
                button = QDUIHelper.generateLightBorderedButton()
                button!.setTitle("button", for: .normal)
                button!.titleLabel?.font = UIFontMake(14)
                button!.contentEdgeInsets = UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12)
                button!.sizeToFit()
                button!.qmui_automaticallyAdjustTouchHighlightedInScrollView = true
                button!.qmui_outsideEdge = UIEdgeInsets(top: -8, left: -8, bottom: -8, right: -8)
                button!.addTarget(self, action: #selector(handleButtonEvent(_:)), for: .touchUpInside)
                headerView.accessoryView = button
            }
            return headerView
        }
        return nil
    }
}

class QDTableViewInsetDebugPanelView: UIView {
    
    // 可视范围内的 sectionHeader 列表
    private lazy var visibleHeadersLabel: UILabel = {
        let label = QDTableViewInsetDebugPanelView.generateTitleLabel()
        label.text = "可视的 sectionHeaders"
        return label
    }()
    private var visibleHeadersValue: UILabel = {
        let label = QDTableViewInsetDebugPanelView.generateValueLabel()
        return label
    }()
    
    // 当前 pinned 的那个 section 序号
    private var pinnedHeaderLabel: UILabel = {
        let label = QDTableViewInsetDebugPanelView.generateTitleLabel()
        label.text = "正在 pinned（悬浮）的 header"
        return label
    }()
    private var pinnedHeaderValue: UILabel = {
        let label = QDTableViewInsetDebugPanelView.generateValueLabel()
        return label
    }()
    
    // 某个指定的 section 的 pinned 状态
    private var headerPinnedLabel: UILabel = {
        let label = QDTableViewInsetDebugPanelView.generateTitleLabel()
        label.text = "section0 和 section1 的 pinned"
        return label
    }()
    private var headerPinnedValue: UILabel = {
        let label = QDTableViewInsetDebugPanelView.generateValueLabel()
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        isUserInteractionEnabled = false
        backgroundColor = UIColor(r: 0, g: 0, b: 0, a: 0.7)
        
        addSubview(visibleHeadersLabel)
        addSubview(visibleHeadersValue)
        addSubview(pinnedHeaderLabel)
        addSubview(pinnedHeaderValue)
        addSubview(headerPinnedLabel)
        addSubview(headerPinnedValue)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func render(tableView: UITableView) {
        visibleHeadersValue.text = tableView.qmui_indexForVisibleSectionHeaders?.reduce("") {
            if $0 == nil || $0 == "" {
                return "\($1)"
            }
            return "\($0!)" + " , \($1)"
        }
        let indexOfPinnedSectionHeader = tableView.qmui_indexOfPinnedSectionHeader
        let pinnedHeaderString = String.qmui_hexString(with: indexOfPinnedSectionHeader)
        pinnedHeaderValue.text = pinnedHeaderString
        pinnedHeaderValue.textColor = indexOfPinnedSectionHeader == -1 ? UIColorRed : UIColorWhite
        
        let isSectionHeader0Pinned = tableView.qmui_isHeaderPinned(for: 0)
        let isSectionHeader1Pinned = tableView.qmui_isHeaderPinned(for: 1)
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font : pinnedHeaderValue.font!,
            .foregroundColor: UIColorWhite
        ]
        let headerPinnedString = NSMutableAttributedString(string: "0: \(isSectionHeader0Pinned) | 1: \(isSectionHeader1Pinned)", attributes: attributes)
        
        let range0 = isSectionHeader0Pinned ? NSMakeRange(3, 4) : NSMakeRange(3, 5)
        let range1 = isSectionHeader1Pinned ? NSMakeRange(headerPinnedString.length - 4, 4) : NSMakeRange(headerPinnedString.length - 5, 5)
        headerPinnedString.addAttribute(.foregroundColor, value: isSectionHeader0Pinned ? UIColorGreen : UIColorRed, range: range0)
        headerPinnedString.addAttribute(.foregroundColor, value: isSectionHeader1Pinned ? UIColorGreen : UIColorRed, range: range1)
        headerPinnedValue.attributedText = headerPinnedString
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let padding = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24).concat(insets: qmui_safeAreaInsets)
        let leftLabels = [visibleHeadersLabel, pinnedHeaderLabel, headerPinnedLabel]
        let rightLabels = [visibleHeadersValue, pinnedHeaderValue, headerPinnedValue]
        
        let contentWidth = qmui_width - padding.horizontalValue
        let labelHorizontalSpacing: CGFloat = 16
        let labelVerticalSpacing: CGFloat = 16
        var minY: CGFloat = padding.top
        
        // 左边的 label
        let leftLabelWidth = flat((contentWidth - labelHorizontalSpacing) * 3 / 5)
        for label in leftLabels {
            label.frame = CGRectFlat(padding.left, minY, leftLabelWidth, label.qmui_height)
            minY = label.qmui_bottom + labelVerticalSpacing
        }
        
        // 右边的 label
        minY = padding.top
        let rightLabelMinX = leftLabels.first?.qmui_right ?? 0 + labelHorizontalSpacing
        let rightLabelWidth = flat(contentWidth - leftLabelWidth - labelHorizontalSpacing)
        for label in rightLabels {
            label.frame = CGRectFlat(rightLabelMinX, minY, rightLabelWidth, label.qmui_height)
            minY = label.qmui_bottom + labelVerticalSpacing
        }
        
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
    }
    
    static private func generateTitleLabel() -> UILabel {
        let label = UILabel(with: UIFontMake(12), textColor: UIColorWhite)
        label.qmui_calculateHeightAfterSetAppearance()
        return label
    }
    
    static private func generateValueLabel() -> UILabel {
        let label = UILabel(with: UIFontMake(12), textColor: UIColorWhite)
        label.textAlignment = .right
        label.qmui_calculateHeightAfterSetAppearance()
        return label
    }
}
