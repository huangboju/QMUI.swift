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
    public var style: QMUINavigationTitleViewStyle = .default {
        didSet {
            if style == .subTitleVertical {
                titleLabel.font = verticalTitleFont
                updateTitleLabelSize()
                
                subtitleLabel.font = verticalSubtitleFont
                updateSubtitleLabelSize()
            } else {
                titleLabel.font = horizontalTitleFont
                updateTitleLabelSize()

                subtitleLabel.font = horizontalSubtitleFont
                updateSubtitleLabelSize()
            }
            refreshLayout()
        }
    }
    public var isActive = false {
        didSet {
            delegate?.didChanged(active: isActive, for: self)
            guard accessoryType == .disclosureIndicator else { return }
            // 目前只对默认的accessoryView添加动画
            accessoryViewAnimating = true
            let angle: CGFloat = isActive ? -180 : 0.1
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
                self.accessoryTypeView?.transform = CGAffineTransform(rotationAngle: AngleWithDegrees(angle))
            }, completion: { (finished) in
                self.accessoryViewAnimating  = false
            })
        }
    }

    // MARK: - Titles
    private(set) var titleLabel: UILabel!
    public var title: String? {
        didSet {
            titleLabel.text = title
            updateTitleLabelSize()
            refreshLayout()
        }
    }

    private(set) var subtitleLabel: UILabel!
    public var subtitle: String? {
        didSet {
            titleLabel.text = subtitle
            updateTitleLabelSize()
            refreshLayout()
        }
    }

    /// 水平布局下的标题字体，默认为 NavBarTitleFont
    public var  horizontalTitleFont = NavBarTitleFont {
        didSet {
            guard style == .default else { return }
            titleLabel.font = horizontalTitleFont
            updateTitleLabelSize()
            refreshLayout()
        }
    }

    /// 水平布局下的副标题的字体，默认为 NavBarTitleFont
    public var horizontalSubtitleFont = NavBarTitleFont {
        didSet {
            guard style == .default else { return }
            subtitleLabel.font = horizontalSubtitleFont
            updateSubtitleLabelSize()
            refreshLayout()
        }
    }

    /// 垂直布局下的标题字体，默认为 UIFontMake(15)
    public var verticalTitleFont = UIFontMake(15) {
        didSet {
            guard style == .subTitleVertical else { return }
            titleLabel.font = verticalTitleFont
            updateTitleLabelSize()
            refreshLayout()
        }
    }

    /// 垂直布局下的副标题字体，默认为 UIFontLightMake(12)
    public var verticalSubtitleFont = UIFontLightMake(12) {
        didSet {
            guard style == .subTitleVertical else { return }
            titleLabel.font = verticalSubtitleFont
            updateTitleLabelSize()
            refreshLayout()
        }
    }

    /// 标题的上下左右间距，当标题不显示时，计算大小及布局时也不考虑这个间距，默认为 UIEdgeInsetsZero
    public var titleEdgeInsets = UIEdgeInsets.zero {
        didSet {
            refreshLayout()
        }
    }

    /// 副标题的上下左右间距，当副标题不显示时，计算大小及布局时也不考虑这个间距，默认为 UIEdgeInsetsZero
    public var subtitleEdgeInsets = UIEdgeInsets.zero {
        didSet {
            refreshLayout()
        }
    }
    
    
    // MARK: - Loading
    
    public private(set) var loadingView: UIActivityIndicatorView?
    
    /*
     *  设置是否需要loading，只有开启了这个属性，loading才有可能显示出来。默认值为false。
     */
    public var needsLoadingView = false {
        didSet {
            if needsLoadingView {
                if loadingView == nil {
                    loadingView = UIActivityIndicatorView(activityIndicatorStyle: NavBarActivityIndicatorViewStyle, size: loadingViewSize)
                    loadingView?.color = tintColor
                    loadingView?.stopAnimating()
                    addSubview(loadingView!)
                }
            } else {
                if let loadingView = loadingView {
                    loadingView.stopAnimating()
                    loadingView.removeFromSuperview()
                    self.loadingView = nil
                }
            }
            refreshLayout()
        }
    }
    
    /*
     *  `needsLoadingView`开启之后，通过这个属性来控制loading的显示和隐藏，默认值为YES
     *
     *  @see needsLoadingView
     */
    public var loadingViewHidden = true {
        didSet {
            if needsLoadingView {
                loadingViewHidden ? loadingView?.stopAnimating() : loadingView?.startAnimating()
            }
            refreshLayout()
        }
    }
    
    /*
     *  如果为true则title居中，loading放在title的左边，title右边有一个跟左边loading一样大的占位空间；如果为false，loading和title整体居中。默认值为true。
     */
    public var needsLoadingPlaceholderSpace = true {
        didSet {
            refreshLayout()
        }
    }
    
    public var loadingViewSize = CGSize(width: 18, height: 18)
    
    /*
     *  控制loading距离右边的距离
     */
    public var loadingViewMarginRight: CGFloat = 3 {
        didSet {
            refreshLayout()
        }
    }
    
    
    // MARK: - Accessory

    /*
     *  当accessoryView不为空时，QMUINavigationTitleViewAccessoryType设置无效，一直都是None
     */
    public var accessoryView: UIView? {
        didSet {
            if let accessoryView = accessoryView {
                accessoryType = .none
                accessoryView.sizeToFit()
                addSubview(accessoryView)
            }
            refreshLayout()
        }
    }

    /*
     *  只有当accessoryView为空时才有效
     */
    public var accessoryType: QMUINavigationTitleViewAccessoryType = .none {
        didSet {

            if accessoryType == .none {
                accessoryTypeView?.removeFromSuperview()
                accessoryTypeView = nil
                refreshLayout()
                return
            }

            if accessoryTypeView == nil {
                accessoryTypeView = UIImageView()
                accessoryTypeView?.contentMode = .center
                addSubview(accessoryTypeView!)
            }

            var accessoryImage: UIImage?
            if accessoryType == .disclosureIndicator {
                accessoryImage = NavBarAccessoryViewTypeDisclosureIndicatorImage?.qmui_image(with: .up)
            }

            accessoryTypeView?.image = accessoryImage
            accessoryTypeView?.sizeToFit()
            refreshLayout()
        }
    }

    /*
     *  用于微调accessoryView的位置
     */
    public var accessoryViewOffset: CGPoint = CGPoint(x: 3, y: 0) {
        didSet {
            refreshLayout()
        }
    }

    /*
     *  如果为true则title居中，`accessoryView`放在title的左边或右边；如果为false，`accessoryView`和title整体居中。默认值为false。
     */
    public var needsAccessoryPlaceholderSpace = false {
        didSet {
            refreshLayout()
        }
    }

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

        // TODO:
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
    
    override var description: String {
        return "\(super.description), title = \(title ?? ""), subtitle = \(subtitle ?? "")"
    }
    
    // MARK: - 布局

    func refreshLayout() {
        superview?.setNeedsLayout()
        setNeedsLayout()
    }

    func updateTitleLabelSize() {
        if titleLabel.text?.isEmpty ?? false {
            // 这里用 CGSizeCeil 是特地保证 titleView 的 sizeThatFits 计算出来宽度是 pt 取整，这样在 layoutSubviews 我们以 px 取整时，才能保证不会出现水平居中时出现半像素的问题，然后由于我们对半像素会认为一像素，所以导致总体宽度多了一像素，从而导致文字布局可能出现缩略...
            titleLabelSize = titleLabel.sizeThatFits(CGSize.max).sizeCeil
        } else {
            titleLabelSize = .zero
        }
    }

    func updateSubtitleLabelSize() {
        if !(subtitleLabel.text?.isEmpty ?? false) {
            // 这里用 CGSizeCeil 是特地保证 titleView 的 sizeThatFits 计算出来宽度是 pt 取整，这样在 layoutSubviews 我们以 px 取整时，才能保证不会出现水平居中时出现半像素的问题，然后由于我们对半像素会认为一像素，所以导致总体宽度多了一像素，从而导致文字布局可能出现缩略...
            subtitleLabelSize = subtitleLabel.sizeThatFits(CGSize.max).sizeCeil
        } else {
            subtitleLabelSize = .zero
        }
    }
    
    var loadingViewSpacingSize: CGSize {
        if needsLoadingView {
            return CGSize(width: loadingViewSize.width + loadingViewMarginRight, height: loadingViewSize.height)
        }
        return .zero
    }

    var loadingViewSpacingSizeIfNeedsPlaceholder: CGSize {
        return CGSize(width: loadingViewSpacingSize.width * (needsLoadingPlaceholderSpace ? 2 : 1), height: loadingViewSpacingSize.height)
    }

    var accessorySpacingSize: CGSize {
        if accessoryView != nil || accessoryTypeView != nil {
            let view = accessoryView ?? accessoryTypeView
            return CGSize(width: view!.bounds.width + accessoryViewOffset.x, height: view!.bounds.height)
        }
        return .zero
    }

    var accessorySpacingSizeIfNeedesPlaceholder: CGSize {
        return CGSize(width: accessorySpacingSize.width * (needsAccessoryPlaceholderSpace ? 2 : 1), height: accessorySpacingSize.height)
    }

    var titleEdgeInsetsIfShowingTitleLabel: UIEdgeInsets {
        return titleLabelSize.isEmpty ? .zero : titleEdgeInsets
    }

    var subtitleEdgeInsetsIfShowingSubtitleLabel: UIEdgeInsets {
        return subtitleLabelSize.isEmpty ? .zero : subtitleEdgeInsets
    }

    private var contentSize: CGSize {
        var size = CGSize()
        if style == .subTitleVertical {
            // 垂直排列的情况下，loading和accessory与titleLabel同一行
            var firstLineWidth = titleLabelSize.width + titleEdgeInsetsIfShowingTitleLabel.horizontalValue
            firstLineWidth += loadingViewSpacingSizeIfNeedsPlaceholder.width
            firstLineWidth += accessorySpacingSizeIfNeedesPlaceholder.width

            let secondLineWidth = subtitleLabelSize.width + subtitleEdgeInsetsIfShowingSubtitleLabel.horizontalValue

            size.width = max(firstLineWidth, secondLineWidth)

            size.height = titleLabelSize.height + titleEdgeInsetsIfShowingTitleLabel.verticalValue + subtitleLabelSize.height + subtitleEdgeInsetsIfShowingSubtitleLabel.verticalValue
        } else {
            size.width = titleLabelSize.width + titleEdgeInsetsIfShowingTitleLabel.horizontalValue + self.subtitleLabelSize.width + subtitleEdgeInsetsIfShowingSubtitleLabel.horizontalValue
            size.width += loadingViewSpacingSizeIfNeedsPlaceholder.width +  accessorySpacingSizeIfNeedesPlaceholder.width
            size.height = max(titleLabelSize.height + titleEdgeInsetsIfShowingTitleLabel.verticalValue, subtitleLabelSize.height + subtitleEdgeInsetsIfShowingSubtitleLabel.verticalValue)
            size.height = max(size.height, loadingViewSpacingSizeIfNeedsPlaceholder.height)
            size.height = max(size.height, accessorySpacingSizeIfNeedesPlaceholder.height)
        }
        return size.flatted
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return contentSize
    }
    
    override func layoutSubviews() {
        if bounds.size.isEmpty {
            print("\(classForCoder), layoutSubviews, size = \(bounds.size)")
            return
        }
        if accessoryViewAnimating {
            return
        }
    
        super.layoutSubviews()

        let alignLeft = contentHorizontalAlignment == .left
        let alignRight = contentHorizontalAlignment == .right

        // 通过sizeThatFit计算出来的size，如果大于可使用的最大宽度，则会被系统改为最大限制的最大宽度
        let maxSize = bounds.size

        // 实际内容的size，小于等于maxSize
        var contentSize = self.contentSize
        contentSize.width = min(maxSize.width, contentSize.width)
        contentSize.height = min(maxSize.height, contentSize.height)

        // 计算左右两边的偏移值
        var offsetLeft: CGFloat = 0
        var offsetRight: CGFloat = 0
        if alignLeft {
            offsetLeft = 0
            offsetRight = maxSize.width - contentSize.width
        } else if alignRight {
            offsetLeft = maxSize.width - contentSize.width
            offsetRight = 0
        } else {
            offsetLeft = floorInPixel((maxSize.width - contentSize.width) / 2.0)
            offsetRight = offsetLeft
        }

        // 计算loading占的单边宽度
        let loadingViewSpace = loadingViewSpacingSize.width

        // 获取当前accessoryView
        let accessoryView = self.accessoryView ?? accessoryTypeView

        // 计算accessoryView占的单边宽度
        let accessoryViewSpace = accessorySpacingSize.width
        
        let isTitleLabelShowing = !(titleLabel.text?.isEmpty ?? false)
        let isSubtitleLabelShowing = !(subtitleLabel.text?.isEmpty ?? false)
        let titleEdgeInsets = titleEdgeInsetsIfShowingTitleLabel
        let subtitleEdgeInsets = subtitleEdgeInsetsIfShowingSubtitleLabel
        
        var minX = offsetLeft + (needsAccessoryPlaceholderSpace ? accessoryViewSpace : 0)
        var maxX = maxSize.width - offsetRight - (needsLoadingPlaceholderSpace ? loadingViewSpace : 0)
        
        if style == .subTitleVertical {

            if let loadingView = loadingView {
                loadingView.frame.setXY(minX, titleLabelSize.height.center(with: loadingViewSize.height) + titleEdgeInsets.top)
                minX = loadingView.frame.maxX + loadingViewMarginRight
            }
            if let accessoryView = accessoryView {
                accessoryView.frame.setXY(maxX - accessoryView.bounds.width, titleLabelSize.height.center(with: accessoryView.bounds.height) + titleEdgeInsets.top + accessoryViewOffset.y)
                maxX = accessoryView.frame.minX - accessoryViewOffset.x
            }
            if isTitleLabelShowing {
                minX += titleEdgeInsets.left
                maxX -= titleEdgeInsets.right
                titleLabel.frame = CGRect(x: minX, y: titleEdgeInsets.top, width: maxX - minX, height: titleLabelSize.height).flatted
            } else {
                titleLabel.frame = .zero
            }
            if isSubtitleLabelShowing {
                subtitleLabel.frame = CGRect(x: subtitleEdgeInsets.left, y: (isTitleLabelShowing ? titleLabel.frame.maxY + titleEdgeInsets.bottom : 0) + subtitleEdgeInsets.top, width: maxSize.width - subtitleEdgeInsets.horizontalValue, height: subtitleLabelSize.height)
            } else {
                subtitleLabel.frame = .zero
            }

        } else {

            if let loadingView = loadingView {
                loadingView.frame.setXY(minX, maxSize.height.center(with: loadingViewSize.height))
                minX = loadingView.frame.maxX + loadingViewMarginRight
            }
            if let accessoryView = accessoryView {
                accessoryView.frame.setXY(maxX - accessoryView.bounds.width, maxSize.height.center(with: accessoryView.bounds.height) + accessoryViewOffset.y)
                maxX = accessoryView.frame.minX - accessoryViewOffset.x
            }
            if (isSubtitleLabelShowing) {
                maxX -= subtitleEdgeInsets.right
                // 如果当前的 contentSize 就是以这个 label 的最大占位计算出来的，那么就不应该先计算 center 再计算偏移
                let shouldSubtitleLabelCenterVertically = subtitleLabelSize.height + subtitleEdgeInsets.verticalValue < contentSize.height
                let subtitleMinY = shouldSubtitleLabelCenterVertically ? maxSize.height.center(with: subtitleLabelSize.height) + subtitleEdgeInsets.top - subtitleEdgeInsets.bottom : subtitleEdgeInsets.top
                subtitleLabel.frame = CGRect(x: maxX - subtitleLabelSize.width, y: subtitleMinY, width: subtitleLabelSize.width, height: subtitleLabelSize.height)
                maxX = subtitleLabel.frame.minX - subtitleEdgeInsets.left
            } else {
                subtitleLabel.frame = .zero
            }
            if (isTitleLabelShowing) {
                minX += titleEdgeInsets.left
                maxX -= titleEdgeInsets.right
                // 如果当前的 contentSize 就是以这个 label 的最大占位计算出来的，那么就不应该先计算 center 再计算偏移
                let shouldTitleLabelCenterVertically = titleLabelSize.height + titleEdgeInsets.verticalValue < contentSize.height
                let titleLabelMinY = shouldTitleLabelCenterVertically ? maxSize.height.center(with: titleLabelSize.height) + titleEdgeInsets.top - titleEdgeInsets.bottom : titleEdgeInsets.top
                titleLabel.frame = CGRect(x: minX, y: titleLabelMinY, width: maxX - minX, height: titleLabelSize.height)
            } else {
                titleLabel.frame = .zero
            }
        }
    }


    // MARK: - setter / getter
    override var contentHorizontalAlignment: UIControlContentHorizontalAlignment {
        didSet {
            refreshLayout()
        }
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()
        titleLabel.textColor = tintColor
        subtitleLabel.textColor = tintColor
        loadingView?.color = tintColor
    }


    // MARK: - Events

    override var isHighlighted: Bool {
        didSet {
            alpha = isHighlighted ? UIControlHighlightedAlpha : 1
        }
    }

    func handleTouchTitleViewEvent() {
        let active = !isActive
        delegate?.didTouch(titleView: self, isActive: active)
        isActive = active
        refreshLayout()
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
                //            NSLog(@"【%@】修正布局前\ntitleView = %@", NSStringFromClass(titleView.class), titleView)
                let titleViewMinY = flat(titleView.frame.minY - ((titleViewSize.height - titleView.bounds.height) / 2.0))// 系统对titleView的y值布局是flat，注意，不能改，改了要测试
                titleView.frame = CGRect(x: titleView.frame.minX, y: titleViewMinY, width: CGFloat(fminf(Float(titleViewMaximumWidth), Float(titleViewSize.width))), height: titleViewSize.height)
                //            NSLog(@"【%@】修正布局后\ntitleView = %@", NSStringFromClass(titleView.class), titleView)
            }
        } else {
            titleView = nil
        }

        qmui_navigationBarLayoutSubviews()

        if titleView != nil {
            //        NSLog(@"【%@】系统布局后\ntitleView = %@", NSStringFromClass(titleView.class), titleView)
        }
    }
}
