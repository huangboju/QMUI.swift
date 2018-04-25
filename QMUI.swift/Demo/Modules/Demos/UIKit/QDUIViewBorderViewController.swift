//
//  QDUIViewBorderViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/4/24.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

class QDUIViewBorderViewController: QDCommonViewController {

    private var label1: QMUILabel!
    private var label2: QMUILabel!
    private var label3: QMUILabel!
    private var label4: QMUILabel!
    
    override func initSubviews() {
        super.initSubviews()
        
        label1 = generateLabel("qmui_borderPosition 可指定四个方向的边框")
        label1.qmui_borderPosition = .bottom
        
        label2 = generateLabel("qmui_borderWidth 可修改边框大小")
        label2.qmui_borderPosition = .bottom
        label2.qmui_borderWidth = 3
        
        label3 = generateLabel("qmui_borderColor 可修改边框颜色")
        label3.qmui_borderPosition = .bottom
        label3.qmui_borderColor = QDThemeManager.shared.currentTheme?.themeTintColor ?? UIColorBlue
        
        label4 = generateLabel("qmui_dashPattern 可定义虚线")
        label4.qmui_borderPosition = .bottom
        label4.qmui_dashPhase = 0
        label4.qmui_dashPattern = [3, 4]
        label4.qmui_borderColor = UIColorSeparatorDashed
        
    }
    
    private func generateLabel(_ text: String) -> QMUILabel {
        let label = QMUILabel()
        label.contentEdgeInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        label.numberOfLines = 0
        let attributes: [NSAttributedStringKey: Any] = [NSAttributedStringKey.font : UIFontMake(16), NSAttributedStringKey.foregroundColor: UIColorGray1]
        let attributedString = NSMutableAttributedString(string: text, attributes: attributes)
        let codeAttributes = CodeAttributes(16)
        text.enumerateCodeString { (codeString, codeRange) in
            attributedString.setAttributes(codeAttributes, range: codeRange)
        }
        label.attributedText = attributedString
        view.addSubview(label)
        return label
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let padding = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
        let labelSpacing: CGFloat = 24
        let contentWidth = view.bounds.width - padding.horizontalValue
        
        label1.frame = CGRectFlat(padding.left, padding.top + qmui_navigationBarMaxYInViewCoordinator, contentWidth, label1.sizeThatFits(CGSize(width: contentWidth, height: CGFloat.greatestFiniteMagnitude)).height)
        label2.frame = CGRectFlat(padding.left, label1.frame.maxY + labelSpacing, contentWidth, label2.sizeThatFits(CGSize(width: contentWidth, height: CGFloat.greatestFiniteMagnitude)).height)
        label3.frame = CGRectFlat(padding.left, label2.frame.maxY + labelSpacing, contentWidth, label3.sizeThatFits(CGSize(width: contentWidth, height: CGFloat.greatestFiniteMagnitude)).height)
        label4.frame = CGRectFlat(padding.left, label3.frame.maxY + labelSpacing, contentWidth, label4.sizeThatFits(CGSize(width: contentWidth, height: CGFloat.greatestFiniteMagnitude)).height)
    }
}
