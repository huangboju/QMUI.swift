//
//  UILabel+QMUI.swift
//  QMUI.swift
//
//  Created by xnxin on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

extension UILabel: SelfAware2 {
    private static let _onceToken = UUID().uuidString

    static func awake2() {
        DispatchQueue.once(token: _onceToken) {
            ReplaceMethod(self, #selector(setter: text), #selector(qmui_setText))
            ReplaceMethod(self, #selector(setter: attributedText), #selector(qmui_setAttributedText))
        }
    }

    @objc private func qmui_setText(_ text: String) {
        if qmui_textAttributes.isEmpty || text.isEmpty {
            qmui_setText(text)
            return
        }

        let attributedString = NSAttributedString(string: text, attributes: qmui_textAttributes)
        qmui_setAttributedText(attributedString)
    }

    // 在 qmui_textAttributes 样式基础上添加用户传入的 attributedString 中包含的新样式。换句话说，如果这个方法里有样式冲突，则以 attributedText 为准
    @objc private func qmui_setAttributedText(_ attributedText: NSAttributedString) {
        if qmui_textAttributes.isEmpty || text?.isEmpty ?? false {
            qmui_setAttributedText(attributedText)
            return
        }

        var attributedString = NSMutableAttributedString(string: attributedText.string, attributes: qmui_textAttributes)
        attributedString = attributedStringWithEndKernRemoved(attributedString).mutableCopy() as? NSMutableAttributedString ?? NSMutableAttributedString()

        attributedText.enumerateAttributes(in: NSMakeRange(0, attributedText.length), options: NSAttributedString.EnumerationOptions(rawValue: 0)) { attrs, range, _ in
            attributedString.addAttributes(attrs, range: range)
        }

        qmui_setAttributedText(attributedString)
    }

    // 去除最后一个字的 kern 效果，使得文字整体在视觉上居中
    private func attributedStringWithEndKernRemoved(_ string: NSAttributedString) -> NSAttributedString {
        if string.string.isEmpty {
            return string
        }

        if let mutableString = string.mutableCopy() as? NSMutableAttributedString {
            mutableString.removeAttribute(NSAttributedStringKey.kern, range: NSMakeRange(string.length - 1, 1))
            return NSAttributedString(attributedString: mutableString)
        }

        return string
    }
}

extension UILabel {
    private struct AssociatedKeys {
        static var kAssociatedObjectKey_textAttributes = "kAssociatedObjectKey_textAttributes"
    }

    public convenience init(with font: UIFont, textColor: UIColor) {
        self.init()
        self.font = font
        self.textColor = textColor
    }

    /**
     * @brief 在需要特殊样式时，可通过此属性直接给整个 label 添加 NSAttributeName 系列样式，然后 setText 即可，无需使用繁琐的 attributedText
     *
     * @note 即使先调用 setText/attributedText ，然后再设置此属性，此属性仍然会生效
     * @note 如果此属性包含了 NSKernAttributeName ，则最后一个字的 kern 效果会自动被移除，否则容易导致文字在视觉上不居中
     *
     * 现在你有三种方法控制 label 的样式：
     * 1. 本身的样式属性（如 textColor, font 等）
     * 2. qmui_textAttributes
     * 3. 构造 NSAttributedString
     * 这三种方式可以同时使用，如果样式发生冲突（比如先通过方法1将文字设成红色，又通过方法2将文字设成蓝色），则绝大部分情况下代码执行顺序靠后的会最终生效
     * 唯一例外的极端情况是：先用方法2将文字设成红色，再用方法1将文字设成蓝色，最后再 setText，这时虽然代码执行顺序靠后的是方法1，但最终生效的会是方法2，为了避免这种极端情况的困扰，建议不要同时使用方法1和方法2去设置同一种样式。
     *
     */
    public var qmui_textAttributes: [NSAttributedStringKey: Any] {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.kAssociatedObjectKey_textAttributes) as? [NSAttributedStringKey: Any] ?? [:]
        }
        set {
            let prevTextAttributes: NSDictionary = qmui_textAttributes as NSDictionary

            if prevTextAttributes.isEqual(to: newValue) {
                return
            }

            objc_setAssociatedObject(self, &AssociatedKeys.kAssociatedObjectKey_textAttributes, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)

            if text?.isEmpty ?? true {
                return
            }

            let string = attributedText?.mutableCopy() as? NSMutableAttributedString ?? NSMutableAttributedString()
            let fullRange = NSMakeRange(0, string.length)

            // 1）清除掉旧的通过 qmui_textAttributes 设置的样式
            if prevTextAttributes.count > 0 {
                // 找出现在 attributedText 中哪些 attrs 是通过上次的 qmui_textAttributes 设置的
                var willRemovedAttributes = [NSAttributedStringKey]()
                string.enumerateAttributes(in: NSMakeRange(0, string.length), options: NSAttributedString.EnumerationOptions(rawValue: 0)) { attrs, range, _ in
                    let attrsDic: NSDictionary = attrs as NSDictionary
                    // 如果存在 kern 属性，则只有 range 是第一个字至倒数第二个字，才有可能是通过 qmui_textAttribtus 设置的
                    if let currentKern = attrsDic[NSAttributedStringKey.kern] as? NSNumber,
                        let prevKern = prevTextAttributes[NSAttributedStringKey.kern] as? NSNumber,
                        currentKern.isEqual(to: prevKern),
                        NSEqualRanges(range, NSMakeRange(0, string.length - 1)) {
                        string.removeAttribute(NSAttributedStringKey.kern, range: NSMakeRange(0, string.length - 1))
                    }

                    // 上面排除掉 kern 属性后，如果 range 不是整个字符串，那肯定不是通过 qmui_textAttributes 设置的
                    if !NSEqualRanges(range, fullRange) {
                        return
                    }
                    for key in attrs.keys {
                        if let currentValue = attrs[key] as? NSNumber, let prevValue = prevTextAttributes[key] as? NSNumber, currentValue.isEqual(to: prevValue) {
                            willRemovedAttributes.append(key)
                        }
                    }
                }
                for key in willRemovedAttributes {
                    string.removeAttribute(key, range: fullRange)
                }
            }

            // 2）添加新样式
            if !qmui_textAttributes.isEmpty {
                string.addAttributes(qmui_textAttributes, range: fullRange)
            }
            // 不能调用 setAttributedText: ，否则若遇到样式冲突，那个方法会让用户传进来的 NSAttributedString 样式覆盖 qmui_textAttributes 的样式
            qmui_setAttributedText(attributedStringWithEndKernRemoved(string))
        }
    }

