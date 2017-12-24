//
//  UIBezierPath+QMUI.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/4/26.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

extension UIBezierPath {

    convenience init(roundedRect rect: CGRect, cornerRadiusArray cornerRadius: [CGFloat], lineWidth: CGFloat) {
        self.init()
        let topLeftCornerRadius = cornerRadius[0]
        let bottomLeftCornerRadius = cornerRadius[1]
        let bottomRightCornerRadius = cornerRadius[2]
        let topRightCornerRadius = cornerRadius[3]
        let lineCenter = lineWidth / 2.0

        move(to: CGPoint(x: topLeftCornerRadius, y: lineCenter))
        addArc(withCenter: CGPoint(x: topLeftCornerRadius, y: topLeftCornerRadius), radius: topLeftCornerRadius - lineCenter, startAngle: .pi * 1.5, endAngle: .pi, clockwise: false)
        addLine(to: CGPoint(x: lineCenter, y: rect.height - bottomLeftCornerRadius))
        addArc(withCenter: CGPoint(x: bottomLeftCornerRadius, y: rect.height - bottomLeftCornerRadius), radius: bottomLeftCornerRadius - lineCenter, startAngle: .pi, endAngle: .pi * 0.5, clockwise: false)
        addLine(to: CGPoint(x: rect.width - bottomRightCornerRadius, y: rect.height - lineCenter))
        addArc(withCenter: CGPoint(x: rect.width - bottomRightCornerRadius, y: rect.height - bottomRightCornerRadius), radius: bottomRightCornerRadius - lineCenter, startAngle: 0.5 * .pi, endAngle: 0, clockwise: false)
        addLine(to: CGPoint(x: rect.width - lineCenter, y: topRightCornerRadius))
        addArc(withCenter: CGPoint(x: rect.width - topRightCornerRadius, y: topRightCornerRadius), radius: topRightCornerRadius - lineCenter, startAngle: 0, endAngle: 1.5 * .pi, clockwise: false)
        close()
    }
}
