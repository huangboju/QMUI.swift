//
//  QDUIKitViewController.swift
//  QMUI.swift
//
//  Created by TonyHan on 2018/3/7.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

class QDUIKitViewController: QDCommonGridViewController {
    
    override private(set) var dataSource: QMUIOrderedDictionary<String, UIImage> {
        get {
            let dataSource = QMUIOrderedDictionary( dictionaryLiteral:
                ("QMUIButton", UIImageMake("icon_grid_button")!),
                ("QMUILabel", UIImageMake("icon_grid_label")!),
                ("QMUITextView", UIImageMake("icon_grid_textView")!),
                ("QMUITextField", UIImageMake("icon_grid_textField")!),
                ("QMUISlider", UIImageMake("icon_grid_slider")!),
                ("QMUIAlertController", UIImageMake("icon_grid_alert")!),
                ("QMUITableView", UIImageMake("icon_grid_cell")!),
                ("QMUICollectionViewLayout", UIImageMake("icon_grid_collection")!),
                ("QMUISearchController", UIImageMake("icon_grid_search")!),
                ("ViewController Orientation", UIImageMake("icon_grid_orientation")!),
                ("QMUINavigationController", UIImageMake("icon_grid_navigation")!),
                ("UITabBarItem+QMUI", UIImageMake("icon_grid_tabBarItem")!),
                ("UIColor+QMUI", UIImageMake("icon_grid_color")!),
                ("UIImage+QMUI", UIImageMake("icon_grid_image")!),
                ("UIFont+QMUI", UIImageMake("icon_grid_font")!),
                ("UIView+QMUI", UIImageMake("icon_grid_view")!),
                ("NSObject+QMUI", UIImageMake("icon_grid_nsobject")!)
            )
            
            return dataSource
        }
        set {
            
        }
    }
    
    override func setupNavigationItems() {
        super.setupNavigationItems()
        title = "QMUIKit"
        navigationItem.rightBarButtonItem = UIBarButtonItem.item(image: UIImageMake("icon_nav_about"), target: self, action: #selector(handleAboutItemEvent))
    }
    
    @objc private func handleAboutItemEvent() {
        let viewController = QDAboutViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    override func didSelectCell(_ title: String) {
        var viewController: UIViewController?
        if title == "UIColor+QMUI" {
            viewController = QDColorViewController()
        }
        if title == "UIImage+QMUI" {
            viewController = QDImageViewController()
        }
        if title == "QMUILabel" {
            viewController = QDLabelViewController()
        }
        if title == "QMUITextView" {
            viewController = QDTextViewController()
        }
        if title == "QMUITextField" {
            viewController = QDTextFieldViewController()
        }
        if title == "QMUISlider" {
            viewController = QDSliderViewController()
        }
        if title == "QMUITableView" {
            viewController = QDTableViewController()
        }
        if title == "QMUICollectionViewLayout" {
            viewController = QDCollectionListViewController()
        }
        if title == "QMUIButton" {
            viewController = QDButtonViewController()
        }
        if title == "QMUISearchController" {
            viewController = QDSearchViewController()
        }
        if title == "QMUIAlertController" {
            viewController = QDAlertController()
        }
        if title == "ViewController Orientation" {
            viewController = QDOrientationViewController()
        }
        if title == "QMUINavigationController" {
            viewController = QDNavigationListViewController()
        }
        if title == "UITabBarItem+QMUI" {
            viewController = QDTabBarItemViewController()
        }
        if title == "UIFont+QMUI" {
            viewController = QDFontViewController()
        }
        if title == "UIView+QMUI" {
            viewController = QDUIViewQMUIViewController()
        }
        if title == "NSObject+QMUI" {
            viewController = QDObjectViewController()
        }
        
        if let viewController = viewController {
            viewController.title = title
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
}
