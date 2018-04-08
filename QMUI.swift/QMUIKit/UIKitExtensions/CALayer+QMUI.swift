//
//  CALayer+QMUI.swift
//  QMUI.swift
//
//  Created by xnxin on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

extension CALayer {
    /**
     *  把某个sublayer移动到当前所有sublayers的最后面
     *  @param  sublayer    要被移动的layer
     *  @warning 要被移动的sublayer必须已经添加到当前layer上
     */
    func qmui_sendSublayerToBack(_ sublayer: CALayer) {
        if sublayer.superlayer == self {
            sublayer.removeFromSuperlayer()
            insertSublayer(sublayer, at: 0)
        }
    }

    /**
     *  把某个sublayer移动到当前所有sublayers的最前面
     *  @param  sublayer    要被移动的layer
     *  @warning 要被移动的sublayer必须已经添加到当前layer上
     */
    func qmui_bringSublayerToFront(_ sublayer: CALayer) {
        if sublayer.superlayer == self {
            sublayer.removeFromSuperlayer()
            insertSublayer(sublayer, at: UInt32(sublayers?.count ?? 0))
        }
    }

    /**
     * 移除 CALayer（包括 CAShapeLayer 和 CAGradientLayer）所有支持动画的属性的默认动画，方便需要一个不带动画的 layer 时使用。
     */
    func qmui_removeDefaultAnimations() {
        var actions: [String: CAAction] = [
            NSStringFromSelector(#selector(getter: bounds)): NSNull(),
            NSStringFromSelector(#selector(getter: position)): NSNull(),
            NSStringFromSelector(#selector(getter: zPosition)): NSNull(),
            NSStringFromSelector(#selector(getter: anchorPoint)): NSNull(),
            NSStringFromSelector(#selector(getter: anchorPointZ)): NSNull(),
            NSStringFromSelector(#selector(getter: transform)): NSNull(),
            NSStringFromSelector(#selector(getter: isHidden)): NSNull(),
            NSStringFromSelector(#selector(getter: isDoubleSided)): NSNull(),
            NSStringFromSelector(#selector(getter: sublayerTransform)): NSNull(),
            NSStringFromSelector(#selector(getter: masksToBounds)): NSNull(),
            NSStringFromSelector(#selector(getter: contents)): NSNull(),
            NSStringFromSelector(#selector(getter: contentsRect)): NSNull(),
            NSStringFromSelector(#selector(getter: contentsScale)): NSNull(),
            NSStringFromSelector(#selector(getter: contentsCenter)): NSNull(),
            NSStringFromSelector(#selector(getter: minificationFilterBias)): NSNull(),
            NSStringFromSelector(#selector(getter: backgroundColor)): NSNull(),
            NSStringFromSelector(#selector(getter: cornerRadius)): NSNull(),
            NSStringFromSelector(#selector(getter: borderWidth)): NSNull(),
            NSStringFromSelector(#selector(getter: borderColor)): NSNull(),
            NSStringFromSelector(#selector(getter: opacity)): NSNull(),
            NSStringFromSelector(#selector(getter: compositingFilter)): NSNull(),
            NSStringFromSelector(#selector(getter: filters)): NSNull(),
            NSStringFromSelector(#selector(getter: backgroundFilters)): NSNull(),
            NSStringFromSelector(#selector(getter: shouldRasterize)): NSNull(),
            NSStringFromSelector(#selector(getter: rasterizationScale)): NSNull(),
            NSStringFromSelector(#selector(getter: shadowColor)): NSNull(),
            NSStringFromSelector(#selector(getter: shadowOpacity)): NSNull(),
            NSStringFromSelector(#selector(getter: shadowOffset)): NSNull(),
            NSStringFromSelector(#selector(getter: shadowRadius)): NSNull(),
            NSStringFromSelector(#selector(getter: shadowPath)): NSNull(),
        ]

        if isKind(of: CAShapeLayer.self) {
            actions[NSStringFromSelector(#selector(getter: CAShapeLayer.path))] = NSNull()
            actions[NSStringFromSelector(#selector(getter: CAShapeLayer.fillColor))] = NSNull()
            actions[NSStringFromSelector(#selector(getter: CAShapeLayer.strokeColor))] = NSNull()
            actions[NSStringFromSelector(#selector(getter: CAShapeLayer.strokeStart))] = NSNull()
            actions[NSStringFromSelector(#selector(getter: CAShapeLayer.strokeEnd))] = NSNull()
            actions[NSStringFromSelector(#selector(getter: CAShapeLayer.lineWidth))] = NSNull()
            actions[NSStringFromSelector(#selector(getter: CAShapeLayer.miterLimit))] = NSNull()
            actions[NSStringFromSelector(#selector(getter: CAShapeLayer.lineDashPhase))] = NSNull()
        }

        if isKind(of: CAGradientLayer.self) {
            actions[NSStringFromSelector(#selector(getter: CAGradientLayer.colors))] = NSNull()
            actions[NSStringFromSelector(#selector(getter: CAGradientLayer.locations))] = NSNull()
            actions[NSStringFromSelector(#selector(getter: CAGradientLayer.startPoint))] = NSNull()
            actions[NSStringFromSelector(#selector(getter: CAGradientLayer.endPoint))] = NSNull()
        }

        self.actions = actions
    }

    /**
     * 产生一个适用于做通用分隔线的 layer，高度为 PixelOne，默认会移除动画，并且背景色用 UIColorSeparator
     */
    static func qmui_separatorLayer() -> CALayer {
        let layer = CALayer()
        layer.qmui_removeDefaultAnimations()
        layer.backgroundColor = UIColorSeparator.cgColor
        layer.frame = CGRect(x: 0, y: 0, width: 0, height: PixelOne)
        return layer
    }

    /**
     * 产生一个适用于做列表分隔线的 layer，高度为 PixelOne，默认会移除动画，并且背景色用 TableViewSeparatorColor
     */
    static func qmui_separatorLayerForTableView() -> CALayer {
        let layer = qmui_separatorLayer()
        layer.backgroundColor = TableViewSeparatorColor.cgColor
        return layer
    }
}
