//
//  QMUIDialogViewController.swift
//  QMUI.swift
//
//  Created by 黄伯驹 on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

let QMUIDialogSelectionViewControllerSelectedItemIndexNone = -1

/**
 * 弹窗组件基类，自带`headerView`、`contentView`、`footerView`，并通过`addCancelButtonWithText:block:`、`addSubmitButtonWithText:block:`方法来添加取消、确定按钮。
 * 建议将一个自定义的UIView设置给`contentView`属性，此时弹窗将会自动帮你计算大小并布局。大小取决于你的contentView的sizeThatFits:返回值。
 * 弹窗继承自`QMUICommonViewController`，因此可直接使用self.titleView的功能来实现双行标题，具体请查看`QMUINavigationTitleView`。
 * `QMUIDialogViewController`支持以类似`UIAppearance`的方式来统一设置全局的dialog样式，例如`[QMUIDialogViewController appearance].headerViewHeight = 48;`。
 *
 * @see QMUIDialogSelectionViewController
 * @see QMUIDialogTextFieldViewController
 */
class QMUIDialogViewController: QMUICommonViewController {
    
    @objc dynamic var cornerRadius: CGFloat = 6 {
        didSet {
            if isViewLoaded {
                view.layer.cornerRadius = cornerRadius
            }
        }
    }
    
    @objc dynamic var dialogViewMargins: UIEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    
    @objc dynamic var maximumContentViewWidth: CGFloat = 0
    
    @objc dynamic var backgroundColor: UIColor = UIColorClear {
        didSet {
            view.backgroundColor = backgroundColor
        }
    }
    
    @objc dynamic var titleTintColor: UIColor = UIColorBlack {
        didSet {
            titleView?.tintColor = titleTintColor
        }
    }
    
    @objc dynamic var titleLabelFont: UIFont = UIFontMake(16) {
        didSet {
            titleView?.titleLabel.font = titleLabelFont
            titleView.verticalTitleFont = titleLabelFont
        }
    }
    
    @objc dynamic var titleLabelTextColor: UIColor = UIColor(r: 53, g: 60, b: 70) {
        didSet {
            titleView?.titleLabel.textColor = titleLabelTextColor
        }
    }
    
    @objc dynamic var subTitleLabelFont: UIFont = UIFontMake(12) {
        didSet {
            titleView?.subtitleLabel.font = subTitleLabelFont
            titleView.verticalSubtitleFont = subTitleLabelFont
        }
    }
    
    @objc dynamic var subTitleLabelTextColor: UIColor = UIColor(r: 133, g: 140, b: 150) {
        didSet {
            titleView?.subtitleLabel.textColor = subTitleLabelTextColor
        }
    }

    @objc dynamic var headerSeparatorColor: UIColor? = UIColor(r: 222, g: 224, b: 226) {
        didSet {
            if let layer = headerViewSeparatorLayer {
                layer.backgroundColor = headerSeparatorColor?.cgColor
            }
        }
    }

    @objc dynamic var headerViewHeight: CGFloat = 48
    
    @objc dynamic var headerViewBackgroundColor: UIColor = UIColor(r: 244, g: 245, b: 247) {
        didSet {
            if isViewLoaded {
                headerView.backgroundColor = headerViewBackgroundColor
            }
        }
    }
    
    @objc dynamic var contentViewMargins: UIEdgeInsets = .zero
    
    @objc dynamic var footerSeparatorColor: UIColor? = UIColor(r: 222, g: 224, b: 226) {
        didSet {
            if let layer = footerViewSeparatorLayer {
                layer.backgroundColor = footerSeparatorColor?.cgColor
            }
            if let layer = buttonSeparatorLayer {
                layer.backgroundColor = footerSeparatorColor?.cgColor
            }
        }
    }

    @objc dynamic var footerViewHeight: CGFloat = 48
    
    @objc dynamic var footerViewBackgroundColor: UIColor = UIColorWhite {
        didSet {
            footerView.backgroundColor = footerViewBackgroundColor
        }
    }

    @objc dynamic var buttonBackgroundColor: UIColor? {
        didSet {
            cancelButton?.backgroundColor = buttonBackgroundColor
            submitButton?.backgroundColor = buttonBackgroundColor
        }
    }
    
