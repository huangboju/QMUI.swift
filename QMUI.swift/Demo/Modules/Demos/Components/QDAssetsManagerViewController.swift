//
//  QDAssetsManagerViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/5/15.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

class QDAssetsManagerViewController: QDCommonListViewController {

    override func setupNavigationItems() {
        super.setupNavigationItems()
    }

    override func initDataSource() {
        super.initDataSource()
        
        dataSourceWithDetailText = QMUIOrderedDictionary(
            dictionaryLiteral:
            ("保存图片到指定相册", "生成随机图片并保存到指定的相册"),
            ("保存视频到指定相册", "拍摄一个视频并保存到指定的相册"))
    }
    
    override func didSelectCell(_ title: String) {
        var viewController: QMUICommonViewController?
        if title == "保存图片到指定相册" {
            viewController = QDSaveImageToSpecifiedAlbumViewController()
        } else if title == "保存视频到指定相册" {
            viewController = QDSaveVideoToSpecifiedAlbumViewController()
        }
        if let viewController = viewController {
            viewController.title = title
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
}
