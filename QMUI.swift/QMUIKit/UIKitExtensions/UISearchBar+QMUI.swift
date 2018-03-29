//
//  UISearchBar+QMUI.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/5/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

extension UISearchBar: SelfAware2 {
    private static let _onceToken = UUID().uuidString

    static func awake2() {
        DispatchQueue.once(token: _onceToken) {
            let selectors = [
                #selector(setter: placeholder),
                #selector(layoutSubviews),
                #selector(setter: frame),
            ]
            selectors.forEach({
                //                print("qmui_" + $0.description)
                ReplaceMethod(self, $0, Selector("qmui_" + $0.description))
            })
        }
    }

    @objc open func qmui_setPlaceholder(_ newPlaceholder: String?) {
        qmui_setPlaceholder(newPlaceholder)

        guard let _ = newPlaceholder else {
            return
        }

        var attributes = [NSAttributedStringKey: Any]()
        attributes[NSAttributedStringKey.foregroundColor] = qmui_placeholderColor
        attributes[NSAttributedStringKey.font] = qmui_font
        qmui_textField()?.attributedPlaceholder = NSAttributedString(string: newPlaceholder!, attributes: attributes)
    }

    @objc open func qmui_layoutSubviews() {
        qmui_layoutSubviews()

        fixLandscapeStyle()
        fixSafeAreaInsetsStyle()

        if !UIEdgeInsetsEqualToEdgeInsets(qmui_textFieldMargins, UIEdgeInsets.zero) {
            if let newFrame = qmui_textField()?.frame.insetEdges(qmui_textFieldMargins) {
                qmui_textField()?.frame = newFrame
            }
        }

        fix58InchScreenStyle()
    }

    @objc open func qmui_setFrame(_ frame: CGRect) {

        var newFrame = frame

        if !qmui_usedAsTableHeaderView {
            qmui_setFrame(newFrame)
            return
        }

        // 重写 setFrame: 是为了这个 issue：https://github.com/QMUI/QMUI_iOS/issues/233
        if #available(iOS 11.0, *) {
            // iOS 11 下用 tableHeaderView 的方式使用 searchBar 的话，进入搜索状态时 y 偏上了，导致间距错乱
            if !qmui_isActive() {
                qmui_setFrame(newFrame)
                return
            }

            if IS_58INCH_SCREEN {
                // 竖屏
                if newFrame.minY == 38 {
                    // searching
                    newFrame.setY(44)
                }

                // 横屏
                if newFrame.minY == -6 {
                    newFrame.setY(0)
                }
            } else {
                // 竖屏
                if newFrame.minY == 14 {
                    newFrame.setY(20)
                }

                // 横屏
                if newFrame.minY == -6 {
                    newFrame.setY(0)
                }
            }

            if layer.animationKeys() != nil {
                // 这一段是为了修复进入/退出搜索状态时的抖动
                if superview?.frame.height == (frame.height + StatusBarHeight) && !showsScopeBar {
                    newFrame.setHeight(56)
                }
            }
        }

