//
//  QMUIToastAnimator.swift
//  QMUI.swift
//
//  Created by 黄伯驹 on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

/**
 * `QMUIToastAnimatorDelegate`是所有`QMUIToastAnimator`或者其子类必须遵循的协议，是整个动画过程实现的地方。
 */
protocol QMUIToastAnimatorDelegate {
    func show(with completion: ((Bool) -> Void)?)

    func hide(with completion: ((Bool) -> Void)?)

    var isShowing: Bool { get }

    var isAnimating: Bool { get }
}

// TODO: 实现多种animation类型

enum QMUIToastAnimationType: Int {
    case fade = 0
    case zoom
    case slide
}

/**
 * `QMUIToastAnimator`可以让你通过实现一些协议来自定义ToastView显示和隐藏的动画。你可以继承`QMUIToastAnimator`，然后实现`QMUIToastAnimatorDelegate`中的方法，即可实现自定义的动画。QMUIToastAnimator默认也提供了几种type的动画：1、QMUIToastAnimationTypeFade；2、QMUIToastAnimationTypeZoom；3、QMUIToastAnimationTypeSlide；
 */
class QMUIToastAnimator: NSObject {

    internal var _isShowing = false
    internal var _isAnimating = false

    /**
     * 初始化方法，请务必使用这个方法来初始化。
     *
     * @param toastView 要使用这个animator的QMUIToastView实例。
     */

    init(toastView: QMUIToastView) {
        super.init()
        self.toastView = toastView
    }

    /**
     * 获取初始化传进来的QMUIToastView。
     */
    private(set) var toastView: QMUIToastView?

    /**
     * 指定QMUIToastAnimator做动画的类型type。此功能暂时未实现，目前所有动画类型都是QMUIToastAnimationTypeFade。
     */
    private var animationType: QMUIToastAnimationType = .fade
}

extension QMUIToastAnimator: QMUIToastAnimatorDelegate {
    @objc func show(with completion: ((Bool) -> Void)?) {
        _isShowing = true
        _isAnimating = true

        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveOut, .beginFromCurrentState], animations: {
            self.toastView?.backgroundView?.alpha = 1.0
            self.toastView?.contentView?.alpha = 1.0
        }, completion: { finished in
            self._isAnimating = false
            completion?(finished)
        })
    }

    @objc func hide(with completion: ((Bool) -> Void)?) {
        _isShowing = false
        _isAnimating = true
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveOut, .beginFromCurrentState], animations: {
            self.toastView?.backgroundView?.alpha = 0.0
            self.toastView?.contentView?.alpha = 0.0
        }, completion: { finished in
            self._isAnimating = false
            completion?(finished)
        })
    }

    var isShowing: Bool {
        return _isShowing
    }

    var isAnimating: Bool {
        return _isAnimating
    }
}
