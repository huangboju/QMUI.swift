//
//  UITableView+QMUIStaticCell.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/5/23.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import Foundation

/**
 *  配合 QMUIStaticTableViewCellDataSource 使用，主要负责：
 *  1. 提供 property 去绑定一个 static dataSource
 *  2. 重写 setDataSource:、setDelegate: 方法，自动实现 UITableViewDataSource、UITableViewDelegate 里一些必要的方法
 *
 *  使用方式：初始化一个 QMUIStaticTableViewCellDataSource 并将其赋值给 qmui_staticCellDataSource 属性即可。
 *
 *  @warning 当要动态更新 dataSource 时，可直接修改 self.qmui_staticCellDataSource.cellDataSections 数组，或者创建一个新的 QMUIStaticTableViewCellDataSource。不管用哪种方法，都不需要手动调用 reloadData，tableView 会自动刷新的。
 */
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
    
    // MARK: TODO
    @objc func staticCell_setDataSource(_ dataSource: UITableViewDataSource?) {
        if let object = dataSource as? NSObject, let _ = qmui_staticCellDataSource {
            let block: @convention(block) (Any, Selector, UITableView) -> Int = { (current_self, current_cmd, tableView) in
                return tableView.qmui_staticCellDataSource?.cellDataSections.count ?? 0
            }
//            addSelector(#selector(dataSource?.numberOfSections(in:)), implementation: imp_implementationWithBlock(unsafeBitCast(block, to: AnyObject.self)), types: "i@:@", for: object)
//            addSelector(NSSelectorFromString("numberOfRows(inSection:)"), implementation: imp_implementationWithBlock(unsafeBitCast(staticCell_numberOfRows, to: AnyObject.self)), types: "l@:@l", for: object)
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
