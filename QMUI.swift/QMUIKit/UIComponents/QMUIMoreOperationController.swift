//
//  QMUIMoreOperationController.swift
//  QMUI.swift
//
//  Created by 黄伯驹 on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

private let kQMUIMoreOperationItemViewTagOffset = 999

/// 操作面板上item的类型，QMUIMoreOperationItemTypeImportant类型的item会放到第一行的scrollView，QMUIMoreOperationItemTypeNormal类型的item会放到第二行的scrollView。
@objc enum QMUIMoreOperationItemType: Int {
    case important = 0 // 将item放在第一行显示
    case normal = 1 // 将item放在第二行显示
}

/// 更多操作面板的delegate。
@objc protocol QMUIMoreOperationControllerDelegate {
    /// 即将显示操作面板
    @objc optional func willPresent(_ moreOperationController: QMUIMoreOperationController)
    /// 已经显示操作面板
    @objc optional func didPresent(_ moreOperationController: QMUIMoreOperationController)
    /// 即将降下操作面板，cancelled参数是用来区分是否触发了maskView或者cancelButton按钮降下面板还是手动调用hide方法来降下面板。
    @objc optional func willDismiss(_ moreOperationController: QMUIMoreOperationController, cancelled: Bool)
    /// 已经降下操作面板，cancelled参数是用来区分是否触发了maskView或者cancelButton按钮降下面板还是手动调用hide方法来降下面板。
    @objc optional func didDismiss(_ moreOperationController: QMUIMoreOperationController, cancelled: Bool)
    /// itemView 点击事件，可以与 itemView.handler 共存，可通过 itemView.tag 或者 itemView.indexPath 来区分不同的 itemView
    @objc optional func moreOperationController(_ moreOperationController: QMUIMoreOperationController, didSelect itemView: QMUIMoreOperationItemView)
}

class QMUIMoreOperationItemView: QMUIButton {
    
    private var _indexPath: IndexPath?
    private(set) var indexPath: IndexPath? {
        get {
            if moreOperationController != nil {
                return moreOperationController?.indexPath(with: self)
            } else {
                return nil
            }
        }
        set {
            _indexPath = newValue
        }
    }

    fileprivate weak var moreOperationController: QMUIMoreOperationController?
    
    typealias QMUIMoreOperationItemHandler = (QMUIMoreOperationController, QMUIMoreOperationItemView) -> Void
    
    var handler: QMUIMoreOperationItemHandler?
    
    override var isHighlighted: Bool {
        didSet {
            imageView?.alpha = isHighlighted ? ButtonHighlightedAlpha : 1
        }
    }
    
