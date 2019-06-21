//
//  UIButton+QMUI.swift
//  QMUI.swift
//
//  Created by xnxin on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

import Foundation
import UIKit

enum QMUICustomizeButtonPropType: UInt {
    case title = 0
    case titleColor = 1
    case titleShadowColor = 2
    case image = 3
    case backgroundImage = 4
    case attributedTitle = 5
}

extension UIButton: SelfAware3 {
    
    private static let _onceToken = UUID().uuidString

    static func awake3() {
        DispatchQueue.once(token: _onceToken) {
            let clazz = UIButton.self
            
            ReplaceMethod(clazz, #selector(UIButton.setTitle(_:for:)), #selector(UIButton.qmui_setTitle(_:for:)))
            ReplaceMethod(clazz, #selector(UIButton.setTitleColor(_:for:)), #selector(UIButton.qmui_setTitleColor(_:for:)))
            ReplaceMethod(clazz, #selector(UIButton.setTitleShadowColor(_:for:)), #selector(UIButton.qmui_setTitleShadowColor(_:for:)))
            ReplaceMethod(clazz, #selector(UIButton.setImage(_:for:)), #selector(UIButton.qmui_setImage(_:for:)))
            ReplaceMethod(clazz, #selector(UIButton.setBackgroundImage(_:for:)), #selector(UIButton.qmui_setBackgroundImage(_:for:)))
            ReplaceMethod(clazz, #selector(UIButton.setAttributedTitle(_:for:)), #selector(UIButton.qmui_setAttributedTitle(_:for:)))
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
    func qmui_setTitleAttributes(_ attributes: [NSAttributedString.Key: Any], for state: UIControl.State) {
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
        if qmui_titleAttributes.count > 0 && qmui_titleAttributes[UIControl.State.normal.rawValue] == nil {
            qmui_setTitleAttributes([:], for: .normal)
        }
    }

    @objc func qmui_setTitle(_ title: String, for state: UIControl.State) {
        qmui_setTitle(title, for: state)
        
        _markQMUICustomize(type: .title, for: state, value: title)

        if title.length <= 0 || qmui_titleAttributes.count == 0 {
            return
        }

        if state == .normal {
            for attribute in qmui_titleAttributes {
                let keyState = UIControl.State(rawValue: attribute.key)
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
    @objc private func qmui_setTitleColor(_ color: UIColor, for state: UIControl.State) {
        qmui_setTitleColor(color, for: state)
        
        _markQMUICustomize(type: .titleColor, for: state, value: color)

        if let attribute = self.qmui_titleAttributes[state.rawValue] {
            var newAttribute = attribute
            newAttribute[NSAttributedString.Key.foregroundColor] = color
            qmui_setTitleAttributes(newAttribute, for: state)
        }
    }
    
    @objc private func qmui_setTitleShadowColor(_ color: UIColor, for state: UIControl.State) {
        qmui_setTitleShadowColor(color, for: state)
        
        _markQMUICustomize(type: .titleShadowColor, for: state, value: color)
    }
    
    @objc private func qmui_setImage(_ image: UIImage?, for state: UIControl.State) {
        qmui_setImage(image, for: state)
        
        _markQMUICustomize(type: .image, for: state, value: image)
    }
    
    @objc private func qmui_setBackgroundImage(_ image: UIImage?, for state: UIControl.State) {
        qmui_setBackgroundImage(image, for: state)
        
        _markQMUICustomize(type: .backgroundImage, for: state, value: image)
    }
    
    @objc private func qmui_setAttributedTitle(_ title: NSAttributedString?, for state: UIControl.State) {
        qmui_setAttributedTitle(title, for: state)
        
        _markQMUICustomize(type: .attributedTitle, for: state, value: title)
    }

    // 去除最后一个字的 kern 效果
    private func attributedStringWithEndKernRemoved(_ string: NSAttributedString) -> NSAttributedString {
        if string.length <= 0 {
            return string
        }

        let mutableString = NSMutableAttributedString(attributedString: string)
        mutableString.removeAttribute(NSAttributedString.Key.kern, range: NSMakeRange(string.length - 1, 1))
        return NSAttributedString(attributedString: mutableString)
    }

    private struct AssociatedKeys {
        static var titleAttributes = "titleAttributes"
        static var qmuiCustomizeButtonPropDict = "qmuiCustomizeButtonPropDict"
    }

    private var qmui_titleAttributes: [UInt: [NSAttributedString.Key: Any]] {
        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys.titleAttributes) as? [UInt: [NSAttributedString.Key: Any]]) ?? [:]
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.titleAttributes, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var qmui_customizeButtonPropDict: [UInt: [UInt: Bool]]? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.qmuiCustomizeButtonPropDict) as? [UInt: [UInt: Bool]]
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.qmuiCustomizeButtonPropDict, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private func _markQMUICustomize(type: QMUICustomizeButtonPropType, for state: UIControl.State, value: Any?) {
        if let _ = value {
            _setQMUICustomize(type: type, for: state)
        } else {
            _removeQMUICustomize(type: type, for: state)
        }
    }
    
    private func _setQMUICustomize(type: QMUICustomizeButtonPropType, for state: UIControl.State) {
        if qmui_customizeButtonPropDict == nil {
            qmui_customizeButtonPropDict = [:]
        }
        
        if qmui_customizeButtonPropDict![state.rawValue] == nil {
            qmui_customizeButtonPropDict![state.rawValue] = [:]
        }
        
        qmui_customizeButtonPropDict![state.rawValue]![type.rawValue] = true
    }
    
    private func _removeQMUICustomize(type: QMUICustomizeButtonPropType, for state: UIControl.State) {
        if qmui_customizeButtonPropDict == nil || qmui_customizeButtonPropDict![state.rawValue] == nil {
            return
        }
        var dict = qmui_customizeButtonPropDict![state.rawValue]!
        dict[type.rawValue] = nil
    }
    
    
    /**
     * 判断该 button 在特定 UIControlState 下是否设置了属性
     * @note 该方法会对设置了任何 QMUICustomizeButtonPropType 都返回 YES
     */
    func qmui_hasCustomizedButtonProp(for state: UIControl.State) -> Bool {
        guard let qmui_customizeButtonPropDict = self.qmui_customizeButtonPropDict else {
            return false
        }
        let result = qmui_customizeButtonPropDict[state.rawValue]?.count ?? 0 > 0
        return result
    }
    
    /**
     * 判断该 button 在特定 UIControlState 下是否设置了某个 QMUICustomizeButtonPropType 属性
     * @param type 对应于 UIbutton 的 setXXX:forState 办法
     */
    func qmui_hasCustomizedButtonProp(with type: QMUICustomizeButtonPropType, for state: UIControl.State) -> Bool {
        guard let qmui_customizeButtonPropDict = self.qmui_customizeButtonPropDict, let dict = qmui_customizeButtonPropDict[state.rawValue] else {
            return false
        }
        let result = dict[type.rawValue]
        return result ?? false
    }
}
