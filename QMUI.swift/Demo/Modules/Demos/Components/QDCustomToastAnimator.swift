//
//  QDCustomToastAnimator.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/5/4.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

class QDCustomToastAnimator: QMUIToastAnimator {
    
    @objc override func show(with completion: ((Bool) -> Void)?) {
        _isShowing = true
        _isAnimating = true
        toastView?.backgroundView?.layer.transform = CATransform3DMakeTranslation(0, -30, 0)
        toastView?.contentView?.layer.transform = CATransform3DMakeTranslation(0, -30, 0)
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveOut, animations: {
            self.toastView?.backgroundView?.alpha = 1.0
            self.toastView?.contentView?.alpha = 1.0
            self.toastView?.backgroundView?.layer.transform = CATransform3DIdentity
            self.toastView?.contentView?.layer.transform = CATransform3DIdentity
        }) { (finished) in
            self._isAnimating = false
            completion?(finished)
        }
    }
    
    @objc override func hide(with completion: ((Bool) -> Void)?) {
        _isShowing = false
        _isAnimating = true
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveOut, animations: {
            self.toastView?.backgroundView?.alpha = 0
            self.toastView?.contentView?.alpha = 0
            self.toastView?.backgroundView?.layer.transform = CATransform3DMakeTranslation(0, -30, 0)
            self.toastView?.contentView?.layer.transform = CATransform3DMakeTranslation(0, -30, 0)
        }) { (finished) in
            self._isAnimating = false
            self.toastView?.backgroundView?.layer.transform = CATransform3DIdentity
            self.toastView?.contentView?.layer.transform = CATransform3DIdentity
            completion?(finished)
        }
    }
}
