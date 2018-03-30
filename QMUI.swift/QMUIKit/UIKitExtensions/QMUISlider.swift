//
//  QMUISlider.swift
//  QMUI.swift
//
//  Created by xnxin on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

import UIKit

/**
 *  相比系统的 UISlider，支持：
 *  1. 修改背后导轨的高度
 *  2. 修改圆点的大小
 *  3. 修改圆点的阴影样式
 */
class QMUISlider: UISlider {

    /// 背后导轨的高度，默认为 0，表示使用系统默认的高度。
    @IBInspectable public var trackHeight: CGFloat = 0

    /// 中间圆球的大小，默认为 .zero
    /// @warning 注意若设置了 thumbSize 但没设置 thumbColor，则圆点的颜色会使用 self.tintColor 的颜色（但系统 UISlider 默认的圆点颜色是白色带阴影）
    @IBInspectable public var thumbSize: CGSize = .zero {
        didSet {
            updateThumbImage()
        }
    }

    /// 中间圆球的颜色，默认为 nil。
    /// @warning 注意请勿使用系统的 thumbTintColor，因为 thumbTintColor 和 thumbImage 是互斥的，设置一个会导致另一个被清空，从而导致样式错误。
    @IBInspectable public var thumbColor: UIColor? {
        didSet {
            updateThumbImage()
        }
    }

    /// 中间圆球的阴影颜色，默认为 nil
    @IBInspectable public var thumbShadowColor: UIColor? {
        didSet {
            if let thumbView = thumbViewIfExist() {
                thumbView.layer.shadowColor = thumbShadowColor?.cgColor
                thumbView.layer.shadowOpacity = (thumbShadowColor != nil) ? 1 : 0
            }
        }
    }

    /// 中间圆球的阴影偏移值，默认为 .zero
    @IBInspectable public var thumbShadowOffset: CGSize = .zero {
        didSet {
            if let thumbView = thumbViewIfExist() {
                thumbView.layer.shadowOffset = thumbShadowOffset
            }
        }
    }

    /// 中间圆球的阴影扩散度，默认为 0
    @IBInspectable public var thumbShadowRadius: CGFloat = 0 {
        didSet {
            if let thumbView = thumbViewIfExist() {
                thumbView.layer.shadowRadius = thumbShadowRadius
            }
        }
    }

    private func updateThumbImage() {
        if thumbSize.isEmpty { return }
        if let thumbColor = self.thumbColor ?? tintColor {
            let thumbImage = UIImage.qmui_image(shape: .oval, size: thumbSize, tintColor: thumbColor)
            setThumbImage(thumbImage, for: .normal)
            setThumbImage(thumbImage, for: .highlighted)
        }
    }

    private func thumbViewIfExist() -> UIView? {
        // thumbView 并非在一开始就存在，而是在某个时机才生成的，所以可能返回 nil
        if let thumbView = value(forKey: "thumbView") {
            return thumbView as? UIView
        } else {
            return nil
        }
    }

    // MARK: Override

    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var result = super.trackRect(forBounds: bounds)
        if trackHeight == 0 {
            return result
        }

        result = result.setHeight(trackHeight)
        result = result.setY(bounds.height.center(result.height))
        return result
    }

    override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        guard subview == thumbViewIfExist() else {
            return
        }
        let thumbView = subview
        thumbView.layer.shadowColor = thumbShadowColor?.cgColor
        thumbView.layer.shadowOpacity = (thumbShadowColor != nil) ? 1 : 0
        thumbView.layer.shadowOffset = thumbShadowOffset
        thumbView.layer.shadowRadius = thumbShadowRadius
    }
}
