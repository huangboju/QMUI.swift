//
//  QDThemeViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/4/16.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

class QDThemeViewController: QDCommonViewController {

    private lazy var themes: [NSObject & QDThemeProtocol] = {
        var themes: [NSObject & QDThemeProtocol] = []
        let allThemeClassName = [
            String(describing: QMUIConfigurationTemplate.self),
            String(describing: QMUIConfigurationTemplateGrapefruit.self),
            String(describing: QMUIConfigurationTemplateGrass.self),
            String(describing: QMUIConfigurationTemplatePinkRose.self),
            ]
        allThemeClassName.forEach({
            if let currentTheme = QDThemeManager.shared.currentTheme {
                if $0 == String(describing: type(of: currentTheme)) {
                    themes.append(currentTheme)
                } else {
                    if let cls: NSObject.Type = NSClassFromString($0) as? NSObject.Type {
                        if let theme = cls.init() as? (NSObject & QDThemeProtocol) {
                            themes.append(theme)
                        }
                    }
                }
            }
        })
        return themes
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: view.bounds)
        return scrollView
    }()
    
    private var themeButtons: [QDThemeButton] = []
    
    override func didInitialized() {
        super.didInitialized()
    }
    
    
    override func initSubviews() {
        super.initSubviews()
        
        view.addSubview(scrollView)
        
        themes.forEach {
            var isCurrentTheme = false
            let currentTheme = QDThemeManager.shared.currentTheme
            if type(of: currentTheme) == type(of: $0) {
                isCurrentTheme = true
            }
            let themeButton = QDThemeButton()
            themeButton.themeColor = $0.themeTintColor
            themeButton.themeName = $0.themeName
            themeButton.isSelected = isCurrentTheme
            themeButton.addTarget(self, action: #selector(handleThemeButtonEvent(_:)), for: .touchUpInside)
            scrollView.addSubview(themeButton)
            themeButtons.append(themeButton)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = view.bounds
        
        let padding = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
        let buttonSpacing: CGFloat = 24
        let buttonSize = CGSize(width: scrollView.bounds.width - padding.horizontalValue, height: 110).flatted
        var buttonMinY = padding.top
        for (i, themeButton) in themeButtons.enumerated() {
            themeButton.frame = CGRect(x: padding.left, y: buttonMinY, width: buttonSize.width, height: buttonSize.height)
            buttonMinY = themeButton.frame.maxY + CGFloat(i == themeButtons.count - 1 ? 0 : buttonSpacing)
        }
        
        scrollView.contentSize = CGSize(width: scrollView.bounds.width - padding.horizontalValue, height: buttonMinY + padding.bottom)
    }

    @objc func handleThemeButtonEvent(_ themeButton: QDThemeButton) {
        themeButtons.forEach {
            $0.isSelected = themeButton == $0
        }
        
        let themeIndex = themeButtons.firstIndex(of: themeButton) ?? 0
        let theme = themes[themeIndex]
        QDThemeManager.shared.currentTheme = theme
        let value = String(describing: type(of: theme))
        UserDefaults.standard.set(value, forKey: QDSelectedThemeClassName)
    }
}

class QDThemeButton: QMUIButton {
    
    fileprivate var themeColor: UIColor? {
        didSet {
            backgroundColor = themeColor
            setTitleColor(themeColor, for: .normal)
        }
    }
    
    fileprivate var themeName: String? {
        didSet {
            setTitle(themeName, for: .normal)
        }
    }
    
    override var isSelected: Bool {
        didSet {
            titleLabel?.font = isSelected ? UIFontBoldMake(14) : UIFontMake(14)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel?.font = UIFontMake(14)
        titleLabel?.textAlignment = .center
        titleLabel?.backgroundColor = UIColorWhite
        setTitleColor(UIColorGray3, for: .normal)
        
        layer.borderWidth = PixelOne
        layer.borderColor = UIColorMakeWithRGBA(0, 0, 0, 0.1).cgColor
        layer.cornerRadius = 4
        layer.masksToBounds = true
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let labelHeight: CGFloat = 36
        titleLabel?.frame = CGRect(x: 0, y: bounds.height - labelHeight, width: bounds.width, height: labelHeight)
    }
}
