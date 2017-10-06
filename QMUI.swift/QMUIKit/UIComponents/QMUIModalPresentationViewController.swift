//
//  QMUIModalPresentationViewController.swift
//  QMUI.swift
//
//  Created by 黄伯驹 on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

protocol QMUIModalPresentationContentViewControllerProtocol: class {
    /**
     *  当浮层以 UIViewController 的形式展示（而非 UIView），并且使用 modalController 提供的默认布局时，则可通过这个方法告诉 modalController 当前浮层期望的大小
     *  @param  controller  当前的modalController
     *  @param  limitSize   浮层最大的宽高，由当前 modalController 的大小及 `contentViewMargins`、`maximumContentViewWidth` 决定
     *  @return 返回浮层在 `limitSize` 限定内的大小，如果业务自身不需要限制宽度/高度，则为 width/height 返回 `CGFLOAT_MAX` 即可
     */
    func preferredContentSize(in modalPresentationViewController: QMUIModalPresentationViewController, limitSize: CGSize) -> CGSize
}

class QMUIModalPresentationViewController: UIViewController {
    public var contentViewMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    public weak var contentViewController: (UIViewController & QMUIModalPresentationContentViewControllerProtocol)?

    /**
     *  控制当前是否以模态的形式存在。如果以模态的形式存在，则点击空白区域不会隐藏浮层。
     *
     *  默认为false，也即点击空白区域将会自动隐藏浮层。
     */
    public var isModal = false
    
    /**
     *  将浮层以 UIWindow 的方式显示出来
     *  @param animated    是否以动画的形式显示
     *  @param completion  显示动画结束后的回调
     */
    public func show(with animated: Bool, completion: ((Bool) -> Void)?) {
    
    }
    
    /**
     *  将浮层隐藏掉
     *  @param animated    是否以动画的形式隐藏
     *  @param completion  隐藏动画结束后的回调
     *  @warning 这里的`completion`只会在你显式调用`hideWithAnimated:completion:`方法来隐藏浮层时会被调用，如果你通过点击`dimmingView`来触发`hideWithAnimated:completion:`，则completion是不会被调用的，那种情况下如果你要在浮层隐藏后做一些事情，请使用`delegate`提供的`didHideModalPresentationViewController:`方法。
     */
    public func hide(with animated: Bool, completion: ((Bool) -> Void)?) {

    }
}

extension UIViewController {

    private struct Keys {
        static var modalPresentationViewController = "ModalPresentationViewController"
    }

    var modalPresentedViewController: QMUIModalPresentationViewController? {
        set {
            if let vc = newValue {
                objc_setAssociatedObject(self, &Keys.modalPresentationViewController, vc, .OBJC_ASSOCIATION_ASSIGN)
            }
        }
        get {
            return objc_getAssociatedObject(self, &Keys.modalPresentationViewController) as? QMUIModalPresentationViewController
        }
    }
}
