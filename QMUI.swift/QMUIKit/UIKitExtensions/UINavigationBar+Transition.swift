//
//  UINavigationBar+Transition.swift
//  QMUI.swift
//
//  Created by xnxin on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

extension UINavigationBar: SelfAware2 {
    private struct Keys {
        static var transitionNavigationBarKey = "transitionNavigationBarKey"
    }

    /// 用来模仿真的navBar，配合 UINavigationController+NavigationBarTransition 在转场过程中存在的一条假navBar
    public var transitionNavigationBar: UINavigationBar? {
        set {
            guard let bar = newValue else {
                return
            }
            objc_setAssociatedObject(self, &Keys.transitionNavigationBarKey, bar, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &Keys.transitionNavigationBarKey) as? UINavigationBar
        }
    }
    
    private static let _onceToken = UUID().uuidString
    
    static func awake2() {
        DispatchQueue.once(token: _onceToken) {
            let type = UINavigationBar.self
            
            ReplaceMethod(type, #selector(setter: shadowImage), #selector(NavigationBarTransition_setShadowImage))
            ReplaceMethod(type, #selector(setter: barTintColor), #selector(NavigationBarTransition_setBarTintColor))
            ReplaceMethod(type, #selector(setBackgroundImage(_:for:)), #selector(NavigationBarTransition_setBackgroundImage(_:for:)))
            
            ReplaceMethod(type, #selector(layoutSubviews), #selector(titleView_navigationBarLayoutSubviews))
        }
    }

    @objc func NavigationBarTransition_setShadowImage(_ image: UIImage) {
        NavigationBarTransition_setShadowImage(image)
        transitionNavigationBar?.shadowImage = image
    }

    @objc func NavigationBarTransition_setBarTintColor(_ tintColor: UIColor) {
        NavigationBarTransition_setBarTintColor(tintColor)
        transitionNavigationBar?.barTintColor = tintColor
    }

    @objc func NavigationBarTransition_setBackgroundImage(_ backgroundImage: UIImage, for barMetrics: UIBarMetrics) {
        NavigationBarTransition_setBackgroundImage(backgroundImage, for: barMetrics)
        transitionNavigationBar?.setBackgroundImage(backgroundImage, for: barMetrics)
    }
}

extension UINavigationBar {
    
    @objc func titleView_navigationBarLayoutSubviews() {
        var titleView = topItem?.titleView as? QMUINavigationTitleView
        
        if let titleView = titleView {
            let titleViewMaximumWidth = titleView.bounds.width // 初始状态下titleView会被设置为UINavigationBar允许的最大宽度
            
            var titleViewSize = titleView.sizeThatFits(CGSize(width: titleViewMaximumWidth, height: CGFloat.greatestFiniteMagnitude))
            titleViewSize.height = ceil(titleViewSize.height) // titleView的高度如果非pt整数，会导致计算出来的y值时多时少，所以干脆做一下pt取整，这个策略不要改，改了要重新测试push过程中titleView是否会跳动
            
            // 当在UINavigationBar里使用自定义的titleView时，就算titleView的sizeThatFits:返回正确的高度，navigationBar也不会帮你设置高度（但会帮你设置宽度），所以我们需要自己更新高度并且修正y值
            if titleView.bounds.height != titleViewSize.height {
                //            NSLog(@"【%@】修正布局前\ntitleView = %@", NSStringFromClass(titleView.class), titleView)
                let titleViewMinY = flat(titleView.frame.minY - ((titleViewSize.height - titleView.bounds.height) / 2.0)) // 系统对titleView的y值布局是flat，注意，不能改，改了要测试
                titleView.frame = CGRect(x: titleView.frame.minX, y: titleViewMinY, width: CGFloat(fminf(Float(titleViewMaximumWidth), Float(titleViewSize.width))), height: titleViewSize.height)
                //            NSLog(@"【%@】修正布局后\ntitleView = %@", NSStringFromClass(titleView.class), titleView)
            }
            
            // iOS 11 之后（iOS 11 Beta 5 测试过） titleView 的布局发生了一些变化，如果不主动设置宽度，titleView 里的内容就可能无法完整展示
            if #available(iOS 11.0, *) {
                if titleView.bounds.width != titleViewSize.width {
                    titleView.frame = titleView.frame.setWidth(titleViewSize.width)
                }
            }
        } else {
            titleView = nil
        }
        
        titleView_navigationBarLayoutSubviews()
        
        if titleView != nil {
            //        NSLog(@"【%@】系统布局后\ntitleView = %@", NSStringFromClass(titleView.class), titleView)
        }
    }
}
