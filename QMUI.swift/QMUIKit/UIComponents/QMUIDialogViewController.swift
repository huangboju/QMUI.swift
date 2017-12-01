//
//  QMUIDialogViewController.swift
//  QMUI.swift
//
//  Created by 黄伯驹 on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

/**
 * 弹窗组件基类，自带`headerView`、`contentView`、`footerView`，并通过`addCancelButtonWithText:block:`、`addSubmitButtonWithText:block:`方法来添加取消、确定按钮。
 * 建议将一个自定义的UIView设置给`contentView`属性，此时弹窗将会自动帮你计算大小并布局。大小取决于你的contentView的sizeThatFits:返回值。
 * 弹窗继承自`QMUICommonViewController`，因此可直接使用self.titleView的功能来实现双行标题，具体请查看`QMUINavigationTitleView`。
 * `QMUIDialogViewController`支持以类似`UIAppearance`的方式来统一设置全局的dialog样式，例如`[QMUIDialogViewController appearance].headerViewHeight = 48`。
 *
 * @see QMUIDialogSelectionViewController
 * @see QMUIDialogTextFieldViewController
 */
class QMUIDialogViewController: QMUICommonViewController {
    public var cornerRadius: CGFloat = 6 {
        didSet {
            if isViewLoaded {
                view.layer.cornerRadius = cornerRadius
            }
        }
    }
    public var contentViewMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    public var titleTintColor = UIColorBlack {
        didSet {
            titleView?.tintColor = titleTintColor
        }
    }
    public var titleLabelFont = UIFontMake(16) {
        didSet {
            titleView?.titleLabel.font = titleLabelFont
        }
    }
    public var titleLabelTextColor = UIColor(r: 53, g: 60, b: 70) {
        didSet {
            titleView?.titleLabel.textColor = titleLabelTextColor
        }
    }
    public var subTitleLabelFont = UIFontMake(12) {
        didSet {
            titleView?.subtitleLabel.font = subTitleLabelFont
        }
    }
    public var subTitleLabelTextColor = UIColor(r: 133, g: 140, b: 150) {
        didSet {
            titleView?.subtitleLabel.textColor = subTitleLabelTextColor
        }
    }
    public var headerFooterSeparatorColor = UIColor(r: 222, g: 224, b: 226) {
        didSet {
            headerViewSeparatorLayer.backgroundColor = headerFooterSeparatorColor.cgColor
            footerViewSeparatorLayer.backgroundColor = headerFooterSeparatorColor.cgColor
            buttonSeparatorLayer.backgroundColor = headerFooterSeparatorColor.cgColor
        }
    }
    public var headerViewHeight: CGFloat = 48
    public var headerViewBackgroundColor = UIColor(r: 244, g: 245, b: 247) {
        didSet {
            if isViewLoaded {
                headerView.backgroundColor = headerViewBackgroundColor
            }
        }
    }
    public var footerViewHeight: CGFloat = 48
    public var footerViewBackgroundColor = UIColorWhite {
        didSet {
            footerView.backgroundColor = footerViewBackgroundColor
        }
    }
    public var buttonTitleAttributes: [NSAttributedStringKey: Any] = [.foregroundColor: UIColorBlue, .kern: 2] {
        didSet {
            if let cancelTitle = cancelButton?.attributedTitle(for: .normal)?.string {
                cancelButton?.setAttributedTitle(NSAttributedString(string: cancelTitle, attributes: buttonTitleAttributes), for: .normal)
            }
            if let submitTitle = submitButton?.attributedTitle(for: .normal)?.string {
                submitButton?.setAttributedTitle(NSAttributedString(string: submitTitle, attributes: buttonTitleAttributes), for: .normal)
            }
        }
    }
    public var buttonHighlightedBackgroundColor = UIColorBlue.withAlphaComponent(0.25) {
        didSet {
            cancelButton?.highlightedBackgroundColor = buttonHighlightedBackgroundColor
            submitButton?.highlightedBackgroundColor = buttonHighlightedBackgroundColor
        }
    }

    public let headerView = UIView()
    public let headerViewSeparatorLayer = CALayer()

    /// dialog的主体内容部分，默认是一个空的白色UIView，建议设置为自己的UIView
    /// dialog会通过询问contentView的sizeThatFits得到当前内容的大小
    public var contentView = UIView() {
        didSet {
            if contentView != oldValue {
                oldValue.removeFromSuperview()
                if isViewLoaded {
                    view.insertSubview(contentView, at: 0)
                }
                hasCustomContentView = true
            } else {
                hasCustomContentView = false
            }
        }
    }

