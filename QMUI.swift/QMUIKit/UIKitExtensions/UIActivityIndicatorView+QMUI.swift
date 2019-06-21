//
//  UIActivityIndicatorView+QMUI.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/4/11.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

extension UIActivityIndicatorView {
    public convenience init(activityIndicatorStyle style: UIActivityIndicatorView.Style, size: CGSize) {
        self.init(style: style)
        let initialSize = bounds.size
        let scale = size.width / initialSize.width
        transform = CGAffineTransform(scaleX: scale, y: scale)
    }
}