    private var _tag: Int = 0
    override var tag: Int {
        set {
            _tag = newValue + kQMUIMoreOperationItemViewTagOffset
        }
        get {
            // 为什么这里用-1而不是0：如果一个 itemView 通过带 tag: 参数初始化，那么 itemView.tag 最小值为 0，而如果一个 itemView 不通过带 tag: 的参数初始化，那么 itemView.tag 固定为 0，可见 tag 为 0 代表的意义不唯一，为了消除歧义，这里用 -1 代表那种不使用 tag: 参数初始化的 itemView
            return max(-1, _tag - kQMUIMoreOperationItemViewTagOffset)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        imagePosition = .top
        adjustsButtonWhenHighlighted = false
        qmui_automaticallyAdjustTouchHighlightedInScrollView = true
        titleLabel?.numberOfLines = 0
        titleLabel?.textAlignment = .center
        imageView?.contentMode = .center
    }
    
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    convenience init(image: UIImage,
         selectedImage: UIImage? = nil,
         title: String,
         selectedTitle: String? = nil,
         tag: Int = 0,
         handler: QMUIMoreOperationItemHandler?) {
        self.init(frame: .zero)
        setImage(image, for: .normal)
        setImage(selectedImage, for: .selected)
        setImage(selectedImage, for: [.highlighted, .selected])
        setTitle(title, for: .normal)
        setTitle(selectedTitle, for: [.highlighted, .selected])
        setTitle(selectedTitle, for: .selected)
        self.handler = handler
        self.tag = tag
    }
    
    override var description: String {
        return "\(type(of: self)):\t\(self)\nimage:\t\t\t\(String(describing: image(for: .normal)))\nselectedImage:\t\(String(describing: image(for: .selected) == image(for: .normal) ? nil : image(for: .selected)))\ntitle:\t\t\t\(String(describing: title(for: .normal)))\nselectedTitle:\t\(String(describing: title(for: .selected) == title(for: .normal) ? nil : title(for: .selected)))\nindexPath:\t\t\(indexPath?.item ?? -1)\ntag:\t\t\t\t\(tag)"
    }
    
    // 被添加到某个 QMUIMoreOperationController 时要调用，用于更新 itemView 的样式，以及 moreOperationController 属性的指针
    // @param moreOperationController 如果为空，则会自动使用 [QMUIMoreOperationController appearance]
    fileprivate func formatItemViewStyle(with moreOperationController: QMUIMoreOperationController?) -> QMUIMoreOperationController {
        var vc: QMUIMoreOperationController
        if moreOperationController != nil {
            vc = moreOperationController!
            // 将事件放到 controller 级别去做，以便实现 delegate 功能
            addTarget(vc, action: #selector(QMUIMoreOperationController.handleItemViewEvent(_:)), for: .touchUpInside)
        } else {
            // 参数 nil 则默认使用 appearance 的样式
            vc = QMUIMoreOperationController.appearance()
        }
        titleLabel?.font = vc.itemTitleFont
        titleEdgeInsets = UIEdgeInsets(top: vc.itemTitleMarginTop, left: 0, bottom: 0, right: 0)
        setTitleColor(vc.itemTitleColor, for: .normal)
        imageView?.backgroundColor = vc.itemBackgroundColor
        return vc
    }
}

/**
 *  更多操作面板。在iOS上是一个比较常见的控件，比如系统的相册分享；或者微信的webview分享都会从底部弹出一个面板。<br/>
 *  这个控件一般分为上下两行，第一行会显示比较重要的操作入口，第二行是一些次要的操作入口。
 *  QMUIMoreOperationController就是这样的一个控件，可以通过QMUIMoreOperationItemType来设置操作入口要放在第一行还是第二行。
 */
class QMUIMoreOperationController: UIViewController, QMUIModalPresentationViewControllerDelegate {

    // 面板上半部分（不包含取消按钮）背景色
    var contentBackgroundColor = UIColorWhite {
        didSet {
            contentView.backgroundColor = contentBackgroundColor
        }
    }

    // 面板距离屏幕的上下左右间距
    var contentEdgeMargin: CGFloat = 10 {
        didSet {
            updateCornerRadius()
        }
    }
    
    // 面板的最大宽度
    var contentMaximumWidth = QMUIHelper.screenSizeFor55Inch.width - 20
    
    // 面板的圆角大小，当值大于 0 时会设置 self.view.clipsToBounds = true
    var contentCornerRadius: CGFloat = 10 {
        didSet {
            updateCornerRadius()
        }
    }
    
    // 面板内部的 padding，UIScrollView 会布局在除去 padding 之后的区域
    var contentPaddings: UIEdgeInsets = .zero
    
    // 每一行之间的顶部分隔线，对第一行无效
    var scrollViewSeparatorColor: UIColor = UIColor(r: 0, g: 0, b: 0, a: 0.15) {
        didSet {
            updateScrollViewsBorderStyle()
        }
    }
    
    // // 每一行内部的 padding
    var scrollViewContentInsets: UIEdgeInsets = UIEdgeInsets.init(top: 14, left: 8, bottom: 14, right: 8) {
        didSet {
            for scrollView in mutableScrollViews {
                scrollView.contentInset = scrollViewContentInsets
            }
            setViewNeedsLayoutIfLoaded()
        }
    }
    
    // 按钮的背景色
    var itemBackgroundColor = UIColorClear {
        didSet {
            for section in mutableItems {
                for itemView in section {
                    itemView.imageView?.backgroundColor = itemBackgroundColor
                }
            }
        }
    }
    
    // 按钮的标题颜色
    var itemTitleColor = UIColorGrayDarken {
        didSet {
            for section in mutableItems {
                for itemView in section {
                    itemView.setTitleColor(itemTitleColor, for: .normal)
                }
            }
        }
    }
    
    // 按钮的标题字体
    var itemTitleFont = UIFontMake(11) {
        didSet {
            for section in mutableItems {
                for itemView in section {
                    itemView.titleLabel?.font = itemTitleFont
                    itemView.setNeedsLayout()
                }
            }
        }
    }
    
    // 按钮内 imageView 的左右间距（按钮宽度 = 图片宽度 + 左右间距 * 2），通常用来调整文字的宽度
    var itemPaddingHorizontal: CGFloat = 16 {
        didSet {
            setViewNeedsLayoutIfLoaded()
        }
    }
    
    // 按钮标题距离文字之间的间距
    var itemTitleMarginTop: CGFloat = 9 {
        didSet {
            for section in mutableItems {
                for itemView in section {
                    itemView.titleEdgeInsets = UIEdgeInsets.init(top: itemTitleMarginTop, left: 0, bottom: 0, right: 0)
                    itemView.setNeedsLayout()
                }
            }
        }
    }

    // 按钮与按钮之间的最小间距
    var itemMinimumMarginHorizontal: CGFloat = 0 {
        didSet {
            setViewNeedsLayoutIfLoaded()
        }
    }
    
    // 是否要自动计算默认一行展示多少个 item，true 表示尽量让每一行末尾露出半个 item 暗示后面还有内容，false 表示直接根据 itemMinimumMarginHorizontal 来计算布局。默认为 true。
    var automaticallyAdjustItemMargins: Bool = true {
        didSet {
            setViewNeedsLayoutIfLoaded()
        }
    }
    
    // 取消按钮的背景色
    var cancelButtonBackgroundColor = UIColorWhite {
        didSet {
            cancelButton.backgroundColor = cancelButtonBackgroundColor
            updateExtendLayerAppearance()
        }
    }
    
    // 取消按钮的标题颜色
    var cancelButtonTitleColor = UIColorBlue {
        didSet {
            cancelButton.setTitleColor(cancelButtonTitleColor, for: .normal)
            cancelButton.setTitleColor(cancelButtonTitleColor.withAlphaComponent(ButtonHighlightedAlpha), for: .highlighted)
        }
    }
    
    // 取消按钮的顶部分隔线颜色
    var cancelButtonSeparatorColor = UIColor(r: 0, g: 0, b: 0, a: 0.15) {
        didSet {
            cancelButton.qmui_borderColor = cancelButtonSeparatorColor
        }
    }
    
    // 取消按钮的字体
    var cancelButtonFont = UIFontBoldMake(17) {
        didSet {
            cancelButton.titleLabel?.font = cancelButtonFont
            cancelButton.setNeedsLayout()
        }
    }
    
    // 取消按钮的高度
    var cancelButtonHeight: CGFloat = 56
    
    // 取消按钮距离内容面板的间距
    var cancelButtonMarginTop: CGFloat = 0 {
        didSet {
            cancelButton.qmui_borderPosition = cancelButtonMarginTop > 0 ? .none : .top
            updateCornerRadius()
            setViewNeedsLayoutIfLoaded()
        }
    }

    /// 代理
    weak var delegate: QMUIMoreOperationControllerDelegate?
    
    // 放 UIScrollView 的容器，与 cancelButton 区分开
    private(set) var contentView: UIView!

    // 获取当前的所有 UIScrollView
    var scrollViews: [UIScrollView] {
        let scrollViews = mutableScrollViews
        return scrollViews
    }
    
    /// 取消按钮，如果不需要，则自行设置其 hidden 为 true
    private(set) var cancelButton: QMUIButton!
    
    /// 在 iPhoneX 机器上是否延伸底部背景色。因为在 iPhoneX 上我们会把整个面板往上移动 safeArea 的距离，如果你的面板本来就配置成撑满全屏的样式，那么就会露出底部的空隙，isExtendBottomLayout 可以帮助你把空暇填补上。默认为false。
    var isExtendBottomLayout: Bool = false {
        didSet {
            if isExtendBottomLayout {
                extendLayer.isHidden = false
                updateExtendLayerAppearance()
            } else {
                extendLayer.isHidden = true
            }
        }
    }
    
    /// 获取当前所有的item
    var items: [[QMUIMoreOperationItemView]] {
        get {
            let items = mutableItems
            return items
        }
        set {
            for section in mutableItems {
                for itemView in section {
                    itemView.removeFromSuperview()
                }
            }
            mutableItems.removeAll()
            mutableItems = newValue
            for scrollView in mutableScrollViews {
                scrollView.removeFromSuperview()
            }
            mutableScrollViews.removeAll()
            for (index, itemViewSection) in mutableItems.enumerated() {
                let scrollView = addScrollView(at: index)
                for itemView in itemViewSection {
                    _add(itemView, to: scrollView)
                }
            }
            setViewNeedsLayoutIfLoaded()
        }
    }
    
    private var mutableScrollViews: [UIScrollView] = []
    
    private var mutableItems: [[QMUIMoreOperationItemView]] = [[]]

    /// 更多操作面板是否正在显示
    private(set) var isShowing = false
    private(set) var isAnimating = false
    
    private var extendLayer: CALayer!
    
    // 是否通过点击取消按钮或者遮罩来隐藏面板，默认为 false
    private var hideByCancel: Bool = false
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
        didInitialized()
    }

    override init(nibName _: String?, bundle _: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func didInitialized() {
        
        if #available(iOS 9.0, *) {
            loadViewIfNeeded()
        } else {
            view.alpha = 1
        }
        
        contentBackgroundColor = QMUIMoreOperationController.appearance().contentBackgroundColor
        contentEdgeMargin = QMUIMoreOperationController.appearance().contentEdgeMargin
        contentMaximumWidth = QMUIMoreOperationController.appearance().contentMaximumWidth
        contentCornerRadius = QMUIMoreOperationController.appearance().contentCornerRadius
        contentPaddings = QMUIMoreOperationController.appearance().contentPaddings
        scrollViewSeparatorColor = QMUIMoreOperationController.appearance().scrollViewSeparatorColor
        scrollViewContentInsets = QMUIMoreOperationController.appearance().scrollViewContentInsets
        
        itemBackgroundColor = QMUIMoreOperationController.appearance().itemBackgroundColor
        itemTitleColor = QMUIMoreOperationController.appearance().itemTitleColor
        itemTitleFont = QMUIMoreOperationController.appearance().itemTitleFont
        itemPaddingHorizontal = QMUIMoreOperationController.appearance().itemPaddingHorizontal
        itemTitleMarginTop = QMUIMoreOperationController.appearance().itemTitleMarginTop
        itemMinimumMarginHorizontal = QMUIMoreOperationController.appearance().itemMinimumMarginHorizontal
        automaticallyAdjustItemMargins = QMUIMoreOperationController.appearance().automaticallyAdjustItemMargins
        
        cancelButtonBackgroundColor = QMUIMoreOperationController.appearance().cancelButtonBackgroundColor
        cancelButtonTitleColor = QMUIMoreOperationController.appearance().cancelButtonTitleColor
        cancelButtonSeparatorColor = QMUIMoreOperationController.appearance().cancelButtonSeparatorColor
        cancelButtonFont = QMUIMoreOperationController.appearance().cancelButtonFont
        cancelButtonHeight = QMUIMoreOperationController.appearance().cancelButtonHeight
        cancelButtonMarginTop = QMUIMoreOperationController.appearance().cancelButtonMarginTop
        
        isExtendBottomLayout = QMUIMoreOperationController.appearance().isExtendBottomLayout
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        contentView = UIView()
        contentView.backgroundColor = contentBackgroundColor
        view.addSubview(contentView)
        
        cancelButton = QMUIButton()
        cancelButton.qmui_automaticallyAdjustTouchHighlightedInScrollView = true
        cancelButton.adjustsButtonWhenHighlighted = false
        cancelButton.titleLabel?.font = cancelButtonFont
        cancelButton.backgroundColor = cancelButtonBackgroundColor
        cancelButton.setTitle("取消", for: .normal)
        cancelButton.setTitleColor(cancelButtonTitleColor, for: .normal)
        cancelButton.setTitleColor(cancelButtonTitleColor.withAlphaComponent(ButtonHighlightedAlpha), for: .highlighted)
        cancelButton.qmui_borderPosition = .bottom
        cancelButton.qmui_borderColor = cancelButtonSeparatorColor
        cancelButton.addTarget(self, action: #selector(handleCancelButtonEvent(_:)), for: .touchUpInside)
        view.addSubview(cancelButton)
        
        extendLayer = CALayer()
        extendLayer.isHidden = !self.isExtendBottomLayout
        extendLayer.qmui_removeDefaultAnimations()
        view.layer.addSublayer(extendLayer)
        updateExtendLayerAppearance()
        
        updateCornerRadius()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        var layoutY = view.bounds.height
        
        if !extendLayer.isHidden {
            extendLayer.frame = CGRect(x: 0, y: layoutY, width: view.bounds.width, height: IPhoneXSafeAreaInsets.bottom)
            if view.clipsToBounds {
                print("QMUIMoreOperationController，\(type(of: self)) 需要显示 extendLayer，但却被父级 clip 掉了，可能看不到")
            }
        }
        
        let isCancelButtonShowing = !cancelButton.isHidden
        if isCancelButtonShowing {
            cancelButton.frame = CGRect(x: 0, y: layoutY - cancelButtonHeight, width: view.bounds.width, height: cancelButtonHeight)
            cancelButton.setNeedsLayout()
            layoutY = cancelButton.frame.minY - cancelButtonMarginTop
        }
        
        contentView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: layoutY)
        layoutY = contentPaddings.top

        let contentWidth: CGFloat = contentView.bounds.width - contentPaddings.horizontalValue

        for (index, scrollView) in mutableScrollViews.enumerated() {
            scrollView.frame = CGRect(x: contentPaddings.left, y: layoutY, width: contentWidth, height: scrollView.frame.height)
            // 要保护 safeAreaInsets 的区域，而这里不使用 scrollView.qmui_safeAreaInsets 是因为此时 scrollView 的 safeAreaInsets 仍然为 0，但 scrollView.superview.safeAreaInsets 已经正确了，所以使用 scrollView.superview 也即 self.view 的
            // 底部的 insets 暂不考虑
            //        UIEdgeInsets scrollViewSafeAreaInsets = scrollView.qmui_safeAreaInsets;
            let scrollViewSafeAreaInsets = UIEdgeInsets(top: fmax(view.qmui_safeAreaInsets.top - scrollView.qmui_top, 0), left: fmax(view.qmui_safeAreaInsets.left - scrollView.qmui_left, 0), bottom: 0, right: fmax(view.qmui_safeAreaInsets.right - (view.qmui_width - scrollView.qmui_right), 0))
            
            let itemSection = mutableItems[index]
            var exampleItemWidth: CGFloat = 0
            if let exampleItemView = itemSection.first, let width = exampleItemView.imageView?.image?.size.width {
                exampleItemWidth = width  + itemPaddingHorizontal * 2
            }
            let scrollViewVisibleWidth = contentWidth - scrollView.contentInset.left - scrollViewSafeAreaInsets.left // 注意计算列数时不需要考虑 contentInset.right 的
            var columnCount = (scrollViewVisibleWidth + itemMinimumMarginHorizontal) / (exampleItemWidth + itemMinimumMarginHorizontal)
            
            // 让初始状态下在 scrollView 右边露出半个 item
            if automaticallyAdjustItemMargins {
                columnCount = suitableColumnCount(columnCount)
            }
            
            let finalItemMarginHorizontal = (scrollViewVisibleWidth - exampleItemWidth * columnCount) / columnCount
            
            var maximumItemHeight: CGFloat = 0
            var itemViewMinX: CGFloat = scrollViewSafeAreaInsets.left
            for itemView in itemSection {
                let itemSize = itemView.sizeThatFits(CGSize(width: exampleItemWidth, height: CGFloat.greatestFiniteMagnitude)).flatted
                maximumItemHeight = fmax(maximumItemHeight, itemSize.height)
                itemView.frame = CGRect(x: itemViewMinX, y: 0, width: exampleItemWidth, height: itemSize.height)
                itemViewMinX = itemView.frame.maxX + finalItemMarginHorizontal
            }
            
            scrollView.contentSize = CGSize(width: itemViewMinX - finalItemMarginHorizontal + scrollViewSafeAreaInsets.right, height: maximumItemHeight)
            scrollView.frame = scrollView.frame.setHeight(scrollView.contentSize.height + scrollView.contentInset.verticalValue)
            layoutY = scrollView.frame.maxY
        }
    }
    
    private func suitableColumnCount(_ columnCount: CGFloat) -> CGFloat {
        // 根据精准的列数，找到一个合适的、能让半个 item 刚好露出来的列数。例如 3.6 会被转换成 3.5，3.2 会被转换成 2.5。
        var result: CGFloat = 0
        if (CGFloat(Int(columnCount)) + 0.5) == CGFloat(Int(columnCount)) {
            result = (CGFloat(Int(columnCount)) - 1) + 0.5
        }
        result = CGFloat(Int(columnCount)) + 0.5
        return result
    }
    
    /// 弹出面板，一般在 init 完并且设置好 items 之后就调用这个接口来显示面板
    func showFromBottom() {
        if isShowing || isAnimating {
            return
        }
        
        hideByCancel = true
        
        let modalPresentationViewController = QMUIModalPresentationViewController()
        modalPresentationViewController.delegate = self
        modalPresentationViewController.maximumContentViewWidth = contentMaximumWidth
        modalPresentationViewController.contentViewMargins = UIEdgeInsets(top: contentEdgeMargin, left: contentEdgeMargin, bottom: contentEdgeMargin, right: contentEdgeMargin)
        modalPresentationViewController.contentViewController = self
        
        
        modalPresentationViewController.layoutClosure = { (containerBounds, keyboardHeight, contentViewDefaultFrame) in
            modalPresentationViewController.contentView?.frame = contentViewDefaultFrame.setY(containerBounds.height - modalPresentationViewController.contentViewMargins.bottom - contentViewDefaultFrame.height - modalPresentationViewController.view.qmui_safeAreaInsets.bottom)
        }
        modalPresentationViewController.showingAnimationClosure =  { [weak self] (dimmingView: UIView?, containerBounds: CGRect, _: CGFloat, contentViewFrame: CGRect, _ completion: ((Bool) -> Void)?) in
            if let strongSelf = self {
                strongSelf.delegate?.willPresent?(strongSelf)
            }
            dimmingView?.alpha = 0
            modalPresentationViewController.contentView?.frame = contentViewFrame.setY(containerBounds.height)
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveOut, animations: {
                dimmingView?.alpha = 1
                modalPresentationViewController.contentView?.frame = contentViewFrame
            }, completion: { (finished) in
                if let strongSelf = self {
                    strongSelf.isShowing = true
                    strongSelf.isAnimating = false
                    strongSelf.delegate?.didPresent?(strongSelf)
                }
                completion?(finished)
            })
        }
        
        modalPresentationViewController.hidingAnimationClosure =  { (dimmingView: UIView?, containerBounds: CGRect, _ : CGFloat, _ completion: ((_ finished: Bool) -> Void)?) in
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveOut, animations: {
                dimmingView?.alpha = 0
                if let contentView = modalPresentationViewController.contentView {
                    contentView.frame = contentView.frame.setY(containerBounds.height)
                }
            }, completion: { (finished) in
                completion?(finished)
            })
        }
        
