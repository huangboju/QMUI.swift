//
//  QDAllSystemFontsViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/4/16.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

class QDAllSystemFontsViewController: QDCommonTableViewController {

    private var allFonts: [UIFont]!
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
        allFonts = [UIFont]()
        DispatchQueue.global().async {
            for familyName in UIFont.familyNames {
                for fontName in UIFont.fontNames(forFamilyName: familyName) {
                    self.allFonts.append(UIFont(name: fontName, size: 16)!)
                }
            }
            DispatchQueue.main.async {
                if self.isViewLoaded {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return allFonts.count
    }

    override func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let fontName = allFonts[indexPath.row].fontName
        if fontName.contains("Zapfino") {
            // 这个字体很飘逸，不够高是显示不全的
            return TableViewCellNormalHeight + 60
        }
        return TableViewCellNormalHeight
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "cell"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? QMUITableViewCell
        if cell == nil {
            cell = QMUITableViewCell(tableView: tableView, style: .subtitle, reuseIdentifier: identifier)
            cell!.selectionStyle = .none
            cell!.textLabel?.textColor = UIColorBlack
            cell!.detailTextLabel?.textColor = UIColorGray3
        }
        let font = allFonts[indexPath.row]
        cell?.textLabel?.font = font
        cell?.textLabel?.text = "\(indexPath.row + 1) \(font.fontName)"
        cell?.detailTextLabel?.font = font
        cell?.detailTextLabel?.text = "中文的效果"
        
        return cell ?? UITableViewCell()
    }
}
