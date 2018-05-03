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
    
    // 图片+文字按钮
    private var imagePositionButton: QMUIButton?
    
    override func setNavigationItems(_ isInEditMode: Bool, animated: Bool) {
        super.setNavigationItems(isInEditMode, animated: animated)
        title = "QMUIKit"
        navigationItem.rightBarButtonItem = QMUINavigationButton.barButtonItem(image: UIImageMake("icon_nav_about"), position: .right, target: self, action: #selector(handleAboutItemEvent))
    }
    
    @objc private func handleAboutItemEvent() {
        let viewController = QDAboutViewController()
//        navigationController?.pushViewController(viewController, animated: true)
        
        if imagePositionButton != nil {
            imagePositionButton?.removeFromSuperview()
            imagePositionButton = nil
        } else {
            imagePositionButton = QMUIButton()
            imagePositionButton!.tintColorAdjustsTitleAndImage = (QDThemeManager.shared.currentTheme?.themeTintColor)!
            imagePositionButton!.imagePosition = .top // 将图片位置改为在文字上方
            imagePositionButton!.spacingBetweenImageAndTitle = 8
            imagePositionButton!.setImage(UIImageMake("icon_emotion"), for: .normal)
            imagePositionButton!.setTitle("图片在上方的按钮", for: .normal)
            imagePositionButton!.titleLabel?.font = UIFontMake(11)
            imagePositionButton!.qmui_borderPosition = [.top, .bottom]
            
            view.addSubview(imagePositionButton!)
            // 图片+文字按钮
            imagePositionButton!.frame = CGRectFlat(50, 200, view.bounds.width / 2, 50)
        }
        
        
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