    @objc dynamic var buttonHighlightedBackgroundColor: UIColor = UIColorBlue.withAlphaComponent(0.25) {
        didSet {
            cancelButton?.highlightedBackgroundColor = buttonHighlightedBackgroundColor
            submitButton?.highlightedBackgroundColor = buttonHighlightedBackgroundColor
        }
    }
    
    @objc dynamic var buttonTitleAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor: UIColorBlue, NSAttributedString.Key.kern: 2] {
        didSet {
            if let cancelTitle = cancelButton?.attributedTitle(for: .normal)?.string {
                cancelButton?.setAttributedTitle(NSAttributedString(string: cancelTitle, attributes: buttonTitleAttributes), for: .normal)
            }
            if let submitTitle = submitButton?.attributedTitle(for: .normal)?.string {
                submitButton?.setAttributedTitle(NSAttributedString(string: submitTitle, attributes: buttonTitleAttributes), for: .normal)
            }
        }
    }

    private(set) var headerView: UIView!

    private(set) var headerViewSeparatorLayer: CALayer!

    /// dialog的主体内容部分，默认是一个空的白色UIView，建议设置为自己的UIView
    /// dialog会通过询问contentView的sizeThatFits得到当前内容的大小
    private var _contentView: UIView!
    var contentView: UIView! {
        get {
            return _contentView
        }
        set {
            if newValue != _contentView {
                _contentView.removeFromSuperview()
                _contentView = newValue
                if isViewLoaded {
                    view.insertSubview(_contentView, at: 0)
                }
                hasCustomContentView = true
            } else {
                hasCustomContentView = false
            }
        }
    }

    private(set) var footerView: UIView!
    private(set) var footerViewSeparatorLayer: CALayer!

    private(set) var cancelButton: QMUIButton?
    private(set) var submitButton: QMUIButton?
    private(set) var buttonSeparatorLayer: CALayer!

    private var hasCustomContentView: Bool = false
    private var cancelButtonClosure: ((QMUIDialogViewController) -> Void)?
    private var submitButtonClosure: ((QMUIDialogViewController) -> Void)?

    convenience init() {
        self.init(nibName: nil, bundle: nil)
        _didInitialized()
    }
    
    override init(nibName _: String?, bundle _: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func _didInitialized() {
        let dialogViewControllerAppearance = QMUIDialogViewController.appearance()
        cornerRadius = dialogViewControllerAppearance.cornerRadius
        dialogViewMargins = dialogViewControllerAppearance.dialogViewMargins.concat(insets: IPhoneXSafeAreaInsets)
        maximumContentViewWidth = dialogViewControllerAppearance.maximumContentViewWidth
        backgroundColor = dialogViewControllerAppearance.backgroundColor
        titleTintColor = dialogViewControllerAppearance.titleTintColor
        titleLabelFont = dialogViewControllerAppearance.titleLabelFont
        titleLabelTextColor = dialogViewControllerAppearance.titleLabelTextColor
        subTitleLabelFont = dialogViewControllerAppearance.subTitleLabelFont
        subTitleLabelTextColor = dialogViewControllerAppearance.subTitleLabelTextColor
        headerSeparatorColor = dialogViewControllerAppearance.headerSeparatorColor
        headerViewHeight = dialogViewControllerAppearance.headerViewHeight
        headerViewBackgroundColor = dialogViewControllerAppearance.headerViewBackgroundColor
        contentViewMargins = dialogViewControllerAppearance.contentViewMargins
        footerSeparatorColor = dialogViewControllerAppearance.footerSeparatorColor
        footerViewHeight = dialogViewControllerAppearance.footerViewHeight
        footerViewBackgroundColor = dialogViewControllerAppearance.footerViewBackgroundColor
        buttonBackgroundColor = dialogViewControllerAppearance.buttonBackgroundColor
        buttonTitleAttributes = dialogViewControllerAppearance.buttonTitleAttributes
        buttonHighlightedBackgroundColor = dialogViewControllerAppearance.buttonHighlightedBackgroundColor
    }
    
    override func setNavigationItems(_ isInEditMode: Bool, animated: Bool) {
        // 不继承父类的实现，从而避免把 titleView 放到 navigationItem 上
    }
    
    override func initSubviews() {
        super.initSubviews()
        
        if hasCustomContentView {
            if contentView.superview == nil {
                view.insertSubview(contentView, at: 0)
            }
        } else {
            _contentView = UIView() // 特地不使用setter，从而不要影响self.hasCustomContentView的默认值
            contentView.backgroundColor = UIColorWhite
            view.addSubview(contentView)
        }
        
        headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: headerViewHeight))
        headerView.backgroundColor = headerViewBackgroundColor
        
        // 使用自带的QMUINavigationTitleView，支持loading、subTitle
        headerView.addSubview(titleView!)
        
        // 加上分隔线
        headerViewSeparatorLayer = CALayer()
        headerViewSeparatorLayer.qmui_removeDefaultAnimations()
        headerViewSeparatorLayer.backgroundColor = headerSeparatorColor?.cgColor
        headerView.layer.addSublayer(headerViewSeparatorLayer)
        
        view.addSubview(headerView)
        
        initFooterViewIfNeeded()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // subview都在[super viewDidLoad]里添加，所以在添加完subview后再强制把headerView和footerView拉到最前面，以保证分隔线不会被subview盖住
        view.bringSubviewToFront(headerView)
        view.bringSubviewToFront(footerView)

        view.backgroundColor = UIColorClear // 减少Color Blended Layers
        view.layer.cornerRadius = cornerRadius
        view.layer.masksToBounds = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let isFooterViewShowing = !footerView.isHidden

        headerView.frame = CGSize(width: view.bounds.width, height: headerViewHeight).rect
        headerViewSeparatorLayer.frame = CGRect(x: 0, y: headerView.bounds.height, width: headerView.bounds.width, height: PixelOne)
        let headerViewPaddingHorizontal: CGFloat = 16
        let headerViewContentWidth = headerView.bounds.width - headerViewPaddingHorizontal * 2
        let titleViewSize = titleView?.sizeThatFits(CGSize(width: headerViewContentWidth, height: .greatestFiniteMagnitude)) ?? .zero
        let titleViewWidth = fmin(titleViewSize.width, headerViewContentWidth)
        titleView?.frame = CGRect(x: headerView.bounds.width.center(titleViewWidth), y: headerView.bounds.height.center(titleViewSize.height), width: titleViewWidth, height: titleViewSize.height)

        if isFooterViewShowing {
            footerView.frame = CGRect(x: 0, y: view.bounds.height - footerViewHeight, width: view.bounds.width, height: footerViewHeight)
            footerViewSeparatorLayer.frame = CGRect(x: 0, y: -PixelOne, width: footerView.bounds.width, height: PixelOne)

            let buttonCount: Int = footerView.subviews.count
            if buttonCount == 1 {
                let button = cancelButton ?? submitButton
                button?.frame = footerView.bounds
                buttonSeparatorLayer.isHidden = true
            } else {
                let buttonWidth = flat(footerView.bounds.width / CGFloat(buttonCount))
                cancelButton?.frame = CGSize(width: buttonWidth, height: footerView.bounds.height).rect
                let maxX = cancelButton?.frame.maxX ?? 0
                submitButton?.frame = CGRect(x: maxX, y: 0, width: footerView.bounds.width - maxX, height: footerView.bounds.height)
                buttonSeparatorLayer.isHidden = false
                buttonSeparatorLayer.frame = CGRect(x: maxX, y: 0, width: PixelOne, height: footerView.bounds.height)
            }
        }

        let contentViewMinY = headerView.frame.maxY + contentViewMargins.top
        let contentViewHeight = (isFooterViewShowing ? (footerView.frame.minY - contentViewMargins.bottom) : view.bounds.height) - contentViewMinY
        contentView.frame = CGRect(x: contentViewMargins.left, y: contentViewMinY, width: view.bounds.width - contentViewMargins.horizontalValue, height: contentViewHeight)
    }

    func initFooterViewIfNeeded() {
        if footerView != nil {
            return
        }
        
        footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: footerViewHeight))
        footerView.backgroundColor = footerViewBackgroundColor
        footerView.isHidden = true

        footerViewSeparatorLayer = CALayer()
        footerViewSeparatorLayer.qmui_removeDefaultAnimations()
        footerViewSeparatorLayer.backgroundColor = footerSeparatorColor?.cgColor
        footerView.layer.addSublayer(footerViewSeparatorLayer)

        buttonSeparatorLayer = CALayer()
        buttonSeparatorLayer.qmui_removeDefaultAnimations()
        buttonSeparatorLayer.backgroundColor = footerViewSeparatorLayer.backgroundColor
        buttonSeparatorLayer.isHidden = true
        footerView.layer.addSublayer(buttonSeparatorLayer)

        view.addSubview(footerView)
    }

    func addCancelButton(with buttonText: String, handler: ((QMUIDialogViewController) -> Void)?) {
        cancelButton?.removeFromSuperview()

        cancelButton = generateButton(with: buttonText)
        cancelButton?.addTarget(self, action: #selector(handleCancelButtonEvent), for: .touchUpInside)

        initFooterViewIfNeeded()
        footerView.isHidden = false
        footerView.addSubview(cancelButton!)

        cancelButtonClosure = handler
    }

    func addSubmitButton(with buttonText: String, handler: ((QMUIDialogViewController) -> Void)?) {
        submitButton?.removeFromSuperview()

        submitButton = generateButton(with: buttonText)
        submitButton?.addTarget(self, action: #selector(handleSubmitButtonEvent), for: .touchUpInside)

        initFooterViewIfNeeded()
        footerView.isHidden = false
        footerView.addSubview(submitButton!)

        submitButtonClosure = handler
    }

    private func generateButton(with buttonText: String) -> QMUIButton {
        let button = QMUIButton()
        button.titleLabel?.font = UIFontBoldMake((IS_320WIDTH_SCREEN) ? 14 : 15)
        button.adjustsTitleTintColorAutomatically = true
        button.backgroundColor = buttonBackgroundColor
        button.highlightedBackgroundColor = buttonHighlightedBackgroundColor
        button.setAttributedTitle(NSAttributedString(string: buttonText, attributes: buttonTitleAttributes), for: .normal)
        return button
    }

    func show(with _: Bool = true, completion: ((Bool) -> Void)? = nil) {
        let modalPresentationViewController = QMUIModalPresentationViewController()
        modalPresentationViewController.contentViewMargins = contentViewMargins
        modalPresentationViewController.contentViewController = self
        modalPresentationViewController.isModal = true
        modalPresentationViewController.show(true, completion: completion)
    }

    func hide(with animated: Bool = true, completion: ((Bool) -> Void)? = nil) {
        qmui_modalPresentationViewController?.hide(animated, completion: { (finished) in
            completion?(finished)
        })
    }

    @objc func handleCancelButtonEvent(_: QMUIButton) {
        hide(with: true) { _ in
            self.cancelButtonClosure?(self)
        }
    }

    @objc func handleSubmitButtonEvent(_: QMUIButton) {
        // 把自己传过去，方便在block里调用self时不会导致内存泄露
        submitButtonClosure?(self)
    }
}

extension QMUIDialogViewController: QMUIModalPresentationContentViewControllerProtocol {
    @objc func preferredContentSize(inModalPresentationViewController _: QMUIModalPresentationViewController, limitSize: CGSize) -> CGSize {
        if !hasCustomContentView {
            return limitSize
        }

        let isFooterViewShowing = !footerView.isHidden
        let footerHeight = isFooterViewShowing ? self.footerViewHeight : 0
        
        let contentViewVerticalMargin = contentViewMargins.verticalValue

        let contentViewLimitSize = CGSize(width: limitSize.width, height: limitSize.height - headerViewHeight - contentViewVerticalMargin - footerHeight)
        let contentViewSize = contentView.sizeThatFits(contentViewLimitSize)

        let finalSize = CGSize(width: min(limitSize.width, contentViewSize.width), height: min(limitSize.height, headerViewHeight + contentViewSize.height + contentViewVerticalMargin + footerHeight))
        return finalSize
    }
}

extension QMUIDialogViewController {
    
    static func appearance() -> QMUIDialogViewController {
        DispatchQueue.once(token: QMUIDialogViewController._onceToken) {
            let dialogViewControllerAppearance = QMUIDialogViewController(nibName: nil, bundle: nil)
            dialogViewControllerAppearance.cornerRadius = 6
            dialogViewControllerAppearance.dialogViewMargins = UIEdgeInsets.init(top: 20, left: 20, bottom: 20, right: 20) // 在实例的 didInitialized 里会适配 iPhone X 的 safeAreaInsets
            dialogViewControllerAppearance.maximumContentViewWidth = QMUIHelper.screenSizeFor55Inch.width - dialogViewControllerAppearance.dialogViewMargins.horizontalValue
            dialogViewControllerAppearance.backgroundColor = UIColorClear
            dialogViewControllerAppearance.titleTintColor = UIColorBlack
            dialogViewControllerAppearance.titleLabelFont = UIFontMake(16)
            dialogViewControllerAppearance.titleLabelTextColor = UIColor(r: 53, g: 60, b: 70)
            dialogViewControllerAppearance.subTitleLabelFont = UIFontMake(12)
            dialogViewControllerAppearance.subTitleLabelTextColor = UIColor(r: 133, g: 140, b: 150)
            
            dialogViewControllerAppearance.headerSeparatorColor = UIColor(r: 222, g: 224, b: 226)
            dialogViewControllerAppearance.headerViewHeight = 48
            dialogViewControllerAppearance.headerViewBackgroundColor = UIColor(r: 244, g: 245, b: 247)
            dialogViewControllerAppearance.contentViewMargins = .zero;
            dialogViewControllerAppearance.footerSeparatorColor = UIColor(r: 222, g: 224, b: 226)
            dialogViewControllerAppearance.footerViewHeight = 48
            dialogViewControllerAppearance.footerViewBackgroundColor = UIColorWhite
            
            dialogViewControllerAppearance.buttonBackgroundColor = nil
            dialogViewControllerAppearance.buttonTitleAttributes = [NSAttributedString.Key.foregroundColor: UIColorBlue, NSAttributedString.Key.kern: 2]
            dialogViewControllerAppearance.buttonHighlightedBackgroundColor = UIColorBlue.withAlphaComponent(0.25)
            
            QMUIDialogViewController.dialogViewControllerAppearance = dialogViewControllerAppearance
        }
        return QMUIDialogViewController.dialogViewControllerAppearance!
    }
    
    private static let _onceToken = UUID().uuidString
    
    static var dialogViewControllerAppearance: QMUIDialogViewController?
}

/**
 *  支持列表选择的弹窗，通过 `items` 指定要展示的所有选项（暂时只支持`NSString`）。默认使用单选，可通过 `allowsMultipleSelection` 支持多选。
 *  单选模式下，通过 `selectedItemIndex` 可获取当前被选中的选项，也可在初始化完dialog后设置这个属性来达到默认值的效果。
 *  多选模式下，通过 `selectedItemIndexes` 可获取当前被选中的多个选项，可也在初始化完dialog后设置这个属性来达到默认值的效果。
 */
class QMUIDialogSelectionViewController: QMUIDialogViewController {
    private(set) var tableView: QMUITableView!

    var items: [String]!

    /// 表示单选模式下已选中的item序号，默认为QMUIDialogSelectionViewControllerSelectedItemIndexNone。此属性与 `selectedItemIndexes` 互斥。
    var selectedItemIndex: Int! {
        didSet {
            if selectedItemIndexes != nil && selectedItemIndexes.count > 0 {
                selectedItemIndexes.removeAll()
            }
        }
    }

    /// 表示多选模式下已选中的item序号，默认为nil。此属性与 `selectedItemIndex` 互斥。
    var selectedItemIndexes: Set<Int>! {
        didSet {
            if selectedItemIndex != QMUIDialogSelectionViewControllerSelectedItemIndexNone {
                selectedItemIndex = QMUIDialogSelectionViewControllerSelectedItemIndexNone
            }
        }
    }

    /// 控制是否允许多选，默认为false。
    var allowsMultipleSelection: Bool = false {
        didSet {
            selectedItemIndex = QMUIDialogSelectionViewControllerSelectedItemIndexNone
        }
    }

    var cellForItemClosure: ((QMUIDialogSelectionViewController, QMUITableViewCell, Int) -> Void)?
    var heightForItemClosure: ((QMUIDialogSelectionViewController, Int) -> CGFloat)?
    var canSelectItemClosure: ((QMUIDialogSelectionViewController, Int) -> Bool)?
    var didSelectItemClosure: ((QMUIDialogSelectionViewController, Int) -> Void)?
    var didDeselectItemClosure: ((QMUIDialogSelectionViewController, Int) -> Void)?

    override func didInitialized() {
        super.didInitialized()
        
        selectedItemIndex = QMUIDialogSelectionViewControllerSelectedItemIndexNone
        selectedItemIndexes = Set<Int>()
        
        if #available(iOS 9.0, *) {
            loadViewIfNeeded()
        } else {
            let alpha = view.alpha
            view.alpha = alpha
        }
    }

    override func initSubviews() {
        super.initSubviews()
        tableView = QMUITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.alwaysBounceVertical = false
        
        // 因为要根据 tableView sizeThatFits: 算出 dialog 的高度，所以禁用 estimated 特性，不然算出来结果不准确
        tableView.estimatedRowHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        
        view.addSubview(tableView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let tableViewMinY = headerView.frame.maxY + contentViewMargins.top
        let tableViewHeight = view.bounds.height - tableViewMinY - (!footerView.isHidden ? (footerView.frame.height + contentViewMargins.bottom) : 0)
        tableView.frame = CGRect(x: contentViewMargins.left, y: tableViewMinY, width: view.bounds.width - contentViewMargins.horizontalValue, height: tableViewHeight)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 当前的分组不在可视区域内，则滚动到可视区域（只对单选有效）

        let indexPath = IndexPath(item: selectedItemIndex, section: 0)
        
        if selectedItemIndex != QMUIDialogSelectionViewControllerSelectedItemIndexNone && selectedItemIndex < items.count && tableView.qmui_cellVisible(at: indexPath) {
            tableView.scrollToRow(at: indexPath, at: .middle, animated: animated)
        }
    }
}

extension QMUIDialogSelectionViewController: QMUITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "cell"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? QMUITableViewCell
        if cell == nil {
            cell = QMUITableViewCell(tableView: tableView, style: .subtitle, reuseIdentifier: identifier)
        }
        cell?.textLabel?.text = items[indexPath.row]

        if allowsMultipleSelection {
            // 多选
            if selectedItemIndexes.contains(indexPath.row) {
                cell?.accessoryType = .checkmark
            } else {
                cell?.accessoryType = .none
            }
        } else {
            // 单选
            if selectedItemIndex == indexPath.row {
                cell?.accessoryType = .checkmark
            } else {
                cell?.accessoryType = .none
            }
        }

        cell?.updateCellAppearance(indexPath)
        cellForItemClosure?(self, cell!, indexPath.row)
        return cell ?? UITableViewCell()
    }
}

