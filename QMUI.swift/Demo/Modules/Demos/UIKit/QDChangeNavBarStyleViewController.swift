//
//  QDChangeNavBarStyleViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/4/23.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

enum QDNavigationBarStyle {
    case origin
    case light
    case dark
}

class QDChangeNavBarStyleViewController: QDCommonListViewController {

    var previousBarStyle: QDNavigationBarStyle = .origin
    
    var customNavBarTransition: Bool = false
    
    private var barStyle: QDNavigationBarStyle
    
    private var viewController: QDChangeNavBarStyleViewController?
    
    convenience init() {
        self.init(barStyle: .origin)
    }
    
    init(barStyle: QDNavigationBarStyle) {
        self.barStyle = barStyle
        super.init(style: .plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func initDataSource() {
        super.initDataSource()
        dataSource = ["默认navBar样式",
                      "暗色navBar样式",
                      "浅色navBar样式"]
    }
    
    override func didSelectCell(_ title: String) {
        super.didSelectCell(title)
        if title == "默认navBar样式" {
            viewController = QDChangeNavBarStyleViewController(barStyle: .origin)
        }
        if title == "暗色navBar样式" {
            viewController = QDChangeNavBarStyleViewController(barStyle: .dark)
        }
        if title == "浅色navBar样式" {
            viewController = QDChangeNavBarStyleViewController(barStyle: .light)
        }
        
        if let viewController = viewController {
            
            if customNavBarTransition {
                viewController.previousBarStyle = barStyle
                viewController.customNavBarTransition = true
            }
            
            viewController.title = title
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    // MARK: QMUINavigationControllerDelegate
    override var shouldSetStatusBarStyleLight: Bool {
        if barStyle == .origin || barStyle == .dark {
            return true
        } else {
            return false
        }
    }
    
    var navigationBarBackgroundImage: UIImage? {
        if barStyle == .origin {
            return NavBarBackgroundImage
        } else if barStyle == .light {
            return nil // nil则用系统默认颜色（带磨砂）
        } else if barStyle == .dark {
            return UIImage.qmui_image(color: UIColorMake(66, 66, 66))
        } else {
            return NavBarBackgroundImage
        }
    }
    
    var navigationBarShadowImage: UIImage? {
        if barStyle == .origin {
            return NavBarShadowImage
        } else if barStyle == .light {
            return nil // nil则用系统默认颜色
        } else if barStyle == .dark {
            return UIImage.qmui_image(color: UIColorMake(99, 99, 99), size: CGSize(width: 10, height: PixelOne), cornerRadius:0)
        } else {
            return NavBarShadowImage
        }
    }
    
    var navigationBarTintColor: UIColor? {
        if barStyle == .origin {
            return NavBarTintColor
        } else if barStyle == .light {
            return UIColorBlue
        } else if barStyle == .dark {
            return NavBarTintColor
        } else {
            return NavBarTintColor
        }
    }
    
    var titleViewTintColor: UIColor? {
        if barStyle == .origin {
            return QMUINavigationTitleView.appearance().tintColor
        } else if barStyle == .light {
            return UIColorBlack
        } else if barStyle == .dark {
            return QMUINavigationTitleView.appearance().tintColor
        } else {
            return QMUINavigationTitleView.appearance().tintColor
        }
    }
    
    // MARK: NavigationBarTransition
    var shouldCustomNavigationBarTransitionWhenPushDisappearing: Bool {
        return customNavBarTransition && barStyle != viewController?.barStyle
    }
    
    var shouldCustomNavigationBarTransitionWhenPopDisappearing: Bool {
        return customNavBarTransition && barStyle != previousBarStyle
    }
    
}
