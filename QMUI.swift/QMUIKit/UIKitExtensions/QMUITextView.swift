//
//  QMUITextView.swift
//  QMUI.swift
//
//  Created by xnxin on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

import UIKit

@objc protocol QMUITextViewDelegate: UITextViewDelegate {

    /**
     *  输入框高度发生变化时的回调，仅当 `autoResizable` 属性为 YES 时才有效。
     *  @note 只有当内容高度与当前输入框的高度不一致时才会调用到这里，所以无需在内部做高度是否变化的判断。
     */
    @objc optional func textView(_ textView: QMUITextView,
                                 newHeightAfterTextChanged height: CGFloat) -> Void

    /**
     *  用户点击键盘的 return 按钮时的回调（return 按钮本质上是输入换行符“\n”）
     *  @return 返回 YES 表示程序认为当前的点击是为了进行类似“发送”之类的操作，所以最终“\n”并不会被输入到文本框里。返回 NO 表示程序认为当前的点击只是普通的输入，所以会继续询问 textView(_:shouldChangeTextIn:replacementText:) 方法，根据该方法的返回结果来决定是否要输入这个“\n”。
     *  @see maximumTextLength
     */
    @objc optional func textViewShouldReturn(_ textView: QMUITextView) -> Bool

    /**
     *  配合 `maximumTextLength` 属性使用，在输入文字超过限制时被调用。例如如果你的输入框在按下键盘“Done”按键时做一些发送操作，就可以在这个方法里判断 replacementText. isEqualToString:@"\n"]。
     *  @warning 在 textViewDidChange(_:) 里也会触发文字长度拦截，由于此时 textView 的文字已经改变完，所以无法得知发生改变的文本位置及改变的文本内容，所以此时 range 和 replacementText 这两个参数的值也会比较特殊，具体请看参数讲解。
     *
     *  @param textView 触发的 textView
     *  @param range 要变化的文字的位置，如果在 textViewDidChange(_:) 里，这里的 range 也即文字变化后的 range，所以可能比最大长度要大。
     *  @param replacementText 要变化的文字，如果在 textViewDidChange(_:) 里，这里永远传入 nil。
     */
    @objc optional func textView(_ textView: QMUITextView,
                                 didPreventTextChangeInRange range: NSRange,
                                 replacementText: String?) -> Void
}

/// 系统 textView 默认的字号大小，用于 placeholder 默认的文字大小。实测得到，请勿修改。
private let kSystemTextViewDefaultFontPointSize: CGFloat = 12.0

/// 当系统的 textView.textContainerInset 为 UIEdgeInsets.zero 时，文字与 textView 边缘的间距。实测得到，请勿修改（在输入框font大于13时准确，小于等于12时，y有-1px的偏差）。
private let kSystemTextViewFixTextInsets: UIEdgeInsets = UIEdgeInsets.init(top: 0, left: 5, bottom: 0, right: 5)

/**
 *  自定义 UITextView，提供的特性如下：
 *
 *  1. 支持 placeholder 并支持更改 placeholderColor；若使用了富文本文字，则 placeholder 的样式也会跟随文字的样式（除了 placeholder 颜色）
 *  2. 支持在文字发生变化时计算内容高度并通知 delegate （需打开 autoResizable 属性）。
 *  3. 支持限制输入的文本的最大长度，默认不限制。
 *  4. 修正系统 UITextView 在输入时自然换行的时候，contentOffset 的滚动位置没有考虑 textContainerInset.bottom
 */
class QMUITextView: UITextView, QMUITextViewDelegate {

    /**
     *  当通过 `setText(_:)`、`setAttributedText(_:)`等方式修改文字时，是否应该自动触发 `UITextViewDelegate` 里的 `textView(_:shouldChangeTextIn:replacementText:)`、 `textViewDidChange(_:)` 方法
     *
     *  默认为YES（注意系统的 UITextView 对这种行为默认是 NO）
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

    /**
     *   placeholder 的文字
     */
    @IBInspectable var placeholder: String? {
        didSet {
            let attributes = Dictionary(uniqueKeysWithValues: convertFromNSAttributedStringKeyDictionary(typingAttributes).map {
                key, value in (key, value)
            })
            placeholderLabel?.attributedText = NSAttributedString(string: placeholder ?? "", attributes: attributes)

            if let placeholderLabel = self.placeholderLabel {
                placeholderLabel.textColor = placeholderColor
                sendSubviewToBack(placeholderLabel)
            }
            setNeedsLayout()
        }
    }

