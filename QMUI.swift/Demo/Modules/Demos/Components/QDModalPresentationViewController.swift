//
//  QDModalPresentationViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/4/12.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

private let kSectionTitleForUsing = "使用方式"
private let kSectionTitleForStyling = "内容及动画"

class QDModalPresentationViewController: QDCommonGroupListViewController {

    private var currentAnimationStyle: QMUIModalPresentationAnimationStyle = .fade
    
    private var modalViewControllerForAddSubview: QMUIModalPresentationViewController?
    
    override func initDataSource() {
        super.initDataSource()
        let od1 = QMUIOrderedDictionary(dictionaryLiteral:
            ("showWithAnimated", "以 UIWindow 的形式盖在当前界面上"),
            ("presentViewController", "以 presentViewController: 的方式显示"),
            ("showInView", "以 addSubview: 的方式直接将浮层添加到要显示的 UIView 上"))
        let od2 = QMUIOrderedDictionary(dictionaryLiteral:
            ("contentView", "直接显示一个UIView浮层"),
            ("contentViewController", "显示一个UIViewController"),
            ("animationStyle", "默认提供3种动画，可重复点击，依次展示"),
            ("dimmingView", "自带背景遮罩，也可自行制定一个遮罩的UIView"),
            ("layoutClosure", "利用layoutClosure、showingAnimationClosure、hidingAnimationClosure制作自定义的显示动画"),
            ("keyboard", "控件自带对keyboard的管理，并且能保证浮层和键盘同时升起，不会有跳动"))
        dataSource = QMUIOrderedDictionary(dictionaryLiteral: (kSectionTitleForUsing, od1), (kSectionTitleForStyling, od2))
    }
    
    override func didSelectCell(_ title: String) {
        if title == "contentView" {
            handleShowContentView()
        } else if title == "contentViewController" {
            handleShowContentViewController()
        } else if title == "animationStyle" {
            handleShowContentView()
        } else if title == "dimmingView" {
            handleCustomDimmingView()
        } else if title == "layoutClosure" {
            handleLayoutClosureAndAnimation()
        } else if title == "keyboard" {
            handleKeyboard()
        } else if title == "showWithAnimated" {
            handleWindowShowing()
        } else if title == "presentViewController" {
            handlePresentShowing()
        } else if title == "showInView" {
            handleShowInView()
        }
    }
    
