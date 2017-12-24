//
//  QMUITips.swift
//  QMUI.swift
//
//  Created by 黄伯驹 on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

/**
 * 简单封装了 QMUIToastView，支持弹出纯文本、loading、succeed、error、info 等五种 tips。如果这些接口还满足不了业务的需求，可以通过 QMUITips 的分类自行添加接口。
 * 注意用类方法显示 tips 的话，会导致父类的 willShowBlock 无法正常工作，具体请查看 willShowBlock 的注释。
 * @see [QMUIToastView willShowBlock]
 */

class QMUITips: QMUIToastView {

    private var contentCustomView: UIView?

    /// 实例方法：需要自己addSubview，hide之后不会自动removeFromSuperView

    public func show(with text: String?, detailText: String? = nil, hideAfterDelay delay: TimeInterval = 0) {
        contentCustomView = nil
        showTip(with: text, detailText: detailText, hideAfterDelay: delay)
    }

    public func showLoadingHideAfterDelay(_ delay: TimeInterval) {
        showLoading(hideAfterDelay: delay)
    }

    public func showLoading(_ text: String? = nil, detailText: String? = nil, hideAfterDelay delay: TimeInterval = 0) {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        indicator.startAnimating()
        contentCustomView = indicator
        showTip(with: text, detailText: detailText, hideAfterDelay: delay)
    }

    public func showSucceed(_ text: String? = nil, detailText: String? = nil, hideAfterDelay delay: TimeInterval = 0) {
        contentCustomView = UIImageView(image: QMUIHelper.image(with: "QMUI_tips_done"))
        showTip(with: text, detailText: detailText, hideAfterDelay: delay)
    }

    public func showError(_ text: String? = nil, detailText: String? = nil, hideAfterDelay delay: TimeInterval = 0) {
        contentCustomView = UIImageView(image: QMUIHelper.image(with: "QMUI_tips_error"))
        showTip(with: text, detailText: detailText, hideAfterDelay: delay)
    }

    public func showInfo(_ text: String? = nil, detailText: String? = nil, hideAfterDelay delay: TimeInterval = 0) {
        contentCustomView = UIImageView(image: QMUIHelper.image(with: "QMUI_tips_info"))
        showTip(with: text, detailText: detailText, hideAfterDelay: delay)
    }

    private func showTip(with text: String?, detailText: String?, hideAfterDelay delay: TimeInterval) {

        let contentView = self.contentView as? QMUIToastContentView
        contentView?.customView = contentCustomView

        contentView?.textLabelText = text ?? ""
        contentView?.detailTextLabelText = detailText ?? ""

        showAnimated(true)

        if delay > 0 {
            hideAnimated(true, afterDelay: delay)
        }
    }

    /// 类方法：主要用在局部一次性使用的场景，hide之后会自动removeFromSuperView

    public static func createTips(to view: UIView) -> QMUITips {
        let tips = QMUITips(view: view)
        view.addSubview(tips)
        tips.removeFromSuperViewWhenHide = true
        return tips
    }

    public static func show(with text: String?, detailText: String? = nil, in view: UIView, hideAfterDelay delay: TimeInterval = 0) -> QMUITips {
        let tips = createTips(to: view)
        tips.show(with: text, detailText: detailText, hideAfterDelay: delay)
        return tips
    }

    public static func showLoading(_ text: String? = nil, detailText: String? = nil, in view: UIView, hideAfterDelay delay: TimeInterval = 0) -> QMUITips {
        let tips = createTips(to: view)
        tips.showLoading(text, detailText: detailText, hideAfterDelay: delay)
        return tips
    }

    public static func showSucceed(_ text: String? = nil, detailText: String? = nil, in view: UIView, hideAfterDelay delay: TimeInterval = 0) -> QMUITips {
        let tips = createTips(to: view)
        tips.showSucceed(text, detailText: detailText, hideAfterDelay: delay)
        return tips
    }

    public static func showError(_ text: String? = nil, detailText: String? = nil, in view: UIView, hideAfterDelay delay: TimeInterval = 0) -> QMUITips {
        let tips = createTips(to: view)
        tips.showError(text, detailText: detailText, hideAfterDelay: delay)
        return tips
    }

    public static func showInfo(_ text: String? = nil, detailText: String? = nil, in view: UIView, hideAfterDelay delay: TimeInterval = 0) -> QMUITips {
        let tips = createTips(to: view)
        tips.showInfo(text, detailText: detailText, hideAfterDelay: delay)
        return tips
    }
}
