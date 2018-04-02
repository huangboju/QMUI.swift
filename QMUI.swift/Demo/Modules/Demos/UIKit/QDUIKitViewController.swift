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
    
    override func setNavigationItems(_ isInEditMode: Bool, animated: Bool) {
        super.setNavigationItems(isInEditMode, animated: animated)
        title = "QMUIKit"
        navigationItem.rightBarButtonItem = QMUINavigationButton.barButtonItem(image: UIImageMake("icon_nav_about"), position: .right, target: self, action: #selector(handleAboutItemEvent))
    }
    
    @objc private func handleAboutItemEvent() {
        let viewController = QDAboutViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
}
