//
//  QDEmotionsViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/5/4.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

class QDEmotionsViewController: QDCommonViewController {

    private var descriptionLabel: UILabel!
    private var toolbar: UIView!
    private var textField: QMUITextField!
    private var emotionInputManager: QMUIEmotionInputManager!
    private var keyboardVisible: Bool = false
    private var keyboardHeight: CGFloat!
    
    override func initSubviews() {
        super.initSubviews()
        
        descriptionLabel = UILabel()
        descriptionLabel.numberOfLines = 0
        
        let attributes: [NSAttributedStringKey: Any] = [NSAttributedStringKey.font : UIFontMake(16), NSAttributedStringKey.foregroundColor: UIColorGray1, NSAttributedStringKey.paragraphStyle: NSMutableParagraphStyle(lineHeight: 22)]
        let attributedString = NSMutableAttributedString(string: "本界面以 QMUIEmotionInputManager 为例，展示 QMUIEmotionView 的功能，若需查看 QMUIEmotionView 的使用方式，请参考 QMUIEmotionInputManager。", attributes: attributes)
        let codeAttributes = CodeAttributes(16)
        attributedString.string.enumerateCodeString { (codeString, codeRange) in
            attributedString.addAttributes(codeAttributes, range: codeRange)
        }
        descriptionLabel.attributedText = attributedString
        view.addSubview(descriptionLabel)
        
        toolbar = UIView()
        toolbar.qmui_borderPosition = .top
        toolbar.backgroundColor = UIColorWhite
        view.addSubview(toolbar)
        
        textField = QMUITextField()
        textField.placeholder = "请输入文字"
        textField.delegate = self
        
        textField.qmui_keyboardWillShowNotificationClosure = { [weak self] (keyboardUserInfo) in
            let keyboardHeight = keyboardUserInfo.height(in: self?.view)
            if keyboardHeight <= 0 {
                return
            }
            self?.keyboardVisible = true
            self?.keyboardHeight = keyboardHeight
            let duration = keyboardUserInfo.animationDuration
            let options = keyboardUserInfo.animationOptions
            UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
                self?.view.setNeedsLayout()
                self?.view.layoutIfNeeded()
            }, completion: nil)
        }
        
        textField.qmui_keyboardWillHideNotificationClosure = { [weak self] (keyboardUserInfo) in
            self?.keyboardVisible = false
            self?.keyboardHeight = 0
            let duration = keyboardUserInfo.animationDuration
            let options = keyboardUserInfo.animationOptions
            UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
                self?.view.setNeedsLayout()
                self?.view.layoutIfNeeded()
            }, completion: nil)
        }
        
        toolbar.addSubview(textField)
        
        emotionInputManager = QMUIEmotionInputManager()
        emotionInputManager.emotionView.emotions = QDUIHelper.qmuiEmotions()
        emotionInputManager.emotionView.qmui_borderPosition = .top
        emotionInputManager.boundTextField = textField
        view.addSubview(emotionInputManager.emotionView)
        
        toolbar.alpha = 0
        emotionInputManager.emotionView.alpha = 0
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        textField.qmui_keyboardManager?.delegateEnabled = false
    }
    
    // 布局时依赖 self.view.safeAreaInset.bottom，但由于前一个界面有 tabBar，导致 push 进来后第一次布局，self.view.safeAreaInset.bottom 依然是以存在 tabBar 的方式来计算的，所以会有跳动，简单处理，这里通过动画来掩饰这个跳动，哈哈
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        toolbar.transform = CGAffineTransform(translationX: 0, y: view.qmui_height - toolbar.qmui_top)
        emotionInputManager.emotionView.transform = CGAffineTransform(translationX: 0, y: view.qmui_height - emotionInputManager.emotionView.qmui_top)
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveOut, animations: {
            self.toolbar.alpha = 1
            self.emotionInputManager.emotionView.alpha = 1
            self.toolbar.transform = .identity
            self.emotionInputManager.emotionView.transform = .identity
        }, completion: nil)
        textField.qmui_keyboardManager?.delegateEnabled = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let padding = UIEdgeInsets(top: 20, left: 20 + view.qmui_safeAreaInsets.left, bottom: 20, right: 20 + view.qmui_safeAreaInsets.right)
        let contentWidth = view.bounds.width - padding.horizontalValue
        let descriptionLabelSize = descriptionLabel.sizeThatFits(CGSize(width: contentWidth, height: CGFloat.greatestFiniteMagnitude))
        descriptionLabel.frame = CGRectFlat(padding.left, qmui_navigationBarMaxYInViewCoordinator + padding.top, contentWidth, descriptionLabelSize.height)
        let toolbarHeight: CGFloat = 56
        let emotionViewHeight: CGFloat = 232
        if keyboardVisible {
            toolbar.frame = CGRect(x: 0, y: view.bounds.height - keyboardHeight - toolbarHeight, width: view.bounds.width, height: toolbarHeight)
            emotionInputManager.emotionView.frame = CGRect(x: 0, y: toolbar.frame.maxY, width: view.bounds.width, height: emotionViewHeight)
        } else {
            emotionInputManager.emotionView.frame = CGRect(x: 0, y: view.bounds.height - view.qmui_safeAreaInsets.bottom - emotionViewHeight, width: view.bounds.width, height: emotionViewHeight)
            toolbar.frame = CGRect(x: 0, y: emotionInputManager.emotionView.frame.minY - toolbarHeight, width: view.bounds.width, height: toolbarHeight)
        }
        
        let toolbarPadding = UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 8).concat(insets: toolbar.qmui_safeAreaInsets)
        textField.frame = CGRect(x: toolbarPadding.left, y: toolbarPadding.top, width: toolbar.bounds.width - toolbarPadding.horizontalValue, height: toolbar.bounds.height - toolbarPadding.verticalValue)
    }
    
    override func shouldHideKeyboardWhenTouch(in view: UIView) -> Bool {
        if view.isDescendant(of: toolbar) {
            // 输入框并非撑满 toolbar 的，所以有可能点击到 toolbar 里空白的地方，此时保持键盘状态不变
            return false
        }
        return true
    }
}

extension QDEmotionsViewController: UITextFieldDelegate {
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        // 告诉 qqEmotionManager 输入框的光标位置发生变化，以保证表情插入在光标之后
        emotionInputManager.selectedRangeForBoundTextInput = textField.qmui_selectedRange!
        return true
    }
}
