//
//  QDLabViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/4/2.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

class QDLabViewController: QDCommonListViewController {
    
    override var dataSource: [String] {
        get {
            return ["All System Fonts",
                    "Default Line Height",
                    "Theme",
                    "Animation",
                    "Log Manager"]
        }
        set {
            
        }
    }
    
    override func setNavigationItems(_ isInEditMode: Bool, animated: Bool) {
        super.setNavigationItems(isInEditMode, animated: animated)
        title = "Lab"
        navigationItem.rightBarButtonItem = QMUINavigationButton.barButtonItem(image: UIImageMake("icon_nav_about"), position: .right, target: self, action: #selector(handleAboutItemEvent))
    }
    
    @objc private func handleAboutItemEvent() {
        QDThemeManager.shared.currentTheme = QMUIConfigurationTemplateGrapefruit()
    }
}
