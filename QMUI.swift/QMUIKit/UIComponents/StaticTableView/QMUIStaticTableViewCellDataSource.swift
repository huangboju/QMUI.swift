//
//  QMUIStaticTableViewCellDataSource.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/4/23.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

/**
 *  这个控件是为了方便地实现那种类似设置界面的列表（每个 cell 的样式、内容、操作控件均不太一样，每个 cell 之间不复用），使用方式：
 *  1. 创建一个带 UITableView 的 viewController。
 *  2. 通过 init 或 initWithCellDataSections: 创建一个 dataSource。若通过 init 方法初始化，则请在 tableView 渲染前（viewDidLoad 或更早）手动设置一个 cellDataSections 数组。
 *  3. 将第 2 步里的 dataSource 赋值给 tableView.qmui_staticCellDataSource 即可完成一般情况下的界面展示。
 *  4. 若需要重写某些 UITableViewDataSource、UITableViewDelegate 方法，则在 viewController 里直接实现该方法，并在方法里调用 QMUIStaticTableViewCellDataSource (Manual) 提供的同名方法即可，具体可参考 QMUI Demo。
 */
class QMUIStaticTableViewCellDataSource: NSObject {

    /// 列表的数据源，是一个二维数组，其中一维表示 section，二维表示某个 section 里的 rows，每次调用这个属性的 setter 方法都会自动刷新 tableView 内容。
    var cellDataSections: [[QMUIStaticTableViewCellData]] {
        didSet {
            tableView?.reloadData()
        }
    }
    
