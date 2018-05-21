//
//  QDFloatLayoutViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/5/9.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

class QDFloatLayoutViewController: QDCommonViewController {

    private var floatLayoutView: QMUIFloatLayoutView!
    
    override func initSubviews() {
        super.initSubviews()
        
        floatLayoutView = QMUIFloatLayoutView()
        floatLayoutView.padding = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        floatLayoutView.itemMargins = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 10)
        floatLayoutView.minimumItemSize = CGSize(width: 69, height: 29) // 以2个字的按钮作为最小宽度
        floatLayoutView.layer.borderWidth = PixelOne
        floatLayoutView.layer.borderColor = UIColorSeparator.cgColor
        view.addSubview(floatLayoutView)
        
        let suggestions = ["东野圭吾", "三体", "爱", "红楼梦", "理智与情感", "读书热榜", "免费榜"]
        suggestions.forEach {
            let button = QMUIGhostButton()
            button.ghostColor = QDThemeManager.shared.currentTheme?.themeTintColor ?? UIColorBlue
            button.setTitle($0, for: .normal)
            button.titleLabel?.font = UIFontMake(14)
            button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 20, bottom: 6, right: 20)
            floatLayoutView.addSubview(button)
        }
        
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let padding = UIEdgeInsets(top: 36 + qmui_navigationBarMaxYInViewCoordinator, left: 24, bottom: 36, right: 24)
        let contentWidth = view.bounds.width - padding.horizontalValue
        let floatLayoutViewSize = floatLayoutView.sizeThatFits(CGSize(width: contentWidth, height: CGFloat.greatestFiniteMagnitude))
        floatLayoutView.frame = CGRect(x: padding.left, y: padding.top, width: contentWidth, height: floatLayoutViewSize.height)
    }
}