    public let footerView = UIView()
    public let footerViewSeparatorLayer = CALayer()
    
    public private(set) var cancelButton: QMUIButton?
    public private(set) var submitButton: QMUIButton?
    public let buttonSeparatorLayer = CALayer()

    private var hasCustomContentView = false
    private var cancelButtonBlock: ((QMUIDialogViewController) -> Void)?
    private var submitButtonBlock: ((QMUIDialogViewController) -> Void)?
    
    override func setNavigationItems(isInEditMode model: Bool, animated: Bool) {
        // 不继承父类的实现，从而避免把 titleView 放到 navigationItem 上
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // subview都在[super viewDidLoad]里添加，所以在添加完subview后再强制把headerView和footerView拉到最前面，以保证分隔线不会被subview盖住
        view.bringSubview(toFront: headerView)
        view.bringSubview(toFront: footerView)

        view.backgroundColor = UIColorClear// 减少Color Blended Layers
        view.layer.cornerRadius = cornerRadius
        view.layer.masksToBounds = true
    }
    
    override func initSubviews() {
        super.initSubviews()
        
        if hasCustomContentView {
            if contentView.superview == nil {
                view.insertSubview(contentView, at: 0)
            }
        } else {
//            _contentView = [[UIView alloc] init]// 特地不使用setter，从而不要影响self.hasCustomContentView的默认值
            contentView.backgroundColor = UIColorWhite
            view.addSubview(contentView)
        }
        
        headerView.frame = CGSize(width: view.bounds.width, height: headerViewHeight).rect
        headerView.backgroundColor = headerViewBackgroundColor

        // 使用自带的QMUINavigationTitleView，支持loading、subTitle
        headerView.addSubview(titleView!)

        // 加上分隔线

        headerViewSeparatorLayer.qmui_removeDefaultAnimations()
        headerViewSeparatorLayer.backgroundColor = headerFooterSeparatorColor.cgColor
        headerView.layer.addSublayer(headerViewSeparatorLayer)

        view.addSubview(headerView)

        initFooterViewIfNeeded()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let isFooterViewShowing = !footerView.isHidden
        
        

        headerView.frame = CGSize(width: view.bounds.width, height: headerViewHeight).rect
        headerViewSeparatorLayer.frame = CGRect(x: 0, y: headerView.bounds.height, width: headerView.bounds.width, height: PixelOne)
        let headerViewPaddingHorizontal: CGFloat = 16
        let headerViewContentWidth = headerView.bounds.width - headerViewPaddingHorizontal * 2
        let titleViewSize = titleView?.sizeThatFits(CGSize(width: headerViewContentWidth, height: .greatestFiniteMagnitude)) ?? .zero
        let titleViewWidth = min(titleViewSize.width, headerViewContentWidth)
        titleView?.frame = CGRect(x: headerView.bounds.width.center(with: titleViewWidth), y: headerView.bounds.height.center(with: titleViewSize.height), width: titleViewWidth, height: titleViewSize.height)

        if isFooterViewShowing {
            footerView.frame = CGRect(x: 0, y: view.bounds.height - footerViewHeight, width: view.bounds.width, height: footerViewHeight)
            footerViewSeparatorLayer.frame = CGRect(x: 0, y: -PixelOne, width: footerView.bounds.width, height: PixelOne)

            let buttonCount = CGFloat(footerView.subviews.count)
            if buttonCount == 1 {
                let button = cancelButton ?? submitButton
                button?.frame = footerView.bounds
                buttonSeparatorLayer.isHidden = true
            } else {
                let buttonWidth = flat(footerView.bounds.width / buttonCount)
                cancelButton?.frame = CGSize(width: buttonWidth, height: footerView.bounds.height).rect
                let maxX = cancelButton?.frame.maxX ?? 0
                submitButton?.frame = CGRect(x: maxX, y: 0, width: footerView.bounds.width - maxX, height: footerView.bounds.height)
                buttonSeparatorLayer.isHidden = false
                buttonSeparatorLayer.frame = CGRect(x: maxX, y: 0, width: PixelOne, height: footerView.bounds.height)
            }
        }

        let contentViewMinY = headerView.frame.maxY
        let contentViewHeight = (isFooterViewShowing ? footerView.frame.minY : view.bounds.height) - contentViewMinY
        contentView.frame = CGRect(x: 0, y: contentViewMinY, width: view.bounds.width, height: contentViewHeight)
    }

