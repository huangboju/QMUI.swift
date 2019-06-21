//
//  QDToastListViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/5/4.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

class QDToastListViewController: QDCommonListViewController {

    override func initDataSource() {
        dataSource = ["Loading",
                      "Loading With Text",
                      "Tips For Succeed",
                      "Tips For Error",
                      "Tips For Info",
                      "Custom TintColor",
                      "Custom BackgroundView Style",
                      "Custom Animator",
                      "Custom Content View"]
    }
    
    override func didSelectCell(_ title: String) {
        guard let parentView = navigationController?.view else {
            return
        }
        
        if title == "Loading" {
            // 如果不需要修改contentView的样式，可以直接使用下面这个工具方法
            //         QMUITips *tips = [QMUITips showLoadingInView:parentView hideAfterDelay:2];
            
            // 展示如何修改自定义的样式
            let tips = QMUITips.createTips(to: parentView)
            let contentView = tips.contentView as? QMUIToastContentView
            contentView?.minimumSize = CGSize(width: 90, height: 90)
            tips.willShowClosure = { (showInView, animated) in
                print("tips calling willShowClosure")
            }
            tips.didShowClosure = { (showInView, animated) in
                print("tips calling didShowClosure")
            }
            tips.willHideClosure = { (showInView, animated) in
                print("tips calling willHideClosure")
            }
            tips.didHideClosure = { (showInView, animated) in
                print("tips calling didHideClosure")
            }
            tips.showLoading(hideAfterDelay: 2)
        } else if title == "Loading With Text" {
            QMUITips.showLoading(text: "加载中...", in: parentView, hideAfterDelay: 2)
        } else if title == "Tips For Succeed" {
            QMUITips.showSucceed(text: "加载成功", in: parentView, hideAfterDelay: 2)
        } else if title == "Tips For Error" {
            QMUITips.showError(text: "加载失败，请检查网络情况", in: parentView, hideAfterDelay: 2)
        } else if title == "Tips For Info" {
            QMUITips.showInfo(text: "活动已经结束", detailText: "本次活动时间为2月1号-2月15号", in: parentView, hideAfterDelay: 2)
        } else if title == "Custom TintColor" {
            let tips = QMUITips.showInfo(text: "活动已经结束", detailText: "本次活动时间为2月1号-2月15号", in: parentView, hideAfterDelay: 2)
            tips.tintColor = UIColorBlue
        } else if title == "Custom BackgroundView Style" {
            let tips = QMUITips.showInfo(text: "活动已经结束", detailText: "本次活动时间为2月1号-2月15号", in: parentView, hideAfterDelay: 2)
            if let backgroundView = tips.backgroundView as? QMUIToastBackgroundView {
                backgroundView.showldBlurBackgroundView = true
                backgroundView.styleColor = UIColor(r: 232, g: 232, b: 232, a: 0.8)
                tips.tintColor = UIColorBlack
            }
        } else if title == "Custom Content View" {
            let tips = QMUITips.createTips(to: parentView)
            tips.toastPosition = .bottom
            let customAnimator = QDCustomToastAnimator(toastView: tips)
            tips.toastAnimator = customAnimator
            let customContentView = QDCustomToastContentView()
            customContentView.render(with: UIImageMake("image0"), text: "什么是QMUIToastView", detailText: "QMUIToastView用于临时显示某些信息，并且会在数秒后自动消失。这些信息通常是轻量级操作的成功信息。")
            tips.contentView = customContentView
            tips.show(true)
            tips.hide(true, afterDelay: 4)
        } else if title == "Custom Animator" {
            let tips = QMUITips.createTips(to: parentView)
            let customAnimator = QDCustomToastAnimator(toastView: tips)
            tips.toastAnimator = customAnimator
            tips.showInfo(text: "活动已经结束", detailText: "本次活动时间为2月1号-2月15号", hideAfterDelay: 2)
        }
        tableView.qmui_clearsSelection()
    }

}
