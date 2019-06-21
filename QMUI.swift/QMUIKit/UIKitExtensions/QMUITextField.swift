//
//  QMUITextField.swift
//  QMUI.swift
//
//  Created by xnxin on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

import UIKit

@objc protocol QMUITextFieldDelegate: UITextFieldDelegate {

    /**
     *  配合 `maximumTextLength` 属性使用，在输入文字超过限制时被调用。
     *  @warning 在 UIControlEventEditingChanged 里也会触发文字长度拦截，由于此时 textField 的文字已经改变完，所以无法得知发生改变的文本位置及改变的文本内容，所以此时 range 和 replacementString 这两个参数的值也会比较特殊，具体请看参数讲解。
     *
     *  @param textField 触发的 textField
     *  @param range 要变化的文字的位置，如果在 UIControlEventEditingChanged 里，这里的 range 也即文字变化后的 range，所以可能比最大长度要大。
     *  @param replacementString 要变化的文字，如果在 UIControlEventEditingChanged 里，这里永远传入 nil。
     */
    @objc optional func textField(_ textField: QMUITextField,
                                  didPreventTextChangeInRange range: NSRange,
                                  replacementString: String?) -> Void
}

/**
 *  支持的特性包括：
 *
 *  1. 自定义 placeholderColor。
 *  2. 自定义 UITextField 的文字 padding。
 *  3. 支持限制输入的文字的长度。
 *  4. 修复 iOS 10 之后 UITextField 输入中文超过文本框宽度后再删除，文字往下掉的 bug。
 */
class QMUITextField: UITextField, QMUITextFieldDelegate, UIScrollViewDelegate {

    private weak var originalDelegate: QMUITextFieldDelegate?

    override var delegate: UITextFieldDelegate? {
        didSet {
            originalDelegate = delegate as? QMUITextFieldDelegate
        }
    }

    /**
     *  修改 placeholder 的颜色，默认是 UIColorPlaceholder。
     */
    @IBInspectable var placeholderColor: UIColor = UIColorPlaceholder {
        didSet {
            if let _ = placeholder {
                updateAttributedPlaceholderIfNeeded()
            }
        }
    }

    override var placeholder: String? {
        didSet {
            updateAttributedPlaceholderIfNeeded()
        }
    }

    override var text: String? {
        get {
            return super.text
        }
        set {
            let textBeforeChange = super.text
            super.text = newValue

            if shouldResponseToProgrammaticallyTextChanges && textBeforeChange?.isEqual(newValue) ?? false {
                fireTextDidChangeEvent(forTextField: self)
            }
        }
    }

    override var attributedText: NSAttributedString? {
        get {
            return super.attributedText
        }
        set {
            let textBeforeChange = super.attributedText
            super.attributedText = newValue
            if let _ = newValue {
                if shouldResponseToProgrammaticallyTextChanges && textBeforeChange?.isEqual(to: newValue!) ?? false {
                    fireTextDidChangeEvent(forTextField: self)
                }
            }
        }
    }

    /**
     *  文字在输入框内的 padding。如果出现 clearButton，则 textInsets.right 会控制 clearButton 的右边距
     *
     *  默认为 TextFieldTextInsets
     */
    var textInsets: UIEdgeInsets = TextFieldTextInsets

    /**
     *  当通过 `setText(_:)`、`setAttributedText(_:)`等方式修改文字时，是否应该自动触发 UIControlEventEditingChanged 事件及 UITextFieldTextDidChangeNotification 通知。
     *
     *  默认为true（注意系统的 UITextField 对这种行为默认是 false）
     */
    @IBInspectable var shouldResponseToProgrammaticallyTextChanges: Bool = true
    /**
     *  显示允许输入的最大文字长度，默认为 Int.max，也即不限制长度。
     */
    @IBInspectable var maximumTextLength: UInt = UInt.max