        qmui_setFrame(newFrame)
    }

    private func fixLandscapeStyle() {
        if !qmui_usedAsTableHeaderView {
            return
        }
        guard #available(iOS 11.0, *) else {
            return
        }
        guard qmui_isActive() && IS_LANDSCAPE else {
            return
        }
        // 11.0 及以上的版本，横屏时，searchBar 内部的内容布局会偏上，所以这里强制居中一下
        qmui_textField()?.frame.setY(qmui_textField()?.qmui_minYWhenCenterInSuperview ?? 0)
        qmui_cancelButton()?.frame.setY(qmui_cancelButton()?.qmui_minYWhenCenterInSuperview ?? 0)
        if let superView = qmui_segmentedControl()?.superview, let bottom = qmui_textField()?.frame.maxY {
            if superView.frame.minY < bottom { // scopeBar 显示在搜索框右边
                let y = superView.bounds.height.center(with: superView.frame.height)
                superView.frame.setY(y)
            }
        }
    }

    private func fixSafeAreaInsetsStyle() {
        if !qmui_usedAsTableHeaderView {
            return
        }
        guard #available(iOS 11.0, *) else {
            return
        }
        // [11.0, 11.1) 这个范围内的 iOS 版本在以 tableHeaderView 的方式使用 searchBar 时，不会根据 safeAreaInsets 自动调整输入框的布局，所以手动处理一下
        if IOS_VERSION >= 11.1 {
            return
        }
        if var newframe = qmui_cancelButton()?.frame {
            _ = newframe.setX(newframe.minX - safeAreaInsets.left)
        }

        var isBelow = false
        if let superView = qmui_segmentedControl()?.superview, let bottom = qmui_textField()?.frame.maxY {
            if superView.frame.minY < bottom {
                isBelow = true
            }
        }
        let isScopeBarShowingAtRightOfTextField = IS_LANDSCAPE && qmui_isActive() && showsScopeBar && isBelow

        let newLeft = qmui_textField()?.frame.minX ?? 0 + safeAreaInsets.left
        _ = qmui_textField()?.frame.setX(newLeft)

        if isScopeBarShowingAtRightOfTextField {
            // 如果 scopeBar 显示在搜索框右边，则搜索框右边不用调整
            let scopeBarHorizontalMargin: CGFloat = 16

            let newLeft = max(qmui_textField()?.frame.maxX ?? 0 + scopeBarHorizontalMargin, qmui_segmentedControl()?.superview?.frame.minX ?? 0)
            var newWidth = qmui_segmentedControl()?.superview?.frame.maxX ?? 0 - newLeft
            _ = qmui_segmentedControl()?.superview?.frame.setX(newLeft)
            _ = qmui_segmentedControl()?.superview?.frame.setWidth(newWidth)

            let newRight = min(qmui_cancelButton()?.frame.minX ?? 0 - scopeBarHorizontalMargin, qmui_segmentedControl()?.superview?.frame.maxX ?? 0)
            newWidth = newRight - (qmui_segmentedControl()?.superview?.frame.minX ?? 0)
            _ = qmui_segmentedControl()?.superview?.frame.setWidth(newWidth)
        } else {
            // 如果 scopeBar 显示在搜索框下方，则搜索框右边要调整到不与 safeAreaInsets 重叠
            let newRight = qmui_textField()?.frame.maxX ?? 0 - safeAreaInsets.right
            let newWidth = newRight - (qmui_textField()?.frame.minX ?? 0)
            qmui_textField()?.frame.setWidth(newWidth)
        }

        // 如果是没进入搜索状态就已经显示了 scopeBar，则此时的 scopeBar 一定是在搜索框下方的
        if !qmui_isActive() && showsScopeBar {
            let newLeft = qmui_segmentedControl()?.frame.minX ?? 0 + safeAreaInsets.left
            var newWidth = qmui_segmentedControl()?.frame.maxX ?? 0 - newLeft
            _ = qmui_segmentedControl()?.frame.setX(newLeft)
            _ = qmui_segmentedControl()?.frame.setWidth(newWidth)

            let newRight = qmui_segmentedControl()?.frame.maxX ?? 0 - safeAreaInsets.right
            newWidth = newRight - (qmui_segmentedControl()?.frame.minX ?? 0)
            qmui_segmentedControl()?.frame.setWidth(newWidth)
        }
    }

    private func fix58InchScreenStyle() {
        if !qmui_usedAsTableHeaderView {
            return
        }

        guard #available(iOS 11.0, *) else {
            return
        }
        // [11.0, 11.1) 范围内的 iOS 版本才会有问题 https://github.com/QMUI/QMUI_iOS/issues/233
        if IOS_VERSION >= 11.1 {
            return
        }
        if !IS_58INCH_SCREEN {
            return
        }

        guard let backgroundView = qmui_backgroundView() else {
            return
        }

        let isActive = backgroundView.superview?.clipsToBounds ?? false
        let isFrameError = backgroundView.safeAreaInsets.top > 0 && (backgroundView.frame.minY == 0)
        guard isActive && isFrameError else {
            return
        }
        // 修改 backgroundView.frame 会导致 searchBar 在进入搜索状态后背景色变成系统默认的（不知道为什么），所以先取出背景图存起来再设置回去
        if let originImage = backgroundView.layer.contents {
            backgroundView.frame.setY(-backgroundView.safeAreaInsets.top)
            let newHeight = backgroundView.frame.maxY - (-backgroundView.safeAreaInsets.top)
            _ = backgroundView.frame.setHeight(newHeight)
            backgroundView.layer.contents = originImage
        }
    }

    private func qmui_isActive() -> Bool {
        // 某些情况下 scopeBar 是显示在搜索框右边的，所以要区分判断
        var scopeBarHeight = qmui_segmentedControl()?.superview?.frame.height ?? 0

        if let superView = qmui_segmentedControl()?.superview, let bottom = qmui_textField()?.frame.maxY {
            if superView.frame.minY < bottom {
                scopeBarHeight = 0
            }
        }
        let result = (frame.height - scopeBarHeight == 50)
        return result
    }
}

extension UISearchBar {

    private struct AssociatedKeys {
        static var kUsedAsTableHeaderView = "kUsedAsTableHeaderView"
        static var kPlaceholderColor = "kPlaceholderColor"
        static var kFont = "kFont"
        static var kTextFieldMargins = "kTextFieldMargins"
        static var kTextColor = "kTextColor"
    }