extension QMUIDialogSelectionViewController: QMUITableViewDelegate {
    func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let heightForItemClosure = heightForItemClosure {
            return heightForItemClosure(self, indexPath.row)
        }
        return TableViewCellNormalHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 单选情况下如果重复选中已被选中的cell，则什么都不做
        if !allowsMultipleSelection && selectedItemIndex == indexPath.row {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }

        // 不允许选中当前cell，直接return
        if let handler = canSelectItemClosure, !handler(self, indexPath.row) {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }

        if allowsMultipleSelection {

            if selectedItemIndexes.contains(indexPath.row) {
                // 当前的cell已经被选中，则取消选中
                selectedItemIndexes.remove(indexPath.row)
                didDeselectItemClosure?(self, indexPath.row)
            } else {
                selectedItemIndexes.insert(indexPath.row)
                didSelectItemClosure?(self, indexPath.row)
            }

            if tableView.qmui_cellVisible(at: indexPath) {
                tableView.reloadRows(at: [indexPath], with: .fade)
            }
        } else {
            var isSelectedIndexPathBeforeVisible = false

            // 选中新的cell时，先反选之前被选中的那个cell
            var selectedIndexPathBefore: IndexPath!
            if selectedItemIndex != QMUIDialogSelectionViewControllerSelectedItemIndexNone {
                selectedIndexPathBefore = IndexPath(row: selectedItemIndex, section: 0)
                didDeselectItemClosure?(self, selectedIndexPathBefore.row)
                isSelectedIndexPathBeforeVisible = tableView.qmui_cellVisible(at: selectedIndexPathBefore)
            }

            selectedItemIndex = indexPath.row

            // 如果之前被选中的那个cell也在可视区域里，则也要用动画去刷新它，否则只需要用动画刷新当前已选中的cell即可，之前被选中的那个交给cellForRow去刷新
            if isSelectedIndexPathBeforeVisible {
                tableView.reloadRows(at: [selectedIndexPathBefore, indexPath], with: .fade)
            } else {
                tableView.reloadRows(at: [indexPath], with: .fade)
            }

            didSelectItemClosure?(self, indexPath.row)
        }
    }
}

