//
//  QDAboutViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/4/2.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

class QDAboutViewController: QDCommonViewController {
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        
        return scrollView
    }()
    
    private lazy var debugView: QMUIButton = {
        let button = QDCommonGridButton()
        
        let attributes = [NSAttributedStringKey.foregroundColor: UIColorGray6, NSAttributedStringKey.font: UIFontMake(11), NSAttributedStringKey.paragraphStyle: NSMutableParagraphStyle(lineHeight: 12, lineBreakMode: .byTruncatingTail, textAlignment: .center)]
        let attributedString = NSAttributedString(string: "qcvwaevawv", attributes: attributes)
        let image = UIImageMake("icon_grid_button")!
        
        if let tintColor = QDThemeManager.shared.currentTheme!.themeGridItemTintColor {
            button.tintColor = tintColor
            button.adjustsImageTintColorAutomatically = true
        } else {
            button.tintColor = nil
            button.adjustsImageTintColorAutomatically = false
        }
        button.setAttributedTitle(attributedString, for: .normal)
        button.setImage(image, for: .normal)
        button.frame = CGRect(x: 100, y: 100, width: 200, height: 200)
        
        return button
    }()
    
    override func didInitialized() {
        super.didInitialized()
        
        view.addSubview(scrollView)
        scrollView.addSubview(debugView)
        
        scrollView.frame = view.bounds
        
        let contentSize = CGSize(width: debugView.frame.width, height:debugView.frame.maxY)
        scrollView.contentSize = contentSize
        
        let string = String(describing: type(of: scrollView))
        
//        debugView.backgroundColor = QDCommonUI.randomThemeColor()
    }
    
    override func setNavigationItems(_ isInEditMode: Bool, animated: Bool) {
        super.setNavigationItems(isInEditMode, animated: animated)
        title = "关于"
        navigationItem.rightBarButtonItem = QMUINavigationButton.barButtonItem(image: UIImageMake("icon_nav_about"), position: .right, target: self, action: #selector(handleAboutItemEvent))
    }
    
    @objc private func handleAboutItemEvent() {
        QDThemeManager.shared.currentTheme = QMUIConfigurationTemplateGrapefruit()
    }
}
