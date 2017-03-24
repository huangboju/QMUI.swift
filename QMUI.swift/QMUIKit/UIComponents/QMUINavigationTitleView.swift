//
//  QMUINavigationTitleView.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/1/17.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

protocol QMUINavigationTitleViewDelegate: class {
    /**
     点击 titleView 后的回调，只需设置 titleView.userInteractionEnabled = YES 后即可使用。不过一般都用于配合 QMUINavigationTitleViewAccessoryTypeDisclosureIndicator。
     
     @param titleView 被点击的 titleView
     @param isActive titleView 是否处于活跃状态（所谓的活跃，对应右边的箭头而言，就是点击后箭头向上的状态）
     */
    func didTouch(titleView: QMUINavigationTitleView, isActive: Bool)

    /**
     titleView 的活跃状态发生变化时会被调用，也即 [titleView setActive:] 被调用时。
     
     @param active 是否处于活跃状态
     @param titleView 变换状态的 titleView
     */
    func didChanged(active: Bool, for titleView: QMUINavigationTitleView)
}

extension QMUINavigationTitleViewDelegate {
    func didTouch(titleView: QMUINavigationTitleView, isActive: Bool) {}
    func didChanged(active: Bool, for titleView: QMUINavigationTitleView) {}
}

/// 设置title和subTitle的布局方式，默认是水平布局。
enum QMUINavigationTitleViewStyle {
    case `default`                // 水平
    case subTitleVertical        // 垂直
}

/// 设置titleView的样式，默认没有任何修饰
enum QMUINavigationTitleViewAccessoryType {
    case none                     // 默认
    case disclosureIndicator     // 有下拉箭头
}

/**
 *  可作为navgationItem.titleView 的标题控件。
 *
 *  支持主副标题，且可控制主副标题的布局方式（水平或垂直）；支持在左边显示loading，在右边显示accessoryView（如箭头）。
 *
 *  默认情况下 titleView 是不支持点击的，需要支持点击的情况下，请把 `userInteractionEnabled` 设为 `YES`。
 *
 *  若要监听 titleView 的点击事件，有两种方法：
 *
 *  1. 使用 UIControl 默认的 addTarget:action:forControlEvents: 方式。这种适用于单纯的点击，不需要涉及到状态切换等。
 *  2. 使用 QMUINavigationTitleViewDelegate 提供的接口。这种一般配合 titleView.accessoryType 来使用，这样就不用自己去做 accessoryView 的旋转、active 状态的维护等。
 */

class QMUINavigationTitleView: UIControl {
    public weak var delegate: QMUINavigationTitleViewDelegate?
    public var style: QMUINavigationTitleViewStyle = .default
    public var isActive = false

    // MARK: - Titles
    private(set) var titleLabel: UILabel?
    public var title: String?

    private(set) var subtitleLabel: UILabel
    public var subtitle: String?
    
    /// 水平布局下的标题字体，默认为 NavBarTitleFont
    var  horizontalTitleFont = NavBarTitleFont

    /// 水平布局下的副标题的字体，默认为 NavBarTitleFont
    var horizontalSubtitleFont = NavBarTitleFont

    /// 垂直布局下的标题字体，默认为 UIFontMake(15)
    var verticalTitleFont = UIFontMake(15)

    /// 垂直布局下的副标题字体，默认为 UIFontLightMake(12)
    var verticalSubtitleFont = UIFontLightMake(12)

    /// 标题的上下左右间距，当标题不显示时，计算大小及布局时也不考虑这个间距，默认为 UIEdgeInsetsZero
    var titleEdgeInsets = UIEdgeInsets.zero

    /// 副标题的上下左右间距，当副标题不显示时，计算大小及布局时也不考虑这个间距，默认为 UIEdgeInsetsZero
    var subtitleEdgeInsets = UIEdgeInsets.zero
}
