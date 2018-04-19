//
//  QDSearchViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/4/19.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

class QDSearchViewController: QDCommonTableViewController {
    
    private let keywords = ["Helps", "Maintain", "Liver", "Health", "Function", "Supports", "Healthy", "Fat", "Metabolism", "Nuturally"]
    
    private var searchResultsKeywords: [String] = []
    
    private lazy var mySearchController: QMUISearchController = {
        // QMUISearchController 有两种使用方式，一种是独立使用，一种是集成到 QMUICommonTableViewController 里使用。为了展示它的使用方式，这里使用第一种，不理会 QMUICommonTableViewController 内部自带的 QMUISearchController
        let mySearchController = QMUISearchController(contentsViewController: self)
        mySearchController.searchResultsDelegate = self
        mySearchController.launchView = QDRecentSearchView() // launchView 会自动布局，无需处理 frame
        mySearchController.searchBar?.qmui_usedAsTableHeaderView = true // 以 tableHeaderView 的方式使用 searchBar 的话，将其置为 YES，以辅助兼容一些系统 bug
        return mySearchController
    }()
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
        // 这个属性默认就是 false，这里依然写出来只是为了提醒 QMUICommonTableViewController 默认就集成了 QMUISearchController，如果你的界面本身就是 QMUICommonTableViewController 的子类，则也可以直接通过将这个属性改为 true 来创建 QMUISearchController
        shouldShowSearchBar = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableHeaderView = mySearchController.searchBar
    }
    
}

extension QDSearchViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection _: Int) -> Int {
        if tableView == self.tableView {
            return keywords.count
        }
        return searchResultsKeywords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "cell"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if cell == nil {
            cell = QMUITableViewCell(tableView: self.tableView, reuseIdentifier: identifier)
        }
        if tableView == self.tableView {
            cell?.textLabel?.text = keywords[indexPath.row]
        } else {
            let keyword = searchResultsKeywords[indexPath.row]
            let attributedString = NSMutableAttributedString(string: keyword, attributes: [NSAttributedStringKey.foregroundColor: UIColorBlack])
            if let string = mySearchController.searchBar?.text, let range = keyword.range(of: string), let color = QDThemeManager.shared.currentTheme?.themeTintColor {
                attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: color, range: NSRange(range, in: string))
            }
            cell?.textLabel?.attributedText = attributedString
        }
        (cell as? QMUITableViewCell)?.updateCellAppearance(indexPath)
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension QDSearchViewController {
    
    override func searchController(_ searchController: QMUISearchController, updateResultsFor searchString: String?) {
        searchResultsKeywords.removeAll()
        for key in keywords {
            if searchString != nil && key.contains(searchString!) {
                searchResultsKeywords.append(key)
            }
        }

        searchController.tableView?.reloadData()
        
        if searchResultsKeywords.count == 0 {
            searchController.showEmptyViewWith(text: "没有匹配结果", detailText: nil, buttonTitle: nil, buttonAction: nil)
        } else {
            searchController.hideEmptyView()
        }
    }

    func willPresent(_ searchController: QMUISearchController) {
        QMUIHelper.renderStatusBarStyleDark()
    }
    
    func willDismiss(_: QMUISearchController) {
        var oldStatusbarLight = false
        oldStatusbarLight = shouldSetStatusBarStyleLight
        if oldStatusbarLight {
            QMUIHelper.renderStatusBarStyleLight()
        } else {
            QMUIHelper.renderStatusBarStyleDark()
        }
    }
}

class QDRecentSearchView: UIView {
    
    private lazy var titleLabel: QMUILabel = {
        let label = QMUILabel(with: UIFontMake(14), textColor: UIColorGray2)
        label.text = "最近搜索"
        label.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)
        label.sizeToFit()
        label.qmui_borderPosition = .bottom
        return label
    }()
    
    private lazy var floatLayoutView: QMUIFloatLayoutView = {
        let floatLayoutView = QMUIFloatLayoutView()
        floatLayoutView.padding = .zero
        floatLayoutView.itemMargins = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 10)
        floatLayoutView.minimumItemSize = CGSize(width: 69, height: 29)
        return floatLayoutView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColorWhite
        addSubview(titleLabel)
        addSubview(floatLayoutView)
        
        let suggestions = ["Helps", "Maintain", "Liver", "Health", "Function", "Supports", "Healthy", "Fat"]
        suggestions.forEach {
            let button = QMUIGhostButton(ghostType: .gray)
            button.setTitle($0, for: .normal)
            button.titleLabel?.font = UIFontMake(14)
            button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 20, bottom: 6, right: 20)
            floatLayoutView.addSubview(button)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let padding = UIEdgeInsets(top: 26, left: 26, bottom: 26, right: 26).concat(insets: qmui_safeAreaInsets)
        let titleLabelMarginTop: CGFloat = 20
        titleLabel.frame = CGRect(x: padding.left, y: padding.top, width: bounds.width - padding.horizontalValue, height: titleLabel.frame.height)
        
        let minY = titleLabel.frame.maxY + titleLabelMarginTop
        floatLayoutView.frame = CGRect(x: padding.left, y: minY, width: bounds.width - padding.horizontalValue, height: bounds.height - minY)
    }
}
