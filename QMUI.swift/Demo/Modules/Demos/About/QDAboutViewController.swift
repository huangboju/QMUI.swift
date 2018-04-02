//
//  QDAboutViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/4/2.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

class QDAboutViewController: QDCommonViewController {
    
    lazy var debugView: UIView = {
        return UIView(frame: CGRect(x: 100, y: 100, width: 200, height: 200))
    }()
    
    override func didInitialized() {
        super.didInitialized()
        
        view.addSubview(debugView)
        debugView.backgroundColor = QDCommonUI.randomThemeColor()
    }
    
    override func setNavigationItems(_ isInEditMode: Bool, animated: Bool) {
        super.setNavigationItems(isInEditMode, animated: animated)
        title = "关于"
        navigationItem.rightBarButtonItem = QMUINavigationButton.barButtonItem(image: UIImageMake("icon_nav_about"), position: .right, target: self, action: #selector(handleAboutItemEvent))
    }
    
    @objc private func handleAboutItemEvent() {
        debugView.qmui_borderColor = UIColorGray1
        debugView.qmui_borderWidth = 2
        debugView.qmui_borderPosition = .left
    }
}
