//
//  QDUIKitViewController.swift
//  QMUI.swift
//
//  Created by TonyHan on 2018/3/7.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

class QDUIKitViewController: QDCommonGridViewController {
    
    override public private(set) var dataSource: QMUIOrderedDictionary<String, UIImage>! {
        get {
            let dataSource = QMUIOrderedDictionary(dictionaryLiteral:
                ("QMUIButton", UIImageMake("icon_grid_button")!),
                                                   ("QMUILabel", UIImageMake("icon_grid_label")!),
                                                   ("QMUITextView", UIImageMake("icon_grid_textView")!)
            )
            
            return dataSource
        }
        set {
            
        }
    }
    
    override func setNavigationItems(_ isInEditMode: Bool, animated: Bool) {
        super.setNavigationItems(isInEditMode, animated: animated)
        title = "QMUIKit"
        if let image = UIImageMake("icon_nav_about") {
            navigationItem.rightBarButtonItem = QMUINavigationButton.barButtonItem(with: image, position: .right, target: self, action: #selector(handleAboutItemEvent))
        }
    }
    
    @objc private func handleAboutItemEvent() {
        
    }
}
