//
//  QMUISearchBar.swift
//  QMUI.swift
//
//  Created by xnxin on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

import UIKit

class QMUISearchBar: UISearchBar {

    override init(frame: CGRect) {
        super.init(frame: frame)
        didInitialized()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        didInitialized()
    }

    private func didInitialized() {
        qmui_styledAsQMUISearchBar()
    }
}
