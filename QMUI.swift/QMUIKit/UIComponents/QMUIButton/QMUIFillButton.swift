//
//  QMUIFillButton.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/5/3.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

enum QMUIFillButtonColor {
    case blue
    case red
    case green
    case gray
    case white
}

/**
 *  用于 `QMUIFillButton.cornerRadius` 属性，当 `cornerRadius` 为 `QMUIFillButtonCornerRadiusAdjustsBounds` 时，`QMUIFillButton` 会在高度变化时自动调整 `cornerRadius`，使其始终保持为高度的 1/2。
 */
fileprivate let QMUIFillButtonCornerRadiusAdjustsBounds: CGFloat = -1

/**
 *  QMUIFillButton
 *  实心填充颜色的按钮，支持预定义的几个色值
 */

class QMUIFillButton: QMUIButton {
    @IBInspectable var fillColor: UIColor = .blue { // 默认为 FillButtonColorBlue
        didSet {
            backgroundColor = fillColor
        }
    }
    
    @IBInspectable var titleTextColor: UIColor = UIColorWhite { // 默认为 UIColorWhite
        didSet {
            setTitleColor(titleTextColor, for: .normal)
            if adjustsImageWithTitleTextColor {
                updateImageColor()
            }
        }
    }
    
    @IBInspectable @objc dynamic var cornerRadius: CGFloat = QMUIFillButtonCornerRadiusAdjustsBounds / 2 { // 默认为 QMUIFillButtonCornerRadiusAdjustsBounds，也即固定保持按钮高度的一半。
        didSet {
            setNeedsLayout()
        }
    }
    
    /**
     *  控制按钮里面的图片是否也要跟随 `titleTextColor` 一起变化，默认为 `NO`
     */
    @objc dynamic var adjustsImageWithTitleTextColor: Bool = false {
        didSet {
            if adjustsImageWithTitleTextColor {
                updateImageColor()
            }
        }
    }
    
    convenience init() {
        self.init(fillType: .blue)
    }
    
    convenience override init(frame: CGRect) {
        self.init(fillType: .blue, frame: frame)
    }
    
    convenience init(fillType: QMUIFillButtonColor) {
        self.init(fillType: fillType, frame: .zero)
    }
    
    convenience init(fillType: QMUIFillButtonColor, frame: CGRect) {
        var color = FillButtonColorBlue
        let textColor = UIColorWhite
        switch fillType {
        case .blue:
            color = FillButtonColorBlue
        case .red:
            color = FillButtonColorRed
        case .green:
            color = FillButtonColorGreen
        case .gray:
            color = FillButtonColorGray
        case .white:
            color = FillButtonColorWhite
        }
        
        self.init(fillColor: color, titleTextColor: textColor, frame: frame)
    }
    
    convenience init(fillColor: UIColor, titleTextColor: UIColor) {
        self.init(fillColor: fillColor, titleTextColor: titleTextColor, frame: .zero)
    }
    
    init(fillColor: UIColor, titleTextColor: UIColor, frame: CGRect) {
        super.init(frame: frame)
        didInitialized(fillColor, titleTextColor: titleTextColor)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.fillColor = FillButtonColorBlue
        self.titleTextColor = UIColorWhite
    }
    
    private static let _onceToken = UUID().uuidString
    
    private func didInitialized(_ fillColor: UIColor, titleTextColor: UIColor) {
        self.fillColor = fillColor
        self.titleTextColor = titleTextColor
        
        DispatchQueue.once(token: QMUIFillButton._onceToken) {
            QMUIFillButton.setDefaultAppearance()
        }
    }
    
    override func setImage(_ image: UIImage?, for state: UIControl.State) {
        var image = image
        if adjustsImageWithTitleTextColor {
            image = image?.withRenderingMode(.alwaysTemplate)
        }
        super.setImage(image, for: state)
    }
    
    private func updateImageColor() {
        self.imageView?.tintColor = adjustsImageWithTitleTextColor ? self.titleTextColor : nil
        if self.currentImage != nil {
            let states: [UIControl.State] = [.normal, .highlighted, .disabled]
            for state in states {
                if let image = self.image(for: state) {
                    if self.adjustsImageWithTitleTextColor {
                        // 这里的image不用做renderingMode的处理，而是放到重写的setImage:forState里去做
                        self.setImage(image, for: state)
                    } else {
                        // 如果不需要用template的模式渲染，并且之前是使用template的，则把renderingMode改回Original
                        self.setImage(image.withRenderingMode(.alwaysOriginal), for: state)
                    }
                }
            }
        }
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        if self.cornerRadius != QMUIGhostButtonCornerRadiusAdjustsBounds {
            self.layer.cornerRadius = self.cornerRadius
        } else {
            self.layer.cornerRadius = flat(self.bounds.height / 2)
        }
    }
}

extension QMUIFillButton {
    
    static func setDefaultAppearance() {
        let appearance = QMUIFillButton.appearance()
        appearance.cornerRadius = QMUIFillButtonCornerRadiusAdjustsBounds
        appearance.adjustsImageWithTitleTextColor = false
    }
}