extension QMUIDialogSelectionViewController {

    // MARK: - QMUIModalPresentationContentViewControllerProtocol

    override func preferredContentSize(inModalPresentationViewController _: QMUIModalPresentationViewController, limitSize: CGSize) -> CGSize {
        let contentViewVerticalMargin = contentViewMargins.verticalValue
        let footerHeight = !footerView.isHidden ? footerView.frame.height : 0
        let tableViewLimitHeight = limitSize.height - headerView.frame.height - footerHeight - contentViewVerticalMargin
        let tableViewSize = tableView.sizeThatFits(CGSize(width: limitSize.width, height: tableViewLimitHeight))
        let finalTableViewHeight = fmin(tableViewSize.height, tableViewLimitHeight)
        return CGSize(width: limitSize.width, height: headerView.frame.height + finalTableViewHeight + contentViewVerticalMargin + footerHeight)
    }
}

/**
 * 支持单行文本输入的弹窗，可通过`maximumLength`属性来控制最长可输入的字符，超过则无法继续输入。
 * 可通过`enablesSubmitButtonAutomatically`来自动设置`submitButton.enabled`的状态
 */
class QMUIDialogTextFieldViewController: QMUIDialogViewController {
    
    /// 输入框的标题
    var textFieldTitle: String! {
        didSet {
            if !textFieldTitle.isEmpty {
                textFieldLabel.isHidden = false
                textFieldLabel.text = textFieldTitle
            } else {
                textFieldLabel.isHidden = true
            }
            view.setNeedsLayout()
        }
    }
    
