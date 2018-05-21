//
//  QDNavigationTransitionViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/4/23.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

class QDNavigationTransitionViewController: QDCommonViewController {

    private var stateLabel: QMUILabel!
    
    override func initSubviews() {
        super.initSubviews()
        
        stateLabel = QMUILabel(with: UIFontMake(16), textColor: UIColorWhite)
        stateLabel.textAlignment = .center
        stateLabel.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        resetStateLabel()
        stateLabel.sizeToFit()
        view.addSubview(stateLabel)
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        stateLabel.frame = CGRect(x: 24, y: qmui_navigationBarMaxYInViewCoordinator + 24, width: view.bounds.width - 24 * 2, height: stateLabel.frame.height)
    }
    
    private func resetStateLabel() {
        stateLabel.text = "请慢慢手势返回"
        stateLabel.backgroundColor = UIColorGray.withAlphaComponent(0.3)
    }
    
    // QMUICommonViewController 默认已经实现了 QMUINavigationControllerDelegate，如果你的 vc 并非继承自 QMUICommonViewController，则需要自行实现 <QMUINavigationControllerDelegate>。
    // 注意，这一切都需要在 QMUINavigationController 里才有效。
    // MARK: QMUINavigationControllerDelegate
    func navigationController(_ navigationController: QMUINavigationController, poppingByInteractive gestureRecognizer: UIScreenEdgePanGestureRecognizer?, viewController willDisappear: UIViewController?, viewController willAppear: UIViewController?) {
        if let gestureRecognizer = gestureRecognizer, gestureRecognizer.state == .ended {
            if willDisappear == self {
                QMUITips.showSucceed(text: "松手了，界面发生切换")
            } else if willAppear == self {
                QMUITips.showInfo(text: "松手了，没有触发界面切换")
            }
            resetStateLabel()
            return
        }
        
        var stateString: String?
        var stateColor: UIColor?
        
        if let gestureRecognizer = gestureRecognizer, gestureRecognizer.state == .began {
            stateString = "触发手势返回"
            stateColor = UIColorBlue.withAlphaComponent(0.5)
        } else if let gestureRecognizer = gestureRecognizer, gestureRecognizer.state == .changed {
            stateString = "手势返回中"
            stateColor = UIColorBlue.withAlphaComponent(0.5)
        } else {
            return
        }
        
        stateLabel.text = stateString
        stateLabel.backgroundColor = stateColor
    }
}