    /**
     *  placeholder 文字的颜色
     */
    @IBInspectable var placeholderColor: UIColor = UIColorPlaceholder {
        didSet {
            placeholderLabel?.textColor = placeholderColor
        }
    }

    /**
     *  placeholder 在默认位置上的偏移（默认位置会自动根据 textContainerInset、contentInset 来调整）
     */
    var placeholderMargins: UIEdgeInsets = UIEdgeInsets.zero

    /**
     *  是否支持自动拓展高度，默认为 false
     *  @see textView(_:newHeightAfterTextChanged:)
     */
    var autoResizable: Bool = false

    /**
     *  控制输入框是否要出现“粘贴”menu
     *  @param sender 触发这次询问事件的来源
     *  @param superReturnValue super.canPerformAction(_:withSender:) 的返回值，当你不需要控制这个 block 的返回值时，可以返回 superReturnValue
     *  @return 控制是否要出现“粘贴”menu，YES 表示出现，NO 表示不出现。当你想要返回系统默认的结果时，请返回参数 superReturnValue
     */
    var canPerformPasteActionBlock: ((_ sender: Any?, _ superReturnValue: Bool) -> Bool)?

    /**
     *  当输入框的“粘贴”事件被触发时，可通过这个 block 去接管事件的响应。
     *  @param sender “粘贴”事件触发的来源，例如可能是一个 UIMenuController
     *  @return 返回值用于控制是否要调用系统默认的 paste: 实现，YES 表示执行完 block 后继续调用系统默认实现，NO 表示执行完 block 后就结束了，不调用 super。
     */
    var pasteBlock: ((_ sender: Any?) -> Bool)?

    private var debug: Bool = false

    /// // 如果在 handleTextChanged(_:) 里主动调整 contentOffset，则为了避免被系统的自动调整覆盖，会利用这个标记去屏蔽系统对 setContentOffset(_:) 的调用
    private var shouldRejectSystemScroll: Bool?

    private var placeholderLabel: UILabel?

    /// 重写 text 的 setter 方法
    override var text: String! {
        get {
            return super.text
        }
        set {
            let textBeforeChange = self.text ?? ""
            let textDifferent = isCurrentTextDifferentOfText(newValue)

            // 如果前后文字没变化，则什么都不做
            if !textDifferent {
                super.text = newValue
                return
            }

            // 前后文字发生变化，则要根据是否主动接管 delegate 来决定是否要询问 delegate
            if shouldResponseToProgrammaticallyTextChanges {
                
                let shouldChangeText = delegate?.textView?(self, shouldChangeTextIn: NSMakeRange(0, textBeforeChange.length), replacementText: newValue) ?? true

                if !shouldChangeText {
                    // 不应该改变文字，所以连 super 都不调用，直接结束方法
                    return
                }

                // 应该改变文字，则调用 super 来改变文字，然后主动调用 textViewDidChange:
                super.text = newValue

                delegate?.textViewDidChange?(self)

                NotificationCenter.default.post(name: UITextView.textDidChangeNotification, object: self)
            } else {
                super.text = newValue

                // 如果不需要主动接管事件，则只要触发内部的监听即可，不用调用 delegate 系列方法
                handleTextChanged(self)
            }
        }
    }

    /// 重写 attributedText 的 setter 方法
    override var attributedText: NSAttributedString! {
        get {
            return super.attributedText
        }
        set {
            let textBeforeChange = self.attributedText.string
            let textDifferent = isCurrentTextDifferentOfText(newValue.string)

            // 如果前后文字没变化，则什么都不做
            if !textDifferent {
                super.attributedText = newValue
                return
            }

            // 前后文字发生变化，则要根据是否主动接管 delegate 来决定是否要询问 delegate
            if shouldResponseToProgrammaticallyTextChanges {
                let shouldChangeText = delegate?.textView?(self, shouldChangeTextIn: NSMakeRange(0, textBeforeChange.length), replacementText: newValue.string) ?? true

                if !shouldChangeText {
                    // 不应该改变文字，所以连 super 都不调用，直接结束方法
                    return
                }

                // 应该改变文字，则调用 super 来改变文字，然后主动调用 textViewDidChange:
                super.attributedText = newValue

                delegate?.textViewDidChange?(self)

                NotificationCenter.default.post(name: UITextView.textDidChangeNotification, object: self)
            } else {
                super.attributedText = newValue

                // 如果不需要主动接管事件，则只要触发内部的监听即可，不用调用 delegate 系列方法
                handleTextChanged(self)
            }
        }
    }

