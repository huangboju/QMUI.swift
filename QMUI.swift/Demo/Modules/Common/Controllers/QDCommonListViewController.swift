//
//  QDCommonListViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/4/2.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

class QDCommonListViewController: QMUICommonTableViewController {
    
    var dataSource: Array<String> = []
    
    var dataSourceWithDetailText: QMUIOrderedDictionary<String, String>?
    
    override init(style: UITableView.Style) {
        super.init(style: style)
        initDataSource()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initDataSource()
    }

    /// 子类继承，可以不调super
    open func initDataSource() {
    }
    
    open func didSelectCell(_ title: String) {
    }
    
    // MARK:  - UITableView Delegate & DataSource
    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        if let dataSourceWithDetailText = dataSourceWithDetailText {
            return dataSourceWithDetailText.count
        }
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifierNormal = "cellNormal"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifierNormal)
        if cell == nil {
            if dataSourceWithDetailText != nil {
                cell = QMUITableViewCell(tableView: self.tableView, style: .subtitle, reuseIdentifier: identifierNormal)
            } else {
                cell = QMUITableViewCell(tableView: self.tableView, style: .value1, reuseIdentifier: identifierNormal)
            }
            cell?.accessoryType = .disclosureIndicator
        }
        if let dataSourceWithDetailText = dataSourceWithDetailText {
            let keyName = dataSourceWithDetailText.allKeys[indexPath.row]
            cell?.textLabel?.text = keyName
            cell?.detailTextLabel?.text = dataSourceWithDetailText[keyName]
        } else {
            cell?.textLabel?.text = dataSource[indexPath.row]
        }
        cell?.textLabel?.font = UIFontMake(15)
        cell?.detailTextLabel?.font = UIFontMake(13)
        if let cell = cell as? QMUITableViewCell {
            cell.updateCellAppearance(indexPath)
        }
        return cell ?? UITableViewCell()
    }
    
    override func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let dataSourceWithDetailText = dataSourceWithDetailText {
            let keyName = dataSourceWithDetailText.allKeys[indexPath.row]
            if let value = dataSourceWithDetailText[keyName], value.count > 0 {
                return 64
            }
        }
        return TableViewCellNormalHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var title: String?
        if let dataSourceWithDetailText = dataSourceWithDetailText {
            title = dataSourceWithDetailText.allKeys[indexPath.row]
        } else {
            title = dataSource[indexPath.row]
        }
        if let title = title{
            didSelectCell(title)
        }
    }
}
