//
//  UIImageView+QMUI.swift
//  QMUI.swift
//
//  Created by xnxin on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    /**
     *  把 UIImageView 的宽高调整为能保持 image 宽高比例不变的同时又不超过给定的 `limitSize` 大小的最大frame
     *
     *  建议在设置完x/y之后调用
     */
    public func qmui_sizeToFitKeepingImageAspectRatio(in limitSize: CGSize) {
        guard let notNilImage = self.image else {
            return
        }

        var currentSize = self.frame.size
        if currentSize.width <= 0 {
            currentSize.width = notNilImage.size.width
        }
        if currentSize.height <= 0 {
            currentSize.height = notNilImage.size.height
        }

        let horizontalRatio = limitSize.width / currentSize.width
        let verticalRatio = limitSize.height / currentSize.height
        let ratio = min(horizontalRatio, verticalRatio)
        var frame = self.frame
        frame.size.width = flat(currentSize.width * ratio)
        frame.size.height = flat(currentSize.height * ratio)
        self.frame = frame
    }
}