        isAnimating = true
        modalPresentationViewController.show(true, completion: nil)
    }
    
    /// 隐藏面板
    func hideToBottom() {
        if !isShowing || isAnimating {
            return
        }
        hideByCancel = false
        qmui_modalPresentationViewController?.hide(true, completion: nil)
    }

    @objc func handleCancelButtonEvent(_ button: QMUIButton) {
        if !isShowing || isAnimating {
            return
        }
        qmui_modalPresentationViewController?.hide(true, completion: nil)
    }
    
    @objc func handleItemViewEvent(_ itemView: QMUIMoreOperationItemView) {
        delegate?.moreOperationController?(self, didSelect: itemView)
        itemView.handler?(self, itemView)
    }

    /// 添加一个 itemView 到指定 section 的末尾
    func add(_ itemView: QMUIMoreOperationItemView, in section: Int) {
        if section == mutableItems.count {
            // 创建新的 itemView section
            mutableItems.append([itemView])
        } else {
            mutableItems[section].append(itemView)
        }
        itemView.moreOperationController = self
        if (section == mutableScrollViews.count) {
            // 创建新的 section
            addScrollView(at: section)
        }
        if section < mutableScrollViews.count {
            _add(itemView, to: mutableScrollViews[section])
        }
        setViewNeedsLayoutIfLoaded()
    }

    /// 插入一个 itemView 到指定的位置，NSIndexPath 请使用 section-item 组合，其中 section 表示行，item 表示 section 里的元素序号
    func insert(_ itemView: QMUIMoreOperationItemView, at indexPath: IndexPath) {
        if indexPath.section == mutableItems.count {
            // 创建新的 itemView section
            mutableItems.append([itemView])
        } else {
            mutableItems[indexPath.section].insert(itemView, at: indexPath.item)
        }
        itemView.moreOperationController = self
        if (indexPath.section == mutableScrollViews.count) {
            // 创建新的 section
            addScrollView(at: indexPath.section)
        }
        if indexPath.section < mutableScrollViews.count {
            itemView.moreOperationController = itemView.formatItemViewStyle(with: self)
            mutableScrollViews[indexPath.section].insertSubview(itemView, at:indexPath.item)
        }
        setViewNeedsLayoutIfLoaded()
    }

    /// 移除指定位置的 itemView，NSIndexPath 请使用 section-item 组合，其中 section 表示行，item 表示 section 里的元素序号
    func removeItemView(at indexPath: IndexPath) {
        let itemView = mutableScrollViews[indexPath.section].subviews[indexPath.item] as! QMUIMoreOperationItemView
        itemView.moreOperationController = nil
        itemView.removeFromSuperview()
        var itemViewSection = mutableItems[indexPath.section]
        itemViewSection.remove(object: itemView)
        mutableItems[indexPath.section] = itemViewSection
        if itemViewSection.count == 0 {
            mutableItems.remove(object: itemViewSection)
            mutableScrollViews[indexPath.section].removeFromSuperview()
            mutableScrollViews.remove(at: indexPath.section)
            updateScrollViewsBorderStyle()
        }
        setViewNeedsLayoutIfLoaded()
    }
    
    /// 获取指定 tag 的 itemView，如果不存在则返回 nil
    func itemView(with tag: Int) -> QMUIMoreOperationItemView? {
        var result: QMUIMoreOperationItemView?
        for section in mutableItems {
            for itemView in section {
                if itemView.tag == tag {
                    result = itemView
                    break
                }
            }
        }
        return result
    }
    
    /// 获取指定 itemView 在当前控件里的 indexPath，如果不存在则返回 nil
    func indexPath(with itemView: QMUIMoreOperationItemView) -> IndexPath? {
        for section in 0..<mutableItems.count {
            if let index = mutableItems[section].firstIndex(of: itemView) {
                return IndexPath(item: index, section: section)
            }
        }
        return nil
    }
    
    @discardableResult
    private func addScrollView(at index: Int) -> UIScrollView {
        let scrollView = generateScrollView(index)
        contentView.addSubview(scrollView)
        mutableScrollViews.append(scrollView)
        updateScrollViewsBorderStyle()
        return scrollView
    }
    
    private func _add(_ itemView: QMUIMoreOperationItemView, to scrollView: UIScrollView) {
        itemView.moreOperationController = itemView.formatItemViewStyle(with: self)
        scrollView.addSubview(itemView)
    }
    
    private func generateScrollView(_ index: Int) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = true
        scrollView.qmui_borderColor = scrollViewSeparatorColor
        scrollView.qmui_borderPosition = index != 0 ? .top : .none
        scrollView.scrollsToTop = false
        if #available(iOS 11, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        scrollView.contentInset = scrollViewContentInsets
        scrollView.qmui_scrollToTopForce(true, animated: false)
        return scrollView
    }
    
    private func updateScrollViewsBorderStyle() {
        for (idx, scrollView) in mutableScrollViews.enumerated() {
            scrollView.qmui_borderColor = scrollViewSeparatorColor
            scrollView.qmui_borderPosition = idx != 0 ? .top : .none
        }
    }
    
    private func setViewNeedsLayoutIfLoaded() {
        if isShowing {
            qmui_modalPresentationViewController?.updateLayout()
            view.setNeedsLayout()
        } else if isViewLoaded {
            view.setNeedsLayout()
        }
    }
    
    private func updateExtendLayerAppearance() {
        extendLayer.backgroundColor = cancelButtonBackgroundColor.cgColor
    }
    
    private func updateCornerRadius() {
        if cancelButtonMarginTop > 0 {
            view.layer.cornerRadius = 0
            view.clipsToBounds = false
            
            contentView.layer.cornerRadius = contentCornerRadius
            cancelButton.layer.cornerRadius = contentCornerRadius
        } else {
            view.layer.cornerRadius = contentCornerRadius
            view.clipsToBounds = view.layer.cornerRadius > 0 // 有圆角才需要 clip
            contentView.layer.cornerRadius = 0
            cancelButton.layer.cornerRadius = 0
        }
    }
}

