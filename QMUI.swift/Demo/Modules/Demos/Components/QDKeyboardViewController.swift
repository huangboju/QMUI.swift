//
//  QDKeyboardViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/5/18.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

private let kToolbarHeight: CGFloat = 56
private let kEmotionViewHeight: CGFloat = 232

class QDKeyboardCustomViewController: QDCommonViewController {
    
    private var keyboardManager: QMUIKeyboardManager!
    private var maskControl: UIControl!
    private var containerView: UIView!
    fileprivate var textView: QMUITextView!
    
    private var toolbarView: UIView!
    private var cancelButton: QMUIButton!
    private var publishButton: QMUIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColorClear
    }
    
    override func initSubviews() {
        super.initSubviews()
        
        maskControl = UIControl()
        maskControl.backgroundColor = UIColorMask
        maskControl.addTarget(self, action: #selector(handleCancelButtonEvent(_:)), for: .touchUpInside)
        view.addSubview(maskControl)
        
        containerView = UIView()
        containerView.backgroundColor = UIColorWhite
        containerView.layer.cornerRadius = 8
        view.addSubview(containerView)
        
        textView = QMUITextView()
        textView.font = UIFontMake(16)
        textView.placeholder = "发表你的想法..."
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 12, bottom: 16, right: 12)
        textView.layer.cornerRadius = 8
        textView.clipsToBounds = true
        containerView.addSubview(textView)
        
        toolbarView = UIView()
        toolbarView.backgroundColor = UIColor(r: 246, g: 246, b: 246)
        toolbarView.qmui_borderColor = UIColorSeparator
        toolbarView.qmui_borderPosition = .top
        containerView.addSubview(toolbarView)
        
        cancelButton = QMUIButton()
        cancelButton.titleLabel?.font = UIFontMake(16)
        cancelButton.setTitle("关闭", for: .normal)
        cancelButton.addTarget(self, action: #selector(handleCancelButtonEvent(_:)), for: .touchUpInside)
        cancelButton.sizeToFit()
        toolbarView.addSubview(cancelButton)
        
        publishButton = QMUIButton()
        publishButton.titleLabel?.font = UIFontMake(16)
        publishButton.setTitle("发布", for: .normal)
        publishButton.addTarget(self, action: #selector(handleCancelButtonEvent(_:)), for: .touchUpInside)
        publishButton.sizeToFit()
        toolbarView.addSubview(publishButton)
        
        keyboardManager = QMUIKeyboardManager(with: self)
        // 设置键盘只接受 self.textView 的通知事件，如果当前界面有其他 UIResponder 导致键盘产生通知事件，则不会被接受
        keyboardManager.add(targetResponder: textView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        maskControl.frame = view.bounds
        let containerRect = CGRectFlat(0, view.bounds.height, view.bounds.width, 300)
        containerView.frame = containerRect.applying(containerView.transform)
        
        toolbarView.frame = CGRectFlat(0, containerView.bounds.height - kToolbarHeight, containerView.bounds.width, kToolbarHeight)
        cancelButton.frame = CGRectFlat(20, toolbarView.bounds.height.center(cancelButton.bounds.height), cancelButton.bounds.width, cancelButton.bounds.height)
        publishButton.frame = CGRectFlat(toolbarView.bounds.width - publishButton.bounds.width - 20, toolbarView.bounds.height.center(publishButton.bounds.height), publishButton.bounds.width, publishButton.bounds.height)
        
        textView.frame = CGRectFlat(0, 0, containerView.bounds.width, containerView.bounds.height - kToolbarHeight)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    fileprivate func show(in parentViewController: UIViewController) {
        if IS_LANDSCAPE {
            QDUIHelper.forceInterfaceOrientationPortrait()
        }
        
        // 这一句访问了self.view，触发viewDidLoad:
        view.frame = parentViewController.view.bounds
        
        // 需要先布局好
        parentViewController.addChild(self)
        parentViewController.view.addSubview(view)
        view.layoutIfNeeded()
        
        // 这一句触发viewWillAppear:
        beginAppearanceTransition(true, animated: true)
        
        maskControl.alpha = 0
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveOut, animations: {
            self.maskControl.alpha = 1
        }) { (finished) in
            self.didMove(toParent: self)
            // 这一句触发viewDidAppear:
            self.endAppearanceTransition()
        }
        
        textView.becomeFirstResponder()
    }
    
    fileprivate func hide() {
        self.willMove(toParent: nil)
        // 这一句触发viewWillDisappear:
        beginAppearanceTransition(false, animated: true)
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveOut, animations: {
            self.maskControl.alpha = 0
        }) { (finished) in
            self.view.removeFromSuperview()
            self.removeFromParent()
            // 这一句触发viewDidAppear:
            self.endAppearanceTransition()
            self.view.removeFromSuperview()
        }
    }
    
    
    @objc private func handleCancelButtonEvent(_ sender: Any?) {
        textView.resignFirstResponder()
    }
}

extension QDKeyboardCustomViewController: QMUIKeyboardManagerDelegate {
    func keyboardWillChangeFrame(with userInfo: QMUIKeyboardUserInfo?) {
        guard let userInfo = userInfo else {
            return
        }
        QMUIKeyboardManager.handleKeyboardNotification(with: userInfo, showClosure: { [weak self] (keyboardUserInfo) in
            QMUIKeyboardManager.animate(with: true, keyboardUserInfo: keyboardUserInfo, animations: {
                guard let strongSelf = self else {
                    return
                }
                let distanceFromBottom = QMUIKeyboardManager.distanceFromMinYToBottom(in: strongSelf.view, keyboardRect: keyboardUserInfo.endFrame)
                strongSelf.containerView.layer.transform = CATransform3DMakeTranslation(0, -distanceFromBottom - strongSelf.containerView.bounds.height, 0)
            }, completion: nil)
        }) { [weak self] (keyboardUserInfo) in
            self?.hide()
            QMUIKeyboardManager.animate(with: true, keyboardUserInfo: keyboardUserInfo, animations: {
                self?.containerView.layer.transform = CATransform3DIdentity
            }, completion: nil)
        }
    }
}

class QDKeyboardViewController: QDCommonViewController {
    
    private var toolbarView: UIView!
    private var toolbarTextField: QMUITextField!
    private var faceButton: QMUIButton!
    
    private var customViewController: QDKeyboardCustomViewController?
    
    private var contentLabel: QMUILabel!
    private var commentButton: QMUIButton!
    private var writeReviewButton: QMUIButton!
    
    private var separatorLayer: CALayer!
    
    private var emotionInputManager: QMUIEmotionInputManager!

    override func initSubviews() {
        super.initSubviews()
        
        separatorLayer = CALayer()
        separatorLayer.qmui_removeDefaultAnimations()
        separatorLayer.backgroundColor = UIColorSeparator.cgColor
        view.layer.addSublayer(separatorLayer)
        
        contentLabel = QMUILabel()
        contentLabel.numberOfLines = 0
        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font : UIFontMake(16), NSAttributedString.Key.foregroundColor: UIColorGray1, NSAttributedString.Key.paragraphStyle: NSMutableParagraphStyle(lineHeight: 24, lineBreakMode: .byCharWrapping)]
        let contentAttributedString = NSMutableAttributedString(string: "QMUIKeyboardManager 以更方便的方式管理键盘事件，无需再关心 notification、键盘坐标转换、判断是否目标输入框等问题，并兼容 iPad 浮动键盘和外接键盘。\nQMUIKeyboardManager 有两种使用方式，一种是直接使用，一种是集成到 UITextField(QMUI) 及 UITextView(QMUI) 内。", attributes: attributes)
        let codeAttributes = CodeAttributes(16)
        contentAttributedString.string.enumerateCodeString { (codeString, codeRange) in
            if codeString != "notification" && codeString != "iPad" {
                contentAttributedString.addAttributes(codeAttributes, range: codeRange)
            }
        }
        contentLabel.attributedText = contentAttributedString
        contentLabel.textAlignment = .center
        contentLabel.sizeToFit()
        view.addSubview(contentLabel)
        
        commentButton = QDUIHelper.generateLightBorderedButton()
        commentButton.setTitle("发表评论", for: .normal)
        commentButton.addTarget(self, action: #selector(handleCommentButtonEvent(_:)), for: .touchUpInside)
        view.addSubview(commentButton)
        
        writeReviewButton = QDUIHelper.generateLightBorderedButton()
        writeReviewButton.setTitle("发表想法", for: .normal)
        writeReviewButton.addTarget(self, action: #selector(handleWriteReviewItemEvent(_:)), for: .touchUpInside)
        view.addSubview(writeReviewButton)
        
        toolbarView = UIView()
        toolbarView.backgroundColor = UIColorWhite
        toolbarView.qmui_borderColor = UIColorSeparator
        toolbarView.qmui_borderPosition = .top
        view.addSubview(toolbarView)
        
        toolbarTextField = QMUITextField()
        toolbarTextField.delegate = self
        toolbarTextField.placeholder = "发表评论..."
        toolbarTextField.font = UIFontMake(15)
        toolbarTextField.backgroundColor = UIColorWhite
        toolbarView.addSubview(toolbarTextField)
        
        toolbarTextField.qmui_keyboardWillChangeFrameNotificationnClosure = { [weak self] (keyboardUserInfo) in
            if let strongSelf = self, !strongSelf.faceButton.isSelected, let keyboardUserInfo = keyboardUserInfo  {
                QMUIKeyboardManager.handleKeyboardNotification(with: keyboardUserInfo, showClosure: { (keyboardUserInfo) in
                    strongSelf.showToolbarView(with: keyboardUserInfo)
                }, hideClosure: { (keyboardUserInfo) in
                    strongSelf.hideToolbarView(with: keyboardUserInfo)
                })
            } else {
                self?.showToolbarView(with: nil)
            }
        }
        
        faceButton = QMUIButton()
        faceButton.titleLabel?.font = UIFontMake(16)
        faceButton.qmui_outsideEdge = UIEdgeInsets(top: -12, left: -12, bottom: -12, right: -12)
        faceButton.setImage(UIImageMake("icon_emotion")?.qmui_image(tintColor: UIColorGray5), for: .normal)
        faceButton.setImage(UIImageMake("icon_emotion"), for: .selected)
        faceButton.sizeToFit()
        faceButton.addTarget(self, action: #selector(handleFaceButtonEvent(_:)), for: .touchUpInside)
        toolbarView.addSubview(faceButton)
        
        emotionInputManager = QMUIEmotionInputManager()
        emotionInputManager.boundTextField = toolbarTextField
        emotionInputManager.emotionView.qmui_borderPosition = .top
        emotionInputManager.emotionView.emotions = QDUIHelper.qmuiEmotions()
        view.addSubview(emotionInputManager.emotionView)
    }
    
    @objc override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if customViewController?.view.superview != nil {
            return .portrait
        }
        return supportedOrientationMask
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        toolbarTextField.qmui_keyboardManager?.delegateEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 避免手势返回的时候输入框往下掉
        toolbarTextField.qmui_keyboardManager?.delegateEnabled = false
    }
    
    override var shouldAutomaticallyForwardAppearanceMethods: Bool {
        return false // 那个 childViewController 是加到 navController.view 上的，所以需要手动管理
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let toolbarRect = CGRectFlat(0, view.bounds.height, view.bounds.width, kToolbarHeight)
        toolbarView.frame = toolbarRect.applying(toolbarView.transform)
        
        let textFieldInset: CGFloat = 8
        let textFieldHeight: CGFloat = kToolbarHeight - textFieldInset * 2
        let emotionRight: CGFloat = 12
        
        faceButton.frame = faceButton.frame.setXY(toolbarView.bounds.width - faceButton.bounds.width - emotionRight, toolbarView.bounds.height.center(faceButton.bounds.height))
        let textFieldWidth = faceButton.frame.minX - textFieldInset * 2
        toolbarTextField.frame = CGRectFlat(textFieldInset, textFieldInset, textFieldWidth, textFieldHeight)
        
        let contentLabelInsetVertical: CGFloat = 30
        let contentLabelInsetHorizontal: CGFloat = 20
        var buttonSectionInset: CGFloat = 40
        let buttonSpacing: CGFloat = 30
        
        let contentWidth = view.bounds.width - contentLabelInsetHorizontal * 2
        let contentOffsetY: CGFloat = -6
        let contentSize = contentLabel.sizeThatFits(CGSize(width: contentWidth, height: CGFloat.greatestFiniteMagnitude))
        let commentButtonHeight = commentButton.bounds.height
        let writeReviewButtonHeight = writeReviewButton.bounds.height
        let navigationBarHeight = qmui_navigationBarMaxYInViewCoordinator
        
        if view.bounds.height - navigationBarHeight < contentSize.height + contentLabelInsetVertical * 2 + contentOffsetY + commentButtonHeight + writeReviewButtonHeight + buttonSpacing + buttonSectionInset * 2 {
            buttonSectionInset = (view.bounds.height - navigationBarHeight - contentSize.height - contentLabelInsetVertical * 2 - contentOffsetY - commentButtonHeight - writeReviewButtonHeight - buttonSpacing) / 2
        }
        
        contentLabel.frame = CGRectFlat(contentLabelInsetHorizontal, navigationBarHeight + contentLabelInsetVertical - 6, contentWidth, contentSize.height)
        
        separatorLayer.frame = CGRectFlat(0, contentLabel.frame.maxY + contentLabelInsetVertical, view.bounds.width, PixelOne)
        
        commentButton.frame = commentButton.frame.setXY(view.bounds.width.center(commentButton.bounds.width), separatorLayer.frame.maxY + buttonSectionInset)
        
        writeReviewButton.frame = writeReviewButton.frame.setXY(view.bounds.width.center(writeReviewButton.bounds.width), commentButton.frame.maxY + buttonSpacing)
        
        let emotionViewRect = CGRect(x: 0, y: view.bounds.height, width: view.bounds.width, height: kEmotionViewHeight)
        emotionInputManager.emotionView.frame = emotionViewRect.applying(emotionInputManager.emotionView.transform)
    }

    private func showToolbarView(with keyboardUserInfo: QMUIKeyboardUserInfo?) {
        if let keyboardUserInfo = keyboardUserInfo {
            // 相对于键盘
            QMUIKeyboardManager.animate(with: true, keyboardUserInfo: keyboardUserInfo, animations: {
                let distanceFromBottom = QMUIKeyboardManager.distanceFromMinYToBottom(in: self.view, keyboardRect: keyboardUserInfo.endFrame)
                self.toolbarView.layer.transform = CATransform3DMakeTranslation(0, -distanceFromBottom - kToolbarHeight, 0)
                self.emotionInputManager.emotionView.layer.transform = CATransform3DMakeTranslation(0, -distanceFromBottom, 0)
            }, completion: nil)
        } else {
            // 相对于表情面板
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveOut, animations: {
                self.toolbarView.layer.transform = CATransform3DMakeTranslation(0, -self.emotionInputManager.emotionView.bounds.height - kToolbarHeight, 0)
            }, completion: nil)
        }
    }
    
    private func hideToolbarView(with keyboardUserInfo: QMUIKeyboardUserInfo?) {
        if let keyboardUserInfo = keyboardUserInfo {
            QMUIKeyboardManager.animate(with: true, keyboardUserInfo: keyboardUserInfo, animations: {
                self.toolbarView.layer.transform = CATransform3DIdentity
                self.emotionInputManager.emotionView.layer.transform = CATransform3DIdentity
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveOut, animations: {
                self.toolbarView.layer.transform = CATransform3DIdentity
                self.emotionInputManager.emotionView.layer.transform = CATransform3DIdentity
            }, completion: nil)
        }
    }
    
    private func showEmotionView() {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveOut, animations: {
            self.emotionInputManager.emotionView.layer.transform = CATransform3DMakeTranslation(0, self.emotionInputManager.emotionView.bounds.height, 0)
        }, completion: nil)
        toolbarTextField.resignFirstResponder()
    }
    
    override func shouldHideKeyboardWhenTouch(in view: UIView) -> Bool {
        if view == toolbarView {
            // 输入框并非撑满 toolbarView 的，所以有可能点击到 toolbarView 里空白的地方，此时保持键盘状态不变
            return false
        }
        
        if faceButton.isSelected {
            faceButton.isSelected = false
            hideToolbarView(with: nil)
        }
        
        return true
    }
    
    @objc private func handleCommentButtonEvent(_ sender: Any?) {
        if !toolbarTextField.isFirstResponder {
            toolbarTextField.becomeFirstResponder()
        } else {
            toolbarTextField.resignFirstResponder()
        }
    }
    
    @objc private func handleWriteReviewItemEvent(_ sender: Any?) {
        if toolbarTextField.isFirstResponder {
            toolbarTextField.resignFirstResponder()
            return
        }
        
        if faceButton.isSelected {
            faceButton.isSelected = false
            hideToolbarView(with: nil)
            return
        }
        
        if customViewController == nil {
            customViewController = QDKeyboardCustomViewController()
        }
        if customViewController?.view.superview == nil && navigationController != nil {
            customViewController?.show(in: navigationController!)
        } else {
            customViewController?.textView.resignFirstResponder()
        }
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    @objc private func handleFaceButtonEvent(_ sender: Any?) {
        faceButton.isSelected = !faceButton.isSelected
        if !faceButton.isSelected {
            toolbarTextField.becomeFirstResponder()
        } else {
            showEmotionView()
        }
    }
}

extension QDKeyboardViewController: QMUITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        faceButton.isSelected = false
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if let range = toolbarTextField.qmui_selectedRange {
            emotionInputManager.selectedRangeForBoundTextInput = range
        }
        return true
    }
}
