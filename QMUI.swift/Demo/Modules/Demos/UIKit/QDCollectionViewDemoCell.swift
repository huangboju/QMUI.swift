//
//  QDCollectionViewDemoCell.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/4/19.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

class QDCollectionViewDemoCell: UICollectionViewCell {
    
    private(set) lazy var contentLabel: UILabel = {
        let contentLabel = UILabel(with: UIFontLightMake(100), textColor: UIColorWhite)
        contentLabel.textAlignment = .center
        return contentLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 3
        contentView.addSubview(contentLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentLabel.sizeToFit()
        contentLabel.center = CGPoint(x: contentView.bounds.width / 2, y: contentView.bounds.height / 2)
    }
}