extension QMUIMoreOperationController: QMUIModalPresentationContentViewControllerProtocol {
    
    func preferredContentSize(inModalPresentationViewController controller: QMUIModalPresentationViewController, limitSize: CGSize) -> CGSize {
        var resultSize = limitSize
        var contentHeight = cancelButton.isHidden ? 0 : cancelButtonHeight + cancelButtonMarginTop
        for (idx, scrollView) in mutableScrollViews.enumerated() {
            let itemSection = mutableItems[idx]
            var exampleItemWidth: CGFloat = 0
            if let exampleItemView = itemSection.first, let width = exampleItemView.imageView?.image?.size.width {
                exampleItemWidth = width + itemPaddingHorizontal * 2
            }
            var maximumItemHeight: CGFloat = 0
            for itemView in itemSection {
                let itemSize = itemView.sizeThatFits(CGSize(width: exampleItemWidth, height: CGFloat.greatestFiniteMagnitude))
                maximumItemHeight = fmax(maximumItemHeight, itemSize.height)
            }
            contentHeight += maximumItemHeight + scrollView.contentInset.verticalValue
        }
        if mutableScrollViews.count > 0 {
            contentHeight += contentPaddings.verticalValue
        }
        resultSize.height = contentHeight;
        return resultSize
    }
}

