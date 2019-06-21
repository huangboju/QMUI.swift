//
//  QMUITips.swift
//  QMUI.swift
//
//  Created by 黄伯驹 on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

// 自动计算秒数的标志符，在 delay 里面赋值 QMUITipsAutomaticallyHideToastSeconds 即可通过自动计算 tips 消失的秒数
private let QMUITipsAutomaticallyHideToastSeconds: TimeInterval = -1

/// 默认的 parentView
private var DefaultTipsParentView: UIView {
    return UIApplication.shared.delegate!.window!!
}

/**
 * 简单封装了 QMUIToastView，支持弹出纯文本、loading、succeed、error、info 等五种 tips。如果这些接口还满足不了业务的需求，可以通过 QMUITips 的分类自行添加接口。
 * 注意用类方法显示 tips 的话，会导致父类的 willShowBlock 无法正常工作，具体请查看 willShowBlock 的注释。
 * @see [QMUIToastView willShowBlock]
 */

class QMUITips: QMUIToastView {

    private var contentCustomView: UIView?

    /// 实例方法：需要自己addSubview，hide之后不会自动removeFromSuperView

    func show(text: String?,
              detailText: String? = nil,
              hideAfterDelay delay: TimeInterval = QMUITipsAutomaticallyHideToastSeconds) {
        contentCustomView = nil
        showTip(text: text,
                detailText: detailText,
                hideAfterDelay: delay)
    }

    func showLoading(text: String? = nil,
                     detailText: String? = nil,
                     hideAfterDelay delay: TimeInterval = QMUITipsAutomaticallyHideToastSeconds) {
        let indicator = UIActivityIndicatorView(style: .whiteLarge)
        indicator.startAnimating()
        contentCustomView = indicator
        showTip(text: text,
                detailText: detailText,
                hideAfterDelay: delay)
    }

    func showSucceed(text: String? = nil,
                     detailText: String? = nil,
                     hideAfterDelay delay: TimeInterval = QMUITipsAutomaticallyHideToastSeconds) {
        contentCustomView = UIImageView(image: QMUIHelper.image(name: "QMUI_tips_done"))
        showTip(text: text,
                detailText: detailText,
                hideAfterDelay: delay)
    }

    func showError(text: String? = nil,
                   detailText: String? = nil,
                   hideAfterDelay delay: TimeInterval = QMUITipsAutomaticallyHideToastSeconds) {
        contentCustomView = UIImageView(image: QMUIHelper.image(name: "QMUI_tips_error"))
        showTip(text: text,
                detailText: detailText,
                hideAfterDelay: delay)
    }

    func showInfo(text: String? = nil,
                  detailText: String? = nil,
                  hideAfterDelay delay: TimeInterval = QMUITipsAutomaticallyHideToastSeconds) {
        contentCustomView = UIImageView(image: QMUIHelper.image(name: "QMUI_tips_info"))
        showTip(text: text,
                detailText: detailText,
                hideAfterDelay: delay)
    }

    private func showTip(text: String?,
                         detailText: String?,
                         hideAfterDelay delay: TimeInterval) {

        guard let contentView = contentView as? QMUIToastContentView else {
            return
        }
        
        contentView.customView = contentCustomView
        contentView.textLabelText = text ?? ""
        contentView.detailTextLabelText = detailText ?? ""
        
        show(true)
        
        if delay == QMUITipsAutomaticallyHideToastSeconds {
            hide(true, afterDelay: QMUITips.smartDelaySeconds(for: text ?? ""))
        } else if delay > 0 {
            hide(true, afterDelay: delay)
        }
    }

    /// 类方法：主要用在局部一次性使用的场景，hide之后会自动removeFromSuperView
    
    static func createTips(to view: UIView) -> QMUITips {
        let tips = QMUITips(view: view)
        view.addSubview(tips)
        tips.removeFromSuperViewWhenHide = true
        return tips
    }

    @discardableResult
    static func show(text: String?,
                     detailText: String? = nil,
                     in view: UIView = DefaultTipsParentView,
                     hideAfterDelay delay: TimeInterval = QMUITipsAutomaticallyHideToastSeconds) -> QMUITips {
        let tips = createTips(to: view)
        tips.show(text: text,
                  detailText: detailText,
                  hideAfterDelay: delay)
        return tips
    }

    @discardableResult
    static func showLoading(text: String? = nil,
                            detailText: String? = nil,
                            in view: UIView = DefaultTipsParentView,
                            hideAfterDelay delay: TimeInterval = QMUITipsAutomaticallyHideToastSeconds) -> QMUITips {
        let tips = createTips(to: view)
        tips.showLoading(text: text,
                         detailText: detailText,
                         hideAfterDelay: delay)
        return tips
    }

    @discardableResult
    static func showSucceed(text: String? = nil,
                            detailText: String? = nil,
                            in view: UIView = DefaultTipsParentView,
                            hideAfterDelay delay: TimeInterval = QMUITipsAutomaticallyHideToastSeconds) -> QMUITips {
        let tips = createTips(to: view)
        tips.showSucceed(text: text,
                         detailText: detailText,
                         hideAfterDelay: delay)
        return tips
    }

    @discardableResult
    static func showError(text: String? = nil,
                          detailText: String? = nil,
                          in view: UIView = DefaultTipsParentView,
                          hideAfterDelay delay: TimeInterval = QMUITipsAutomaticallyHideToastSeconds) -> QMUITips {
        let tips = createTips(to: view)
        tips.showError(text: text,
                       detailText: detailText,
                       hideAfterDelay: delay)
        return tips
    }

    @discardableResult
    static func showInfo(text: String? = nil,
                         detailText: String? = nil,
                         in view: UIView = DefaultTipsParentView,
                         hideAfterDelay delay: TimeInterval = QMUITipsAutomaticallyHideToastSeconds) -> QMUITips {
        let tips = createTips(to: view)
        tips.showInfo(text: text,
                      detailText: detailText,
                      hideAfterDelay: delay)
        return tips
    }
    
    /// 隐藏 tips
    static func hideAllTips(in view: UIView) {
        QMUITips.hideAllToast(in: view, animated: true)
    }
    
    static func hideAllTips() {
        QMUITips.hideAllToast(in: DefaultTipsParentView, animated: true)
    }
    
    static func smartDelaySeconds(for tipsText: String) -> TimeInterval {
        let length = tipsText.qmui_lengthWhenCountingNonASCIICharacterAsTwo
        if length <= 20 {
            return 1.5
        } else if length <= 40 {
            return 2.0
        } else if length <= 50 {
            return 2.5
        } else {
            return 3.0
        }
    }
}
