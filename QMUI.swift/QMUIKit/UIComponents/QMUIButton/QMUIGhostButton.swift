//
//  QMUIGhostButton.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/5/3.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

enum QMUIGhostButtonColor {
    case blue
    case red
    case green
    case gray
    case white
}

/**
 *  用于 `QMUIGhostButton.cornerRadius` 属性，当 `cornerRadius` 为 `QMUIGhostButtonCornerRadiusAdjustsBounds` 时，`QMUIGhostButton` 会在高度变化时自动调整 `cornerRadius`，使其始终保持为高度的 1/2。
 */
let QMUIGhostButtonCornerRadiusAdjustsBounds: CGFloat = -1

/**
 *  “幽灵”按钮，也即背景透明、带圆角边框的按钮
 *
 *  可通过 `QMUIGhostButtonColor` 设置几种预设的颜色，也可以用 `ghostColor` 设置自定义颜色。
 *
 *  @warning 默认情况下，`ghostColor` 只会修改文字和边框的颜色，如果需要让 image 也跟随 `ghostColor` 的颜色，则可将 `adjustsImageWithGhostColor` 设为 `YES`
 */
class QMUIGhostButton: QMUIButton {
    @IBInspectable var ghostColor: UIColor = GhostButtonColorBlue { // 默认为 GhostButtonColorBlue
        didSet {
            setTitleColor(ghostColor, for: .normal)
            layer.borderColor = ghostColor.cgColor
            if adjustsImageWithGhostColor {
                updateImageColor()
            }
        }
    }
    
    @IBInspectable @objc dynamic var borderWidth: CGFloat = 1 { // 默认为 1pt
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable @objc dynamic var cornerRadius: CGFloat = QMUIGhostButtonCornerRadiusAdjustsBounds / 2 { // 默认为 QMUIGhostButtonCornerRadiusAdjustsBounds，也即固定保持按钮高度的一半。
        didSet {
            setNeedsLayout()
        }
    }
    
    /**
     *  控制按钮里面的图片是否也要跟随 `ghostColor` 一起变化，默认为 `NO`
     */
    @objc dynamic var adjustsImageWithGhostColor: Bool = false {
        didSet {
            updateImageColor()
        }
    }
    
    init(ghostColor: UIColor, frame: CGRect) {
        super.init(frame: frame)
        didInitialized(ghostColor)
    }
    
    private static let _onceToken = UUID().uuidString
    
    private func didInitialized(_ ghostColor:UIColor) {
        self.ghostColor = ghostColor
        
        DispatchQueue.once(token: QMUIGhostButton._onceToken) {
            QMUIGhostButton.setDefaultAppearance()
        }
    }
    
    convenience init() {
        self.init(ghostColor: GhostButtonColorBlue, frame: .zero)
    }
    
    convenience init(ghostColor: UIColor) {
        self.init(ghostColor: ghostColor, frame: .zero)
    }
    
    convenience init(ghostType: QMUIGhostButtonColor, frame: CGRect) {
        var ghostColor: UIColor = GhostButtonColorBlue
        switch ghostType {
        case .blue:
            ghostColor = GhostButtonColorBlue
        case .red:
            ghostColor = GhostButtonColorRed
        case .green:
            ghostColor = GhostButtonColorGreen
        case .gray:
            ghostColor = GhostButtonColorGray
        case .white:
            ghostColor = GhostButtonColorWhite
        }
        self.init(ghostColor: ghostColor, frame: frame)
    }
    
    convenience init(ghostType: QMUIGhostButtonColor) {
        self.init(ghostType: ghostType, frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        didInitialized(GhostButtonColorBlue)
    }
    
    private func updateImageColor() {
        imageView?.tintColor = adjustsImageWithGhostColor ? ghostColor : nil
        guard let _ = currentImage else { return }
        let states: [UIControl.State] = [.normal, .highlighted, .disabled]
        for state in states {
            if let image = image(for: state) {
                if adjustsImageWithGhostColor {
                    // 这里的image不用做renderingMode的处理，而是放到重写的setImage:forState里去做
                    setImage(image, for: state)
                } else {
                    // 如果不需要用template的模式渲染，并且之前是使用template的，则把renderingMode改回Original
                    setImage(image.withRenderingMode(.alwaysOriginal), for: state)
                }
            }
        }
    }
    
    override func setImage(_ image: UIImage?, for state: UIControl.State) {
        var newImage = image
        if adjustsImageWithGhostColor {
            newImage = image?.withRenderingMode(.alwaysTemplate)
        }
        super.setImage(newImage, for: state)
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        if cornerRadius != QMUIGhostButtonCornerRadiusAdjustsBounds {
            layer.cornerRadius = cornerRadius
        } else {
            layer.cornerRadius = flat(bounds.height / 2)
        }
    }
}

extension QMUIGhostButton {
    
    static func setDefaultAppearance() {
        let appearance = QMUIGhostButton.appearance()
        appearance.borderWidth = 1
        appearance.cornerRadius = QMUIGhostButtonCornerRadiusAdjustsBounds
        appearance.adjustsImageWithGhostColor = false
    }
}
