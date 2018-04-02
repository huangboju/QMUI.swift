//
//  UIButton+QMUI.swift
//  QMUI.swift
//
//  Created by xnxin on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

import Foundation
import UIKit

extension UIButton: SelfAware3 {
    
    private static let _onceToken = UUID().uuidString

    static func awake3() {
        DispatchQueue.once(token: _onceToken) {
            let type = UIButton.self
            
            ReplaceMethod(type, #selector(UIButton.setTitle(_:for:)), #selector(UIButton.qmui_setTitle(_:for:)))
            ReplaceMethod(type, #selector(UIButton.setTitleColor(_:for:)), #selector(UIButton.qmui_setTitleColor(_:for:)))
        }
    }
 }

extension UIButton {

    /**
     * 在UIButton的样式（如字体）设置完后，将button的text设置为一个测试字符，再调用sizeToFit，从而令button的高度适应字体
     * @warning 会调用<i>setText:forState:</i>，因此请确保在设置完按钮的样式之后、设置text之前调用
     */
    func qmui_calculateHeightAfterSetAppearance() {
        setTitle("测", for: .normal)
        sizeToFit()
        setTitle(nil, for: .normal)
    }

    // MARK: - Title Attributes

    /**
     * 通过这个方法设置了 attributes 之后，setTitle:forState: 会自动把文字转成 attributedString 再添加上去，无需每次都自己构造 attributedString
     * @note 即使先调用 setTitle:forState: 然后再调用这个方法，之前的 title 仍然会被应用上这些 attributes
     * @note 该方法和 setTitleColor:forState: 均可设置字体颜色，如果二者冲突，则代码顺序较后的方法定义的颜色会最终生效
     * @note 如果包含了 NSKernAttributeName ，则此方法会自动帮你去掉最后一个字的 kern 效果，否则容易导致文字整体在视觉上不居中
     */
    func qmui_setTitleAttributes(_ attributes: [NSAttributedStringKey: Any], for state: UIControlState) {
        var attributes = attributes
        if attributes.isEmpty {
            qmui_titleAttributes.removeValue(forKey: state.rawValue)
            setAttributedTitle(nil, for: state)
            return
        }

        // 如果传入的 attributes 没有包含文字颜色，则使用用户之前通过 setTitleColor:forState: 方法设置的颜色
        if attributes[.foregroundColor] == nil {
            attributes[.foregroundColor] = titleColor(for: state)
        }
        qmui_titleAttributes[state.rawValue] = attributes

        // 确保调用此方法设置 attributes 之前已经通过 setTitle:forState: 设置的文字也能应用上新的 attributes
        let originalText = title(for: state)
        setTitle(originalText, for: state)

        // 一个系统的不好的特性（bug?）：如果你给 UIControlStateHighlighted（或者 normal 之外的任何 state）设置了包含 NSFont/NSKern/NSUnderlineAttributeName 之类的 attributedString ，但又仅用 setTitle:forState: 给 UIControlStateNormal 设置了普通的 string ，则按钮从 highlighted 切换回 normal 状态时，font 之类的属性依然会停留在 highlighted 时的状态
        // 为了解决这个问题，我们要确保一旦有 normal 之外的 state 通过设置 qmui_titleAttributes 属性而导致使用了 attributedString，则 normal 也必须使用 attributedString
        if qmui_titleAttributes.count > 0 && qmui_titleAttributes[UIControlState.normal.rawValue] == nil {
            qmui_setTitleAttributes([:], for: .normal)
        }
    }

    @objc func qmui_setTitle(_ title: String, for state: UIControlState) {
        qmui_setTitle(title, for: state) // 方法替换之后相当于调用系统的setTitle方法

        if title.length <= 0 || qmui_titleAttributes.count == 0 {
            return
        }

        if state == .normal {
            for attribute in qmui_titleAttributes {
                let keyState = UIControlState(rawValue: attribute.key)
                let titleForState = self.title(for: keyState) ?? ""
                let attributeString = NSAttributedString(string: titleForState, attributes: attribute.value)
                setAttributedTitle(attributedStringWithEndKernRemoved(attributeString), for: keyState)
            }
            return
        }

        if let attribute = qmui_titleAttributes[state.rawValue] {
            let string = NSAttributedString(string: title, attributes: attribute)
            setAttributedTitle(attributedStringWithEndKernRemoved(string), for: state)
            return
        }
    }

    // 如果之前已经设置了此 state 下的文字颜色，则覆盖掉之前的颜色
    @objc private func qmui_setTitleColor(_ color: UIColor, for state: UIControlState) {
        qmui_setTitleColor(color, for: state)

        if let attribute = self.qmui_titleAttributes[state.rawValue] {
            var newAttribute = attribute
            newAttribute[NSAttributedStringKey.foregroundColor] = color
            qmui_setTitleAttributes(newAttribute, for: state)
        }
    }

    // 去除最后一个字的 kern 效果
    private func attributedStringWithEndKernRemoved(_ string: NSAttributedString) -> NSAttributedString {
        if string.length <= 0 {
            return string
        }

        let mutableString = NSMutableAttributedString(attributedString: string)
        mutableString.removeAttribute(NSAttributedStringKey.kern, range: NSMakeRange(string.length - 1, 1))
        return NSAttributedString(attributedString: mutableString)
    }

    private struct AssociatedKeys {
        static var kTitleAttributes = "kTitleAttributes"
    }

    private var qmui_titleAttributes: [UInt: [NSAttributedStringKey: Any]] {
        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys.kTitleAttributes) as? [UInt: [NSAttributedStringKey: Any]]) ?? [:]
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.kTitleAttributes, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