    func initFooterViewIfNeeded() {
        footerView.frame = CGSize(width: view.bounds.width, height: footerViewHeight).rect
        footerView.backgroundColor = footerViewBackgroundColor
        footerView.isHidden = true

        footerViewSeparatorLayer.qmui_removeDefaultAnimations()

        footerViewSeparatorLayer.backgroundColor = headerFooterSeparatorColor.cgColor
        footerView.layer.addSublayer(footerViewSeparatorLayer)

        buttonSeparatorLayer.qmui_removeDefaultAnimations()
        buttonSeparatorLayer.backgroundColor = footerViewSeparatorLayer.backgroundColor
        buttonSeparatorLayer.isHidden = true
        footerView.layer.addSublayer(buttonSeparatorLayer)

        view.addSubview(footerView)
    }

    public func addCancelButton(with buttonText: String, block: ((QMUIDialogViewController) -> Void)?) {
        cancelButton?.removeFromSuperview()

        cancelButton = generateButton(with: buttonText)
        cancelButton?.addTarget(self, action: #selector(handleCancelButtonEvent), for: .touchUpInside)

        initFooterViewIfNeeded()
        footerView.isHidden = false
        footerView.addSubview(cancelButton!)

        cancelButtonBlock = block
    }

    public func addSubmitButton(with buttonText: String, block: ((QMUIDialogViewController) -> Void)?) {
        submitButton?.removeFromSuperview()
        
        submitButton = generateButton(with: buttonText)
        submitButton?.addTarget(self, action: #selector(handleSubmitButtonEvent), for: .touchUpInside)

        initFooterViewIfNeeded()
        footerView.isHidden = false
        footerView.addSubview(submitButton!)

        submitButtonBlock = block
    }

    private func generateButton(with buttonText: String) -> QMUIButton {
        let button = QMUIButton()
        button.titleLabel?.font = UIFontBoldMake(15)
        button.adjustsTitleTintColorAutomatically = true
        button.highlightedBackgroundColor = buttonHighlightedBackgroundColor
        button.setAttributedTitle(NSAttributedString(string: buttonText, attributes: buttonTitleAttributes), for: .normal)
        return button
    }

    public func show(with animated: Bool = true, completion: ((Bool) -> Void)? = nil) {
        let modalPresentationViewController = QMUIModalPresentationViewController()
        modalPresentationViewController.contentViewMargins = contentViewMargins
        modalPresentationViewController.contentViewController = self
        modalPresentationViewController.isModal = true
        modalPresentationViewController.show(with: true, completion: completion)
    }

    public func hide(with animated: Bool = true, completion: ((Bool) -> Void)? = nil) {
        modalPresentedViewController?.hide(with: animated, completion: completion)
    }

    @objc func handleCancelButtonEvent(_ cancelButton: QMUIButton) {
        hide(with: true) { _ in
            self.cancelButtonBlock?(self)
        }
    }
    
    @objc func handleSubmitButtonEvent(_ submitButton: QMUIButton) {
        submitButtonBlock?(self)
    }
}

extension QMUIDialogViewController: QMUIModalPresentationContentViewControllerProtocol {
    @objc func preferredContentSize(in modalPresentationViewController: QMUIModalPresentationViewController, limitSize: CGSize) -> CGSize {
        if !hasCustomContentView {
            return limitSize
        }

        let isFooterViewShowing = !footerView.isHidden
        let footerViewHeight = isFooterViewShowing ? self.footerViewHeight : 0

        let contentViewLimitSize = CGSize(width: limitSize.width, height: limitSize.height - headerViewHeight - footerViewHeight)
        let contentViewSize = contentView.sizeThatFits(contentViewLimitSize)

        let finalSize = CGSize(width: min(limitSize.width, contentViewSize.width), height: min(limitSize.height, headerViewHeight + contentViewSize.height + footerViewHeight))
        return finalSize
    }
}

/**
 *  支持列表选择的弹窗，通过 `items` 指定要展示的所有选项（暂时只支持`NSString`）。默认使用单选，可通过 `allowsMultipleSelection` 支持多选。
 *  单选模式下，通过 `selectedItemIndex` 可获取当前被选中的选项，也可在初始化完dialog后设置这个属性来达到默认值的效果。
 *  多选模式下，通过 `selectedItemIndexes` 可获取当前被选中的多个选项，可也在初始化完dialog后设置这个属性来达到默认值的效果。
 */
class QMUIDialogSelectionViewController: QMUIDialogViewController {
    public let tableView = QMUITableView(frame: .zero, style: .plain)

    public var items: [String] = []

    /// 表示单选模式下已选中的item序号，默认为QMUIDialogSelectionViewControllerSelectedItemIndexNone。此属性与 `selectedItemIndexes` 互斥。
    public var selectedItemIndex = -1 {
        didSet {
            selectedItemIndexes.removeAll()
        }
    }
    
    /// 表示多选模式下已选中的item序号，默认为nil。此属性与 `selectedItemIndex` 互斥。
    public var selectedItemIndexes: Set<Int> = [] {
        didSet {
            selectedItemIndex = -1
        }
    }
    
    /// 控制是否允许多选，默认为false。
    public var allowsMultipleSelection = false {
        didSet {
            selectedItemIndex = -1
        }
    }
    
    public var cellForItemBlock: ((QMUIDialogSelectionViewController, QMUITableViewCell, Int) -> Void)?
    public var heightForItemBlock: ((QMUIDialogSelectionViewController, Int) -> CGFloat)?
    public var canSelectItemBlock: ((QMUIDialogSelectionViewController, Int) -> Bool)?
    public var didSelectItemBlock: ((QMUIDialogSelectionViewController, Int) -> Void)?
    public var didDeselectItemBlock: ((QMUIDialogSelectionViewController, Int) -> Void)?
    
    override func didInitialized() {
        super.didInitialized()
        if #available(iOS 9.0, *) {
            loadViewIfNeeded()
        }
    }
    
    override func initSubviews() {
        super.initSubviews()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.alwaysBounceVertical = false
        view.addSubview(tableView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let tableViewMinY = headerView.frame.maxY
        let tableViewHeight = view.bounds.height - tableViewMinY - (!footerView.isHidden ? footerView.frame.height : 0)
        tableView.frame = CGRect(x: 0, y: tableViewMinY, width: view.bounds.width, height: tableViewHeight)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 当前的分组不在可视区域内，则滚动到可视区域（只对单选有效）

        let indexPath = IndexPath(item: selectedItemIndex, section: 0)
        if (selectedItemIndex != -1 && selectedItemIndex < items.count && !tableView.qmui_cellVisible(at: indexPath)) {
            tableView.scrollToRow(at: indexPath, at: .middle, animated: animated)
        }
    }
}

extension QMUIDialogSelectionViewController: QMUITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "cell"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if cell == nil {
            cell = QMUITableViewCell(tableView: tableView, withStyle: .subtitle, reuseIdentifier: identifier)
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

        if let customCell = cell as? QMUITableViewCell {
            customCell.updateCellAppearance(with: indexPath)
            cellForItemBlock?(self, customCell, indexPath.row)
        }
        return cell!
    }
}

extension QMUIDialogSelectionViewController: QMUITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightForItemBlock?(self, indexPath.row) ?? TableViewCellNormalHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 单选情况下如果重复选中已被选中的cell，则什么都不做
        if (!allowsMultipleSelection && selectedItemIndex == indexPath.row) {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        // 不允许选中当前cell，直接return
        if let block = canSelectItemBlock, !block(self, indexPath.row) {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }

        if allowsMultipleSelection {
            
            if selectedItemIndexes.contains(indexPath.row) {
                // 当前的cell已经被选中，则取消选中
                selectedItemIndexes.remove(indexPath.row)
                didDeselectItemBlock?(self, indexPath.row)
            } else {
                selectedItemIndexes.insert(indexPath.row)
                didSelectItemBlock?(self, indexPath.row)
            }
            
            if tableView.qmui_cellVisible(at: indexPath) {
                tableView.reloadRows(at: [indexPath], with: .fade)
            }
        } else {
            var isSelectedIndexPathBeforeVisible = false
            
            // 选中新的cell时，先反选之前被选中的那个cell
            var selectedIndexPathBefore: IndexPath?
            if selectedItemIndex != -1 {
                selectedIndexPathBefore = IndexPath(row: selectedItemIndex, section: 0)
                didDeselectItemBlock?(self, selectedIndexPathBefore!.row)
                isSelectedIndexPathBeforeVisible = tableView.qmui_cellVisible(at: selectedIndexPathBefore!)
            }

            selectedItemIndex = indexPath.row
            
            // 如果之前被选中的那个cell也在可视区域里，则也要用动画去刷新它，否则只需要用动画刷新当前已选中的cell即可，之前被选中的那个交给cellForRow去刷新
            if isSelectedIndexPathBeforeVisible {
                tableView.reloadRows(at: [selectedIndexPathBefore!, indexPath], with: .fade)
            } else {
                tableView.reloadRows(at: [indexPath], with: .fade)
            }

            didSelectItemBlock?(self, indexPath.row)
        }
    }
}

