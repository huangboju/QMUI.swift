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
    private(set) var titleLabel: UILabel!
    public var title: String?

    private(set) var subtitleLabel: UILabel!
    public var subtitle: String?
    
    /// 水平布局下的标题字体，默认为 NavBarTitleFont
    public var  horizontalTitleFont = NavBarTitleFont

    /// 水平布局下的副标题的字体，默认为 NavBarTitleFont
    public var horizontalSubtitleFont = NavBarTitleFont

    /// 垂直布局下的标题字体，默认为 UIFontMake(15)
    public var verticalTitleFont = UIFontMake(15)

    /// 垂直布局下的副标题字体，默认为 UIFontLightMake(12)
    public var verticalSubtitleFont = UIFontLightMake(12)

    /// 标题的上下左右间距，当标题不显示时，计算大小及布局时也不考虑这个间距，默认为 UIEdgeInsetsZero
    public var titleEdgeInsets = UIEdgeInsets.zero

    /// 副标题的上下左右间距，当副标题不显示时，计算大小及布局时也不考虑这个间距，默认为 UIEdgeInsetsZero
    public var subtitleEdgeInsets = UIEdgeInsets.zero
    
    
    // MARK: - Loading
    
    public private(set) var loadingView: UIActivityIndicatorView?
    
    /*
     *  设置是否需要loading，只有开启了这个属性，loading才有可能显示出来。默认值为false。
     */
    public var needsLoadingView = false
    
    /*
     *  `needsLoadingView`开启之后，通过这个属性来控制loading的显示和隐藏，默认值为YES
     *
     *  @see needsLoadingView
     */
    public var loadingViewHidden = true
    
    /*
     *  如果为true则title居中，loading放在title的左边，title右边有一个跟左边loading一样大的占位空间；如果为false，loading和title整体居中。默认值为true。
     */
    public var needsLoadingPlaceholderSpace = true
    
    public var loadingViewSize = CGSize.zero
    
    /*
     *  控制loading距离右边的距离
     */
    public var loadingViewMarginRight: CGFloat = 0
    
    
    // MARK: - Accessory

    /*
     *  当accessoryView不为空时，QMUINavigationTitleViewAccessoryType设置无效，一直都是None
     */
    public var accessoryView: UIView?

    /*
     *  只有当accessoryView为空时才有效
     */
    public var accessoryType: QMUINavigationTitleViewAccessoryType = .none

    /*
     *  用于微调accessoryView的位置
     */
    public var accessoryViewOffset: CGPoint = .zero
    
    /*
     *  如果为true则title居中，`accessoryView`放在title的左边或右边；如果为false，`accessoryView`和title整体居中。默认值为false。
     */
    public var needsAccessoryPlaceholderSpace = false

    private var accessoryViewAnimating = false
    private var titleLabelSize: CGSize = .zero
    private var subtitleLabelSize: CGSize = .zero
    private var accessoryTypeView: UIImageView?

    
    convenience override init(frame: CGRect) {
        self.init(style: .`default` , frame: frame)
    }

    convenience init(style: QMUINavigationTitleViewStyle) {
        self.init(style: style, frame: .zero)
    }
    
    init(style: QMUINavigationTitleViewStyle, frame: CGRect) {
        super.init(frame: frame)
        
        addTarget(self, action: #selector(handleTouchTitleViewEvent), for: .touchUpInside)
        
        titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.lineBreakMode = .byTruncatingTail
        addSubview(titleLabel)

        subtitleLabel = UILabel()
        subtitleLabel.textAlignment = .center
        subtitleLabel.lineBreakMode = .byTruncatingTail
        addSubview(subtitleLabel)
        
        isUserInteractionEnabled = false
        contentHorizontalAlignment = .center
        self.style = style

//        let appearance = QMUINavigationTitleView.appearance
//        loadingViewSize = appearance.loadingViewSize
//        loadingViewMarginRight = appearance.loadingViewMarginRight
//        horizontalTitleFont = appearance.horizontalTitleFont
//        horizontalSubtitleFont = appearance.horizontalSubtitleFont
//        verticalTitleFont = appearance.verticalTitleFont
//        verticalSubtitleFont = appearance.verticalSubtitleFont
//        accessoryViewOffset = appearance.accessoryViewOffset
        tintColor = NavBarTitleColor
    }
    
    // MARK: - Events
    
//    func setHighlighted:(BOOL)highlighted {
//    [super setHighlighted:highlighted];
//    self.alpha = highlighted ? UIControlHighlightedAlpha : 1;
//    }
    
    func handleTouchTitleViewEvent() {
//        BOOL active = !self.active;
//        if ([self.delegate respondsToSelector:@selector(didTouchTitleView:isActive:)]) {
//            [self.delegate didTouchTitleView:self isActive:active];
//        }
//        self.active = active;
//        [self refreshLayout];
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UINavigationBar {
    private static let _onceToken = UUID().uuidString

    open override class func initialize() {
        DispatchQueue.once(token: _onceToken) {
            ReplaceMethod(self, #selector(layoutSubviews), #selector(qmui_navigationBarLayoutSubviews))
        }
    }

    func qmui_navigationBarLayoutSubviews() {
        var titleView = topItem?.titleView as? QMUINavigationTitleView

        if let titleView = titleView {
            let titleViewMaximumWidth = titleView.bounds.width // 初始状态下titleView会被设置为UINavigationBar允许的最大宽度

            var titleViewSize = titleView.sizeThatFits(CGSize(width: titleViewMaximumWidth, height: CGFloat.greatestFiniteMagnitude))
            titleViewSize.height = ceil(titleViewSize.height) // titleView的高度如果非pt整数，会导致计算出来的y值时多时少，所以干脆做一下pt取整，这个策略不要改，改了要重新测试push过程中titleView是否会跳动

            // 当在UINavigationBar里使用自定义的titleView时，就算titleView的sizeThatFits:返回正确的高度，navigationBar也不会帮你设置高度（但会帮你设置宽度），所以我们需要自己更新高度并且修正y值
            if titleView.bounds.height != titleViewSize.height {
                //            NSLog(@"【%@】修正布局前\ntitleView = %@", NSStringFromClass(titleView.class), titleView);
                let titleViewMinY = flat(titleView.frame.minY - ((titleViewSize.height - titleView.bounds.height) / 2.0))// 系统对titleView的y值布局是flat，注意，不能改，改了要测试
                titleView.frame = CGRect(x: titleView.frame.minX, y: titleViewMinY, width: CGFloat(fminf(Float(titleViewMaximumWidth), Float(titleViewSize.width))), height: titleViewSize.height)
                //            NSLog(@"【%@】修正布局后\ntitleView = %@", NSStringFromClass(titleView.class), titleView);
            }
        } else {
            titleView = nil
        }
        
        qmui_navigationBarLayoutSubviews()
    
        if titleView != nil {
            //        NSLog(@"【%@】系统布局后\ntitleView = %@", NSStringFromClass(titleView.class), titleView);
        }
    }
}
