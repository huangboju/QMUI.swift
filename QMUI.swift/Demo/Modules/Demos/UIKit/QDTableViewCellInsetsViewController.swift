//
//  QDTableViewCellInsetsViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/4/18.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

class QDTableViewCellInsetsViewController: QDCommonTableViewController {

    override func numberOfSections(in _: UITableView) -> Int {
        return 5
    }
    
    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "普通 cell"
        } else if section == 1 {
            return "使用 imageEdgeInsets"
        } else if section == 2 {
            return "使用 textLabelEdgeInsets"
        } else if section == 3 {
            return "使用 detailTextLabelEdgeInsets"
        } else if section == 4 {
            return "使用 accessoryEdgeInsets"
        }
        return nil
    }

    func qmui_tableView(_ tableView: UITableView, cellWithIdentifier identifier: String) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if cell == nil {
            cell = QMUITableViewCell(tableView: self.tableView, style: .subtitle, reuseIdentifier: identifier)
            cell!.imageView?.image = UIImage.qmui_image(shape: .oval, size: CGSize(width: 16, height: 16), lineWidth: 2, tintColor: QDCommonUI.randomThemeColor())
            cell!.textLabel?.text = String(describing: QMUITableViewCell.self)
            cell!.accessoryType = .disclosureIndicator
        }
        return cell ?? UITableViewCell()
    }
    
    override func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = qmui_tableView(tableView, cellWithIdentifier: "cell") as? QMUITableViewCell else {
            return UITableViewCell()
        }
        
        // reset
        cell.imageEdgeInsets = .zero
        cell.textLabelEdgeInsets = .zero
        cell.detailTextLabelEdgeInsets = .zero
        cell.accessoryEdgeInsets = .zero
        
        if indexPath.section == 0 {
            cell.detailTextLabel?.text = nil
        } else if indexPath.section == 1 {
            cell.detailTextLabel?.text = "imageEdgeInsets"
            cell.imageEdgeInsets = UIEdgeInsetsMake(0, 30, 0, 0)
        } else if indexPath.section == 2 {
            cell.detailTextLabel?.text = "textLabelEdgeInsets"
            cell.textLabelEdgeInsets = UIEdgeInsetsMake(-6, 30, 0, 0)
        } else if indexPath.section == 3 {
            cell.detailTextLabel?.text = "detailTextLabelEdgeInsets"
            cell.detailTextLabelEdgeInsets = UIEdgeInsetsMake(6, 30, 0, 0);
        } else if indexPath.section == 4 {
            cell.detailTextLabel?.text = "accessoryEdgeInsets, accessoryEdgeInsets, accessoryEdgeInsets, accessoryEdgeInsets, accessoryEdgeInsets, accessoryEdgeInsets"
            cell.accessoryEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 32);
        }
        
        return cell
    }
    
    override func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return TableViewCellNormalHeight + 10
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
