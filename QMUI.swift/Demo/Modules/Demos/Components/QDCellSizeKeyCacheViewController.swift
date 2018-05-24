//
//  QDCellSizeKeyCacheViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/5/23.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

class QDDynamicSizeCollectionViewCell: UICollectionViewCell {
    
    fileprivate var textLabel: UILabel!
    
    fileprivate var paddings: UIEdgeInsets!
    
    fileprivate var indexPath: IndexPath?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColorWhite
        layer.shadowColor = UIColorBlack.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 15
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.cornerRadius = 6
        
        textLabel = UILabel()
        textLabel.numberOfLines = 0
        contentView.addSubview(textLabel)
        
        paddings = UIEdgeInsets(top: 12, left: 16, bottom: 16, right: 16)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let result = super.preferredLayoutAttributesFitting(layoutAttributes)
        let resultHeight = textLabel.sizeThatFits(CGSize(width: result.size.width - paddings.horizontalValue, height: CGFloat.greatestFiniteMagnitude)).height + paddings.verticalValue
        let resultSize = CGSize(width: result.size.width, height: resultHeight).flatted
        print("第 \(String(describing: indexPath?.item)) 个 cell 的 preferredLayoutAttributesFittingAttributes: 被调用（说明这个 cell 的 size 重新计算了一遍），结果为 \(NSStringFromCGSize(resultSize))")
        result.size = resultSize
        return result
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
        textLabel.frame = CGRect(x: paddings.left, y: paddings.top, width: contentView.bounds.width - paddings.horizontalValue, height: contentView.bounds.height - paddings.verticalValue)
    }
}

class QDCellSizeKeyCacheViewController: QDCommonViewController {

    private var dataSource: [String] {
        get {
            return ["UIViewController is a generic controller base class that manages a view.  It has methods that are called when a view appears or disappears.",
                    "Subclasses can override -loadView to create their custom view hierarchy, or specify a nib name to be loaded automatically.  This class is also a good place for delegate & datasource methods, and other controller stuff.",
                    "Views are the fundamental building blocks of your app's user interface, and the UIView class defines the behaviors that are common to all views. A view object renders content within its bounds rectangle and handles any interactions with that content.",
                    "The UIView class is a concrete class that you can instantiate and use to display a fixed background color. You can also subclass it to draw more sophisticated content.",
                    "To display labels, images, buttons, and other interface elements commonly found in apps, use the view subclasses provided by the UIKit framework rather than trying to define your own.",
                    "The base class for controls, which are visual elements that convey a specific action or intention in response to user interactions.",
                    "Controls implement elements such as buttons and sliders, which your app might use to facilitate navigation, gather user input, or manipulate content. Controls use the Target-Action mechanism to report user interactions to your app.",
                    "You do not create instances of this class directly. The UIControl class is a subclassing point that you extend to implement custom controls. You can also subclass existing control classes to extend or modify their behaviors. For example, you might override the methods of this class to track touch events yourself or to determine when the state of the control changes.",
                    "A control’s state determines its appearance and its ability to support user interactions. Controls can be in one of several states, which are defined by the UIControlState type. You can change the state of a control programmatically based on your app’s needs. For example, you might disable a control to prevent the user from interacting with it. User interactions can also change the state of a control.",
                    "The appearance of labels is configurable, and they can display attributed strings, allowing you to customize the appearance of substrings within a label. You can add labels to your interface programmatically or by using Interface Builder.",
                    "Supply either a string or an attributed string that represents the content.",
                    "If using a nonattributed string, configure the appearance of the label.",
                    "Set up Auto Layout rules to govern the size and position of the label in your interface.",
                    "Provide accessibility information and localized strings.",
                    "Image views let you efficiently draw any image that can be specified using a UIImage object. For example, you can use the UIImageView class to display the contents of many standard image files, such as JPEG and PNG files. You can configure image views programmatically or in your storyboard file and change the images they display at runtime. For animated images, you can also use the methods of this class to start and stop the animation and specify other animation parameters."
            ]
        }
    }

    private var collectionView: UICollectionView!
    private var collectionLayout: UICollectionViewFlowLayout!
    
    override func initSubviews() {
        super.initSubviews()
        
        collectionLayout = UICollectionViewFlowLayout()
        collectionLayout.scrollDirection = .vertical
        collectionLayout.sectionInset = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
        collectionLayout.minimumLineSpacing = collectionLayout.sectionInset.top
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: collectionLayout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColorWhite
        collectionView.register(QDDynamicSizeCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.qmui_cacheCellSizeByKeyAutomatically = true
        view.addSubview(collectionView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        collectionView.frame = view.bounds
        collectionLayout.estimatedItemSize = CGSize(width: collectionView.bounds.width - collectionLayout.sectionInset.horizontalValue, height: 300)
    }
}

extension QDCellSizeKeyCacheViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? QDDynamicSizeCollectionViewCell
        let text = dataSource[indexPath.item]
        let attributes: [NSAttributedStringKey: Any] = [NSAttributedStringKey.font : UIFontMake(14), NSAttributedStringKey.foregroundColor: UIColorBlack, NSAttributedStringKey.paragraphStyle: NSMutableParagraphStyle(lineHeight: 20)]
        cell?.textLabel.attributedText = NSAttributedString(string: text, attributes: attributes)
        cell?.indexPath = indexPath
        cell?.setNeedsLayout()
        return cell ?? UICollectionViewCell()
    }
}

extension QDCellSizeKeyCacheViewController: QMUICellSizeKeyCache_UICollectionViewDelegate {
    func qmui_collectionView(_ collectionView: UICollectionView, cacheKeyForRowAt indexPath: IndexPath) -> AnyObject {
        return dataSource[indexPath.item].qmui_md5 as AnyObject
    }
}
