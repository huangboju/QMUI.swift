//
//  QDTextFieldViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/4/17.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

class QDTextFieldViewController: QDCommonViewController {

    private lazy var textField: QMUITextField = {
        let textField = QMUITextField()
        textField.delegate = self
        textField.maximumTextLength = 10
        textField.placeholder = "请输入文字"
        textField.font = UIFontMake(16)
        textField.layer.cornerRadius = 2
        textField.layer.borderColor = UIColorSeparator.cgColor
        textField.layer.borderWidth = PixelOne
        textField.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        textField.clearButtonMode = .always
        return textField
    }()

    private lazy var tipsLabel: UILabel = {
        let label = UILabel()
        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFontMake(12), NSAttributedString.Key.foregroundColor: UIColorGray6, NSAttributedString.Key.paragraphStyle: NSMutableParagraphStyle(lineHeight: 16)]
        label.attributedText = NSAttributedString(string: "支持自定义 placeholder 颜色，支持调整输入框与文字之间的间距，支持限制最大可输入的文字长度（可试试输入 emoji、从中文输入法候选词输入等）。", attributes: attributes)
        label.numberOfLines = 0
        return label
    }()
    
    override func didInitialized() {
        super.didInitialized()
        automaticallyAdjustsScrollViewInsets = false
    }
    
    override func initSubviews() {
        super.initSubviews()
        
        view.addSubview(textField)
        view.addSubview(tipsLabel)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let padding = UIEdgeInsets(top: qmui_navigationBarMaxYInViewCoordinator + 16, left: 16, bottom: 16, right: 16)
        let contentWidth = view.bounds.width - padding.horizontalValue
        textField.frame = CGRect(x: padding.left, y: padding.top, width: contentWidth, height: 40)
        
        let tipsLabelHeight = tipsLabel.sizeThatFits(CGSize(width: contentWidth, height: CGFloat.greatestFiniteMagnitude)).height
        tipsLabel.frame = CGRectFlat(padding.left, textField.frame.maxY + 8, contentWidth, tipsLabelHeight)
    }
}

extension QDTextFieldViewController: QMUITextFieldDelegate {
    
    func textField(_ textField: QMUITextField, didPreventTextChangeInRange range: NSRange, replacementString: String?) {
        QMUITips.showSucceed(text: "文字不能超过 \(textField.maximumTextLength)个字符", in: view, hideAfterDelay: 2)
    }
}