    /// 重写 typingAttributes 的 setter 方法
    override var typingAttributes: [NSAttributedString.Key: Any] {
        get {
            return convertFromNSAttributedStringKeyDictionary(super.typingAttributes)
        }
        set {
            super.typingAttributes = convertToNSAttributedStringKeyDictionary(newValue)
            updatePlaceholderStyle()
        }
    }

    override var textColor: UIColor? {
        get {
            return super.textColor
        }
        set {
            super.textColor = newValue
            updatePlaceholderStyle()
        }
    }

    override var textAlignment: NSTextAlignment {
        get {
            return super.textAlignment
        }
        set {
            super.textAlignment = newValue
            updatePlaceholderStyle()
        }
    }

    override var delegate: UITextViewDelegate? {
        get {
            return super.delegate
        }
        set {
            if newValue as? NSObject != self {
                originalDelegate = newValue as? QMUITextViewDelegate
            } else {
                originalDelegate = nil
            }
            if newValue != nil {
                super.delegate = self
            } else {
                super.delegate = nil
            }
        }
    }

    private weak var originalDelegate: QMUITextViewDelegate?

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        didInitialized()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        didInitialized()
    }

    private func didInitialized() {
        delegate = self
        scrollsToTop = false
        placeholderColor = UIColorPlaceholder
        placeholderMargins = .zero
        autoResizable = false
        maximumTextLength = UInt.max
        shouldResponseToProgrammaticallyTextChanges = true
        
        if #available(iOS 11.0, *) {
            contentInsetAdjustmentBehavior = .never
        }

        let placeholderLabel = UILabel()
        placeholderLabel.font = UIFontMake(kSystemTextViewDefaultFontPointSize)
        placeholderLabel.textColor = placeholderColor
        placeholderLabel.numberOfLines = 0
        placeholderLabel.alpha = 0
        self.placeholderLabel = placeholderLabel
        addSubview(placeholderLabel)

        NotificationCenter.default.addObserver(self, selector: #selector(handleTextChanged(_:)), name: UITextView.textDidChangeNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        delegate = nil
        originalDelegate = nil
    }

    override var description: String {
        return "\(super.description); text.length: \(text.length) | \(lengthWithString(text)); markedTextRange: \(String(describing: markedTextRange))"
    }

    private func isCurrentTextDifferentOfText(_ text: String?) -> Bool {
        let textBeforeChange = self.text // UITextView 如果文字为空，self.text 永远返回 "" 而不是 nil（即便你设置为 nil 后立即 get 出来也是）
        if textBeforeChange!.isEqual(text) || (textBeforeChange!.length == 0 && text != nil) {
            return false
        }
        return true
    }

    @objc private func handleTextChanged(_ sender: AnyObject) {
        // 输入字符的时候，placeholder隐藏
        if placeholder?.length ?? 0 > 0 {
            updatePlaceholderLabelHidden()
        }

        var textView: QMUITextView?

        if sender is Notification {
            let object = (sender as! Notification).object
            if object is QMUITextView {
                textView = object as? QMUITextView
            }
        } else if sender is QMUITextView {
            textView = sender as? QMUITextView
        }

        if textView != nil {
            // 计算高度
            if autoResizable {
                let resultHeight = textView!.sizeThatFits(CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)).height

                if debug {
                    print("handleTextDidChange, text = \(textView!.text ?? ""), resultHeight = \(resultHeight)")
                }

                // 通知delegate去更新textView的高度
                textView?.originalDelegate?.textView?(self, newHeightAfterTextChanged: resultHeight)
            }

            // textView 尚未被展示到界面上时，此时过早进行光标调整会计算错误
            if textView?.window == nil {
                return
            }

            shouldRejectSystemScroll = true

            // 用 dispatch 延迟一下，因为在文字发生换行时，系统自己会做一些滚动，我们要延迟一点才能避免被系统的滚动覆盖
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0, execute: {
                self.shouldRejectSystemScroll = false
                self.qmui_scrollCaretVisibleAnimated(false)
            })
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if !(placeholder?.isEmpty ?? true) && placeholderLabel != nil {
            let labelMargins = textContainerInset.concat(insets: placeholderMargins).concat(insets: kSystemTextViewFixTextInsets)
            let limitWidth = bounds.width - contentInset.horizontalValue - labelMargins.horizontalValue
            let limitHeight = bounds.height - contentInset.verticalValue - labelMargins.verticalValue
            var labelSize = placeholderLabel!.sizeThatFits(CGSize(width: limitWidth, height: limitHeight))
            labelSize.height = fmin(limitHeight, labelSize.height)
            placeholderLabel!.frame = CGRectFlat(labelMargins.left, labelMargins.top, limitWidth, labelSize.height)
        }
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        updatePlaceholderLabelHidden()
    }

    private func updatePlaceholderLabelHidden() {
        if text?.isEmpty ?? true && !(placeholder?.isEmpty ?? true) {
            placeholderLabel?.alpha = 1
        } else {
            placeholderLabel?.alpha = 0
        }
    }

    private func lengthWithString(_ string: String) -> UInt {
        return UInt(shouldCountingNonASCIICharacterAsTwo ? string.qmui_lengthWhenCountingNonASCIICharacterAsTwo : string.length)
    }

    private func updatePlaceholderStyle() {
        let placeholder = self.placeholder
        self.placeholder = placeholder // 触发文字样式的更新
    }

    // MARK: - UIResponderStandardEditActions

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        let superReturnValue = super.canPerformAction(action, withSender: sender)
        if action == #selector(paste(_:)) && canPerformPasteActionBlock != nil {
            return canPerformPasteActionBlock!(sender, superReturnValue)
        }
        return superReturnValue
    }

    override func paste(_ sender: Any?) {
        var shouldCallSuper = true
        if let pasteBlock = self.pasteBlock {
            shouldCallSuper = pasteBlock(sender)
        }
        if shouldCallSuper {
            super.paste(sender)
        }
    }

    // MARK: - QMUITextViewDelegate

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if debug {
            print("textView.text(\(textView.text.length) | \(textView.text.qmui_lengthWhenCountingNonASCIICharacterAsTwo) = \(textView.text ?? "")\nmarkedTextRange = \(String(describing: textView.markedTextRange))\nrange = \(NSStringFromRange(range))\ntext = \(text)")
        }

        if text == "\n" {
            let shouldReturn = originalDelegate?.textViewShouldReturn?(self) ?? false
            if shouldReturn {
                return false
            }
        }

        if let textView = textView as? QMUITextView {
            if textView.maximumTextLength < Int.max {
                // 如果是中文输入法正在输入拼音的过程中（markedTextRange 不为 nil），是不应该限制字数的（例如输入“huang”这5个字符，其实只是为了输入“黄”这一个字符），所以在 shouldChange 这里不会限制，而是放在 didChange 那里限制。
                let isDeleting = range.length > 0 && text.length <= 0
                if isDeleting || (textView.markedTextRange != nil) {
                     return textView.originalDelegate?.textView?(textView, shouldChangeTextIn: range, replacementText: text) ?? true
                }

                let valueIfTrue = textView.text.substring(with: range).qmui_lengthWhenCountingNonASCIICharacterAsTwo
                let rangeLength = UInt(shouldCountingNonASCIICharacterAsTwo ? valueIfTrue : range.length)
                let textWillOutofMaximumTextLength = lengthWithString(textView.text) - rangeLength + lengthWithString(text) > textView.maximumTextLength
                if textWillOutofMaximumTextLength {
                    // 当输入的文本达到最大长度限制后，此时继续点击 return 按钮（相当于尝试插入“\n”），就会认为总文字长度已经超过最大长度限制，所以此次 return 按钮的点击被拦截，外界无法感知到有这个 return 事件发生，所以这里为这种情况做了特殊保护
                    if lengthWithString(textView.text) - rangeLength == textView.maximumTextLength && text.isEqual("\n") {
                        // 不管外面 return YES 或 NO，都不允许输入了，否则会超出 maximumTextLength。
                        _ = textView.originalDelegate?.textView?(textView, shouldChangeTextIn: range, replacementText: text)
                        return false
                    }

                    // 将要插入的文字裁剪成多长，就可以让它插入了
                    let substringLength = textView.maximumTextLength - lengthWithString(textView.text) + rangeLength
                    if substringLength > 0 && lengthWithString(text) > substringLength {
                        let nsRange = NSMakeRange(0, Int(substringLength))
                        let swiftRange = Range(nsRange, in: text)
                        let allowedText = text.qmui_substringAvoidBreakingUpCharacterSequencesWithRange(range: swiftRange!, lessValue: true, countingNonASCIICharacterAsTwo: shouldCountingNonASCIICharacterAsTwo)
                        if lengthWithString(allowedText) <= substringLength {
                            textView.text = (textView.text as NSString).replacingCharacters(in: range, with: allowedText) as String
                            let location = range.location + Int(substringLength)
                            textView.selectedRange = NSMakeRange(location, 0)

                            if !textView.shouldResponseToProgrammaticallyTextChanges {
                                textView.originalDelegate?.textViewDidChange!(textView)
                            }
                        }
                    }
                    originalDelegate?.textView?(textView, didPreventTextChangeInRange: range, replacementText: text)
                    return false
                }
            }

            return textView.originalDelegate?.textView?(textView, shouldChangeTextIn: range, replacementText: text) ?? true
        }

        return true
    }

    func textViewDidChange(_ textView: UITextView) {
        // 1、iOS 10 以下的版本，从中文输入法的候选词里选词输入，是不会走到 textView:shouldChangeTextInRange:replacementText: 的，所以要在这里截断文字
        // 2、如果是中文输入法正在输入拼音的过程中（markedTextRange 不为 nil），是不应该限制字数的（例如输入“huang”这5个字符，其实只是为了输入“黄”这一个字符），所以在 shouldChange 那边不会限制，而是放在 didChange 这里限制。
        if let textView = textView as? QMUITextView {
            if textView.markedTextRange == nil && lengthWithString(textView.text) > textView.maximumTextLength {

                let nsRange = NSMakeRange(0, Int(textView.maximumTextLength))
                let swiftRange = Range(nsRange, in: textView.text)
                textView.text = textView.text.qmui_substringAvoidBreakingUpCharacterSequencesWithRange(range: swiftRange!, lessValue: true, countingNonASCIICharacterAsTwo: shouldCountingNonASCIICharacterAsTwo)

                // 如果是在这里被截断，是无法得知截断前光标所处的位置及要输入的文本的，所以只能将当前的 selectedRange 传过去，而 replacementText 为 nil
                originalDelegate?.textView?(textView, didPreventTextChangeInRange: textView.selectedRange, replacementText: nil)

                if textView.shouldResponseToProgrammaticallyTextChanges {
                    return
                }
            }
        }

        originalDelegate?.textViewDidChange?(textView)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        originalDelegate?.scrollViewDidScroll?(scrollView)
    }

    override func setContentOffset(_ contentOffset: CGPoint, animated: Bool) {
        if !shouldRejectSystemScroll! {
            super.setContentOffset(contentOffset, animated: animated)
            if debug {
                print("\(NSStringFromSelector(#function)), contentOffset.y = \(String(format: "%.2f", contentOffset.y))")
            }
        } else {
            if debug {
                print("被屏蔽的 \(NSStringFromSelector(#function)), contentOffset.y = \(String(format: "%.2f", contentOffset.y))")
            }
        }
    }

    override var contentOffset: CGPoint {
        get {
            return super.contentOffset
        }
        set {
            if shouldRejectSystemScroll != nil && !shouldRejectSystemScroll! {
                super.contentOffset = contentOffset
                if debug {
                    print("\(NSStringFromSelector(#function)), contentOffset.y = \(String(format: "%.2f", contentOffset.y))")
                }
            } else {
                if debug {
                    print("被屏蔽的 \(NSStringFromSelector(#function)), contentOffset.y = \(String(format: "%.2f", contentOffset.y))")
                }
            }
        }
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        originalDelegate?.scrollViewDidZoom?(scrollView)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKeyDictionary(_ input: [NSAttributedString.Key: Any]) -> [NSAttributedString.Key: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSAttributedStringKeyDictionary(_ input: [NSAttributedString.Key: Any]) -> [NSAttributedString.Key: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (key, value)})
}