extension QMUIDialogSelectionViewController {
    // MARK: - QMUIModalPresentationContentViewControllerProtocol
    override func preferredContentSize(in modalPresentationViewController: QMUIModalPresentationViewController, limitSize: CGSize) -> CGSize {
        let footerViewHeight = !footerView.isHidden ? footerView.frame.height : 0
        let tableViewLimitHeight = limitSize.height - headerView.frame.height - footerViewHeight
        let tableViewSize = tableView.sizeThatFits(CGSize(width: limitSize.width, height: tableViewLimitHeight))
        let finalTableViewHeight = min(tableViewSize.height, tableViewLimitHeight)
        return CGSize(width: limitSize.width, height: headerView.frame.height + finalTableViewHeight + footerViewHeight)
    }
}

/**
 * 支持单行文本输入的弹窗，可通过`maximumLength`属性来控制最长可输入的字符，超过则无法继续输入。
 * 可通过`enablesSubmitButtonAutomatically`来自动设置`submitButton.enabled`的状态
 */
class QMUIDialogTextFieldViewController: QMUIDialogViewController {
    private let textField = QMUITextField()
    
    /// 是否自动控制提交按钮的enabled状态，默认为YES，则当输入框内容为空时禁用提交按钮
    public var enablesSubmitButtonAutomatically = true {
        didSet {
            textField.enablesReturnKeyAutomatically = enablesSubmitButtonAutomatically
            if enablesSubmitButtonAutomatically {
                updateSubmitButtonEnables()
            }
        }
    }

