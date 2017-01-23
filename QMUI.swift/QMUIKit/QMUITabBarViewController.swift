//
//  QMUITabBarViewController.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/1/17.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

class QMUITabBarViewController: UITabBarController {
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        didInitialized()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        didInitialized()
    }

    func didInitialized() {
        // UIView.tintColor 并不支持 UIAppearance 协议，所以不能通过 appearance 来设置，只能在实例里设置
        tabBar.tintColor = TabBarTintColor
    }

    // MARK: - 屏幕旋转
    override var shouldAutorotate: Bool {
        guard let selectedViewController = selectedViewController else { return false }
        return selectedViewController.responds(to: #selector(getter: self.shouldAutorotate)) ? selectedViewController.shouldAutorotate : false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        guard let selectedViewController = selectedViewController else { return .portrait }
        return selectedViewController.responds(to: #selector(getter: self.supportedInterfaceOrientations)) ? selectedViewController.supportedInterfaceOrientations : .portrait
    }
}
