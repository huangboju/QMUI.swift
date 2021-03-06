//
//  QDTextViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/4/10.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

class QDTextViewController: QDCommonViewController {

    private lazy var textView: QMUITextView = {
        let textView = QMUITextView()
        textView.delegate = self
        textView.placeholder = "支持 placeholder、支持自适应高度、支持限制文本输入长度"
        textView.placeholderColor = UIColorPlaceholder // 自定义 placeholder 的颜色
        textView.autoResizable = true
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 7, bottom: 10, right: 7)
        textView.returnKeyType = .send
        textView.enablesReturnKeyAutomatically = true
        let attributes: [String: Any] = [NSAttributedString.Key.font.rawValue: UIFontMake(15), NSAttributedString.Key.foregroundColor.rawValue: UIColorGray1, NSAttributedString.Key.paragraphStyle.rawValue: NSMutableParagraphStyle(lineHeight: 20)]
        textView.typingAttributes = convertToNSAttributedStringKeyDictionary(attributes)
        textView.layer.borderWidth = PixelOne
        textView.layer.borderColor = UIColorSeparator.cgColor
        textView.layer.cornerRadius = 4
        // 限制可输入的字符长度
        textView.maximumTextLength = 100
        return textView
    }()
    
    private lazy var tipsLabel: UILabel = {
        let label = UILabel()
        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFontMake(12), NSAttributedString.Key.foregroundColor: UIColorGray6, NSAttributedString.Key.paragraphStyle: NSMutableParagraphStyle(lineHeight: 16)]
        label.attributedText = NSAttributedString(string: "最长不超过 \(textView.maximumTextLength) 个文字，可尝试输入 emoji、粘贴一大段文字。\n会自动监听回车键，触发发送逻辑。", attributes: attributes)
        label.numberOfLines = 0
        return label
    }()

    private var textViewMinimumHeight: CGFloat = 96
    private var textViewMaximumHeight: CGFloat = 200
    
    override func didInitialized() {
        super.didInitialized()
        automaticallyAdjustsScrollViewInsets = false
    }
    
    override func initSubviews() {
        super.initSubviews()
        
        view.addSubview(textView)
        view.addSubview(tipsLabel)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let padding = UIEdgeInsets(top: qmui_navigationBarMaxYInViewCoordinator + 16, left: 16, bottom: 16, right: 16)
        let contentWidth = view.bounds.width - padding.horizontalValue
        
        let textViewSize = textView.sizeThatFits(CGSize(width: contentWidth, height: CGFloat.greatestFiniteMagnitude))
        textView.frame = CGRect(x: padding.left, y: padding.top, width: view.bounds.width - padding.horizontalValue, height: fmin(textViewMaximumHeight, fmax(textViewSize.height, textViewMinimumHeight)))
        
        let tipsLabelHeight = tipsLabel.sizeThatFits(CGSize(width: contentWidth, height: CGFloat.greatestFiniteMagnitude)).height
        tipsLabel.frame = CGRectFlat(padding.left, textView.frame.maxY + 8, contentWidth, tipsLabelHeight)
    }
    
    override func shouldHideKeyboardWhenTouch(in view: UIView) -> Bool {
        // 表示点击空白区域都会降下键盘
        return true
    }
}

extension QDTextViewController: QMUITextViewDelegate {
    
    func textView(_ textView: QMUITextView, newHeightAfterTextChanged height: CGFloat) {
        let newHeight = fmin(textViewMaximumHeight, fmax(height, textViewMinimumHeight))
        let needsChangeHeight = textView.frame.height != newHeight
        if needsChangeHeight {
            view.setNeedsLayout()
            view.layoutIfNeeded()
        }
    }
    
    func textView(_ textView: QMUITextView, didPreventTextChangeInRange range: NSRange, replacementText: String?) {
        QMUITips.show(text: "文字不能超过 \(textView.maximumTextLength) 个字符", in: view, hideAfterDelay: 2)
    }
    
    // 可以利用这个 delegate 来监听发送按钮的事件，当然，如果你习惯以前的方式的话，也可以继续在 textView:shouldChangeTextInRange:replacementText: 里处理
    func textViewShouldReturn(_ textView: QMUITextView) -> Bool {
        QMUITips.showSucceed(text: "成功发送文字：\(textView.text ?? "")", in: view, hideAfterDelay: 3)
        textView.text = ""
        // return true 表示这次 return 按钮的点击是为了触发“发送”，而不是为了输入一个换行符
        return true;
    }
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSAttributedStringKeyDictionary(_ input: [String: Any]) -> [NSAttributedString.Key: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
