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
     * 生成虚线的方法，注意返回的是 CAShapeLayer
     * @param lineLength   每一段的线宽
     * @param lineSpacing  线之间的间隔
     * @param lineWidth    线的宽度
     * @param lineColor    线的颜色
     * @param isHorizontal 是否横向，因为画虚线的缘故，需要指定横向或纵向，横向是 YES，纵向是 NO。
     * 注意：暂不支持 dashPhase 和 dashPattens 数组设置，因为这些都定制性太强，如果用到则自己调用系统方法即可。
     */
    static func qmui_seperatorDashLayer(_ lineLength: Int, lineSpacing: Int, lineWidth: CGFloat, lineColor: CGColor, isHorizontal: Bool) -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.fillColor = UIColorClear.cgColor
        layer.strokeColor = lineColor
        layer.lineWidth = lineWidth
        layer.lineDashPattern = [NSNumber(integerLiteral: lineLength), NSNumber(value: lineSpacing)]
        layer.masksToBounds = true
        
        let path = CGMutablePath()
        if isHorizontal {
            path.move(to: CGPoint(x: 0, y: lineWidth / 2))
            path.addLine(to: CGPoint(x: SCREEN_WIDTH, y: lineWidth / 2))
        } else {
            path.move(to: CGPoint(x: lineWidth / 2, y: 0))
            path.addLine(to: CGPoint(x: lineWidth / 2, y: SCREEN_HEIGHT))
        }
        layer.path = path
        return layer
    }
    
    /**
     
     * 产生一个通用分隔虚线的 layer，高度为 PixelOne，线宽为 2，线距为 2，默认会移除动画，并且背景色用 UIColorSeparator，注意返回的是 CAShapeLayer。
     
     * 其中，InHorizon 是横向；InVertical 是纵向。
     
     */
    static func qmui_seperatorDashLayerInHorizontal() -> CAShapeLayer {
        let layer = CAShapeLayer.qmui_seperatorDashLayer(2, lineSpacing: 2, lineWidth: PixelOne, lineColor: UIColorSeparatorDashed.cgColor, isHorizontal: true)
        return layer
    }
    
    static func qmui_seperatorDashLayerInVertical() -> CAShapeLayer {
        let layer = CAShapeLayer.qmui_seperatorDashLayer(2, lineSpacing: 2, lineWidth: PixelOne, lineColor: UIColorSeparatorDashed.cgColor, isHorizontal: false)
        return layer
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