    /**
     *  在使用 maximumTextLength 功能的时候，是否应该把文字长度按照 NSString (QMUI) qmui_lengthWhenCountingNonASCIICharacterAsTwo(_:) 的方法来计算。
     *  默认为 false。
     */
    @IBInspectable var shouldCountingNonASCIICharacterAsTwo: Bool = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        didInitialized()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        didInitialized()
    }

    func didInitialized() {
        tintColor = TextFieldTintColor
        delegate = self
        addTarget(self, action: #selector(handleTextChangeEvent(_:)), for: .editingChanged)
    }

    deinit {
        delegate = nil
        originalDelegate = nil
    }

    func updateAttributedPlaceholderIfNeeded() {
        if let _ = placeholder {
            attributedPlaceholder = NSAttributedString(string: placeholder!, attributes: [NSAttributedString.Key.foregroundColor: placeholderColor])
        }
    }

    // MARK: TextInsets

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let newBounds = bounds.insetEdges(textInsets)
        let resultRect = super.textRect(forBounds: newBounds)
        return resultRect
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let newBounds = bounds.insetEdges(textInsets)
        return super.editingRect(forBounds: newBounds)
    }

    // MARK: TextPosition

    override func layoutSubviews() {
        super.layoutSubviews()

        // 以下代码修复系统的 UITextField 在 iOS 10 下的 bug：https://github.com/QMUI/QMUI_iOS/issues/64
        if IOS_VERSION < 10.0 {
            return
        }

        guard let scrollView = subviews.first as? UIScrollView else {
            return
        }

        // 默认 delegate 是为 nil 的，所以我们才利用 delegate 修复这 个 bug，如果哪一天 delegate 不为 nil，就先不处理了。
        if scrollView.delegate != nil {
            return
        }

        scrollView.delegate = self
    }

    // MARK: UIScrollViewDelegate

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 以下代码修复系统的 UITextField 在 iOS 10 下的 bug：https://github.com/QMUI/QMUI_iOS/issues/64
        guard let subView = subviews.first as? UIScrollView else {
            return
        }

        if scrollView != subView {
            return
        }

        var lineHeight = (convertFromNSAttributedStringKeyDictionary(defaultTextAttributes)[NSAttributedString.Key.paragraphStyle.rawValue] as! NSParagraphStyle).minimumLineHeight

        if lineHeight == 0 {
            lineHeight = (convertFromNSAttributedStringKeyDictionary(defaultTextAttributes)[NSAttributedString.Key.font.rawValue] as! UIFont).lineHeight
        }

        if scrollView.contentSize.height > ceil(lineHeight) && scrollView.contentOffset.y < 0 {
            scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: 0)
        }
    }

    @objc private func handleTextChangeEvent(_ textField: QMUITextField) {
        // 1、iOS 10 以下的版本，从中文输入法的候选词里选词输入，是不会走到 textField:shouldChangeCharactersInRange:replacementString: 的，所以要在这里截断文字
        // 2、如果是中文输入法正在输入拼音的过程中（markedTextRange 不为 nil），是不应该限制字数的（例如输入“huang”这5个字符，其实只是为了输入“黄”这一个字符），所以在 shouldChange 那边不会限制，而是放在 didChange 这里限制。
        if textField.markedTextRange == nil {
            if lengthWithString(textField.text ?? "") > textField.maximumTextLength {
                let nsRange = NSMakeRange(0, Int(textField.maximumTextLength))
                let swiftRange = Range(nsRange, in: textField.text!)
                let allowedText = textField.text!.qmui_substringAvoidBreakingUpCharacterSequencesWithRange(range: swiftRange!, lessValue: true, countingNonASCIICharacterAsTwo: shouldCountingNonASCIICharacterAsTwo)
                textField.text = allowedText

                if let range = textField.qmui_selectedRange {
                    originalDelegate?.textField?(textField, didPreventTextChangeInRange: range, replacementString: nil)
                }
            }
        }
    }

    func fireTextDidChangeEvent(forTextField textField: QMUITextField) {
        textField.sendActions(for: .editingChanged)
        NotificationCenter.default.post(name: UITextField.textDidChangeNotification, object: textField)
    }

    private func lengthWithString(_ string: String) -> UInt {
        return UInt(shouldCountingNonASCIICharacterAsTwo ? string.qmui_lengthWhenCountingNonASCIICharacterAsTwo : string.length)
    }

    // MARK: QMUITextFieldDelegate

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if let textField = textField as? QMUITextField {
            if textField.maximumTextLength < UInt.max {
                // 如果是中文输入法正在输入拼音的过程中（markedTextRange 不为 nil），是不应该限制字数的（例如输入“huang”这5个字符，其实只是为了输入“黄”这一个字符），所以在 shouldChange 这里不会限制，而是放在 didChange 那里限制。

                let isDeleting = range.length > 0 && string.length <= 0
                if isDeleting || (textField.markedTextRange != nil) {
                    return textField.originalDelegate?.textField?(textField, shouldChangeCharactersIn: range, replacementString: string) ?? true
                }

                let valueIfTrue = textField.text?.substring(with: range).qmui_lengthWhenCountingNonASCIICharacterAsTwo ?? 0
                let rangeLength = UInt(shouldCountingNonASCIICharacterAsTwo ? valueIfTrue : range.length)

                let textWillOutofMaximumTextLength = lengthWithString(textField.text ?? "") - rangeLength + lengthWithString(string) > textField.maximumTextLength
                if textWillOutofMaximumTextLength {
                    // 将要插入的文字裁剪成这么长，就可以让它插入了
                    let substringLength = textField.maximumTextLength - lengthWithString(textField.text ?? "") + rangeLength
                    if substringLength > 0 && lengthWithString(string) > substringLength {
                        let nsRange = NSMakeRange(0, Int(substringLength))
                        let swiftRange = Range(nsRange, in: string)
                        let allowedText = string.qmui_substringAvoidBreakingUpCharacterSequencesWithRange(range: swiftRange!, lessValue: true, countingNonASCIICharacterAsTwo: shouldCountingNonASCIICharacterAsTwo)
                        if lengthWithString(allowedText) <= substringLength {
                            if let _ = textField.text {
                                textField.text = (textField.text! as NSString).replacingCharacters(in: range, with: allowedText)
                            }
                            if !textField.shouldResponseToProgrammaticallyTextChanges {
                                textField.fireTextDidChangeEvent(forTextField: textField)
                            }
                        }
                    }

                    originalDelegate?.textField?(textField, didPreventTextChangeInRange: range, replacementString: string)
                    return false
                }
            }

            return textField.originalDelegate?.textField?(textField, shouldChangeCharactersIn: range, replacementString: string) ?? true
        }

        return true
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKeyDictionary(_ input: [NSAttributedString.Key: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}
