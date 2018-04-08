//
//  QDColorViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/4/4.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

class QDColorViewController: QDCommonTableViewController {

    override func initTableView() {
        super.initTableView()
        tableView.separatorStyle = .none
        
        let topInset: CGFloat = 32
        let width = tableView.bounds.width
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: topInset))
    }
    
    // MARK: TableView Delegate & DataSource
    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return 7
    }
    
    override func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 1 {
            return 360
        }
        return 130
    }
    
    override func tableView(_: UITableView, cellForRowAt _: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
