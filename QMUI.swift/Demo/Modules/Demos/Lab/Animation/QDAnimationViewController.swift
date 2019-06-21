//
//  QDAnimationViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/5/21.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

class QDAnimationViewController: QDCommonListViewController {

    override func initDataSource() {
        super.initDataSource()
        
        dataSource = ["Loading",
                      "Loading With CAShapeLayer",
                      "Animation For CAReplicatorLayer",
                      "水波纹"]
    }
    
    override func didSelectCell(_ title: String) {
        var viewController: UIViewController?
        if title == "Loading" {
            viewController = QDAllAnimationViewController()
        } else if title == "Loading With CAShapeLayer" {
            viewController = QDCAShapeLoadingViewController()
        } else if title == "Animation For CAReplicatorLayer" {
            viewController = QDReplicatorLayerViewController()
        } else if title == "水波纹" {
            viewController = QDRippleAnimationViewController()
        }
        
        if let viewController = viewController {
            viewController.title = title
            navigationController?.pushViewController(viewController, animated: true)
        }
    }

}
