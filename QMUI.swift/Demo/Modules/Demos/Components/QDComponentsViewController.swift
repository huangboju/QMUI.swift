//
//  QDComponentsViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/4/2.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

class QDComponentsViewController: QDCommonGridViewController {

    override private(set) var dataSource: QMUIOrderedDictionary<String, UIImage> {
        get {
            let dataSource = QMUIOrderedDictionary(dictionaryLiteral:
                ("QMUIModalPresentationViewController", UIImageMake("icon_grid_modal")!),
                ("QMUIDialogViewController", UIImageMake("icon_grid_dialog")!),
                ("QMUIMoreOperationController", UIImageMake("icon_grid_moreOperation")!),
                ("QMUINavigationTitleView", UIImageMake("icon_grid_titleView")!),
                ("QMUIEmptyView", UIImageMake("icon_grid_emptyView")!),
                ("QMUIToastView", UIImageMake("icon_grid_toast")!),
                ("QMUIEmotionView", UIImageMake("icon_grid_emotionView")!),
                ("QMUIGridView", UIImageMake("icon_grid_gridView")!),
                ("QMUIFloatLayoutView", UIImageMake("icon_grid_floatView")!),
                ("QMUIStaticTableView", UIImageMake("icon_grid_staticTableView")!),
                ("QMUIPickingImage", UIImageMake("icon_grid_pickingImage")!),
                ("QMUIAssetsManager", UIImageMake("icon_grid_assetsManager")!),
                ("QMUIImagePreviewView", UIImageMake("icon_grid_previewImage")!),
                ("QMUIPieProgressView", UIImageMake("icon_grid_pieProgressView")!),
                ("QMUIPopupContainerView", UIImageMake("icon_grid_popupView")!),
                ("QMUIKeyboardManager", UIImageMake("icon_grid_keyboard")!),
                ("QMUIMarqueeLabel", UIImageMake("icon_grid_marquee")!)
            )
            
            return dataSource
        }
        set {
            
        }
    }
    
    override func setNavigationItems(_ isInEditMode: Bool, animated: Bool) {
        super.setNavigationItems(isInEditMode, animated: animated)
        title = "Components"
        navigationItem.rightBarButtonItem = QMUINavigationButton.barButtonItem(image: UIImageMake("icon_nav_about"), position: .right, target: self, action: #selector(handleAboutItemEvent))
    }
    
    @objc private func handleAboutItemEvent() {
        let viewController = QDAboutViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    override func didSelectCell(_ title: String) {
        var viewController: UIViewController?
        if title == "QMUINavigationTitleView" {
            viewController = QDNavigationTitleViewController()
        }
        if title == "QMUIEmptyView" {
            viewController = QDEmptyViewController()
        }
        if title == "QMUIToastView" {
            viewController = QDToastListViewController()
        }
        if title == "QMUIStaticTableView" {
            viewController = QDStaticTableViewController()
        }
        if title == "QMUIImagePreviewView" {
            viewController = QDSliderViewController()
        }
        if title == "QMUIPickingImage" {
            viewController = QDImagePickerExampleViewController()
        }
        if title == "QMUIAssetsManager" {
            viewController = QDSliderViewController()
        }
        if title == "QMUIMoreOperationController" {
            viewController = QDMoreOperationViewController()
        }
        if title == "QMUIEmotionView" {
            viewController = QDEmotionsViewController()
        }
        if title == "QMUIGridView" {
            viewController = QDGridViewController()
        }
        if title == "QMUIFloatLayoutView" {
            viewController = QDFloatLayoutViewController()
        }
        if title == "QMUIPieProgressView" {
            viewController = QDSliderViewController()
        }
        if title == "QMUIPopupContainerView" {
            viewController = QDSliderViewController()
        }
        if title == "QMUIModalPresentationViewController" {
            viewController = QDModalPresentationViewController(style: .grouped)
        }
        if title == "QMUIDialogViewController" {
            viewController = QDDialogViewController()
        }
        if title == "QMUIKeyboardManager" {
            viewController = QDSliderViewController()
        }
        if title == "QMUIMarqueeLabel" {
            viewController = QDSliderViewController()
        }
        
        if let viewController = viewController {
            viewController.title = title
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
}
