//
//  QDToolBarButtonViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/4/10.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

class QDToolBarButtonViewController: QDCommonListViewController {

    override func initDataSource() {
        dataSource = ["普通工具栏按钮",
                      "图标工具栏按钮"]
    }
    
    override func didSelectCell(_ title: String) {
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        if title == "普通工具栏按钮" {
            let item1 = QMUIToolbarButton.barButtonItem(type: .normal, title: "转发", target: self, action: nil)
            let item2 = QMUIToolbarButton.barButtonItem(type: .normal, title: "回复", target: self, action: nil)
            let item3 = QMUIToolbarButton.barButtonItem(type: .red, title: "删除", target: self, action: nil)
            toolbarItems = [item1, flexibleItem, item2, flexibleItem, item3] as? [UIBarButtonItem]
        } else if title == "图标工具栏按钮" {
            let image1 = UIImage.qmui_image(strokeColor: UIColorWhite, size: CGSize(width: 18, height: 18), lineWidth: 2, cornerRadius: 4)
            let image2 = UIImage.qmui_image(strokeColor: UIColorWhite, size: CGSize(width: 18, height: 18), lineWidth: 2, cornerRadius: 4)
            let image3 = UIImage.qmui_image(strokeColor: UIColorWhite, size: CGSize(width: 18, height: 18), lineWidth: 2, cornerRadius: 4)
            // item有默认的tintColor，不受图片颜色的影响。如果需要自定义tintColor，需要设置item的titnColor属性
            let item1 = QMUIToolbarButton.barButtonItem(image: image1, target: self, action: nil)
            let item2 = QMUIToolbarButton.barButtonItem(image: image2, target: self, action: nil)
            item2?.tintColor = UIColorTheme2
            let item3 = QMUIToolbarButton.barButtonItem(image: image3, target: self, action: nil)
            item3?.tintColor = UIColorTheme3
            toolbarItems = [item1, flexibleItem, item2, flexibleItem, item3] as? [UIBarButtonItem]
        }
        
        navigationController?.setToolbarHidden(false, animated: true)
        tableView.qmui_clearsSelection()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setToolbarHidden(true, animated: true)
    }
}
