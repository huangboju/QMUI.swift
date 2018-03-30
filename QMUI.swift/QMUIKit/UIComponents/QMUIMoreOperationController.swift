//
//  QMUIMoreOperationController.swift
//  QMUI.swift
//
//  Created by 黄伯驹 on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

private let TagOffset = 999

/// 操作面板上item的类型，QMUIMoreOperationItemTypeImportant类型的item会放到第一行的scrollView，QMUIMoreOperationItemTypeNormal类型的item会放到第二行的scrollView。
enum QMUIMoreOperationItemType {
    case important // 将item放在第一行显示
    case normal // 将item放在第二行显示
}

/// 更多操作面板的delegate。
protocol QMUIMoreOperationDelegate: class {
    /// 即将显示操作面板
    func willPresentMoreOperationController(_ moreOperationController: QMUIMoreOperationController)
    /// 已经显示操作面板
    func didPresentMoreOperationController(_ moreOperationController: QMUIMoreOperationController)
    /// 即将降下操作面板，cancelled参数是用来区分是否触发了maskView或者cancelButton按钮降下面板还是手动调用hide方法来降下面板。
    func willDismissMoreOperationController(_ moreOperationController: QMUIMoreOperationController, cancelled: Bool)
    /// 已经降下操作面板，cancelled参数是用来区分是否触发了maskView或者cancelButton按钮降下面板还是手动调用hide方法来降下面板。
    func didDismissMoreOperationController(_ moreOperationController: QMUIMoreOperationController, cancelled: Bool)
    /// 点击了操作面板上的一个item，可以通过参数拿到当前item的index和type
    func moreOperationController(_ moreOperationController: QMUIMoreOperationController, didSelectItemAt buttonIndex: Int, type: QMUIMoreOperationItemType)
    /// 点击了操作面板上的一个item，可以通过参数拿到当前item的tag
    func moreOperationController(_ moreOperationController: QMUIMoreOperationController, didSelectItemAt tag: Int)
}

class QMUIMoreOperationItemView: QMUIButton {
    public var itemType: QMUIMoreOperationItemType = .important

    private var _tag = 0
    private let TagOffset = 999

    override init(frame: CGRect) {
        super.init(frame: frame)

        imagePosition = .top
        adjustsButtonWhenHighlighted = false
        qmui_automaticallyAdjustTouchHighlightedInScrollView = true
        titleLabel?.numberOfLines = 0
        titleLabel?.textAlignment = .center
        imageView?.contentMode = .center
        imageView?.backgroundColor = UIColorClear
    }

    override var isHighlighted: Bool {
        didSet {
            imageView?.alpha = isHighlighted ? ButtonHighlightedAlpha : 1
        }
    }

