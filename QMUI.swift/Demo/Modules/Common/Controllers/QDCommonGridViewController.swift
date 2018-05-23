//
//  QDCommonGridViewController.swift
//  QMUI.swift
//
//  Created by TonyHan on 2018/3/6.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

class QDCommonGridViewController: QDCommonViewController {
    
    private(set) var dataSource: QMUIOrderedDictionary<String, UIImage> = [:]
    
    private(set) var gridView: QMUIGridView!
    
    private(set) var scrollView: UIScrollView!
    
    /// 子类继承，可以不调super
    open func initDataSource() {
        
    }
    
    open func didSelectCell(_ title: String) {
        
    }
    
    override func didInitialized() {
        super.didInitialized()
        initDataSource()
    }
    
    override func initSubviews() {
        super.initSubviews()
        
        scrollView = UIScrollView()
        view.addSubview(scrollView)
        
        gridView = QMUIGridView()
        for index in 0..<dataSource.count {
            let subview = generateButton(index)
            gridView.addSubview(subview)
        }
        scrollView.addSubview(gridView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        解决 bug。由于 qmui_UIViewController_viewDidLoad 在 tabBar set 方法发出通知后才进行添加通知，所以重新进行 set 一次，用来触发修改 SafeAreaInsets 的方法。
        if let tabBarController = tabBarController {
            let isHidden = tabBarController.tabBar.isHidden
            tabBarController.tabBar.isHidden = !isHidden
            tabBarController.tabBar.isHidden = isHidden
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds

        let gridViewWidth = scrollView.bounds.width - scrollView.qmui_safeAreaInsets.horizontalValue

        if view.bounds.width <= QMUIHelper.screenSizeFor55Inch.width {
            gridView.columnCount = 3
            let itemWidth = flat(gridViewWidth / CGFloat(gridView.columnCount))
            gridView.rowHeight = itemWidth
        } else {
            let minimumItemWidth = flat(QMUIHelper.screenSizeFor55Inch.width / 3)
            let maximumItemWidth = flat(gridViewWidth / 5.0)
            let freeSpacingWhenDisplayingMinimumCount = gridViewWidth / maximumItemWidth - floor(gridViewWidth / maximumItemWidth)
            let freeSpacingWhenDisplayingMaximumCount = gridViewWidth / minimumItemWidth - floor(gridViewWidth / minimumItemWidth)
            if freeSpacingWhenDisplayingMinimumCount < freeSpacingWhenDisplayingMaximumCount {
                // 按每行最少item的情况来布局的话，空间利用率会更高，所以按最少item来
                gridView.columnCount = Int(floor(gridViewWidth / maximumItemWidth))
                let itemWidth = floor(gridViewWidth / CGFloat(gridView.columnCount))
                gridView.rowHeight = itemWidth
            } else {
                gridView.columnCount = Int(floor(gridViewWidth / minimumItemWidth))
                let itemWidth = floor(gridViewWidth / CGFloat(gridView.columnCount))
                gridView.rowHeight = itemWidth
            }
        }

        for (index, item) in gridView.subviews.enumerated() {
            item.qmui_borderPosition = [.left, .top]

            if (index % gridView.columnCount == gridView.columnCount - 1) || (index == gridView.subviews.count - 1) {
                // 每行最后一个，或者所有的最后一个（因为它可能不是所在行的最后一个）
                item.qmui_borderPosition = item.qmui_borderPosition.union([.right])
            }
            if (index + gridView.columnCount >= gridView.subviews.count) {
                // 那些下方没有其他 item 的 item，底部都加个边框
                item.qmui_borderPosition = item.qmui_borderPosition.union([.bottom])
            }

        }

        let gridViewHeight = gridView.sizeThatFits(CGSize(width: gridViewWidth, height: CGFloat.greatestFiniteMagnitude)).height
        gridView.frame = CGRect(x: scrollView.qmui_safeAreaInsets.left, y: 0, width: gridViewWidth, height: gridViewHeight)
        let contentSize = CGSize(width: gridView.frame.width, height:gridView.frame.maxY)
        scrollView.contentSize = contentSize
    }
    
    // MARK: private
    private func generateButton(_ index: Int) -> QDCommonGridButton {
        let keyName = dataSource.allKeys[index]
        let attributes = [NSAttributedStringKey.foregroundColor: UIColorGray6, NSAttributedStringKey.font: UIFontMake(11), NSAttributedStringKey.paragraphStyle: NSMutableParagraphStyle(lineHeight: 12, lineBreakMode: .byTruncatingTail, textAlignment: .center)]
        let attributedString = NSAttributedString(string: keyName, attributes: attributes)
        let image = dataSource[keyName]
        
        let button = QDCommonGridButton()
        
        if let tintColor = QDThemeManager.shared.currentTheme?.themeGridItemTintColor {
            button.tintColor = tintColor
            button.adjustsImageTintColorAutomatically = true
        } else {
            button.tintColor = nil
            button.adjustsImageTintColorAutomatically = false
        }
        button.setAttributedTitle(attributedString, for: .normal)
        button.setImage(image, for: .normal)
        button.tag = index
        button.addTarget(self, action: #selector(handleGirdButtonEvent(_:)), for: .touchUpInside)
        return button
    }
    
    @objc private func handleGirdButtonEvent(_ button: QDCommonGridButton) {
        let keyName = dataSource.allKeys[button.tag]
        didSelectCell(keyName)
    }
    
    override func themeBeforeChanged(_ beforeChanged: QDThemeProtocol, afterChanged: QDThemeProtocol) {
        super.themeBeforeChanged(beforeChanged, afterChanged: afterChanged)
        gridView.subviews.forEach {
            let button = $0 as! QDCommonGridButton
            if let tintColor = afterChanged.themeGridItemTintColor {
                button.tintColor = tintColor
                button.adjustsImageTintColorAutomatically = true
            } else {
                button.tintColor = nil
                button.adjustsImageTintColorAutomatically = false
            }
        }
    }
}


class QDCommonGridButton: QMUIButton {
    
    convenience init() {
        self.init(frame: CGRect.zero)
        contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        imageView?.contentMode = .center
        titleLabel?.numberOfLines = 2
        highlightedBackgroundColor = TableViewCellSelectedBackgroundColor
        qmui_automaticallyAdjustTouchHighlightedInScrollView = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if bounds.isEmpty {
            return
        }
        let width = bounds.width - contentEdgeInsets.horizontalValue
        let height = bounds.height - contentEdgeInsets.verticalValue
        let contentSize = CGSize(width: width, height: height)
        let x = flat(contentEdgeInsets.left + contentSize.width / 2)
        let y = flat(contentEdgeInsets.top + contentSize.height / 2)
        let center = CGPoint(x: x, y: y)
        imageView?.center = CGPoint(x: center.x, y: center.y - 12)

        if let titleLabel = titleLabel {
            let titleLabelSize = titleLabel.sizeThatFits(contentSize)
            titleLabel.frame = CGRectFlat(contentEdgeInsets.left, center.y + PreferredVarForDevices(27, 27, 21, 21), contentSize.width, titleLabelSize.height)
        }
    }
}
