//
//  QDStaticTableViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/5/9.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

class QDStaticTableViewController: QDCommonTableViewController {
    // MARK: TODO QMUIStaticTableViewCellDataSource 和 QMUIStaticTableViewCellData 比较麻烦
    override func initTableView() {
        super.initTableView()
        
        let data0 = QMUIStaticTableViewCellData(identifier: 0,
                                                image: nil,
                                                text: "标题",
                                                didSelectTarget: nil,
                                                didSelectAction: nil,
                                                accessoryType: .none)
        
        let data1 = QMUIStaticTableViewCellData(identifier: 1,
                                                style: .subtitle,
                                                height: TableViewCellNormalHeight + 6,
                                                text: "标题",
                                                detailText: "副标题",
                                                didSelectTarget: nil,
                                                didSelectAction: nil)
        
        let data2 = QMUIStaticTableViewCellData(identifier: 2,
                                                text: "箭头类型",
                                                didSelectTarget: self,
                                                didSelectAction: #selector(handleDisclosureIndicatorCellEvent(_:)),
                                                accessoryType: .disclosureIndicator)
        
        let data3 = QMUIStaticTableViewCellData(identifier: 3,
                                                text: "按钮类型",
                                                didSelectTarget: self,
                                                didSelectAction: #selector(handleDisclosureIndicatorCellEvent(_:)),
                                                accessoryType: .detailButton,
                                                accessoryTarget: self,
                                                accessoryAction: #selector(handleAccessoryDetailButtonEvent(_:)))
        
        let data4 = QMUIStaticTableViewCellData(identifier: 4,
                                                text: "按钮类型",
                                                didSelectTarget: self,
                                                didSelectAction: #selector(handleDisclosureIndicatorCellEvent(_:)),
                                                accessoryType: .detailDisclosureButton,
                                                accessoryTarget: self,
                                                accessoryAction: #selector(handleAccessoryDetailButtonEvent(_:)))
        
        let data5 = QMUIStaticTableViewCellData(identifier: 5,
                                                text: "UISwitch 类型",
                                                didSelectTarget: nil,
                                                didSelectAction: nil,
                                                accessoryType: .switch,
                                                accessoryValueObject: true as AnyObject, // switch 类型的，可以通过传一个 NSNumber 对象给 accessoryValueObject 来指定这个 switch.on 的值
            accessoryTarget: self,
            accessoryAction: #selector(handleSwitchCellEvent(_:)))
//        data5.cellFor
        
        let dataSource = QMUIStaticTableViewCellDataSource(cellDataSections: [
            // section0
            [
                data0,
                data1
            ],
            // section1
            [
                data2,
                data3,
                data4,
                data5
            ]
        ])
        
        // 把数据塞给 tableView 即可
        tableView.qmui_staticCellDataSource = dataSource
    }

    @objc func handleDisclosureIndicatorCellEvent(_ cellData: QMUIStaticTableViewCellData) {
        
    }
    
    @objc func handleCheckmarkCellEvent(_ cellData: QMUIStaticTableViewCellData) {
        
    }
    
    @objc func handleAccessoryDetailButtonEvent(_ cellData: QMUIStaticTableViewCellData) {
        
    }
    
    @objc func handleSwitchCellEvent(_ cellData: QMUIStaticTableViewCellData) {
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 2 ? "单选" : nil
    }
}