    /**
     * 将目标UILabel的样式属性设置到当前UILabel上
     *
     * 将会复制的样式属性包括：font、textColor、backgroundColor
     * @param label 要从哪个目标UILabel上复制样式
     */
    public func qmui_setTheSameAppearance(as label: UILabel) {
        font = label.font
        textColor = label.textColor
        backgroundColor = label.backgroundColor
        lineBreakMode = label.lineBreakMode
        textAlignment = label.textAlignment
        if let selfQmuiLabel = self as? QMUILabel,
            let otherQmuiLabel = label as? QMUILabel {
            selfQmuiLabel.contentEdgeInsets = otherQmuiLabel.contentEdgeInsets
        }
    }

    /**
     * 在UILabel的样式（如字体）设置完后，将label的text设置为一个测试字符，再调用sizeToFit，从而令label的高度适应字体
     * @warning 会setText:，因此确保在配置完样式后、设置text之前调用
     */
    public func qmui_calculateHeightAfterSetAppearance() {
        text = "测"
        sizeToFit()
        text = nil
    }

    /**
     * UILabel在显示中文字符时，会比显示纯英文字符额外多了一个sublayers，并且这个layer超出了label.bounds的范围，这会导致label必定需要做像素合成，所以通过一些方式来避免合成操作
     * @see http://stackoverflow.com/questions/34895641/uilabel-is-marked-as-red-when-color-blended-layers-is-selected
     */
    public func qmui_avoidBlendedLayersIfShowingChinese(with backgroundColor: UIColor) {
        isOpaque = true // 本来默认就是YES，这里还是明确写一下，表意清晰
        self.backgroundColor = backgroundColor
        if IOS_VERSION >= 8.0 {
            clipsToBounds = true // 只clip不适用cornerRadius就不会触发offscreen render
        }
    }
}
