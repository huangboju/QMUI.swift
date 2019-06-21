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
            let clazz = UILabel.self
            
            ReplaceMethod(clazz, #selector(setter: text), #selector(qmui_setText))
            ReplaceMethod(clazz, #selector(setter: attributedText), #selector(qmui_setAttributedText))
        }
    }

    @objc func qmui_setText(_ text: String?) {
        if text == nil {
            qmui_setText(text)
            return
        }
        
        if qmui_textAttributes.count <= 0 && qmui_lineHeight <= 0 {
            qmui_setText(text)
            return
        }

        let attributedString = NSAttributedString(string: text!, attributes: qmui_textAttributes)
        qmui_setAttributedText(attributedStringWithKernAndLineHeightAdjusted(attributedString))
    }

    // 在 qmui_textAttributes 样式基础上添加用户传入的 attributedString 中包含的新样式。换句话说，如果这个方法里有样式冲突，则以 attributedText 为准
    @objc func qmui_setAttributedText(_ attributedText: NSAttributedString) {
        if qmui_textAttributes.isEmpty || text?.isEmpty ?? false {
            qmui_setAttributedText(attributedText)
            return
        }

        var attributedString = NSMutableAttributedString(string: attributedText.string, attributes: qmui_textAttributes)
        attributedString = attributedStringWithKernAndLineHeightAdjusted(attributedString).mutableCopy() as? NSMutableAttributedString ?? NSMutableAttributedString()

        attributedText.enumerateAttributes(in: NSMakeRange(0, attributedText.length), options: NSAttributedString.EnumerationOptions(rawValue: 0)) { attrs, range, _ in
            attributedString.addAttributes(attrs, range: range)
        }

        qmui_setAttributedText(attributedString)
    }

    // 去除最后一个字的 kern 效果，使得文字整体在视觉上居中
    private func attributedStringWithKernAndLineHeightAdjusted(_ string: NSAttributedString) -> NSAttributedString {
        if string.string.isEmpty {
            return string
        }

        // 去除最后一个字的 kern 效果，使得文字整体在视觉上居中
        // 只有当 qmui_textAttributes 中设置了 kern 时这里才应该做调整
        if let attributedString = string.mutableCopy() as? NSMutableAttributedString {
            attributedString.removeAttribute(NSAttributedString.Key.kern, range: NSMakeRange(string.length - 1, 1))
            
            // 判断是否应该应用上通过 qmui_setLineHeight: 设置的行高
            var shouldAdjustLineHeight = true
            if qmui_lineHeight <= 0 {
                shouldAdjustLineHeight = false
            }
            
            attributedString.enumerateAttribute(NSAttributedString.Key.paragraphStyle, in: NSMakeRange(0, attributedString.length), options: []) { (style, range, stop) in
                // 如果用户已经通过传入 NSParagraphStyle 对文字整个 range 设置了行高，则这里不应该再次调整行高
                if range == NSMakeRange(0, attributedString.length) {
                    if let style = style as? NSParagraphStyle, (style.maximumLineHeight != 0 || style.minimumLineHeight != 0) {
                        shouldAdjustLineHeight = false
                    }
                }
            }
            
            if shouldAdjustLineHeight {
                let paraStyle = NSMutableParagraphStyle(lineHeight: qmui_lineHeight, lineBreakMode: lineBreakMode, textAlignment: textAlignment)
                attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paraStyle, range: NSMakeRange(0, attributedString.length))
            }
            
            return NSAttributedString(attributedString: attributedString)
        }

        return string
    }
}

extension UILabel {
    private struct AssociatedKeys {
        static var kAssociatedObjectKey_textAttributes = "kAssociatedObjectKey_textAttributes"
        static var kAssociatedObjectKey_lineHeight = "kAssociatedObjectKey_lineHeight"
    }

