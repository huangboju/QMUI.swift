//
//  QDGridViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/5/8.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

class QDGridViewController: QDCommonViewController {
    
    private var gridView: QMUIGridView!
    
    private var tipsLabel: UILabel!

    override func initSubviews() {
        super.initSubviews()
        
        gridView = QMUIGridView()
        gridView.columnCount = 3
        gridView.rowHeight = 60
        gridView.separatorWidth = PixelOne
        gridView.separatorColor = UIColorSeparator
        gridView.separatorDashed = false
        view.addSubview(gridView)
        
        // 将要布局的 item 以 addSubview: 的方式添加进去即可自动布局
        let themeColors = [UIColorTheme1,
                           UIColorTheme2,
                           UIColorTheme3,
                           UIColorTheme4,
                           UIColorTheme5,
                           UIColorTheme6,
                           UIColorTheme7,
                           UIColorTheme8]
        themeColors.forEach {
            let view = UIView()
            view.backgroundColor = $0.withAlphaComponent(0.7)
            gridView.addSubview(view)
        }
        
        tipsLabel = UILabel()
        let attributes: [NSAttributedStringKey: Any] = [NSAttributedStringKey.font : UIFontMake(12), NSAttributedStringKey.foregroundColor: UIColorGray6, NSAttributedStringKey.paragraphStyle: NSMutableParagraphStyle(lineHeight: 18)]
        tipsLabel.attributedText = NSAttributedString(string: "适用于那种要将若干个 UIView 以九宫格的布局摆放的情况，支持显示 item 之间的分隔线。\n注意当 QMUIGridView 宽度发生较大变化时（例如横屏旋转），并不会自动增加列数，这种场景要么自己重新设置 columnCount，要么改为用 UICollectionView 实现。", attributes: attributes)
        tipsLabel.numberOfLines = 0
        view.addSubview(tipsLabel)
    }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let padding = UIEdgeInsets(top: 24 + qmui_navigationBarMaxYInViewCoordinator, left: 24, bottom: 24, right: 24)
        let contentWidth = view.bounds.width - padding.horizontalValue
        let gridViewHeight = gridView.sizeThatFits(CGSize(width: contentWidth, height: CGFloat.greatestFiniteMagnitude)).height
        gridView.frame = CGRect(x: padding.left, y: padding.top, width: contentWidth, height: gridViewHeight)
        
        let tipsLabelHeight = tipsLabel.sizeThatFits(CGSize(width: contentWidth, height: CGFloat.greatestFiniteMagnitude)).height
        tipsLabel.frame = CGRectFlat(padding.left, gridView.frame.maxY + 16, contentWidth, tipsLabelHeight)
    }
}
