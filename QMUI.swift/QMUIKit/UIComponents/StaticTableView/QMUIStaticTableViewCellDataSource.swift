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
    fileprivate(set) var tableView: UITableView? {
        didSet {
            let delegate = tableView?.delegate
            tableView?.delegate = nil
            tableView?.delegate = delegate
            let dataSource = tableView?.dataSource
            tableView?.dataSource = nil
            tableView?.dataSource = dataSource
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
            Thread.detachNewThreadSelector(didSelectAction, toTarget: didSelectTarget, with: data)
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
                Thread.detachNewThreadSelector(didSelectAction, toTarget: didSelectTarget, with: data)
            }
        }
    }
}

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
    fileprivate(set) var indexPath: IndexPath?
    
    /// cell 要使用的 class，默认为 QMUITableViewCell，若要改为自定义 class，必须是 QMUITableViewCell 的子类
    var cellClass: AnyClass {
        willSet {
            assert(cellClass is QMUITableViewCell.Type, "\(type(of: self)).cellClass 必须为 QMUITableViewCell 的子类")
        }
    }
    
    /// init cell 时要使用的 style
    var style: UITableViewCell.CellStyle
    
    /// cell 的高度，默认为 TableViewCellNormalHeight
    var height: CGFloat
    
    /// cell 左边要显示的图片，将会被设置到 cell.imageView.image
    var image: UIImage?
    
    /// cell 的文字，将会被设置到 cell.textLabel.text
    var text: String
    
    /// cell 的详细文字，将会被设置到 cell.detailTextLabel.text，所以要求 cellData.style 的值必须是带 detailTextLabel 类型的 style
    var detailText: String?
    
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
         style: UITableViewCell.CellStyle = .default,
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
    
    static func tableViewCellAccessoryType(withStaticAccessoryType type: QMUIStaticTableViewCellAccessoryType) -> UITableViewCell.AccessoryType {
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

extension UITableView {
    
    fileprivate struct Keys {
        static var staticCellDataSource = "staticCellDataSource"
    }
    
    var qmui_staticCellDataSource: QMUIStaticTableViewCellDataSource? {
        get {
            return objc_getAssociatedObject(self, &Keys.staticCellDataSource) as? QMUIStaticTableViewCellDataSource
        }
        set {
            objc_setAssociatedObject(self, &Keys.staticCellDataSource, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            newValue?.tableView = self
            reloadData()
        }
    }
    
    @objc func staticCell_setDataSource(_ dataSource: UITableViewDataSource?) {
        if let dataSource = dataSource as? NSObject, let _ = qmui_staticCellDataSource {
            // 这些 addMethod 的操作必须要在系统的 setDataSource 执行前就执行，否则 tableView 可能会认为不存在这些 method
            // 并且 addMethod 操作执行一次之后，直到 App 进程被杀死前都会生效，所以多次进入这段代码可能就会提示添加方法失败，请不用在意

            // MARK: TODO
            addSelector(#selector(UITableViewDataSource.numberOfSections(in:)), implementation: imp_implementationWithBlock(unsafeBitCast(staticCell_numberOfSections, to: AnyObject.self)), types: "l@:@", for: dataSource)
            addSelector(#selector(UITableViewDataSource.tableView(_:numberOfRowsInSection:)), implementation: imp_implementationWithBlock(staticCell_numberOfRows), types: "l@:@l", for: dataSource)
            addSelector(#selector(UITableViewDataSource.tableView(_:cellForRowAt:)), implementation: imp_implementationWithBlock(staticCell_cellForRow), types: "@@:@@", for: dataSource)
        }
        staticCell_setDataSource(dataSource)
    }
    
    @objc func staticCell_setDelegate(_ delegate: UITableViewDelegate?) {
        if let delegate = delegate, let _ = qmui_staticCellDataSource {
            
        }
        staticCell_setDelegate(delegate)
    }
    
    private typealias StaticCell_numberOfSectionsBlockType = @convention(block) (Any, Selector, UITableView) -> Int
    private var staticCell_numberOfSections: StaticCell_numberOfSectionsBlockType {
        get {
            let block: StaticCell_numberOfSectionsBlockType = { (current_self, current_cmd, tableView) in
                return tableView.qmui_staticCellDataSource?.cellDataSections.count ?? 0
            }
            return block
        }
    }
    
    private typealias StaticCell_numberOfRowsBlockType = @convention(block) (Any, Selector, UITableView, Int) -> Int
    private var staticCell_numberOfRows: StaticCell_numberOfRowsBlockType {
        get {
            let block: StaticCell_numberOfRowsBlockType = { (current_self, current_cmd, tableView, section) in
                print(tableView)
                return tableView.qmui_staticCellDataSource?.cellDataSections[section].count ?? 0
            }
            return block
        }
    }
    
    private typealias StaticCell_cellForRowBlockType = @convention(block) (Any, Selector, UITableView, IndexPath) -> Any?
    private var staticCell_cellForRow: StaticCell_cellForRowBlockType {
        get {
            let block: StaticCell_cellForRowBlockType = { (current_self, current_cmd, tableView, indexPath) in
                return tableView.qmui_staticCellDataSource?.accessoryButtonTappedForRow(with: indexPath) ?? nil
            }
            return block
        }
    }
}

fileprivate var QMUI_staticTableViewAddedClass = Set<String>()
fileprivate func addSelector(_ selector: Selector, implementation: IMP, types: UnsafePointer<Int8>?, for object: NSObject) {
    let cls = type(of: object)
    if !class_addMethod(cls.self, selector, implementation, types) {
        let identifier = "\(type(of: object))\(NSStringFromSelector(selector))"
        if !QMUI_staticTableViewAddedClass.contains(identifier) {
            print("\(cls), 尝试为 \(cls) 添加方法 \(NSStringFromSelector(selector)) 失败，可能该类里已经实现了这个方法")
            QMUI_staticTableViewAddedClass.insert(identifier)
        }
    }
}