    convenience init(with font: UIFont, textColor: UIColor) {
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
     * @note 当你设置了此属性后，每次你调用 setText: 时，其实都会被自动转而调用 setAttributedText:
     *
     * 现在你有三种方法控制 label 的样式：
     * 1. 本身的样式属性（如 textColor, font 等）
     * 2. qmui_textAttributes
     * 3. 构造 NSAttributedString
     * 这三种方式可以同时使用，如果样式发生冲突（比如先通过方法1将文字设成红色，又通过方法2将文字设成蓝色），则绝大部分情况下代码执行顺序靠后的会最终生效
     * 唯一例外的极端情况是：先用方法2将文字设成红色，再用方法1将文字设成蓝色，最后再 setText，这时虽然代码执行顺序靠后的是方法1，但最终生效的会是方法2，为了避免这种极端情况的困扰，建议不要同时使用方法1和方法2去设置同一种样式。
     *
     */
    var qmui_textAttributes: [NSAttributedString.Key: Any] {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.kAssociatedObjectKey_textAttributes) as? [NSAttributedString.Key: Any] ?? [:]
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

            // 1）当前 attributedText 包含的样式可能来源于两方面：通过 qmui_textAttributes 设置的、通过直接传入 attributedString 设置的，这里要过滤删除掉前者的样式效果，保留后者的样式效果
            if prevTextAttributes.count > 0 {
                // 找出现在 attributedText 中哪些 attrs 是通过上次的 qmui_textAttributes 设置的
                var willRemovedAttributes = [NSAttributedString.Key]()
                string.enumerateAttributes(in: NSMakeRange(0, string.length), options: NSAttributedString.EnumerationOptions(rawValue: 0)) { attrs, range, _ in
                    let attrsDic: NSDictionary = attrs as NSDictionary
                    // 如果存在 kern 属性，则只有 range 是第一个字至倒数第二个字，才有可能是通过 qmui_textAttribtus 设置的
                    if let currentKern = attrsDic[NSAttributedString.Key.kern] as? NSNumber,
                        let prevKern = prevTextAttributes[NSAttributedString.Key.kern] as? NSNumber,
                        currentKern.isEqual(to: prevKern),
                        NSEqualRanges(range, NSMakeRange(0, string.length - 1)) {
                        string.removeAttribute(NSAttributedString.Key.kern, range: NSMakeRange(0, string.length - 1))
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
            qmui_setAttributedText(attributedStringWithKernAndLineHeightAdjusted(string))
        }
    }
    
    /**
     *  设置当前整段文字的行高
     *  @note 如果同时通过 qmui_textAttributes 或 attributedText 给整段文字设置了行高，则此方法将不再生效。换句话说，此方法设置的行高将永远不会覆盖 qmui_textAttributes 或 attributedText 设置的行高。
     *  @note 比如对于字符串"abc"，你通过 attributedText 设置 {0, 1} 这个 range 范围内的行高为 10，又通过 setQmui_lineHeight: 设置了整体行高为 20，则最终 {0, 1} 内的行高将为 10，而 {1, 2} 内的行高将为全局行高 20
     *  @note 比如对于字符串"abc"，你先通过 setQmui_lineHeight: 设置整体行高为 10，又通过 attributedText/qmui_textAttributes 设置整体行高为 20，无论这两个设置的代码的先后顺序如何，最终行高都将为 20
     *
     *  @note 当你设置了此属性后，每次你调用 setText: 时，其实都会被自动转而调用 setAttributedText:
     *
     */
    var qmui_lineHeight: CGFloat {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.kAssociatedObjectKey_lineHeight) as? CGFloat ?? 0
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.kAssociatedObjectKey_lineHeight, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            // 注意：对于 UILabel，只要你设置过 text，则 attributedText 就是有值的，因此这里无需区分 setText 还是 setAttributedText
            let attributedText = self.attributedText
            self.attributedText = attributedText
        }
    }

    /**
     * 将目标UILabel的样式属性设置到当前UILabel上
     *
     * 将会复制的样式属性包括：font、textColor、backgroundColor
     * @param label 要从哪个目标UILabel上复制样式
     */
    func qmui_setTheSameAppearance(as label: UILabel) {
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
    func qmui_calculateHeightAfterSetAppearance() {
        text = "测"
        sizeToFit()
        text = nil
    }

    /**
     * UILabel在显示中文字符时，会比显示纯英文字符额外多了一个sublayers，并且这个layer超出了label.bounds的范围，这会导致label必定需要做像素合成，所以通过一些方式来避免合成操作
     * @see http://stackoverflow.com/questions/34895641/uilabel-is-marked-as-red-when-color-blended-layers-is-selected
     */
    func qmui_avoidBlendedLayersIfShowingChinese(with backgroundColor: UIColor) {
        isOpaque = true // 本来默认就是YES，这里还是明确写一下，表意清晰
        self.backgroundColor = backgroundColor
        if IOS_VERSION >= 8.0 {
            clipsToBounds = true // 只clip不适用cornerRadius就不会触发offscreen render
        }
    }
}
