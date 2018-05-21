//
//  QDUIViewQMUIViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/4/24.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

class QDUIViewQMUIViewController: QDCommonListViewController {

    override func initDataSource() {
        dataSource = ["UIView (QMUI_Border)",
                      "UIView (QMUI_Debug)",
                      "UIView (QMUI_Layout)"]
    }
    
    override func didSelectCell(_ title: String) {
        var viewController: UIViewController?
        if title == "UIView (QMUI_Border)" {
            viewController = QDUIViewBorderViewController()
        }
        if title == "UIView (QMUI_Debug)" {
            viewController = QDUIViewDebugViewController()
        }
        if title == "UIView (QMUI_Layout)" {
            viewController = QDUIViewLayoutViewController()
        }
        
        if let viewController = viewController {
            viewController.title = title
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
}