    private func handleShowContentView() {
        let contentView = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 400))
        contentView.backgroundColor = UIColorWhite
        contentView.layer.cornerRadius = 6
        
        let label = UILabel()
        label.numberOfLines = 0
        let paragraphStyle = NSMutableParagraphStyle(lineHeight: 24)
        paragraphStyle.paragraphSpacing = 16
        let string = "默认的布局是上下左右居中，可通过contentViewMargins、maximumContentViewWidth属性来调整宽高、上下左右的偏移。\n你现在可以试试旋转一下设备试试看。"
        let attributedString = NSMutableAttributedString(string: string, attributes: [NSAttributedString.Key.font : UIFontMake(16), NSAttributedString.Key.foregroundColor: UIColorBlack, NSAttributedString.Key.paragraphStyle: paragraphStyle])
        let codeAttributes = CodeAttributes(16)
        attributedString.string.enumerateCodeString { (codeString, codeRange) -> () in
            attributedString.addAttributes(codeAttributes, range: codeRange)
        }
        
        label.attributedText = attributedString
        contentView.addSubview(label)
        
        let contentViewPadding = UIEdgeInsets.init(top: 20, left: 20, bottom: 20, right: 20)
        let contentLimitWidth = contentView.bounds.width - contentViewPadding.horizontalValue
        
        let labelSize = label.sizeThatFits(CGSize(width: contentLimitWidth, height: CGFloat.greatestFiniteMagnitude))
        label.frame = CGRect(x: contentViewPadding.left, y: contentViewPadding.top, width: contentLimitWidth, height: labelSize.height)
        
        let modalViewController = QMUIModalPresentationViewController()
        modalViewController.contentView = contentView
        modalViewController.show(true, completion: nil)
    }
    
    private func handleShowContentViewController() {
        let contentViewController = QDModalContentViewController()
        let modalViewController = QMUIModalPresentationViewController()
        modalViewController.contentViewController = contentViewController
        modalViewController.maximumContentViewWidth = CGFloat.greatestFiniteMagnitude
        modalViewController.show(true, completion: nil)
    }
    
    private func handleCustomDimmingView() {
        let contentView = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 400))
        contentView.backgroundColor = UIColorWhite
        contentView.layer.cornerRadius = 6
        contentView.layer.shadowColor = UIColorBlack.cgColor
        contentView.layer.shadowOpacity = 0.08
        contentView.layer.shadowRadius = 15
        contentView.layer.shadowPath = UIBezierPath(roundedRect: contentView.bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
        
        let label = UILabel()
        label.numberOfLines = 0
        
        let paragraphStyle = NSMutableParagraphStyle(lineHeight: 24)
        paragraphStyle.paragraphSpacing = 16
        let string = "QMUIModalPresentationViewController允许自定义背景遮罩的dimmingView，例如这里的背景遮罩是拿当前界面进行截图磨砂后显示出来的。"
        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font : UIFontMake(16), NSAttributedString.Key.foregroundColor: UIColorBlack, NSAttributedString.Key.paragraphStyle: paragraphStyle]
        let attributedString = NSMutableAttributedString(string: string, attributes: attributes)
        
        let codeAttributes = CodeAttributes(16)
        attributedString.string.enumerateCodeString { (codeString, codeRange) -> () in
            attributedString.addAttributes(codeAttributes, range: codeRange)
        }
        
        label.attributedText = attributedString
        contentView.addSubview(label)
        
        let contentViewPadding = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        let contentLimitWidth = contentView.bounds.width - contentViewPadding.horizontalValue
        let labelSize = label.sizeThatFits(CGSize(width: contentLimitWidth, height: CGFloat.greatestFiniteMagnitude))
        label.frame = CGRect(x: contentViewPadding.left, y: contentViewPadding.top, width: contentLimitWidth, height: labelSize.height)
        
        if let navigationController = navigationController {
            var blurredBackgroundImage = UIImage.qmui_image(view: navigationController.view)
            blurredBackgroundImage = blurredBackgroundImage?.applyExtraLightEffect()
            let blurredDimmingView = UIImageView(image: blurredBackgroundImage)
            
            let modalViewController = QMUIModalPresentationViewController()
            modalViewController.dimmingView = blurredDimmingView
            modalViewController.contentView = contentView
            modalViewController.show(true, completion: nil)
        }
    }
    
    private func handleLayoutClosureAndAnimation() {
        let contentView = UIScrollView(frame: CGRect(x: 0, y: 0, width: 300, height: 250))
        contentView.backgroundColor = UIColorWhite
        contentView.layer.cornerRadius = 6
        contentView.alwaysBounceVertical = false
        
        let label = UILabel()
        label.numberOfLines = 0
        
        let paragraphStyle = NSMutableParagraphStyle(lineHeight: 24)
        paragraphStyle.paragraphSpacing = 16
        let string = "利用layoutClosure可以自定义浮层的布局，注意此时contentViewMargins、maximumContentViewWidth属性均无效，如果需要实现外间距、最大宽高的保护，请自行计算。\n另外搭配showingAnimation、hidingAnimation也可制作自己的显示/隐藏动画，例如这个例子里实现了一个从底部升起的面板，升起后停靠在容器底端，你可以试着旋转设备，会发现依然能正确布局。"
        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font : UIFontMake(16), NSAttributedString.Key.foregroundColor: UIColorBlack, NSAttributedString.Key.paragraphStyle: paragraphStyle]
        let attributedString = NSMutableAttributedString(string: string, attributes: attributes)
        let codeAttributes = CodeAttributes(16)
        attributedString.string.enumerateCodeString { (codeString, codeRange) -> () in
            attributedString.addAttributes(codeAttributes, range: codeRange)
        }
        
        label.attributedText = attributedString
        contentView.addSubview(label)
        
        let contentViewPadding = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        let contentLimitWidth = contentView.bounds.width - contentViewPadding.horizontalValue
        let labelSize = label.sizeThatFits(CGSize(width: contentLimitWidth, height: CGFloat.greatestFiniteMagnitude))
        label.frame = CGRect(x: contentViewPadding.left, y: contentViewPadding.top, width: contentLimitWidth, height: labelSize.height)
    
        contentView.contentSize = CGSize(width: contentView.bounds.width, height: label.frame.maxY + contentViewPadding.bottom)
        
        let modalViewController = QMUIModalPresentationViewController()
        modalViewController.contentView = contentView
        modalViewController.layoutClosure = { (containerBounds, keyboardHeight, contentViewDefaultFrame) in
            contentView.frame = contentView.frame.setXY(containerBounds.width.center(contentView.frame.width), containerBounds.height - 20 - contentView.frame.height)
        }
        modalViewController.showingAnimationClosure = { (dimmingView, containerBounds, keyboardHeight, contentViewFrame, completion) in
            contentView.frame = contentView.frame.setY(containerBounds.height)
            dimmingView?.alpha = 0
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveOut, animations: {
                dimmingView?.alpha = 1
                contentView.frame = contentViewFrame
            }, completion: { (finished) in
                // 记住一定要在适当的时机调用completion()
                completion?(finished)
            })
        }
        modalViewController.hidingAnimationClosure = { (dimmingView, containerBounds, keyboardHeight, completion) in
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveOut, animations: {
                dimmingView?.alpha = 0
                contentView.frame = contentView.frame.setY(containerBounds.height)
            }, completion: { (finished) in
                // 记住一定要在适当的时机调用completion()
                completion?(finished)
            })
        }
        modalViewController.show(true, completion: nil)
    }
    
    private func handleKeyboard() {
        let contentView = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 200))
        contentView.backgroundColor = UIColorWhite
        contentView.layer.cornerRadius = 6
        
        let contentViewPadding = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        let contentLimitWidth = contentView.bounds.width - contentViewPadding.horizontalValue
        
        let textField = QMUITextField(frame: CGRect(x: contentViewPadding.left, y: contentViewPadding.top, width: contentLimitWidth, height: 36))
        textField.placeholder = "请输入文字"
        textField.borderStyle = .roundedRect
        textField.font = UIFontMake(16)
        contentView.addSubview(textField)
        textField.becomeFirstResponder
        
        let label = UILabel()
        label.numberOfLines = 0
        
        let paragraphStyle = NSMutableParagraphStyle(lineHeight: 20)
        paragraphStyle.paragraphSpacing = 10
        let string = "如果你的浮层里有输入框，建议在把输入框添加到界面上后立即调用becomeFirstResponder（如果你用contentViewController，则在viewWillAppear:时调用becomeFirstResponder），以保证键盘跟随浮层一起显示。\n而在浮层消失时，modalViewController会自动降下键盘，所以你的浮层里并不需要处理。"
        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font : UIFontMake(12), NSAttributedString.Key.foregroundColor: UIColorGrayDarken, NSAttributedString.Key.paragraphStyle: paragraphStyle]
        let attributedString = NSMutableAttributedString(string: string, attributes: attributes)
        
        let codeAttributes = [NSAttributedString.Key.font : UIFontMake(12), NSAttributedString.Key.foregroundColor: (QDThemeManager.shared.currentTheme?.themeCodeColor ?? UIColorGrayDarken).withAlphaComponent(0.8)]
        attributedString.string.enumerateCodeString { (codeString, codeRange) -> () in
            attributedString.addAttributes(codeAttributes, range: codeRange)
        }
        label.attributedText = attributedString
        contentView.addSubview(label)
        
        let labelSize = label.sizeThatFits(CGSize(width: contentLimitWidth, height: CGFloat.greatestFiniteMagnitude))
        label.frame = CGRect(x: contentViewPadding.left, y: textField.frame.maxY + 8, width: contentLimitWidth, height: labelSize.height)
        
        contentView.frame = contentView.frame.setHeight(label.frame.maxY + contentViewPadding.bottom)
        
        let modalViewController = QMUIModalPresentationViewController()
        modalViewController.animationStyle = .slide
        modalViewController.contentView = contentView
        modalViewController.show(true, completion: nil)
    }
    
    private func handleWindowShowing() {
        let contentView = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 160))
        contentView.backgroundColor = UIColorWhite
        contentView.layer.cornerRadius = 6
        
        let label = UILabel()
        label.numberOfLines = 0
        
        let paragraphStyle = NSMutableParagraphStyle(lineHeight: 24)
        paragraphStyle.paragraphSpacing = 16
        let string = "QMUIModalPresentationViewController支持 3 种使用方式，当前使用第 1 种，注意状态栏被遮罩盖住了"
        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font : UIFontMake(16), NSAttributedString.Key.foregroundColor: UIColorBlack, NSAttributedString.Key.paragraphStyle: paragraphStyle]
        let attributedString = NSMutableAttributedString(string: string, attributes: attributes)
        let codeAttributes = CodeAttributes(16)
        attributedString.string.enumerateCodeString { (codeString, codeRange) -> () in
            attributedString.addAttributes(codeAttributes, range: codeRange)
        }
        
        label.attributedText = attributedString
        contentView.addSubview(label)
        
        let contentViewPadding = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        let contentLimitWidth = contentView.bounds.width - contentViewPadding.horizontalValue
        let labelSize = label.sizeThatFits(CGSize(width: contentLimitWidth, height: CGFloat.greatestFiniteMagnitude))
        label.frame = CGRect(x: contentViewPadding.left, y: contentViewPadding.top, width: contentLimitWidth, height: labelSize.height)
        
        let modalViewController = QMUIModalPresentationViewController()
        modalViewController.contentView = contentView
        // 以 UIWindow 的形式来展示
        modalViewController.show(true, completion: nil)
    }
    
    private func handlePresentShowing() {
        let contentView = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 160))
        contentView.backgroundColor = UIColorWhite
        contentView.layer.cornerRadius = 6
        
        let label = UILabel()
        label.numberOfLines = 0
        
        let paragraphStyle = NSMutableParagraphStyle(lineHeight: 24)
        paragraphStyle.paragraphSpacing = 16
        let string = "QMUIModalPresentationViewController支持 3 种使用方式，当前使用第 2 种，注意遮罩无法盖住屏幕顶部的状态栏。"
        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font : UIFontMake(16), NSAttributedString.Key.foregroundColor: UIColorBlack, NSAttributedString.Key.paragraphStyle: paragraphStyle]
        let attributedString = NSMutableAttributedString(string: string, attributes: attributes)
        let codeAttributes = CodeAttributes(16)
        attributedString.string.enumerateCodeString { (codeString, codeRange) -> () in
            attributedString.addAttributes(codeAttributes, range: codeRange)
        }
        
        label.attributedText = attributedString
        contentView.addSubview(label)
        
        let contentViewPadding = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        let contentLimitWidth = contentView.bounds.width - contentViewPadding.horizontalValue
        let labelSize = label.sizeThatFits(CGSize(width: contentLimitWidth, height: CGFloat.greatestFiniteMagnitude))
        label.frame = CGRect(x: contentViewPadding.left, y: contentViewPadding.top, width: contentLimitWidth, height: labelSize.height)
        
        let modalViewController = QMUIModalPresentationViewController()
        modalViewController.contentView = contentView
        // 以 presentViewController 的形式展示时，animated 要传 false，否则系统的动画会覆盖 QMUIModalPresentationAnimationStyle 的动画
        present(modalViewController, animated: false, completion: nil)
    }
    
    private func handleShowInView() {
        if let modalViewControllerForAddSubview = modalViewControllerForAddSubview  {
            modalViewControllerForAddSubview.hide(in: view, animated: true, completion: nil)
        }
        
        let modalRect = CGRect(x: 40, y: qmui_navigationBarMaxYInViewCoordinator + 40, width: view.bounds.width - 40 * 2, height: view.bounds.height - qmui_navigationBarMaxYInViewCoordinator - 40 * 2)
        
        let contentView = UIView(frame: CGRect(x: 0, y: 0, width: modalRect.width - 40, height: 200))
        contentView.backgroundColor = UIColorWhite
        contentView.layer.cornerRadius = 6
        
        modalViewControllerForAddSubview = QMUIModalPresentationViewController()
        guard let modalViewControllerForAddSubview = modalViewControllerForAddSubview else { return }
        modalViewControllerForAddSubview.contentView = contentView
        modalViewControllerForAddSubview.view.frame = modalRect
        // 以 addSubview 的形式显示，此时需要retain住modalPresentationViewController，防止提前被释放
        modalViewControllerForAddSubview.show(in: view, animated: true, completion: nil)
        
        let label = UILabel()
        label.numberOfLines = 0
        
        let paragraphStyle = NSMutableParagraphStyle(lineHeight: 24)
        paragraphStyle.paragraphSpacing = 16
        let string = "QMUIModalPresentationViewController支持 3 种使用方式，当前使用第 3 种，注意可以透过遮罩外的空白地方点击到背后的 cell"
        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font : UIFontMake(16), NSAttributedString.Key.foregroundColor: UIColorBlack, NSAttributedString.Key.paragraphStyle: paragraphStyle]
        let attributedString = NSMutableAttributedString(string: string, attributes: attributes)
        let codeAttributes = CodeAttributes(16)
        attributedString.string.enumerateCodeString { (codeString, codeRange) -> () in
            attributedString.addAttributes(codeAttributes, range: codeRange)
        }
        label.attributedText = attributedString
        contentView.addSubview(label)
        
        let contentViewPadding = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        let contentLimitWidth = contentView.bounds.width - contentViewPadding.horizontalValue
        let labelSize = label.sizeThatFits(CGSize(width: contentLimitWidth, height: CGFloat.greatestFiniteMagnitude))
        label.frame = CGRect(x: contentViewPadding.left, y: contentViewPadding.top, width: contentLimitWidth, height: labelSize.height)
    }
}

