//
//  AppDelegate.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/1/17.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // QD自定义的全局样式渲染
        QDCommonUI.renderGlobalAppearances()
        
        // 预加载 QQ 表情，避免第一次使用时卡顿
        DispatchQueue.global().async {
            QDUIHelper.qmuiEmotions()
        }
        
        // 界面
        window = UIWindow(frame: UIScreen.main.bounds)
        createTabBarController()
        
        // 启动动画
        startLaunchingAnimation()
        
        return true
    }
    
    private func createTabBarController() {
        let tabBarViewController = QDTabBarViewController()
        
        // QMUIKit
        let uikitViewController = QDUIKitViewController()
        uikitViewController.hidesBottomBarWhenPushed = false
        let uikitNavController = QDNavigationController(rootViewController: uikitViewController)
        var image = UIImageMake("icon_tabbar_uikit")?.withRenderingMode(.alwaysOriginal)
        var selectedImage = UIImageMake("icon_tabbar_uikit_selected")
        uikitNavController.tabBarItem = QDUIHelper.tabBarItem(title: "QMUIKit", image: image, selectedImage: selectedImage, tag: 0)
        
        // UIComponents
        let componentViewController = QDComponentsViewController()
        componentViewController.hidesBottomBarWhenPushed = false
        let componentNavController = QDNavigationController(rootViewController: componentViewController)
        image = UIImageMake("icon_tabbar_component")?.withRenderingMode(.alwaysOriginal)
        selectedImage = UIImageMake("icon_tabbar_component_selected")
        componentNavController.tabBarItem = QDUIHelper.tabBarItem(title: "Components", image: image, selectedImage: selectedImage, tag: 0)
        
        // UIComponents
        let labViewController = QDLabViewController()
        labViewController.hidesBottomBarWhenPushed = false
        let labNavController = QDNavigationController(rootViewController: labViewController)
        image = UIImageMake("icon_tabbar_lab")?.withRenderingMode(.alwaysOriginal)
        selectedImage = UIImageMake("icon_tabbar_lab_selected")
        labNavController.tabBarItem = QDUIHelper.tabBarItem(title: "Lab", image: image, selectedImage: selectedImage, tag: 0)
        
        
        // window root controller
        tabBarViewController.viewControllers = [uikitNavController, componentNavController, labNavController]
        window?.rootViewController = tabBarViewController
        window?.makeKeyAndVisible()
    }
    
    private func startLaunchingAnimation() {
        guard
            let delegate = UIApplication.shared.delegate,
            let window = delegate.window!,
            let launchScreenView = Bundle.main.loadNibNamed("LaunchScreen", owner: self, options: nil)?.first as? UIView
            else {
            return
        }
        launchScreenView.frame = window.bounds
        window.addSubview(launchScreenView)
        
        let backgroundImageView = launchScreenView.subviews[0]
        backgroundImageView.clipsToBounds = true
        
        let logoImageView = launchScreenView.subviews[1]
        let copyrightLabel = launchScreenView.subviews.last
        
        let maskView = UIView(frame: launchScreenView.bounds)
        maskView.backgroundColor = UIColorWhite
        launchScreenView.insertSubview(maskView, belowSubview: backgroundImageView)
        
        launchScreenView.layoutIfNeeded()
        
        launchScreenView.constraints.forEach {
            if $0.identifier == "bottomAlign" {
                $0.isActive = false
                NSLayoutConstraint.init(item: backgroundImageView, attribute: .bottom, relatedBy: .equal, toItem: launchScreenView, attribute: .top, multiplier: 1, constant: NavigationContentTop).isActive = true
                return
            }
        }
        
        UIView.animate(withDuration: 0.15, delay: 0.9, options: .curveOut, animations: {
            launchScreenView.layoutIfNeeded()
            logoImageView.alpha = 0
            copyrightLabel?.alpha = 0
        }, completion: nil)
        
        UIView.animate(withDuration: 1.2, delay: 0.9, options: .curveEaseOut, animations: {
            maskView.alpha = 0
            backgroundImageView.alpha = 0
        }) { (finished) in
            launchScreenView.removeFromSuperview()
        }
    }
    
    func applicationWillResignActive(_: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}
