//
//  QDAboutViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/4/2.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

class QDAboutViewController: QDCommonViewController {
    
    private lazy var themeAboutLogoImage: UIImage? = {
        var themeAboutLogoImage: UIImage?
        let key = userDefaultsKeyForAboutLogoImage
        if let imagePath = UserDefaults.standard.url(forKey: key) {
            do {
                let imageData = try Data(contentsOf: imagePath as URL)
                themeAboutLogoImage = UIImage(data: imageData)
                return themeAboutLogoImage
            } catch {
                return nil
            }
        }
        return nil
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    
    private lazy var logoImageView: UIImageView = {
        let defaultImage = UIImageMake("about_logo_monochrome")
        let logoImageView = UIImageView(image: themeAboutLogoImage ?? defaultImage)
        logoImageView.frame = logoImageView.frame.setSize(size: defaultImage!.size)
        return logoImageView
    }()
    
    private lazy var versionButton: QMUIButton = {
        let versionButton = QMUIButton()
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? ""
        versionButton.titleLabel?.font = UIFontMake(14)
        versionButton.setTitleColor(UIColorGray3, for: .normal)
        versionButton.setTitle("版本 \(appVersion)", for: .normal)
        versionButton.sizeToFit()
        versionButton.qmui_outsideEdge = UIEdgeInsets(top: -12, left: -12, bottom: -12, right: -12)
        versionButton.addTarget(self, action: #selector(handleVersionButtonEvent(_:)), for: .touchUpInside)
        return versionButton
    }()
    
    private lazy var websiteButton: QMUIButton = {
        let button = generateCellButton("访问官网")
        button.qmui_borderPosition = .top
        button.addTarget(self, action: #selector(handleWebsiteButtonEvent(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var documentButton: QMUIButton = {
        let button = generateCellButton("功能列表")
        button.qmui_borderPosition = .top
        button.addTarget(self, action: #selector(handleDocumentButtonEvent(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var gitHubButton: QMUIButton = {
        let button = generateCellButton("GitHub")
        button.qmui_borderPosition = [.top, .bottom]
        button.addTarget(self, action: #selector(handleGitHubButtonEvent(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var copyrightLabel: UILabel = {
        let copyrightLabel = UILabel()
        copyrightLabel.numberOfLines = 0
        let attributes = [NSAttributedStringKey.font : UIFontMake(12), NSAttributedStringKey.foregroundColor: UIColorGray5, NSAttributedStringKey.paragraphStyle: NSMutableParagraphStyle(lineHeight: 16, lineBreakMode: .byWordWrapping, textAlignment: .center)]
        copyrightLabel.attributedText = NSAttributedString(string: "© 2018 QMUI Team All Rights Reserved.", attributes: attributes)
        return copyrightLabel
    }()
    
    private lazy var userDefaultsKeyForAboutLogoImage: String = {
        let key = "about_logo_\(QDThemeManager.shared.currentTheme?.themeName ?? "")\(ScreenScale)x.png"
        return key
    }()
    
    override func didInitialized() {
        super.didInitialized()
        
        DispatchQueue.global().async {
            let aboutLogoImage = UIImageMake("about_logo_monochrome")
            if let currentTheme = QDThemeManager.shared.currentTheme, let blendedAboutLogoImage = aboutLogoImage?.qmui_image(blendColor: currentTheme.themeTintColor) {
                self.saveImageAsFile(blendedAboutLogoImage)
                DispatchQueue.main.async {
                    self.themeAboutLogoImage = blendedAboutLogoImage
                    
                    if self.logoImageView.image != self.themeAboutLogoImage {
                        let templateImageView = UIImageView(frame: self.logoImageView.bounds)
                        templateImageView.image = self.themeAboutLogoImage
                        templateImageView.alpha = 0
                        self.logoImageView.addSubview(templateImageView)
                        UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseOut, animations: {
                            templateImageView.alpha = 1
                        }) { (_) in
                            self.logoImageView.image = self.themeAboutLogoImage
                            templateImageView.removeFromSuperview()
                        }
                    }
                }
            }
        }
    }
    
    override func initSubviews() {
        super.initSubviews()
        
        view.addSubview(scrollView)
        scrollView.frame = view.bounds
        
        scrollView.addSubview(logoImageView)
        scrollView.addSubview(versionButton)
        scrollView.addSubview(websiteButton)
        scrollView.addSubview(documentButton)
        scrollView.addSubview(gitHubButton)
        scrollView.addSubview(copyrightLabel)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let navigationBarHeight = qmui_navigationBarMaxYInViewCoordinator
        let padding = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
        let versionLabelMarginTop: CGFloat = 10
        let buttonHeight = TableViewCellNormalHeight
        
        scrollView.frame = view.bounds.setHeight(view.bounds.height)
        
        if IS_IPHONE && IS_LANDSCAPE {
            let leftWidth = flat(scrollView.bounds.width / 2)
            let rightWidth = scrollView.bounds.width - leftWidth
            
            let leftHeight = logoImageView.frame.height + versionLabelMarginTop + versionButton.frame.height
            let leftMinY = (scrollView.bounds.height - navigationBarHeight).center(leftHeight)
            logoImageView.frame = logoImageView.frame.setXY(leftWidth.center(logoImageView.frame.height), leftMinY)
            versionButton.frame = versionButton.frame.setXY(logoImageView.frame.minXHorizontallyCenter(versionButton.frame), logoImageView.frame.maxY + versionLabelMarginTop)
            
            let contentWidthInRight = rightWidth - padding.horizontalValue
            websiteButton.frame = CGRect(x: leftWidth + padding.left, y: logoImageView.frame.minY + 10, width: contentWidthInRight, height: buttonHeight)
            documentButton.frame = websiteButton.frame.setY(websiteButton.frame.maxY)
            gitHubButton.frame = websiteButton.frame.setY(documentButton.frame.maxY)
            
            let copyrightLabelHeight = copyrightLabel.sizeThatFits(CGSize(width: contentWidthInRight, height: CGFloat.greatestFiniteMagnitude)).height
            copyrightLabel.frame = CGRectFlat(leftWidth + padding.left, scrollView.bounds.height - navigationBarHeight - padding.bottom - copyrightLabelHeight, contentWidthInRight, copyrightLabelHeight)
            
            scrollView.contentSize = CGSize(width: view.bounds.width, height: view.bounds.height - navigationBarHeight)
        } else {
            
            let containerHeight = scrollView.bounds.height - padding.verticalValue
            let buttonMarginTop: CGFloat = 36
            let mainContentHeight = logoImageView.frame.height + versionLabelMarginTop + versionButton.frame.height + buttonMarginTop + buttonHeight * 2
            let mainContentMinY = padding.top + (containerHeight - mainContentHeight) / 6
            
            logoImageView.frame = logoImageView.frame.setXY(logoImageView.frame.minXHorizontallyCenter(in: scrollView.bounds), mainContentMinY)
            
            versionButton.frame = versionButton.frame.setXY(versionButton.frame.minXHorizontallyCenter(in: scrollView.bounds), logoImageView.frame.maxY + versionLabelMarginTop)
            
            websiteButton.frame = CGRect(x: 0, y: versionButton.frame.maxY + buttonMarginTop, width: scrollView.bounds.width, height: buttonHeight)
            documentButton.frame = websiteButton.frame.setY(websiteButton.frame.maxY)
            gitHubButton.frame = documentButton.frame.setY(documentButton.frame.maxY)
            
            let copyrightLabelWidth = scrollView.bounds.width - padding.horizontalValue
            let copyrightLabelHeight = copyrightLabel.sizeThatFits(CGSize(width: copyrightLabelWidth, height: CGFloat.greatestFiniteMagnitude)).height
            copyrightLabel.frame = CGRectFlat(padding.left, scrollView.bounds.height - navigationBarHeight - padding.bottom - copyrightLabelHeight, copyrightLabelWidth, copyrightLabelHeight)
            
            scrollView.contentSize = CGSize(width: view.bounds.width, height: copyrightLabel.frame.maxY + padding.bottom)
        }
    }
    
    override func setupNavigationItems() {
        super.setupNavigationItems()
        title = "关于"
    }
    
    private func saveImageAsFile(_ image: UIImage) {
        let imageData = UIImagePNGRepresentation(image)
        let documentDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let imageName = userDefaultsKeyForAboutLogoImage
        let imagePath = documentDirectory.appendingPathComponent(imageName)
        do {
            try imageData?.write(to: imagePath, options: .atomic)
            UserDefaults.standard.set(imagePath, forKey: imageName)
        } catch {
            print(error)
        }
    }
    
    @objc func handleVersionButtonEvent(_ button: QMUIButton) {
        openUrl("https://github.com/QMUI/QMUI_iOS/releases")
    }
    
    @objc func handleWebsiteButtonEvent(_ button: QMUIButton) {
        openUrl("http://www.qmuiteam.com/ios")
    }
    
    @objc func handleDocumentButtonEvent(_ button: QMUIButton) {
        openUrl("http://qmuiteam.com/ios/page/document.html")
    }
    
    @objc func handleGitHubButtonEvent(_ button: QMUIButton) {
        openUrl("https://github.com/QMUI/QMUI_iOS")
    }
    
    private func openUrl(_ string: String) {
        guard let url = URL(string: string) else { return }
        if #available(iOS 10, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    private func generateCellButton(_ title: String) -> QMUIButton {
        let button = QMUIButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(TableViewCellTitleLabelColor ?? UIColorBlack, for: .normal)
        button.titleLabel?.font = UIFontMake(15)
        button.highlightedBackgroundColor = TableViewCellSelectedBackgroundColor
        button.qmui_borderColor = TableViewSeparatorColor
        button.contentHorizontalAlignment = .left
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        button.qmui_automaticallyAdjustTouchHighlightedInScrollView = true
        return button
    }
    
    deinit {
        print("\(type(of: self))  deinit")
    }
}
