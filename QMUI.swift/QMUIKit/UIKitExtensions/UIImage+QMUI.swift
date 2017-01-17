//
//  UIImage+QMUI.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/1/17.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

enum QMUIImageShape {
    case oval // 椭圆
    case triangle              // 三角形
    case disclosureIndicator   // 列表cell右边的箭头
    case checkmark             // 列表cell右边的checkmark
    case navBack               // 返回按钮的箭头
    case navClose              // 导航栏的关闭icon
}

enum QMUIImageBorderPosition: Int {
    case all = 0
    case top
    case left
    case bottom
    case right
}

extension UIImage {
    static func qmui_image(with shape: QMUIImageShape, size: CGSize, tintColor: UIColor) -> UIImage {
        var lineWidth: CGFloat = 0
        switch shape {
        case .navBack:
            lineWidth = 2.0
        case .disclosureIndicator:
            lineWidth = 1.5
        case .checkmark:
            lineWidth = 1.5
        case .navClose:
            lineWidth = 1.2 // 取消icon默认的lineWidth
        default:
            break
        }
        return qmui_image(with: shape, size: size, lineWidth: lineWidth, tintColor: tintColor)
    }

    static func qmui_image(with shape: QMUIImageShape, size: CGSize, lineWidth: CGFloat, tintColor: UIColor) -> UIImage {
        return UIImage()
    }

    func qmui_image(with orientation: UIImageOrientation) -> UIImage {
        return UIImage()
    }

    static func qmui_image(with: UIColor, size: CGSize, cornerRadius: CGFloat) -> UIImage {
        return UIImage()
    }
}