extension QMUIMoreOperationController {
    
    static func appearance() -> QMUIMoreOperationController {
        DispatchQueue.once(token: QMUIMoreOperationController._onceToken) {
            QMUIMoreOperationController.resetAppearance()
        }
        return QMUIMoreOperationController.moreOperationViewControllerAppearance!
    }
    
    private static let _onceToken = UUID().uuidString
    
    static var moreOperationViewControllerAppearance: QMUIMoreOperationController?
    
    private static func resetAppearance() {
        let moreOperationViewControllerAppearance = QMUIMoreOperationController(nibName: nil, bundle: nil)
        if #available(iOS 9.0, *) {
            moreOperationViewControllerAppearance.loadViewIfNeeded()
        } else {
            moreOperationViewControllerAppearance.view.alpha = 1
        }
        moreOperationViewControllerAppearance.contentBackgroundColor = UIColorWhite
        moreOperationViewControllerAppearance.contentEdgeMargin = 10
        moreOperationViewControllerAppearance.contentMaximumWidth = QMUIHelper.screenSizeFor55Inch.width - moreOperationViewControllerAppearance.contentEdgeMargin * 2
        moreOperationViewControllerAppearance.contentCornerRadius = 10
        moreOperationViewControllerAppearance.contentPaddings = UIEdgeInsets(top: 10, left: 0, bottom: 5, right: 0)
        moreOperationViewControllerAppearance.scrollViewSeparatorColor = UIColor(r: 0, g: 0, b: 0, a: 0.15)
        moreOperationViewControllerAppearance.scrollViewContentInsets = UIEdgeInsets(top: 14, left: 8, bottom: 14, right: 8)
        