    public var shouldEnableSubmitButtonBlock: ((QMUIDialogTextFieldViewController) -> Bool)?
    
    override func didInitialized() {
        super.didInitialized()
        if #available(iOS 9.0, *) {
            loadViewIfNeeded()
        } else {
            // Fallback on earlier versions
        }
    }
    
    override func initSubviews() {
        super.initSubviews()
        textField.backgroundColor = UIColorWhite;
        textField.textInsets.left = 16
        textField.textInsets.right = 16
        textField.returnKeyType = .done
        textField.enablesReturnKeyAutomatically = enablesSubmitButtonAutomatically
        textField.addTarget(self, action: #selector(handleTextFieldTextDidChangeEvent), for: .editingChanged)
        view.addSubview(textField)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        textField.frame = CGRect(x: 0, y: headerView.frame.maxY, width: view.bounds.width, height: (!footerView.isHidden ? footerView.frame.minY : view.bounds.height) - headerView.frame.maxY)
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

    var shouldEnabledSubmitButton: Bool {
        if let shouldEnableSubmitButtonBlock = shouldEnableSubmitButtonBlock {
            return shouldEnableSubmitButtonBlock(self)
        }
        
        if enablesSubmitButtonAutomatically {
            let textLength = textField.text?.qmui_trim.length ?? 0
            return 0 < textLength && textLength <= textField.maximumTextLength
        }

        return true
    }

    @objc func handleTextFieldTextDidChangeEvent(_ textField: QMUITextField) {
        if textField == textField {
            updateSubmitButtonEnables()
        }
    }

    override func addSubmitButton(with buttonText: String, block: ((QMUIDialogViewController) -> Void)?) {
        super.addSubmitButton(with: buttonText, block: block)
        updateSubmitButtonEnables()
    }
    
    override func preferredContentSize(in modalPresentationViewController: QMUIModalPresentationViewController, limitSize: CGSize) -> CGSize {
        let textFieldHeight: CGFloat = 56
        return CGSize(width: limitSize.width, height: headerView.frame.height + textFieldHeight + (!footerView.isHidden ?  self.footerView.frame.height : 0))
    }
}
