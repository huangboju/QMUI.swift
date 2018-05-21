//
//  QDPopupContainerViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/5/17.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

class QDPopupContainerView: QMUIPopupContainerView {
    
    private var emotionInputManager: QMUIEmotionInputManager!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentEdgeInsets = .zero
        emotionInputManager = QMUIEmotionInputManager()
        emotionInputManager.emotionView.emotions = QDUIHelper.qmuiEmotions()
        emotionInputManager.emotionView.sendButton.isHidden = true
        contentView.addSubview(emotionInputManager.emotionView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sizeThatFitsInContentView(_ size: CGSize) -> CGSize {
        return CGSize(width: 300, height: 320)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 所有布局都参照 contentView
        emotionInputManager.emotionView.frame = contentView.bounds
    }
}

class QDPopupContainerViewController: QDCommonViewController {
    
    private var button1: QMUIButton!
    private var popupView1: QMUIPopupContainerView!
    private var button2: QMUIButton!
    private var popupView2: QMUIPopupMenuView!
    private var button3: QMUIButton!
    private var popupView3: QDPopupContainerView!
    private var separatorLayer1: CALayer!
    private var separatorLayer2: CALayer!
    private var popupView4: QMUIPopupMenuView!
    
    override func initSubviews() {
        super.initSubviews()
        
        separatorLayer1 = CALayer()
        separatorLayer1.qmui_removeDefaultAnimations()
        separatorLayer1.backgroundColor = UIColorSeparator.cgColor
        view.layer.addSublayer(separatorLayer1)
        
        separatorLayer2 = CALayer()
        separatorLayer2.qmui_removeDefaultAnimations()
        separatorLayer2.backgroundColor = UIColorSeparator.cgColor
        view.layer.addSublayer(separatorLayer2)
        
        button1 = QDUIHelper.generateLightBorderedButton()
        button1.addTarget(self, action: #selector(handleButtonEvent(_:)), for: .touchUpInside)
        button1.setTitle("显示默认浮层", for: .normal)
        view.addSubview(button1)
        
        // 使用方法 1，以 addSubview: 的形式显示到界面上
        popupView1 = QMUIPopupContainerView()
        popupView1.imageView.image = UIImageMake("icon_emotion")?.qmui_imageResized(in: CGSize(width: 24, height: 24), contentMode: .scaleToFill)?.qmui_image(tintColor: QDThemeManager.shared.currentTheme?.themeTintColor)
        popupView1.textLabel.text = "默认自带 imageView、textLabel，可展示简单的内容"
        popupView1.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        popupView1.didHideClosure = { [weak self] (hidesByUserTap) in
            self?.button1.setTitle("显示默认浮层", for: .normal)
        }
        // 使用方法 1 时，显示浮层前需要先手动隐藏浮层，并自行添加到目标 UIView 上
        popupView1.isHidden = true
        view.addSubview(popupView1)
        
        button2 = QDUIHelper.generateLightBorderedButton()
        button2.addTarget(self, action: #selector(handleButtonEvent), for: .touchUpInside)
        button2.setTitle("显示菜单浮层", for: .normal)
        view.addSubview(button2)
        
        // 使用方法 2，以 UIWindow 的形式显示到界面上，这种无需默认隐藏，也无需 add 到某个 UIView 上
        popupView2 = QMUIPopupMenuView()
        popupView2.automaticallyHidesWhenUserTap = true // 点击空白地方消失浮层
        popupView2.maskViewBackgroundColor = UIColorMaskWhite // 使用方法 2 并且打开了 automaticallyHidesWhenUserTap 的情况下，可以修改背景遮罩的颜色
        popupView2.maximumWidth = 180;
        popupView2.shouldShowItemSeparator = true
        popupView2.separatorInset = UIEdgeInsets(top: 0, left: popupView2.padding.left, bottom: 0, right: popupView2.padding.right)
        popupView2.items = [
            QMUIPopupMenuItem(image: UIImageMake("icon_tabbar_uikit")?.withRenderingMode(.alwaysTemplate), title: "QMUIKit", handler: { [weak self] in
                self?.popupView2.hide(with: true)
            }),
            QMUIPopupMenuItem(image: UIImageMake("icon_tabbar_component")?.withRenderingMode(.alwaysTemplate), title: "Components", handler: { [weak self] in
                self?.popupView2.hide(with: true)
            }),
            QMUIPopupMenuItem(image: UIImageMake("icon_tabbar_lab")?.withRenderingMode(.alwaysTemplate), title: "Lab", handler: { [weak self] in
                self?.popupView2.hide(with: true)
            })]
        popupView2.didHideClosure = { [weak self] (hidesByUserTap) in
            self?.button2.setTitle("显示菜单浮层", for: .normal)
        }
        
        button3 = QDUIHelper.generateLightBorderedButton()
        button3.addTarget(self, action: #selector(handleButtonEvent), for: .touchUpInside)
        button3.setTitle("显示自定义浮层", for: .normal)
        view.addSubview(button3)
        
        popupView3 = QDPopupContainerView()
        popupView3.preferLayoutDirection = .below // 默认在目标的下方，如果目标下方空间不够，会尝试放到目标上方。若上方空间也不够，则缩小自身的高度。
        popupView3.didHideClosure = { [weak self] (hidesByUserTap) in
            self?.button3.setTitle("显示自定义浮层", for: .normal)
        }
        
        // 在 UIBarButtonItem 上显示
        popupView4 = QMUIPopupMenuView()
        popupView4.automaticallyHidesWhenUserTap = true // 点击空白地方消失浮层
        popupView4.maximumWidth = 180
        popupView4.shouldShowItemSeparator = true
        popupView4.separatorInset = UIEdgeInsets(top: 0, left: popupView4.padding.left, bottom: 0, right: popupView4.padding.right)
        popupView4.items = [
            QMUIPopupMenuItem(image: UIImageMake("icon_tabbar_uikit")?.withRenderingMode(.alwaysTemplate), title: "QMUIKit", handler: nil),
            QMUIPopupMenuItem(image: UIImageMake("icon_tabbar_component")?.withRenderingMode(.alwaysTemplate), title: "Components", handler: nil),
            QMUIPopupMenuItem(image: UIImageMake("icon_tabbar_lab")?.withRenderingMode(.alwaysTemplate), title: "Lab", handler: nil),
        ]
    }
    
    override func setNavigationItems(_ isInEditMode: Bool, animated: Bool) {
        super.setNavigationItems(isInEditMode, animated: animated)
        navigationItem.rightBarButtonItem = UIBarButtonItem.item(image: UIImageMake("icon_nav_about"), target: self, action: #selector(handleRightBarButtonItemEvent(_:)))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // popupView3 使用方法 2 显示，并且没有打开 automaticallyHidesWhenUserTap，则需要手动隐藏
        if popupView3.isShowing {
            popupView3.hide(with: animated)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let minY = qmui_navigationBarMaxYInViewCoordinator
        let viewportHeight = view.bounds.height - minY
        let sectionHeight = viewportHeight / 3
        
        button1.frame = button1.frame.setXY(view.bounds.width.center(button1.frame.width), minY + (sectionHeight - button1.frame.height) / 2)
        popupView1.safetyMarginsOfSuperview = popupView1.safetyMarginsOfSuperview.setTop(qmui_navigationBarMaxYInViewCoordinator + 10)
        popupView1.layout(with: button1) // 相对于 button1 布局
        
        separatorLayer1.frame = CGRectFlat(0, minY + sectionHeight, view.bounds.width, PixelOne)
        
        button2.frame = button1.frame.setY(button1.frame.maxY + sectionHeight - button2.frame.height)
        popupView2.layout(with: button2) // 相对于 button2 布局
        
        separatorLayer2.frame = separatorLayer1.frame.setY(minY + sectionHeight * 2)
        
        button3.frame = button1.frame.setY(button2.frame.maxY + sectionHeight - button3.frame.height)
        popupView3.layoutWithTargetRectInScreenCoordinate(button3.convert(button3.bounds, to: nil)) // 将 button3 的坐标转换到相对于 UIWindow 的坐标系里，然后再传给浮层布局
        
        // 在横竖屏旋转时，viewDidLayoutSubviews 这个时机还无法获取到正确的 navigationItem 的 frame，所以直接隐藏掉
        if popupView4.isShowing {
            popupView4.hide(with: false)
        }
    }

    @objc private func handleRightBarButtonItemEvent(_ button: QMUIButton) {
        if popupView4.isShowing {
            popupView4.hide(with: true)
        } else {
            // 相对于右上角的按钮布局，显示前重新对准布局，避免横竖屏导致位置不准确
            if let qmui_view = navigationItem.rightBarButtonItem?.qmui_view {
                popupView4.layout(with: qmui_view)
                popupView4.show(with: true)
            }
        }
    }

    @objc private func handleButtonEvent(_ button: QMUIButton) {
        if button == button1 {
            if popupView1.isShowing {
                popupView1.hide(with: true)
                button1.setTitle("显示默认浮层", for: .normal)
            } else {
                popupView1.show(with: true)
                button1.setTitle("隐藏默认浮层", for: .normal)
            }
            return
        }
        
        if button == button2 {
            popupView2.show(with: true)
            button2.setTitle("隐藏菜单浮层", for: .normal)
            return
        }
        
        if button == button3 {
            if popupView3.isShowing {
                popupView3.hide(with: true)
            } else {
                popupView3.show(with: true)
                button3.setTitle("隐藏自定义浮层", for: .normal)
            }
            return
        }
    }

}
