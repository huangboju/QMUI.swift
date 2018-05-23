//
//  QDStaticTableViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/5/9.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

class QDStaticTableViewController: QDCommonTableViewController {
    
    override func initTableView() {
        super.initTableView()
        
        let dataSource = QMUIStaticTableViewCellDataSource(cellDataSections: [
            // section0
            [
                {
                    QMUIStaticTableViewCellData(
                        identifier: 0,
                        image: nil,
                        text: "标题",
                        didSelectTarget: nil,
                        didSelectAction: nil,
                        accessoryType: .none)
                }(),
                {
                    QMUIStaticTableViewCellData(
                        identifier: 1,
                        style: .subtitle,
                        height: TableViewCellNormalHeight + 6,
                        text: "标题",
                        detailText: "副标题",
                        didSelectTarget: nil,
                        didSelectAction: nil)
                }()
            ],
            // section1
            [
                {
                    QMUIStaticTableViewCellData(
                        identifier: 2,
                        text: "箭头类型",
                        didSelectTarget: self,
                        didSelectAction: #selector(handleDisclosureIndicatorCellEvent(_:)),
                        accessoryType: .disclosureIndicator)
                }(),
                {
                    QMUIStaticTableViewCellData(
                        identifier: 3,
                        text: "按钮类型",
                        didSelectTarget: self,
                        didSelectAction: #selector(handleDisclosureIndicatorCellEvent(_:)),
                        accessoryType: .detailButton,
                        accessoryTarget: self,
                        accessoryAction: #selector(handleAccessoryDetailButtonEvent(_:)))
                }(),
                {
                    QMUIStaticTableViewCellData(
                        identifier: 4,
                        text: "按钮类型",
                        didSelectTarget: self,
                        didSelectAction: #selector(handleDisclosureIndicatorCellEvent(_:)),
                        accessoryType: .detailDisclosureButton,
                        accessoryTarget: self,
                        accessoryAction: #selector(handleAccessoryDetailButtonEvent(_:)))
                }(),
                {
                    let d = QMUIStaticTableViewCellData(
                        identifier: 5,
                        text: "UISwitch 类型",
                        didSelectTarget: nil,
                        didSelectAction: nil,
                        accessoryType: .switch,
                        accessoryValueObject: true as AnyObject, // switch 类型的，可以通过传一个 NSNumber 对象给 accessoryValueObject 来指定这个 switch.on 的值
                        accessoryTarget: self,
                        accessoryAction: #selector(handleSwitchCellEvent(_:)))
                    d.cellForRowClosure = { (tableView, cell, cellData) in
                        if let switchControl = cell.accessoryView as? UISwitch {
                            switchControl.onTintColor = QDThemeManager.shared.currentTheme?.themeTintColor
                            switchControl.tintColor = switchControl.onTintColor
                        }
                    }
                    return d
                }()
            ],
            [
                {
                    QMUIStaticTableViewCellData(
                        identifier: 6,
                        text: "选项 1",
                        didSelectTarget: self,
                        didSelectAction: #selector(handleCheckmarkCellEvent(_:)),
                        accessoryType: .checkmark)
                }(),
                {
                    QMUIStaticTableViewCellData(
                        identifier: 7,
                        text: "选项 2",
                        didSelectTarget: self,
                        didSelectAction: #selector(handleCheckmarkCellEvent(_:)))
                }(),
                {
                    QMUIStaticTableViewCellData(
                        identifier: 8,
                        text: "选项 3",
                        didSelectTarget: self,
                        didSelectAction: #selector(handleCheckmarkCellEvent(_:)))
                }()
            ]
        ])
        
        // 把数据塞给 tableView 即可
        tableView.qmui_staticCellDataSource = dataSource
    }

    @objc func handleDisclosureIndicatorCellEvent(_ cellData: QMUIStaticTableViewCellData) {
        // cell 的点击事件，注意第一个参数的类型是 QMUIStaticTableViewCellData
        QMUITips.show(text: "点击了 \(cellData.text)", in: self.view, hideAfterDelay: 1.2)
    }
    
    @objc func handleCheckmarkCellEvent(_ cellData: QMUIStaticTableViewCellData) {
        // checkmark 类型的 cell 如果要实现单选，可以这么写
        
        if cellData.accessoryType == .checkmark {
            // 选项没变化，直接结束
            return
        }
        
        // 先取消之前的所有勾选
        guard let qmui_staticCellDataSource = tableView.qmui_staticCellDataSource, let indexPath = cellData.indexPath else {
            return
        }
        for data in qmui_staticCellDataSource.cellDataSections[indexPath.section] {
            data.accessoryType = .none
        }
        
        // 再勾选当前点击的 cell
        cellData.accessoryType = .checkmark
        
        // 注意：如果不需要考虑动画，则下面这两步不用这么麻烦，直接调用 [self.tableView reloadData] 即可
        
        // 刷新除了被点击的那个 cell 外的其他单选 cell
        var indexPathsAnimated = [IndexPath]()
        let l = self.tableView.numberOfRows(inSection: indexPath.section)
        for i in 0..<l {
            if i != indexPath.row {
                indexPathsAnimated.append(IndexPath(row: i, section: indexPath.section))
            }
        }
        
        tableView.reloadRows(at: indexPathsAnimated, with: .none)
        
        // 直接拿到 cell 去修改 accessoryType，保证动画不受 reload 的影响
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        cellData.accessoryType = .checkmark
    }
    
    @objc func handleAccessoryDetailButtonEvent(_ cellData: QMUIStaticTableViewCellData) {
        QMUITips.show(text: "点击了右边的按钮", in: self.view, hideAfterDelay: 1.2)
    }
    
    @objc func handleSwitchCellEvent(_ switchControl: UISwitch) {
        // UISwitch 的开关事件，注意第一个参数的类型是 UISwitch
        if switchControl.isOn {
            QMUITips.showSucceed(text: "打开", in: self.view, hideAfterDelay: 0.8)
        } else {
            QMUITips.showError(text: "打开", in: self.view, hideAfterDelay: 0.8)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 2 ? "单选" : nil
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tableView.qmui_staticCellDataSource?.cellDataSections.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection cellDataSections: Int) -> Int {
        return tableView.qmui_staticCellDataSource?.cellDataSections[cellDataSections].count  ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.qmui_staticCellDataSource?.cellForRow(at: indexPath)
        return cell ?? UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.qmui_staticCellDataSource?.heightForRow(at: indexPath) ?? 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.qmui_staticCellDataSource?.didSelectRow(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        tableView.qmui_staticCellDataSource?.accessoryButtonTappedForRow(with: indexPath)
    }
}
