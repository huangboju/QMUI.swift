//
//  QDTableViewCellAccessoryTypeViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/4/18.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

class QDTableViewCellAccessoryTypeViewController: QDCommonTableViewController {

    lazy var dataSource: [String] = {
        let dataSource = ["UITableViewCellAccessoryNone",
                          "UITableViewCellAccessoryDisclosureIndicator",
                          "UITableViewCellAccessoryDetailDisclosureButton",
                          "UITableViewCellAccessoryCheckmark",
                          "UITableViewCellAccessoryDetailButton"]
        return dataSource
    }()
    
    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return dataSource.count
    }
    
    override func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "cell"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? QMUITableViewCell
        if cell == nil {
            cell = QMUITableViewCell(tableView: self.tableView, reuseIdentifier: identifier)
            cell!.textLabel?.adjustsFontSizeToFitWidth = true
            cell!.textLabel?.text = dataSource[indexPath.row]
            cell!.accessoryType = UITableViewCellAccessoryType(rawValue: indexPath.row)!
            cell!.updateCellAppearance(indexPath)
        }
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        QMUITips.show(text: "点击了第 \(indexPath.row) 行的按钮", in: view, hideAfterDelay: 1.2)
    }
}