        moreOperationViewControllerAppearance.itemBackgroundColor = UIColorClear
        moreOperationViewControllerAppearance.itemTitleColor = UIColorGrayDarken
        moreOperationViewControllerAppearance.itemTitleFont = UIFontMake(11)
        moreOperationViewControllerAppearance.itemPaddingHorizontal = 16
        moreOperationViewControllerAppearance.itemTitleMarginTop = 9
        moreOperationViewControllerAppearance.itemMinimumMarginHorizontal = 0
        moreOperationViewControllerAppearance.automaticallyAdjustItemMargins = true
        
        moreOperationViewControllerAppearance.cancelButtonBackgroundColor = UIColorWhite
        moreOperationViewControllerAppearance.cancelButtonTitleColor = UIColorBlue
        moreOperationViewControllerAppearance.cancelButtonSeparatorColor = UIColor(r: 0, g: 0, b: 0, a: 0.15)
        moreOperationViewControllerAppearance.cancelButtonFont = UIFontBoldMake(16)
        moreOperationViewControllerAppearance.cancelButtonHeight = 56.0
        moreOperationViewControllerAppearance.cancelButtonMarginTop = 0
        
        moreOperationViewControllerAppearance.isExtendBottomLayout = false
        
        QMUIMoreOperationController.moreOperationViewControllerAppearance = moreOperationViewControllerAppearance
    }
}