    /// 当以 tableHeaderView 的方式使用 UISearchBar 时，建议将这个属性置为 YES，从而可以帮你处理 https://github.com/QMUI/QMUI_iOS/issues/233 里列出的问题（抖动、iPhone X 适配等）
    /// 默认值为 false
    public var qmui_usedAsTableHeaderView: Bool {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.kUsedAsTableHeaderView) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.kUsedAsTableHeaderView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    public var qmui_placeholderColor: UIColor? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.kPlaceholderColor) as? UIColor
        }
        set {
            if let value = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.kPlaceholderColor, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                if placeholder != nil {
                    // 触发 setPlaceholder 里更新 placeholder 样式的逻辑
                    let holder = placeholder
                    placeholder = holder
                }
            }
        }
    }

    public var qmui_textColor: UIColor? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.kTextColor) as? UIColor
        }
        set {
            if let value = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.kTextColor, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                qmui_textField()?.textColor = value
            }
        }
    }

    public var qmui_font: UIFont? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.kFont) as? UIFont
        }
        set {
            if let value = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.kFont, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                if placeholder != nil {
                    // 触发 setPlaceholder 里更新 placeholder 样式的逻辑
                    let holder = placeholder
                    placeholder = holder
                }

                // 更新输入框的文字样式
                qmui_textField()?.font = value
            }
        }
    }

    public func qmui_textField() -> UITextField? {
        if let textField = value(forKey: "searchField") {
            return textField as? UITextField
        }
        return nil
    }

    public var qmui_textFieldMargins: UIEdgeInsets {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.kTextFieldMargins) as? UIEdgeInsets ?? UIEdgeInsets.zero
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.kTextFieldMargins, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /// 获取 searchBar 内的取消按钮
    public func qmui_cancelButton() -> UIButton? {
        if let button = value(forKey: "cancelButton") {
            return button as? UIButton
        }
        return nil
    }

    /// 获取 scopeBar 里的 UISegmentedControl
    public func qmui_segmentedControl() -> UISegmentedControl? {
        // 注意，segmentedControl 只是整条 scopeBar 里的一部分，虽然它的 key 叫做“scopeBar”
        if let segmentedControl = value(forKey: "scopeBar") {
            return segmentedControl as? UISegmentedControl
        }
        return nil
    }

    public func qmui_backgroundView() -> UIView? {
        if let backgroundView = value(forKey: "background") {
            return backgroundView as? UIView
        }
        return nil
    }

    public func qmui_styledAsQMUISearchBar() {
        // 搜索框的字号及 placeholder 的字号
        if let font = SearchBarFont {
            qmui_font = font
        }

        // 搜索框的文字颜色
        if let textColor = SearchBarTextColor {
            qmui_textColor = textColor
        }

        // placeholder 的文字颜色
        qmui_placeholderColor = SearchBarPlaceholderColor

        placeholder = "搜索"
        autocorrectionType = .no
        autocapitalizationType = .none
        searchTextPositionAdjustment = UIOffset(horizontal: 5, vertical: 0)

        // 设置搜索icon
        if let searchIconImage = SearchBarSearchIconImage {
            if !searchIconImage.size.equalTo(CGSize(width: 13, height: 13)) {
                QMUILog("搜索框放大镜图片（SearchBarSearchIconImage）的大小最好为 (13, 13)，否则会失真，目前的大小为 \(NSStringFromCGSize(CGSize(width: 13, height: 23)))")
            }
            setImage(searchIconImage, for: .search, state: .normal)
        }

        // 设置搜索右边的清除按钮的icon
        if let clearIconImage = SearchBarClearIconImage {
            setImage(clearIconImage, for: .clear, state: .normal)
        }

        // 设置SearchBar上的按钮颜色
        tintColor = SearchBarTintColor

        // 输入框背景图
        if let textFieldBackgroundColor = SearchBarTextFieldBackground {
            var image = UIImage.qmui_image(color: textFieldBackgroundColor, size: CGSize(width: 60, height: 28), cornerRadius: SearchBarTextFieldCornerRadius)
            image = image?.qmui_image(borderColor: textFieldBackgroundColor, borderWidth: PixelOne, cornerRadius: SearchBarTextFieldCornerRadius)
            image?.resizableImage(withCapInsets: UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14))
            setSearchFieldBackgroundImage(image, for: .normal)
        }

        // 整条bar的背景
        // 为了让 searchBar 底部的边框颜色支持修改，背景色不使用 barTintColor 的方式去改，而是用 backgroundImage
        var backgroundImage: UIImage? = nil
        if let barTintColor = SearchBarBarTintColor {
            backgroundImage = UIImage.qmui_image(color: barTintColor, size: CGSize(width: 10, height: 10), cornerRadius: 0)
        }
        
        if let bottomBorderColor = SearchBarBottomBorderColor {
            if backgroundImage != nil {
                backgroundImage = UIImage.qmui_image(color: UIColorWhite, size: CGSize(width: 10, height: 10), cornerRadius: 0)
            }
            backgroundImage = backgroundImage?.qmui_image(borderColor: bottomBorderColor, borderWidth: PixelOne, borderPosition: .bottom)
        }

        if backgroundImage != nil {
            backgroundImage = backgroundImage?.resizableImage(withCapInsets: UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1))
            setBackgroundImage(backgroundImage, for: .any, barMetrics: .default)
            setBackgroundImage(backgroundImage, for: .any, barMetrics: .defaultPrompt)
        }
    }
}