    override var tag: Int {
        set {
            _tag = newValue + TagOffset
        }
        get {
            return _tag - TagOffset
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/**
 *  更多操作面板。在iOS上是一个比较常见的控件，比如系统的相册分享；或者微信的webview分享都会从底部弹出一个面板。<br/>
 *  这个控件一般分为上下两行，第一行会显示比较重要的操作入口，第二行是一些次要的操作入口。
 *  QMUIMoreOperationController就是这样的一个控件，可以通过QMUIMoreOperationItemType来设置操作入口要放在第一行还是第二行。
 */
class QMUIMoreOperationController: UIViewController {

    public var contentBackgroundColor = UIColorWhite {
        didSet {
            contentView.backgroundColor = contentBackgroundColor
        }
    }

    public var contentSeparatorColor = UIColorMakeWithRGBA(0, 0, 0, 0.15) {
        didSet {
            scrollViewDividingLayer.backgroundColor = contentSeparatorColor.cgColor
        }
    }

    public var cancelButtonBackgroundColor = UIColorWhite {
        didSet {
            cancelButton.backgroundColor = cancelButtonBackgroundColor
        }
    }

    public var cancelButtonTitleColor = UIColorBlue {
        didSet {
            cancelButton.setTitleColor(cancelButtonTitleColor, for: .normal)
            cancelButton.setTitleColor(cancelButtonTitleColor.withAlphaComponent(ButtonHighlightedAlpha), for: .highlighted)
        }
    }

    public var cancelButtonSeparatorColor = UIColorMakeWithRGBA(0, 0, 0, 0.15) {
        didSet {
            cancelButtonDividingLayer.backgroundColor = cancelButtonSeparatorColor.cgColor
        }
    }

    public var itemBackgroundColor = UIColorClear {
        didSet {
            let result = importantItems + normalItems
            for item in result {
                item.imageView?.backgroundColor = itemBackgroundColor
            }
        }
    }

    public var itemTitleColor = UIColorGrayDarken {
        didSet {
            let result = importantItems + normalItems
            for item in result {
                item.setTitleColor(itemTitleColor, for: .normal)
            }
        }
    }

    public var itemTitleFont = UIFontMake(11) {
        didSet {
            let result = importantItems + normalItems
            for item in result {
                item.titleLabel?.font = itemTitleFont
            }
        }
    }

    public var cancelButtonFont = UIFontBoldMake(17) {
        didSet {
            cancelButton.titleLabel?.font = cancelButtonFont
        }
    }

    public var contentEdgeMargin: CGFloat = 10 {
        didSet {
            updateCornerRadius()
        }
    }

    public var contentMaximumWidth = QMUIHelper.screenSizeFor55Inch.width - 20
    public var contentCornerRadius: CGFloat = 10
    public var itemTitleMarginTop: CGFloat = 9 {
        didSet {
            let result = importantItems + normalItems
            for item in result {
                item.titleEdgeInsets = UIEdgeInsets(top: itemTitleMarginTop, left: 0, bottom: 0, right: 0)
            }
        }
    }

    public var topScrollViewInsets = UIEdgeInsets(top: 18, left: 14, bottom: 12, right: 14)
    public var bottomScrollViewInsets = UIEdgeInsets(top: 18, left: 14, bottom: 12, right: 14)
    public var cancelButtonHeight: CGFloat = 52
    public var cancelButtonMarginTop: CGFloat = 0 {
        didSet {
            updateCornerRadius()
        }
    }

    /// 代理
    public weak var delegate: QMUIMoreOperationDelegate?

    /// 获取当前所有的item
    public var items: [QMUIMoreOperationItemView] {
        return importantItems + normalItems
    }

    /// 获取取消按钮
    public let cancelButton = QMUIButton()

    /// 更多操作面板是否正在显示
    public private(set) var isShowing = false
    public private(set) var isAnimating = false

    private let containerView = UIView()
    private let contentView = UIView()
    private let maskView = UIControl()
    private let importantItemsScrollView = UIScrollView()
    private let normalItemsScrollView = UIScrollView()

    private let scrollViewDividingLayer = CALayer()
    private let cancelButtonDividingLayer = CALayer()

    private var importantItems: [QMUIMoreOperationItemView] = []
    private var normalItems: [QMUIMoreOperationItemView] = []
    private var importantShowingItems: [QMUIMoreOperationItemView] = []
    private var normalShowingItems: [QMUIMoreOperationItemView] = []

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        didInitialized()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        didInitialized()
    }

    private func didInitialized() {
        initSubviewsIfNeeded()
    }

    private func initSubviewsIfNeeded() {
        maskView.alpha = 0
        maskView.backgroundColor = UIColorMask
        maskView.addTarget(self, action: #selector(handleMaskControlEvent), for: .touchUpInside)

        containerView.clipsToBounds = true

        contentView.clipsToBounds = true
        contentView.backgroundColor = contentBackgroundColor

        scrollViewDividingLayer.isHidden = true
        scrollViewDividingLayer.backgroundColor = contentSeparatorColor.cgColor
        scrollViewDividingLayer.qmui_removeDefaultAnimations()

        importantItemsScrollView.showsHorizontalScrollIndicator = false
        importantItemsScrollView.showsVerticalScrollIndicator = false

        normalItemsScrollView.showsHorizontalScrollIndicator = false
        normalItemsScrollView.showsVerticalScrollIndicator = false
        normalItemsScrollView.isHidden = true

        cancelButton.adjustsButtonWhenHighlighted = false
        cancelButton.titleLabel?.font = cancelButtonFont
        cancelButton.backgroundColor = cancelButtonBackgroundColor
        cancelButton.setTitle("取消", for: .normal)
        cancelButton.setTitleColor(cancelButtonTitleColor, for: .normal)
        cancelButton.setTitleColor(cancelButtonTitleColor.withAlphaComponent(ButtonHighlightedAlpha), for: .highlighted)
        cancelButton.addTarget(self, action: #selector(handleCancelButtonEvent), for: .touchUpInside)

        cancelButtonDividingLayer.backgroundColor = cancelButtonSeparatorColor.cgColor
        cancelButtonDividingLayer.qmui_removeDefaultAnimations()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(maskView)
        view.addSubview(containerView)
        containerView.addSubview(contentView)
        contentView.layer.addSublayer(scrollViewDividingLayer)
        contentView.addSubview(importantItemsScrollView)
        contentView.addSubview(normalItemsScrollView)
        containerView.addSubview(cancelButton)
        containerView.layer.addSublayer(cancelButtonDividingLayer)
        updateCornerRadius()
    }

    private func resetShowingItemsArray() {
        importantShowingItems.removeAll()
        normalShowingItems.removeAll()
        for item in importantItems where !item.isHidden {
            importantShowingItems.append(item)
        }
        for item in normalItems where !item.isHidden {
            normalShowingItems.append(item)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        resetShowingItemsArray()

        maskView.frame = view.bounds

        var layoutOriginY: CGFloat = 0
        let contentWidth: CGFloat = min(view.bounds.width - contentEdgeMargin * 2, contentMaximumWidth)

        var importantScrollViewInsets = topScrollViewInsets
        var normaltScrollViewInsets = bottomScrollViewInsets

        // 当两个scrollView其中一个没有的时候，需要调整对应的insets
        if importantShowingItems.isEmpty {
            normaltScrollViewInsets.setTop(importantScrollViewInsets.top)
            bottomScrollViewInsets = normaltScrollViewInsets
        }
        if normalShowingItems.isEmpty {
            importantScrollViewInsets.setBottom(bottom: normaltScrollViewInsets.bottom)
            topScrollViewInsets = importantScrollViewInsets
        }

        let isLargeSreen = view.bounds.width > QMUIHelper.screenSizeFor40Inch.width
        let maxItemCountInScrollView = CGFloat(max(importantShowingItems.count, normalShowingItems.count))
        let itemCountForTotallyVisibleItem: CGFloat = isLargeSreen ? 4 : 3

        let itemWidth = flat((contentWidth - max(importantScrollViewInsets.horizontalValue, normaltScrollViewInsets.horizontalValue)) / itemCountForTotallyVisibleItem) - (maxItemCountInScrollView > itemCountForTotallyVisibleItem ? 11.0 : 0.0)

        var itemMaxHeight: CGFloat = 0
        var itemMaxX: CGFloat = 0
        if !importantShowingItems.isEmpty {
            importantItemsScrollView.isHidden = false
            for i in 0 ..< importantShowingItems.count {
                let itemView = importantShowingItems[i]
                itemView.sizeToFit()
                itemView.frame = CGRect(x: itemWidth * CGFloat(i), y: 0, width: itemWidth, height: itemView.bounds.height).flatted
                itemMaxX = itemView.frame.maxX
                itemMaxHeight = max(itemView.bounds.height, itemMaxHeight)
            }
            importantItemsScrollView.contentSize = CGSize(width: itemMaxX, height: itemMaxHeight).flatted
            importantItemsScrollView.contentInset = importantScrollViewInsets
            importantItemsScrollView.contentOffset = CGPoint(x: -importantItemsScrollView.contentInset.left, y: -importantItemsScrollView.contentInset.top)
            importantItemsScrollView.frame = CGSize(width: contentWidth, height: importantItemsScrollView.contentInset.verticalValue + importantItemsScrollView.contentSize.height).rect.flatted
            layoutOriginY = importantItemsScrollView.frame.maxY
        } else {
            importantItemsScrollView.isHidden = true
        }

        itemMaxHeight = 0
        itemMaxX = 0
        if !normalShowingItems.isEmpty {
            normalItemsScrollView.isHidden = false
            scrollViewDividingLayer.isHidden = importantShowingItems.isEmpty
            scrollViewDividingLayer.frame = CGRectFlat(0, layoutOriginY, contentWidth, PixelOne)
            layoutOriginY = scrollViewDividingLayer.frame.maxY
            for i in 0 ..< normalShowingItems.count {
                let itemView = normalShowingItems[i]
                itemView.sizeToFit()
                itemView.frame = CGRect(x: itemWidth * CGFloat(i), y: 0, width: itemWidth, height: itemView.bounds.height).flatted
                itemMaxX = itemView.frame.maxX
                itemMaxHeight = max(itemMaxHeight, itemView.bounds.height)
            }

            normalItemsScrollView.contentSize = CGSize(width: itemMaxX, height: itemMaxHeight).flatted
            normalItemsScrollView.contentInset = normaltScrollViewInsets
            normalItemsScrollView.frame = CGRect(x: 0, y: layoutOriginY, width: contentWidth, height: normalItemsScrollView.contentInset.verticalValue + normalItemsScrollView.contentSize.height).flatted
            normalItemsScrollView.contentOffset = CGPoint(x: -normalItemsScrollView.contentInset.left, y: -normalItemsScrollView.contentInset.top)
            layoutOriginY = normalItemsScrollView.frame.maxY
        } else {
            normalItemsScrollView.isHidden = true
            scrollViewDividingLayer.isHidden = true
        }

        contentView.frame = CGSize(width: contentWidth, height: layoutOriginY).rect.flatted
        layoutOriginY = contentView.frame.maxY

        cancelButtonDividingLayer.isHidden = cancelButtonMarginTop > 0
        cancelButtonDividingLayer.frame = CGRect(x: 0, y: layoutOriginY + cancelButtonMarginTop, width: contentWidth, height: PixelOne).flatted
        cancelButton.frame = CGRect(x: 0.0, y: cancelButtonDividingLayer.frame.minY, width: contentWidth, height: cancelButtonHeight).flatted

        containerView.frame = CGRect(x: (view.bounds.width - contentWidth) / 2,
                                     y: view.bounds.height - cancelButton.frame.maxY - contentEdgeMargin,
                                     width: contentWidth,
                                     height: cancelButton.frame.maxY).flatted
    }

    private func updateCornerRadius() {
        if cancelButtonMarginTop > 0 {
            contentView.layer.cornerRadius = contentCornerRadius
            containerView.layer.cornerRadius = 0
            cancelButton.layer.cornerRadius = contentCornerRadius
        } else {
            containerView.layer.cornerRadius = contentCornerRadius
            contentView.layer.cornerRadius = 0
            cancelButton.layer.cornerRadius = 0
        }
    }

    /// 弹出更多操作面板，一般在init完并且设置好item之后就调用这个接口来显示面板
    public func showFromBottom() {
        if isShowing || isAnimating {
            return
        }

        let modalPresentationViewController = QMUIModalPresentationViewController()
        modalPresentationViewController.maximumContentViewWidth = CGFloat.greatestFiniteMagnitude
        modalPresentationViewController.contentViewMargins = .zero
        modalPresentationViewController.dimmingView = nil
        modalPresentationViewController.contentViewController = self

        modalPresentationViewController.showingAnimation = { [weak self] _, _, _, _, completion in
            self?.delegate?.willPresentMoreOperationController(self!)
            self?.containerView.frame.setY(self?.view.bounds.height ?? 0)
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveOut, animations: {
                self?.maskView.alpha = 1
                self?.containerView.frame.setY((self?.view.bounds.height ?? 0) - (self?.containerView.frame.height ?? 0) - (self?.contentEdgeMargin ?? 0))
            }, completion: { finished in
                self?.isShowing = true
                self?.isAnimating = false
                self?.delegate?.didPresentMoreOperationController(self!)
                completion?(finished)
            })
        }

        modalPresentationViewController.hidingAnimation = { [weak self] _, containerBounds, _, completion in
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveOut, animations: {
                self?.maskView.alpha = 0
                self?.containerView.frame.setY(containerBounds.height)
            }, completion: completion)
        }

        isAnimating = true
        modalPresentationViewController.show(with: true, completion: nil)
    }

    /// 与showFromBottom相反
    public func hideToBottom() {
        hideToBottomCancelled(false)
    }

    private func hideToBottomCancelled(_ cancelled: Bool) {

        if !isShowing || isAnimating {
            return
        }
        isAnimating = true

        delegate?.willDismissMoreOperationController(self, cancelled: cancelled)

        modalPresentedViewController?.hide(with: true, completion: { [weak self] _ in
            self?.isShowing = false
            self?.isAnimating = false
            self?.delegate?.didDismissMoreOperationController(self!, cancelled: cancelled)
        })
    }

    @objc func handleMaskControlEvent(_: UIControl) {
        hideToBottomCancelled(true)
    }

    @objc func handleCancelButtonEvent(_: QMUIButton) {
        hideToBottomCancelled(true)
    }

    /// 下面几个`addItem`方法，是用来往面板里面增加item的
    public func addItem(with title: String, selectedTitle: String, image: UIImage, selectedImage: UIImage, type: QMUIMoreOperationItemType, tag: Int = -1) -> Int {
        let itemView = createItem(with: title, selectedTitle: selectedTitle, image: image, selectedImage: selectedImage, type: type, tag: tag)
        if itemView.itemType == .important {
            return insertItem(itemView, to: importantItems.count) ? importantItems.index(of: itemView) ?? -1 : -1
        } else if itemView.itemType == .normal {
            return insertItem(itemView, to: normalItems.count) ? normalItems.index(of: itemView) ?? -1 : -1
        }
        return -1
    }

    public func addItem(with title: String, selectedTitle: String, image: UIImage, selectedImage _: UIImage, type: QMUIMoreOperationItemType) -> Int {
        return addItem(with: title, selectedTitle: selectedTitle, image: image, selectedImage: image, type: type)
    }

    public func addItem(with title: String, image: UIImage, type: QMUIMoreOperationItemType) -> Int {
        return addItem(with: title, selectedTitle: title, image: image, selectedImage: image, type: type)
    }

    /// 初始化一个item，并通过下面的`insertItem`来将item插入到面板的某个位置
    public func createItem(with title: String, selectedTitle: String, image: UIImage, selectedImage: UIImage, type: QMUIMoreOperationItemType, tag: Int) -> QMUIMoreOperationItemView {
        let itemView = QMUIMoreOperationItemView(frame: .zero)
        itemView.itemType = type
        itemView.titleLabel?.font = itemTitleFont
        itemView.titleEdgeInsets.top = itemTitleMarginTop
        itemView.setImage(image, for: .normal)
        itemView.setImage(selectedImage, for: .selected)
        itemView.setImage(selectedImage, for: [.highlighted, .selected])
        itemView.setTitle(title, for: .normal)
        itemView.setTitle(selectedTitle, for: [.highlighted, .selected])
        itemView.setTitle(selectedTitle, for: .selected)
        itemView.setTitleColor(itemTitleColor, for: .normal)
        itemView.imageView?.backgroundColor = itemBackgroundColor
        itemView.tag = tag
        itemView.addTarget(self, action: #selector(handleButtonClick), for: .touchUpInside)
        return itemView
    }

    /// 将通过上面初始化的一个item插入到某个位置
    public func insertItem(_ itemView: QMUIMoreOperationItemView, to index: Int) -> Bool {
        if itemView.itemType == .important {
            importantItems.insert(itemView, at: index)
            importantItemsScrollView.addSubview(itemView)
            return true
        } else if itemView.itemType == .normal {
            normalItems.insert(itemView, at: index)
            normalItemsScrollView.addSubview(itemView)
            return true
        }
        return false
    }

    /// 获取某种类型上的item
    public func item(at index: Int, type: QMUIMoreOperationItemType) -> QMUIMoreOperationItemView {
        if type == .important {
            return importantItems[index]
        } else {
            return normalItems[index]
        }
    }

    /// 获取某个tag的item
    func item(at tag: Int) -> QMUIMoreOperationItemView {
        var item = importantItemsScrollView.viewWithTag(tag + TagOffset) as? QMUIMoreOperationItemView
        if item == nil {
            item = normalItemsScrollView.viewWithTag(tag + TagOffset) as? QMUIMoreOperationItemView
        }
        return item!
    }

    /// 下面两个`setItemHidden`方法可以隐藏某一个item
    public func setItemHidden(_ hidden: Bool, index: Int, type: QMUIMoreOperationItemType) {
        let item = self.item(at: index, type: type)
        item.isHidden = hidden
    }

    /// 同上
    public func setItemHidden(_ hidden: Bool, tag: Int) {
        let item = self.item(at: tag)
        item.isHidden = hidden
    }

    @objc func handleButtonClick(_ sender: QMUIMoreOperationItemView) {
        let item = sender
        var index = 0
        let itemType: QMUIMoreOperationItemType
        if item.superview == importantItemsScrollView {
            index = importantItems.index(of: item) ?? 0
            itemType = .important
        } else {
            index = normalItems.index(of: item) ?? 0
            itemType = .normal
        }
        let tag = item.tag
        delegate?.moreOperationController(self, didSelectItemAt: index, type: itemType)
        delegate?.moreOperationController(self, didSelectItemAt: tag)
    }
}

extension QMUIMoreOperationController: QMUIModalPresentationContentViewControllerProtocol {
    func preferredContentSize(in modalPresentationViewController: QMUIModalPresentationViewController, limitSize _: CGSize) -> CGSize {
        return modalPresentationViewController.view.bounds.size
    }
}
