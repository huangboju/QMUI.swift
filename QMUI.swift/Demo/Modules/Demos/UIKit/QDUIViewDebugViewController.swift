//
//  QDUIViewDebugViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/4/24.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

class QDUIViewDebugViewController: QDCommonViewController {

    private var descriptionLabel: UILabel!
    private var parentView: UIView!
    private var subview1: UIView!
    private var subview2: UIView!
    
    override func initSubviews() {
        super.initSubviews()
        
        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font : UIFontMake(16), NSAttributedString.Key.foregroundColor: UIColorGray1]
        let attributedString = NSMutableAttributedString(string: "通过 qmui_shouldShowDebugColor 让 UIView 以及其所有的 subviews 都加上一个背景色，方便查看其布局情况", attributes: attributes)
        attributedString.string.enumerateCodeString { (codeString, codeRange) in
            attributedString.addAttributes(CodeAttributes(16), range: codeRange)
        }
        
        descriptionLabel = UILabel()
        descriptionLabel.attributedText = attributedString
        descriptionLabel.numberOfLines = 0
        view.addSubview(descriptionLabel)
        
        parentView = UIView()
        parentView.qmui_shouldShowDebugColor = true// 打开 debug 背景色
        parentView.qmui_needsDifferentDebugColor = true// 让背景颜色随机
        view.addSubview(parentView)
        
        subview1 = UIView(size: CGSize(width: 50, height: 50))
        parentView.addSubview(subview1)
        
        subview2 = UIView(size: CGSize(width: 160, height: 90))
        parentView.addSubview(subview2)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let padding = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
        let contentWidth = view.bounds.width - padding.horizontalValue
        descriptionLabel.frame = CGRect(x: padding.left, y: qmui_navigationBarMaxYInViewCoordinator + padding.top, width: contentWidth, height: descriptionLabel.sizeThatFits(CGSize(width: contentWidth, height: CGFloat.greatestFiniteMagnitude)).height)
        
        subview1.qmui_left = 24
        subview1.qmui_top = 24;
        subview2.qmui_left = subview1.qmui_left
        subview2.qmui_top = subview1.qmui_bottom + 24
        
        parentView.frame = CGRect(x: padding.left, y: descriptionLabel.frame.maxY + 24, width: contentWidth, height: subview2.qmui_bottom + 24)
    }
}
