//
//  QDCustomToastContentView.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/5/4.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

private let kInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
private let kImageViewHeight: CGFloat = 86
private let kImageViewMarginRight: CGFloat = 12
private let kTextLabelMarginBottom: CGFloat = 4

class QDCustomToastContentView: UIView {

    var imageView: UIImageView!
    private(set) var textLabel: UILabel!
    private(set) var detailTextLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initSubviews() {
        
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 4
        addSubview(imageView)
        
        textLabel = UILabel()
        textLabel.textColor = UIColorWhite
        textLabel.font = UIFontBoldMake(17)
        textLabel.isOpaque = false
        addSubview(textLabel)
        
        detailTextLabel = UILabel()
        detailTextLabel.numberOfLines = 0
        detailTextLabel.textAlignment = .justified
        detailTextLabel.lineBreakMode = .byTruncatingTail
        detailTextLabel.textColor = UIColorWhite
        detailTextLabel.font = UIFontMake(14)
        detailTextLabel.isOpaque = false
        addSubview(detailTextLabel)
    }
    
    func render(with image: UIImage?, text: String, detailText: String) {
        imageView.image = image
        textLabel.text = text
        detailTextLabel.text = detailText
        imageView.sizeToFit()
        textLabel.sizeToFit()
        detailTextLabel.sizeToFit()
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let width = fmin(size.width, QMUIHelper.screenSizeFor55Inch.width)
        let height = kImageViewHeight + kInsets.verticalValue
        return CGSize(width: fmin(size.width, width), height: fmin(size.height, height))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.qmui_sizeToFitKeepingImageAspectRatio(in: CGSize(width: CGFloat.greatestFiniteMagnitude, height: kImageViewHeight))
        let contentWidth = bounds.width
        let maxContentWidth = contentWidth - kInsets.verticalValue
        let labelWidth = maxContentWidth - imageView.frame.width - kImageViewMarginRight
        
        imageView.frame = imageView.frame.setXY(kInsets.left, kInsets.top)
        textLabel.frame = CGRectFlat(imageView.frame.maxX + kImageViewMarginRight, imageView.frame.minY + 5, labelWidth, textLabel.bounds.height)
        
        let detailLimitHeight = bounds.height - textLabel.frame.maxY - kTextLabelMarginBottom - kInsets.bottom
        let detailSize = detailTextLabel.sizeThatFits(CGSize(width: labelWidth, height: detailLimitHeight))
        detailTextLabel.frame = CGRectFlat(textLabel.frame.minX, textLabel.frame.maxY + kTextLabelMarginBottom, labelWidth, fmin(detailLimitHeight, detailSize.height))
    }
}
