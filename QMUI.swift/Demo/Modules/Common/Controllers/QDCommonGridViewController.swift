//
//  QDCommonGridViewController.swift
//  QMUI.swift
//
//  Created by TonyHan on 2018/3/6.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

class QDCommonGridViewController: QDCommonViewController {
    
    public private(set) var dataSource: QMUIOrderedDictionary<String, UIImage>!
    
    public private(set) var gridView: QMUIGridView!
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        
        return scrollView
    }()
    
    /// 子类继承，可以不调super
    open func initDataSource() {
        
    }
    
    override func didInitialized() {
        super.didInitialized()
        initDataSource()
    }
    
    override func initSubviews() {
        super.initSubviews()
        
        view.addSubview(scrollView)
        
        gridView = QMUIGridView()
        for index in 0..<dataSource.count {
            let subview = generateButton(index)
//            gridView.addSubview(<#T##view: UIView##UIView#>)
        }
        view.addSubview(gridView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.frame
        
        let gridViewWidth = scrollView.bounds.width - scrollView.qmui_safeAreaInsets.horizontalValue
        
    }
    
    // MARK: private
    private func generateButton(_ index: Int) -> QDCommonGridButton {
        let keyName = dataSource.allKeys[index]
        let attributes = [NSAttributedStringKey.foregroundColor: UIColorGray6, NSAttributedStringKey.font: UIFontMake(11), NSAttributedStringKey.paragraphStyle: NSMutableParagraphStyle(lineHeight: 12, lineBreakMode: .byTruncatingTail, textAlignment: .center)]
        var attributedString = NSAttributedString(string: keyName, attributes: attributes)
        let image = dataSource[keyName]
        
        let tintColor = QDThemeManager.shared.currentTheme
        
        return QDCommonGridButton()
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
