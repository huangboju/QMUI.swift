//
//  QMUIGridView.swift
//  QMUI.swift
//
//  Created by 黄伯驹 on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

/**
 *  用于做九宫格布局，会将内部所有的 subview 根据指定的列数和行高，把每个 item（也即 subview） 拉伸到相同的大小。
 *
 *  支持在 item 和 item 之间显示分隔线，分隔线支持虚线。
 *
 *  @warning 注意分隔线是占位的，把 item 隔开，而不是盖在某个 item 上。
 */
class QMUIGridView: UIView {
    
    /// 指定要显示的列数，默认为 0
    @IBInspectable
    public var columnCount = 0
    
    /// 指定每一行的高度，默认为 0
    @IBInspectable
    public var rowHeight: CGFloat = 0
    
    /// 指定 item 之间的分隔线宽度，默认为 0
    @IBInspectable
    public var separatorWidth: CGFloat = 0
    
    /// 指定 item 之间的分隔线颜色，默认为 UIColorSeparator
    @IBInspectable
    public var separatorColor = UIColorSeparator
    
    /// item 之间的分隔线是否要用虚线显示，默认为 false
    @IBInspectable
    public var separatorDashed = false

    /// 候选的初始化方法，亦可通过 initWithFrame:、init 来初始化。
    init(column: Int, rowHeight: CGFloat) {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