    /// 输入框Label
    private(set) var textFieldLabel: QMUILabel!
    
    /// 输入框底部分隔线
    private(set) var textFieldSeparatorLayer: CALayer!
    
    /// 输入框
    private(set) var textField: QMUITextField!
    
    /// 是否应该自动管理输入框的键盘 Return 事件，默认为 YES，YES 表示当点击 Return 按钮时，视为点击了 dialog 的 submit 按钮。你也可以通过 UITextFieldDelegate 自己管理，此时请将此属性置为 NO
    var shouldManageTextFieldsReturnEventAutomatically: Bool!
    
    /// 是否自动控制提交按钮的enabled状态，默认为YES，则当输入框内容为空时禁用提交按钮
    var enablesSubmitButtonAutomatically: Bool! {
        didSet {
            textField?.enablesReturnKeyAutomatically = enablesSubmitButtonAutomatically
            if enablesSubmitButtonAutomatically {
                updateSubmitButtonEnables()
            }
        }
    }

    var shouldEnableSubmitButtonClosure: ((QMUIDialogTextFieldViewController) -> Bool)?
    
    override func didInitialized() {
        super.didInitialized()
        shouldManageTextFieldsReturnEventAutomatically = true
        enablesSubmitButtonAutomatically = true
        if #available(iOS 9.0, *) {
            loadViewIfNeeded()
        } else {
            let alpha = view.alpha
            view.alpha = alpha
        }
    }

    override func initSubviews() {
        super.initSubviews()
        
        textField = QMUITextField()
        textField.delegate = self
        textField.backgroundColor = UIColorWhite
        textField.textInsets = UIEdgeInsets(top: textField.textInsets.top, left: 16, bottom: textField.textInsets.bottom, right: 16)
        textField.returnKeyType = .done
        textField.enablesReturnKeyAutomatically = enablesSubmitButtonAutomatically
        textField.addTarget(self, action: #selector(handleTextFieldTextDidChangeEvent), for: .editingChanged)
        view.addSubview(textField)
        
        textFieldLabel = QMUILabel()
        textFieldLabel.font = UIFontBoldMake(12)
        textFieldLabel.contentEdgeInsets = UIEdgeInsets(top: 11, left: 16, bottom: 8, right: 16)
        textFieldLabel.text = ""
        textFieldLabel.isHidden = true
        view.addSubview(textFieldLabel)
        
        textFieldSeparatorLayer = CALayer()
        textFieldSeparatorLayer.qmui_removeDefaultAnimations()
        textFieldSeparatorLayer.backgroundColor = UIColorSeparator.cgColor
        view.layer.addSublayer(textFieldSeparatorLayer)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var minY = headerView.frame.maxY + contentViewMargins.top
        let horizontalMargin = contentViewMargins.horizontalValue
        let widthLimit = view.bounds.width - horizontalMargin
        let separatorOffsetY: CGFloat = 13
        
        if !textFieldLabel.isHidden {
            textFieldLabel.sizeToFit()
            textFieldLabel.frame = CGRect(x: contentViewMargins.left, y: minY, width: widthLimit, height: textFieldLabel.bounds.height)
            minY += textFieldLabel.bounds.height
        }
        
        var textFieldHeight: CGFloat = 0
        if footerView.isHidden {
            textFieldHeight = view.bounds.height - contentViewMargins.bottom - minY
        } else {
            textFieldHeight = footerView.frame.minY - contentViewMargins.bottom - minY
        }
        
        textField.frame = CGRect(x: contentViewMargins.left, y: minY, width: widthLimit, height: textFieldHeight)
        textFieldSeparatorLayer.frame = CGRect(x: contentViewMargins.left + textField.textInsets.left, y: textField.frame.maxY  - PixelOne + separatorOffsetY, width: widthLimit - textField.textInsets.left - textField.textInsets.right, height: PixelOne)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textField.becomeFirstResponder()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        textField.resignFirstResponder()
    }

    private func updateSubmitButtonEnables() {
        submitButton?.isEnabled = shouldEnabledSubmitButton
    }

    private var shouldEnabledSubmitButton: Bool {
        if let shouldEnableSubmitButtonClosure = shouldEnableSubmitButtonClosure {
            return shouldEnableSubmitButtonClosure(self)
        }

        if enablesSubmitButtonAutomatically {
            let textLength = textField.text?.qmui_trim.length ?? 0
            return 0 < textLength && textLength <= textField.maximumTextLength
        }

        return true
    }

    @objc func handleTextFieldTextDidChangeEvent(_ textField: QMUITextField) {
        if self.textField == textField {
            updateSubmitButtonEnables()
        }
    }

    override func addSubmitButton(with buttonText: String, handler: ((QMUIDialogViewController) -> Void)?) {
        super.addSubmitButton(with: buttonText, handler: handler)
        updateSubmitButtonEnables()
    }

    override func preferredContentSize(inModalPresentationViewController _: QMUIModalPresentationViewController, limitSize: CGSize) -> CGSize {
        let textFieldHeight: CGFloat = textFieldLabel.isHidden ? 56 : 25
        // 25.0 考虑了行高导致的 offsetoffset
        let textFieldTitleHeight: CGFloat = 29
        let result = CGSize(width: limitSize.width, height: headerView.frame.height + contentViewMargins.verticalValue +  textFieldHeight + (!textFieldLabel.isHidden ? textFieldTitleHeight : 0) + textFieldHeight + (!footerView.isHidden ?  footerView.frame.height : 0))
        return result
    }
}

extension QMUIDialogTextFieldViewController: QMUITextFieldDelegate {
    
    // MARK: TODO delegate 有修改
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if !shouldManageTextFieldsReturnEventAutomatically {
            return false
        }
        
        if textField != self.textField {
            return false
        }
        
        // 有 submitButton 则响应它，没有的话响应 cancel，再没有就降下键盘即可（体验与 UIAlertController 一致）
        
        if submitButton != nil && submitButton!.isEnabled {
            submitButton!.sendActions(for: .touchUpInside)
            return false
        }
        
        if cancelButton != nil {
            cancelButton!.sendActions(for: .touchUpInside)
            return false
        }
        
        view.endEditing(true)
        return false
    }
    
}
