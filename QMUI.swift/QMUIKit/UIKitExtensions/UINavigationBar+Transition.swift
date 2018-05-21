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
    
    private static let _onceToken = UUID().uuidString
    
    static func awake2() {
        DispatchQueue.once(token: _onceToken) {
            let clazz = UINavigationBar.self
            
            // MARK: TODO 使用 UINavigationBar.appearance() 时，交换会发生崩溃
            ReplaceMethod(clazz, #selector(setter: shadowImage), #selector(UINavigationBar.qmui_setShadowImage(_:)))
            ReplaceMethod(clazz, #selector(setter: barTintColor), #selector(UINavigationBar.qmui_setBarTintColor(_:)))
            ReplaceMethod(clazz, #selector(UINavigationBar.setBackgroundImage(_:for:)), #selector(UINavigationBar.qmui_setBackgroundImage(_:for:)))
            
            ReplaceMethod(clazz, #selector(UINavigationBar.layoutSubviews), #selector(UINavigationBar.titleView_navigationBarLayoutSubviews))
        }
    }
    
    @objc func qmui_setShadowImage(_ image: UIImage?) {
        qmui_setShadowImage(image)
        transitionNavigationBar?.shadowImage = image
    }
    
    @objc func qmui_setBarTintColor(_ tintColor: UIColor?) {
        qmui_setBarTintColor(tintColor)
        transitionNavigationBar?.barTintColor = tintColor
    }
    
    @objc func qmui_setBackgroundImage(_ backgroundImage: UIImage?, for barMetrics: UIBarMetrics) {
        qmui_setBackgroundImage(backgroundImage, for: barMetrics)
        transitionNavigationBar?.setBackgroundImage(backgroundImage, for: barMetrics)
    }

    /// 用来模仿真的navBar，配合 UINavigationController+NavigationBarTransition 在转场过程中存在的一条假navBar
    var transitionNavigationBar: UINavigationBar? {
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
