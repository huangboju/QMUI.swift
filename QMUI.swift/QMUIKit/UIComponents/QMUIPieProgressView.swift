//
//  QMUIPieProgressView.swift
//  QMUI.swift
//
//  Created by 黄伯驹 on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

class QMUIPieProgressView: UIControl {
    /**
     当前进度值，默认为 0.0。调用 `setProgress:` 相当于调用 `setProgress:animated:NO`
     */
    @IBInspectable
    public var progress: CGFloat = 0

    func setProgress(_ progress: CGFloat, animated: Bool) {

    }
}
