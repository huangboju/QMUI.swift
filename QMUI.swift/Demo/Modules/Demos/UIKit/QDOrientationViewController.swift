//
//  QDOrientationViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/4/23.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

private let kIdentifierForDoneCell = 999

class QDOrientationViewController: QDCommonTableViewController {

    private var orientationLabel: QMUILabel!
    
    init() {
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func initTableView() {
        super.initTableView()
        
        tableView.qmui_staticCellDataSource = QMUIStaticTableViewCellDataSource(
            cellDataSections: [
                // section 0
                [QMUIStaticTableViewCellData(identifier: Int(UIInterfaceOrientationMask.portrait.rawValue), text: "UIInterfaceOrientationMaskPortrait", didSelectTarget: self, didSelectAction: #selector(handleCheckmarkEvent(_:)), accessoryType: .checkmark),
                 QMUIStaticTableViewCellData(identifier: Int(UIInterfaceOrientationMask.landscapeLeft.rawValue), text: "UIInterfaceOrientationMaskLandscapeLeft", didSelectTarget: self, didSelectAction: #selector(handleCheckmarkEvent(_:)), accessoryType: .checkmark),
                 QMUIStaticTableViewCellData(identifier: Int(UIInterfaceOrientationMask.landscapeRight.rawValue), text: "UIInterfaceOrientationMaskLandscapeRight", didSelectTarget: self, didSelectAction: #selector(handleCheckmarkEvent(_:)), accessoryType: .checkmark),
                 QMUIStaticTableViewCellData(identifier: Int(UIInterfaceOrientationMask.portraitUpsideDown.rawValue), text: "UIInterfaceOrientationMaskPortraitUpsideDown", didSelectTarget: self, didSelectAction: #selector(handleCheckmarkEvent(_:)), accessoryType: .checkmark),
                ],
                // section 1
                [QMUIStaticTableViewCellData(identifier: kIdentifierForDoneCell, text: "完成方向选择，进入该界面", didSelectTarget: self, didSelectAction: #selector(handleDoneCellEvent(_:))),
                ]])
        
        orientationLabel = QMUILabel(with: UIFontMake(14), textColor: UIColorGray7)
        let attributes: [NSAttributedStringKey: Any] = [NSAttributedStringKey.font : UIFontMake(14), NSAttributedStringKey.foregroundColor: UIColorGray7, NSAttributedStringKey.paragraphStyle: NSMutableParagraphStyle(lineHeight: 22, lineBreakMode: .byWordWrapping, textAlignment: .center)]
        orientationLabel.attributedText = NSAttributedString(string: "当前界面支持的方向：\n\(descriptionString(supportedOrientationMask))", attributes: attributes)
        orientationLabel.numberOfLines = 2
        orientationLabel.contentEdgeInsets = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
        orientationLabel.sizeToFit()
        tableView.tableFooterView = orientationLabel
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.qmui_staticCellDataSource?.cellForRow(at: indexPath)
        cell?.textLabel?.adjustsFontSizeToFitWidth = true
        
        if let data = tableView.qmui_staticCellDataSource?.cellData(at: indexPath) {
            if data.identifier == kIdentifierForDoneCell {
                cell?.textLabel?.textAlignment = .center
                cell?.textLabel?.textColor = QDThemeManager.shared.currentTheme?.themeTintColor
            }
        }
        
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "请为下一个界面选择支持的设备方向"
        }
        return nil
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tableView.qmui_staticCellDataSource?.cellDataSections.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView.qmui_staticCellDataSource?.cellDataSections[section].count ?? 0
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
    
    @objc func handleCheckmarkEvent(_ data: QMUIStaticTableViewCellData) {
        DispatchQueue.main.async {
            guard let indexPath = data.indexPath, let cell = self.tableView.cellForRow(at: indexPath) else {
                return
            }
            if data.accessoryType == .checkmark {
                cell.accessoryType = .none
                data.accessoryType = .none
            } else {
                cell.accessoryType = .checkmark
                data.accessoryType = .checkmark
            }
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    @objc func handleDoneCellEvent(_ data: QMUIStaticTableViewCellData) {
        DispatchQueue.main.async {
        var mask = UIInterfaceOrientationMask()
            for data in self.tableView.qmui_staticCellDataSource?.cellDataSections.first ?? [] {
                if data.accessoryType == .checkmark {
                    mask = mask.union(UIInterfaceOrientationMask(rawValue: UInt(data.identifier)))
                }
            }
            
            let viewController = QDOrientationViewController()
            // QMUICommonViewController 提供属性 supportedOrientationMask 用于控制界面所支持的显示方向，在 UIViewController (QMUI) 里会自动根据下一个要显示的界面去旋转设备的方向
            viewController.supportedOrientationMask = mask
            
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    private func descriptionString(_ mask: UIInterfaceOrientationMask) -> String {
        var string = ""
        if mask.contains(.portrait) {
            string += "Portrait"
        }
        if mask.contains(.landscapeLeft) {
            if !string.isEmpty {
                string += " | "
            }
            string += "Left"
        }
        if mask.contains(.landscapeRight) {
            if !string.isEmpty {
                string += " | "
            }
            string += "Right"
        }
        if mask.contains(.portraitUpsideDown) {
            if !string.isEmpty {
                string += " | "
            }
            string += "PortraitUpsideDown"
        }
        return string
    }
}
