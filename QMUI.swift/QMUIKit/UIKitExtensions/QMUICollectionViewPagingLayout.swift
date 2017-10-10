//
//  QMUICollectionViewPagingLayout.swift
//  QMUI.swift
//
//  Created by xnxin on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

enum QMUICollectionViewPagingLayoutStyle {
    case `default` // 普通模式，水平滑动
    case  scale    // 缩放模式，两边的item会小一点，逐渐向中间放大
    case  rotation // 旋转模式，围绕底部某个点为中心旋转
}

class QMUICollectionViewPagingLayout: UICollectionViewFlowLayout {
    
    /**
     *  是否支持一次滑动可以滚动多个 item，默认为 true
     */
    public var allowsMultipleItemScroll = true

    init(style: QMUICollectionViewPagingLayoutStyle = .`default`) {
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
