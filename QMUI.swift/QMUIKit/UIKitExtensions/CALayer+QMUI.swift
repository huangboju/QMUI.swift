//
//  CALayer+QMUI.swift
//  QMUI.swift
//
//  Created by xnxin on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

extension CALayer {
    public func qmui_removeDefaultAnimations() {
        
    }
    
    /**
     *  把某个sublayer移动到当前所有sublayers的最前面
     *  @param  sublayer    要被移动的layer
     *  @warning 要被移动的sublayer必须已经添加到当前layer上
     */
    func qmui_bringSublayerToFront(_ sublayer: CALayer *) {
        if sublayer.superlayer == self {
            sublayer.removeFromSuperlayer()
            insertSublayer(sublayer, at: sublayers.count)
        }
    }
}
