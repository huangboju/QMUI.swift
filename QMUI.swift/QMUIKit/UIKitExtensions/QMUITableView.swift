//
//  QMUITableView.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/2/9.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

class QMUITableView: UITableView {

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        didInitialized()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        didInitialized()
    }

    func didInitialized() {
        qmui_styledAsQMUITableView()
        
//        if !TableViewEstimatedHeightEnabled {
//            estimatedRowHeight = 0
//            estimatedSectionHeaderHeight = 0
//            estimatedSectionFooterHeight = 0
//        } else {
//            estimatedRowHeight = UITableViewAutomaticDimension
//            estimatedSectionHeaderHeight = UITableViewAutomaticDimension
//            estimatedSectionFooterHeight = UITableViewAutomaticDimension
//        }
    }

    // 保证一直存在tableFooterView，以去掉列表内容不满一屏时尾部的空白分割线
    override var tableFooterView: UIView? {
        didSet {
            if tableFooterView == nil {
                tableFooterView = UIView()
            }
        }
    }

    override func touchesShouldCancel(in view: UIView) -> Bool {
        if let delegate = delegate as? QMUITableViewDelegate {
            return delegate.tableView?(self, touchesShouldCancelIn: view) ?? true
        }

        // 默认情况下只有当view是非UIControl的时候才会返回yes，这里统一对UIButton也返回yes
        // 原因是UITableView上面把事件延迟去掉了，但是这样如果拖动的时候手指是在UIControl上面的话，就拖动不了了
        if view is UIControl {
            return view is UIButton
        }
        return true
    }
}