fileprivate class QDModalContentViewController: UIViewController {
    
    fileprivate lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = false
        return scrollView
    }()
    fileprivate lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = PixelOne
        imageView.layer.borderColor = UIColorSeparator.cgColor
        imageView.image = UIImageMake("image0")
        return imageView
    }()
    var textLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.numberOfLines = 0
        let paragraphStyle = NSMutableParagraphStyle(lineHeight: 24)
        paragraphStyle.paragraphSpacing = 16
        let string = "如果你的浮层是以UIViewController的形式存在的，那么就可以通过modalViewController.contentViewController属性来显示出来。\n利用UIViewController的特点，你可以方便地管理复杂的UI状态，并且响应设备在不同状态下的布局。\n例如这个例子里，图片和文字的排版会随着设备的方向变化而变化，你可以试着旋转屏幕看看效果。"
        let attributedString = NSMutableAttributedString(string: string, attributes: [NSAttributedString.Key.font : UIFontMake(16), NSAttributedString.Key.foregroundColor: UIColorBlack, NSAttributedString.Key.paragraphStyle: paragraphStyle])
        let codeAttributes = CodeAttributes(16)
        attributedString.string.enumerateCodeString {
            if $0 != "UI" {
                attributedString.addAttributes(codeAttributes, range: $1)
            }
        }
        textLabel.attributedText = attributedString
        return textLabel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColorWhite
        view.layer.cornerRadius = 6
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(textLabel)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let padding = UIEdgeInsets.init(top: 20, left: 20, bottom: 20, right: 20)
        let contentSize = CGSize(width: view.bounds.width - padding.horizontalValue, height: view.bounds.height - padding.verticalValue)
        scrollView.frame = view.bounds
        
        if IS_LANDSCAPE {
            // 横屏下图文水平布局
            let imageViewLimitWidth = contentSize.width / 3
            imageView.frame = imageView.frame.setXY(padding.left, padding.top)
            imageView.qmui_sizeToFitKeepingImageAspectRatio(in: CGSize(width: imageViewLimitWidth, height: CGFloat.greatestFiniteMagnitude))
            
            let textLabelMarginLeft: CGFloat = 20
            let textLabelLimitWidth = contentSize.width - imageView.frame.width - textLabelMarginLeft
            let textLabelSize = textLabel.sizeThatFits(CGSize(width: textLabelLimitWidth, height: CGFloat.greatestFiniteMagnitude))
            textLabel.frame = CGRect(x: imageView.frame.maxX + textLabelMarginLeft, y: padding.top - 6, width: textLabelLimitWidth, height: textLabelSize.height)
        } else {
            // 竖屏下图文垂直布局
            let imageViewLimitHeight: CGFloat = 120
            imageView.frame = CGRect(x: padding.left, y: padding.top, width: contentSize.width, height: imageViewLimitHeight)
            
            let textLabelMarginTop: CGFloat = 20
            let textLabelSize = textLabel.sizeThatFits(CGSize(width: contentSize.width, height: CGFloat.greatestFiniteMagnitude))
            textLabel.frame = CGRect(x: padding.left, y: imageView.frame.maxY + textLabelMarginTop, width: contentSize.width, height: textLabelSize.height)
        }
        
        scrollView.contentSize = CGSize(width: view.bounds.width, height: textLabel.frame.maxY + padding.bottom)
    }
}

extension QDModalContentViewController: QMUIModalPresentationContentViewControllerProtocol {
    func preferredContentSize(inModalPresentationViewController controller: QMUIModalPresentationViewController, limitSize: CGSize) -> CGSize {
        // 高度无穷大表示不显示高度，则默认情况下会保证你的浮层高度不超过QMUIModalPresentationViewController的高度减去contentViewMargins
        return CGSize(width: controller.view.bounds.width - controller.contentViewMargins.horizontalValue, height: CGFloat.greatestFiniteMagnitude)
    }
}
