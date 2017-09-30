//
//  QMUITableViewCell.swift
//  QMUI.swift
//
//  Created by xnxin on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

import UIKit

class QMUITableViewCell: UITableViewCell {

    /// 保存对tableView的弱引用，在布局时可能会使用到tableView的一些属性例如separatorColor等。只有使用下面两个 initForTableView: 的接口初始化时这个属性才有值，否则就只能自己初始化后赋值
    public weak var parentTableView: UITableView?
    
    /**
     *  cell 处于 section 中的位置，要求：
     *  1. cell 使用 initForTableViewXxx 方法初始化，或者初始化完后为 parentTableView 属性赋值。
     *  2. 在 cellForRow 里调用 [cell updateCellAppearanceWithIndexPath:] 方法。
     *  3. 之后即可通过 cellPosition 获取到正确的位置。
     */
    fileprivate(set) var cellPosition: QMUITableViewCellPosition = .none

    convenience init(tableView: UITableView, withStyle style: UITableViewCellStyle, reuseIdentifier: String?) {
        self.init(style: style, reuseIdentifier: reuseIdentifier)
        parentTableView = tableView
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension QMUITableViewCell {
    @objc func updateCellAppearance(with indexPath: IndexPath) {
        // 子类继承
        if let parentTableView = parentTableView {
            cellPosition = parentTableView.qmui_positionForRow(at: indexPath)
        }
    }
}
