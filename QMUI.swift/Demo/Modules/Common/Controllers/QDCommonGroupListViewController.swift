//
//  QDCommonGroupListViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/4/12.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

class QDCommonGroupListViewController: QDCommonTableViewController {

    var dataSource: QMUIOrderedDictionary<String, QMUIOrderedDictionary<String, String>> = [:]

    convenience init() {
        self.init(style: .grouped)
    }
    
    override func didInitialized(with style: UITableViewStyle) {
        super.didInitialized(with: style)
        initDataSource()
    }
    
    // MARK: QMUITableViewDataSource, QMUITableViewDelegate
    override func numberOfSections(in _: UITableView) -> Int {
        return dataSource.count
    }
    
    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderedDictionary(in: section).count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return title(for: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifierNormal = "cellNormal"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifierNormal) as? QMUITableViewCell
        if cell == nil {
            cell = QMUITableViewCell(tableView: tableView, style: .subtitle, reuseIdentifier: identifierNormal)
            cell!.accessoryType = .disclosureIndicator
        }
        let key = keyName(at: indexPath)
        cell!.textLabel?.text = key
        cell!.detailTextLabel?.text = (orderedDictionary(in: indexPath.section))[key]
        
        cell!.textLabel?.font = UIFontMake(15)
        cell!.detailTextLabel?.font = UIFontMake(13)
        
        cell!.updateCellAppearance(indexPath)
        
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let key = keyName(at: indexPath)
        didSelectCell(key)
        tableView.qmui_clearsSelection()
    }
    
    // MARK: DataSource
    
    func title(for section: Int) -> String {
        return dataSource.allKeys[section]
    }
    
    func keyName(at indexPath: IndexPath) -> String {
        let od = orderedDictionary(in: indexPath.section)
        return od.allKeys[indexPath.row]
    }
    
    func orderedDictionary(in section: Int) -> QMUIOrderedDictionary<String, String> {
        let key = title(for: section)
        return dataSource[key] ?? [:]
    }
    
    open func initDataSource() {
        
    }
    
    open func didSelectCell(_ title: String) {
        
    }
}
