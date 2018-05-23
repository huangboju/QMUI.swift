//
//  QMUIStaticTableViewCellData.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/5/23.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

enum QMUIStaticTableViewCellAccessoryType {
    case none
    case disclosureIndicator
    case detailDisclosureButton
    case checkmark
    case detailButton
    case `switch`
}

/**
 *  一个 cellData 对象用于存储 static tableView（例如设置界面那种列表） 列表里的一行 cell 的基本信息，包括这个 cell 的 class、text、detailText、accessoryView 等。
 *  @see QMUIStaticTableViewCellDataSource
 */
class QMUIStaticTableViewCellData: NSObject {
    /// 当前 cellData 的标志，一般同个 tableView 里的每个 cellData 都会拥有不相同的 identifier
    var identifier: Int
    
    /// 当前 cellData 所对应的 indexPath
    var indexPath: IndexPath?
    
    /// cell 要使用的 class，默认为 QMUITableViewCell，若要改为自定义 class，必须是 QMUITableViewCell 的子类
    var cellClass: AnyClass {
        willSet {
            assert(cellClass is QMUITableViewCell.Type, "\(type(of: self)).cellClass 必须为 QMUITableViewCell 的子类")
        }
    }
    
    /// init cell 时要使用的 style
    var style: UITableViewCellStyle
    
    /// cell 的高度，默认为 TableViewCellNormalHeight
    var height: CGFloat
    
    /// cell 左边要显示的图片，将会被设置到 cell.imageView.image
    var image: UIImage?
    
    /// cell 的文字，将会被设置到 cell.textLabel.text
    var text: String
    
    /// cell 的详细文字，将会被设置到 cell.detailTextLabel.text，所以要求 cellData.style 的值必须是带 detailTextLabel 类型的 style
    var detailText: String?
    
    /// 会自动在 tableView:cellForRowAtIndexPath: 里调用，这样就不需要实现 cellForRow
    var cellForRowClosure: ((UITableView, QMUITableViewCell, QMUIStaticTableViewCellData) -> Void)?
    
    /// 当 cell 的点击事件被触发时，要由哪个对象来接收
    var didSelectTarget: Any?
    
    /// 当 cell 的点击事件被触发时，要向 didSelectTarget 指针发送什么消息以响应事件
    /// @warning 这个 selector 接收一个参数，这个参数也即当前的 QMUIStaticTableViewCellData 对象
    var didSelectAction: Selector?
    
    /// cell 右边的 accessoryView 的类型
    var accessoryType: QMUIStaticTableViewCellAccessoryType
    
    /// 配合 accessoryType 使用，不同的 accessoryType 需要配合不同 class 的 accessoryValueObject 使用。例如 QMUIStaticTableViewCellAccessoryTypeSwitch 要求传 @YES 或 @NO 用于控制 UISwitch.on 属性。
    /// @warning 目前也仅支持与 QMUIStaticTableViewCellAccessoryTypeSwitch 搭配使用。
    var accessoryValueObject: AnyObject?
    
    /// 当 accessoryType 是某些带 UIControl 的控件时，可通过这两个属性来为 accessoryView 添加操作事件。
    /// 目前支持的类型包括：QMUIStaticTableViewCellAccessoryTypeDetailDisclosureButton、QMUIStaticTableViewCellAccessoryTypeDetailButton、QMUIStaticTableViewCellAccessoryTypeSwitch
    /// @warning 这个 selector 接收一个参数，与 didSelectAction 一样，这个参数一般情况下也是当前的 QMUIStaticTableViewCellData 对象，仅在 Switch 时会传 UISwitch 控件的实例
    var accessoryTarget: Any?
    var accessoryAction: Selector?
    
    init(identifier: Int,
         cellClass: AnyClass = QMUITableViewCell.self,
         style: UITableViewCellStyle = .default,
         height: CGFloat = TableViewCellNormalHeight,
         image: UIImage? = nil,
         text: String,
         detailText: String? = nil,
         didSelectTarget: Any?,
         didSelectAction: Selector?,
         accessoryType: QMUIStaticTableViewCellAccessoryType = .none,
         accessoryValueObject: AnyObject? = nil,
         accessoryTarget: Any? = nil,
         accessoryAction: Selector? = nil) {
        self.identifier = identifier
        self.cellClass = cellClass
        self.style = style
        self.height = height
        self.image = image
        self.text = text
        self.detailText = detailText
        self.didSelectTarget = didSelectTarget
        self.didSelectAction = didSelectAction
        self.accessoryType = accessoryType
        self.accessoryValueObject = accessoryValueObject
        self.accessoryTarget = accessoryTarget
        self.accessoryAction = accessoryAction
    }
    
    static func tableViewCellAccessoryType(withStaticAccessoryType type: QMUIStaticTableViewCellAccessoryType) -> UITableViewCellAccessoryType {
        switch type {
        case .disclosureIndicator:
            return .disclosureIndicator
        case .detailDisclosureButton:
            return .detailDisclosureButton
        case .checkmark:
            return .checkmark
        case .detailButton:
            return .detailButton
        default:
            return .none
        }
    }
}
