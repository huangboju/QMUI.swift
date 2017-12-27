//
//  UISearchBar+QMUI.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/5/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

extension UISearchBar: SelfAware {
    private static let _onceToken = UUID().uuidString
    
    static func awake() {
        DispatchQueue.once(token: _onceToken) {
            let selectors = [
                #selector(setter: placeholder)
            ]
            selectors.forEach({
                print("qmui_" + $0.description)
                ReplaceMethod(self, $0, Selector("qmui_" + $0.description))
            })
        }
    }
    
    open func qmui_setPlaceholder(_ newPlaceholder: String?) {
        guard let holder = newPlaceholder else {
            return
        }
        
        if (qmui_placeholderColor != nil || qmui_font != nil) {
            var attributes[String: String] = []
        }
        
        qmui_setPlaceholder(holder)
        
        
    }
}

extension UISearchBar {
    
    private struct AssociatedKeys {
        static var kUsedAsTableHeaderView = "kUsedAsTableHeaderView"
        static var kPlaceholderColor = "kPlaceholderColor"
        static var kFont = "kFont"
    }

    /// 当以 tableHeaderView 的方式使用 UISearchBar 时，建议将这个属性置为 YES，从而可以帮你处理 https://github.com/QMUI/QMUI_iOS/issues/233 里列出的问题（抖动、iPhone X 适配等）
    /// 默认值为 NO
    public var qmui_usedAsTableHeaderView: Bool? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.kUsedAsTableHeaderView) as? Bool ?? false
        }
        set {
            if let value = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.kUsedAsTableHeaderView, value, .OBJC_ASSOCIATION_ASSIGN)
            }
        }
    }
    
    public var qmui_placeholderColor: UIColor? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.kPlaceholderColor) as? UIColor
        }
        set {
            if let value = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.kPlaceholderColor, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                if (placeholder != nil) {
                    // 触发 setPlaceholder 里更新 placeholder 样式的逻辑
//                    self.placeholder = self.placeholder
                }
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
                if (placeholder != nil) {
                    // 触发 setPlaceholder 里更新 placeholder 样式的逻辑
                    //                    self.placeholder = self.placeholder
                }
                
                // 更新输入框的文字样式
                self.qmui_textField().font = value;
            }
        }
    }
    
    public func qmui_textField() -> UITextField {
        let textField = value(forKey: "searchField") as! UITextField
        return textField
    }

    func qmui_styledAsQMUISearchBar() {
        //        self.qmui_textColor = SearchBarTextColor;
        //        self.qmui_placeholderColor = SearchBarPlaceholderColor;
        //        self.placeholder = @"搜索";
        //        self.autocorrectionType = UITextAutocorrectionTypeNo;
        //        self.autocapitalizationType = UITextAutocapitalizationTypeNone;
        //        self.searchTextPositionAdjustment = UIOffsetMake(5, 0);
        //
        //        // 设置搜索icon
        //        UIImage *searchIconImage = SearchBarSearchIconImage;
        //        if (searchIconImage) {
        //            if (!CGSizeEqualToSize(searchIconImage.size, CGSizeMake(13, 13))) {
        //                QMUILog(@"搜索框放大镜图片（SearchBarSearchIconImage）的大小最好为 (13, 13)，否则会失真，目前的大小为 %@", NSStringFromCGSize(searchIconImage.size));
        //            }
        //            [self setImage:searchIconImage forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
        //        }
        //
        //        // 设置搜索右边的清除按钮的icon
        //        UIImage *clearIconImage = SearchBarClearIconImage;
        //        if (clearIconImage) {
        //            [self setImage:clearIconImage forSearchBarIcon:UISearchBarIconClear state:UIControlStateNormal];
        //        }
        //
        //        // 设置SearchBar上的按钮颜色
        //        self.tintColor = SearchBarTintColor;
        //
        //        // 输入框背景图
        //        UIColor *textFieldBackgroundColor = SearchBarTextFieldBackground;
        //        if (textFieldBackgroundColor) {
        //            [self setSearchFieldBackgroundImage:[[[UIImage qmui_imageWithColor:SearchBarTextFieldBackground size:CGSizeMake(60, 28) cornerRadius:SearchBarTextFieldCornerRadius] qmui_imageWithBorderColor:SearchBarTextFieldBorderColor borderWidth:PixelOne cornerRadius:SearchBarTextFieldCornerRadius] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 14, 14, 14)] forState:UIControlStateNormal];
        //        }
        //
        //        // 整条bar的背景
        //        // iOS7及以后不用barTintColor设置背景是因为这么做的话会出现上下border，去不掉，所以iOS6和7都改为用backgroundImage实现
        //        UIColor *barTintColor = SearchBarBarTintColor;
        //        if (barTintColor) {
        //            UIImage *backgroundImage = [[[UIImage qmui_imageWithColor:SearchBarBarTintColor size:CGSizeMake(10, 10) cornerRadius:0] qmui_imageWithBorderColor:SearchBarBottomBorderColor borderWidth:PixelOne borderPosition:QMUIImageBorderPositionBottom] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
        //            [self setBackgroundImage:backgroundImage forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        //        }
    }
}