    // 在 UITableView (QMUI_StaticCell) 那边会把 tableView 的 property 改为 readwrite，所以这里补上 setter
    var tableView: UITableView? {
        didSet {
            if #available(iOS 9.0, *) {
                tableView?.delegate = tableView?.delegate
                tableView?.dataSource = tableView?.dataSource
            } else {
                let delegate = tableView?.delegate
                tableView?.delegate = nil
                tableView?.delegate = delegate
                let dataSource = tableView?.dataSource
                tableView?.dataSource = nil
                tableView?.dataSource = dataSource
            }
        }
    }
    
    override init() {
        self.cellDataSections = [[QMUIStaticTableViewCellData]]()
        super.init()
    }

    convenience init(cellDataSections: [[QMUIStaticTableViewCellData]]) {
        self.init()
        self.cellDataSections = cellDataSections
    }
    
    // MARK:  当需要重写某些 UITableViewDataSource、UITableViewDelegate 方法时，这个分类里提供的同名方法需要在该方法中被调用，否则可能导致 QMUIStaticTableViewCellData 里设置的一些值无效。
    /**
     *  从 dataSource 里获取处于 indexPath 位置的 QMUIStaticTableViewCellData 对象
     *  @param indexPath cell 所处的位置
     */
    func cellData(at indexPath: IndexPath) -> QMUIStaticTableViewCellData? {
        if indexPath.section >= cellDataSections.count {
            print("cellDataWithIndexPath:\(indexPath), data not exist in section!")
            return nil
        }
        
        let rowDatas = cellDataSections[indexPath.section]
        if indexPath.row >= rowDatas.count {
            print("cellDataWithIndexPath:\(indexPath), data not exist in row!")
            return nil
        }
        
        let cellData = rowDatas[indexPath.row]
        cellData.indexPath = indexPath // 在这里才为 cellData.indexPath 赋值
        return cellData
    }
    
    /**
     *  根据 dataSource 计算出指定的 indexPath 的 cell 所对应的 reuseIdentifier（static tableView 里一般每个 cell 的 reuseIdentifier 都是不一样的，避免复用）
     *  @param indexPath cell 所处的位置
     */
    func reuseIdentifierForCell(at indexPath: IndexPath) -> String {
        guard let data = cellData(at: indexPath) else {
            return ""
        }
        return "cell_\(data.identifier)"
    }
    
    /**
     *  用于结合 indexPath 和 dataSource 生成 cell 的方法，其中 cell 使用的是 QMUITableViewCell
     *  @prama indexPath 当前 cell 的 indexPath
     */
    func cellForRow(at indexPath: IndexPath) -> QMUITableViewCell? {
        guard let data = cellData(at: indexPath) else {
            return nil
        }
        
        let identifier = reuseIdentifierForCell(at: indexPath)
        
        var cell = tableView?.dequeueReusableCell(withIdentifier: identifier) as? QMUITableViewCell
        if cell == nil, let cls = data.cellClass as? QMUITableViewCell.Type, let tableView = tableView {
            cell = cls.init(tableView: tableView, style: data.style, reuseIdentifier: identifier)
        }
        cell?.imageView?.image = data.image
        cell?.textLabel?.text = data.text
        cell?.detailTextLabel?.text = data.detailText
        cell?.accessoryType = QMUIStaticTableViewCellData.tableViewCellAccessoryType(withStaticAccessoryType: data.accessoryType)
        
        // 为某些控件类型的accessory添加控件及相应的事件绑定
        if data.accessoryType == .switch, let cell = cell {
            var switcher: UISwitch?
            var switcherOn = false
            if cell.accessoryView is UISwitch {
                switcher = cell.accessoryView as? UISwitch
            } else {
                switcher = UISwitch()
            }
            
            if let accessoryValueObject = data.accessoryValueObject as? Int {
                switcherOn = accessoryValueObject == 0 ? false : true
            }
            switcher?.isOn = switcherOn
            switcher?.removeTarget(nil, action: nil, for: .allEvents)
            if data.accessoryAction != nil {
                switcher?.addTarget(data.accessoryTarget, action: data.accessoryAction!, for: .valueChanged)
            }
            cell.accessoryView = switcher
        }
        
        // 统一设置selectionStyle
        if data.accessoryType == .switch || data.didSelectTarget == nil || data.didSelectAction == nil {
            cell?.selectionStyle = .none
        } else {
            cell?.selectionStyle = .blue
        }
        
        cell?.updateCellAppearance(indexPath)
        
        if let tableView = tableView, let cell = cell {
            data.cellForRowClosure?(tableView, cell, data)
        }
        
        return cell
    }
    
    /**
     *  从 dataSource 里获取指定位置的 cell 的高度
     *  @prama indexPath 当前 cell 的 indexPath
     *  @return 该位置的 cell 的高度
     */
    func heightForRow(at indexPath: IndexPath) -> CGFloat {
        guard let data = cellData(at: indexPath) else {
            return 0
        }
        return data.height
    }
    
    /**
     *  在 tableView:didSelectRowAtIndexPath: 里调用，可从 dataSource 里读取对应 indexPath 的 cellData，然后触发其中的 target 和 action
     *  @param indexPath 当前 cell 的 indexPath
     */
    func didSelectRow(at indexPath: IndexPath) {
        guard let data = cellData(at: indexPath), let didSelectTarget = data.didSelectTarget as? UIResponder, let didSelectAction = data.didSelectAction else {
            if let cell = tableView?.cellForRow(at: indexPath), cell.selectionStyle != .none {
                tableView?.deselectRow(at: indexPath, animated: true)
            }
            return
        }
        
        // 1、分发选中事件（UISwitch 类型不支持 didSelect）
        if didSelectTarget.responds(to: didSelectAction) && data.accessoryType != .switch {
            didSelectTarget.perform(didSelectAction, with: data)
        }
        
        // 2、处理点击状态（对checkmark类型的cell，选中后自动反选）
        if data.accessoryType == .checkmark {
            tableView?.deselectRow(at: indexPath, animated: true)
        }
    }
    
    /**
     *  在 tableView:accessoryButtonTappedForRowWithIndexPath: 里调用，可从 dataSource 里读取对应 indexPath 的 cellData，然后触发其中的 target 和 action
     *  @param indexPath 当前 cell 的 indexPath
     */
    func accessoryButtonTappedForRow(with indexPath: IndexPath) {
        if let data = cellData(at: indexPath), let didSelectTarget = data.didSelectTarget as? UIResponder, let didSelectAction = data.didSelectAction {
            if didSelectTarget.responds(to: didSelectAction) && data.accessoryType != .switch {
                didSelectTarget.perform(didSelectAction, with: data)
            }
        }
    }
}
