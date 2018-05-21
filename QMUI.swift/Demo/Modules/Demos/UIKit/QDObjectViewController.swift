//
//  QDObjectViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/4/24.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

class QDObjectViewController: QDCommonTableViewController {

    private var allClasses = [String]()
    private var autocompletionClasses = [String]()
    
    init() {
        super.init(style: .plain)
        shouldShowSearchBar = true
        
        DispatchQueue.global().async {
            self.allClasses = self.allClassesArray()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func initSearchController() {
        super.initSearchController()
        searchController?.hidesNavigationBarDuringPresentation = false
        searchBar?.placeholder = "请输入 Class 名称，不区分大小写"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showEmptyViewWith(text: "NSObject (QMUI) 支持列出给定的 Class、Protocol 的方法。本示例允许你查看任意 Class 的实例方法，请通过上方搜索框搜索。", detailText: nil, buttonTitle: nil, buttonAction: nil)
    }
    
    override func showEmptyView() {
        super.showEmptyView()
        emptyView?.textLabel.qmui_textAttributes = [NSAttributedStringKey.paragraphStyle: NSMutableParagraphStyle(lineHeight: 24)]
    }
    
    private func allClassesArray() -> [String] {
        var allClasses = [String]()
        let typeCount = Int(objc_getClassList(nil, 0))
        let types = UnsafeMutablePointer<AnyClass?>.allocate(capacity: typeCount)
        let autoreleasingTypes = AutoreleasingUnsafeMutablePointer<AnyClass>(types)
        objc_getClassList(autoreleasingTypes, Int32(typeCount))
        for index in 0 ..< typeCount {
            if let type = types[index] {
                allClasses.append(NSStringFromClass(type))
            }
        }
        types.deallocate()
        return allClasses
    }
    
    private func matchingWeigh(className: String, with searchString: String) -> Double {
        /**
         排序方式：
         1. 每个 className 都有一个基准的匹配权重，权重取值范围 [0-1]，这个权重简单地以字符串长度来计算，匹配到的 className 里长度越短的 className 认为匹配度越高
         2. 基于步骤 1 得到的匹配权重进行分段，以搜索词开头的 className 权重最高，以下划线开头的 className 权重最低（如果搜索词本来就以下划线开头则不计入此种情况），其他情况权重中等。
         3. 特别的，如果 className 与搜索词完全匹配，则权重最高，为 1
         4. 最终权重越高者排序越靠前
         */
        let classNameLower = className.lowercased()
        let searchStringLower = searchString.lowercased()
        if classNameLower == searchStringLower {
            return 1
        }
        var matchingWeight = Double(searchStringLower.length) / Double(classNameLower.length)
        if classNameLower.hasPrefix(searchStringLower) {
            return matchingWeight * 1.0 / 3.0 + 2.0 / 3.0
        }
        if classNameLower.hasPrefix("_") && !searchStringLower.hasPrefix("_") {
            return matchingWeight * 1.0 / 3.0
        }
        matchingWeight = matchingWeight * 1.0 / 3.0 + 1.0 / 3.0
        
        return matchingWeight
    }
    
    // MARK: QMUITableViewDataSource, QMUITableViewDelegate
    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return autocompletionClasses.count
    }
    
    func qmui_tableView(_ tableView: UITableView, cellWithIdentifier identifier: String) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? QMUITableViewCell
        if cell == nil {
            cell = QMUITableViewCell(tableView: tableView, reuseIdentifier: identifier)
            cell?.textLabel?.numberOfLines = 0
        }
        return cell ?? UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = qmui_tableView(tableView, cellWithIdentifier: "cell") as? QMUITableViewCell
        let className = autocompletionClasses[indexPath.row]
        if let text = searchBar?.text, let matchingRange = className.lowercased().range(of: text.lowercased()) {
            let attributes: [NSAttributedStringKey: Any] = [NSAttributedStringKey.font : CodeFontMake(14), NSAttributedStringKey.foregroundColor: UIColorGray1]
            let attributedString = NSMutableAttributedString(string: className, attributes: attributes)
            attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: QDThemeManager.shared.currentTheme?.themeTintColor ?? UIColorBlue, range: NSRange(matchingRange, in: text))
            cell?.textLabel?.attributedText = attributedString
        }
        cell?.updateCellAppearance(indexPath)
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let className = autocompletionClasses[indexPath.row]
        guard let aClass = NSClassFromString(className) else {
            return
        }
        let methodsListController = QDObjectMethodsListViewController(aClass: aClass)
        methodsListController.title = className
        navigationController?.pushViewController(methodsListController, animated: true)
    }
    
    // MARK: QMUISearchControllerDelegate
    override func searchController(_ searchController: QMUISearchController, updateResultsFor searchString: String?) {
        
        autocompletionClasses.removeAll()
        
        if let searchString = searchString, searchString.length > 2 {
            allClasses.forEach {
                if $0.lowercased().contains(searchString.lowercased()) {
                    autocompletionClasses.append($0)
                }
            }
            
            autocompletionClasses = (autocompletionClasses as NSArray).sortedArray { (obj1, obj2) -> ComparisonResult in
                let string1 = obj1 as! String
                let string2 = obj2 as! String
                let matchingWeight1 = self.matchingWeigh(className: string1, with: searchString)
                let matchingWeight2 = self.matchingWeigh(className: string2, with: searchString)
                let result: ComparisonResult = matchingWeight1 == matchingWeight2 ? .orderedSame : (matchingWeight1 > matchingWeight2 ? .orderedAscending : .orderedDescending)
                if string1 == "PLUIView" && string2 == "UIViewAnimation" {
                    print("1, searchString = \(searchString), \(string1) vs. \(string2) =\(String(format:"%.3f", matchingWeight1)), \(String(format:"%.3f", matchingWeight2))")
                } else {
                    print("2, searchString = \(searchString), \(string1) vs. \(string2) =\(String(format:"%.3f", matchingWeight1)), \(String(format:"%.3f", matchingWeight2))")
                }
                return result
                } as! [String]
        }
        
        searchController.tableView?.reloadData()
    }
}
