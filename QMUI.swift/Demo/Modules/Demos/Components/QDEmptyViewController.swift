//
//  QDEmptyViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/5/4.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

class QDEmptyViewController: QDCommonTableViewController {

    override init(style: UITableViewStyle) {
        super.init(style: style)
        shouldShowSearchBar = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setNavigationItems(_ isInEditMode: Bool, animated: Bool) {
        super.setNavigationItems(isInEditMode, animated: animated)
    }
    
    override func setToolbarItems(isInEditMode: Bool, animated: Bool) {
        super.setToolbarItems(isInEditMode: isInEditMode, animated: animated)
    }
}

// MARK: QMUITableViewDataSource, QMUITableViewDelegate
extension QDEmptyViewController {
    
    @objc private func reload(_ sender: Any) {
        hideEmptyView()
        tableView.reloadData()
    }
    
    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return isEmptyViewShowing ? 0 : 4
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "cell"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? QMUITableViewCell
        if cell == nil {
            cell = QMUITableViewCell(tableView: tableView, reuseIdentifier: identifier)
        }
        cell?.updateCellAppearance(indexPath)
        if indexPath.row == 0 {
            cell?.textLabel?.text = "显示loading"
        } else if indexPath.row == 1 {
            cell?.textLabel?.text = "显示提示语"
        } else if indexPath.row == 2 {
            cell?.textLabel?.text = "显示提示语及操作按钮"
        } else if indexPath.row == 3 {
            cell?.textLabel?.text = "显示占位图及文字"
        }
        return cell ?? QMUITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            showEmptyViewWithLoading()
        } else if indexPath.row == 1 {
            showEmptyViewWith(text: "联系人为空", detailText: "请到设置-隐私查看你的联系人权限设置", buttonTitle: nil, buttonAction: nil)
        } else if indexPath.row == 2 {
            showEmptyViewWith(text: "请求失败", detailText: "请检查网络连接", buttonTitle: "重试", buttonAction: #selector(reload(_:)))
        } else if indexPath.row == 3 {
            showEmptyViewWith(image: UIImageMake("image1"), text: nil, detailText: "图片间距可通过imageInsets来调整", buttonTitle: nil, buttonAction: nil)
        }
        tableView.reloadData()
    }
}

// MARK: QMUISearchControllerDelegate
extension QDEmptyViewController {
    func willPresent(_ searchController: QMUISearchController) {
        QMUIHelper.renderStatusBarStyleDark()
    }
    
    func willDismiss(_ searchController: QMUISearchController) {
        QMUIHelper.renderStatusBarStyleLight()
    }
}
