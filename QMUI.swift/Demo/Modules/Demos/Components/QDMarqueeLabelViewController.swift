//
//  QDMarqueeLabelViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/5/21.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

class QDMarqueeLabelViewController: QDCommonViewController {

    private var label: QMUIMarqueeLabel!
    private var shortTextLabel: QMUIMarqueeLabel!
    private var noFadeAndQuickLabel: QMUIMarqueeLabel!
    private var textStartLabel: QMUIMarqueeLabel!
    private var separatorLayer: CALayer!
    private var collectionView: UICollectionView!
    private var collectionViewLayout: QMUICollectionViewPagingLayout!
    
    override func initSubviews() {
        super.initSubviews()
        
        shortTextLabel = generateLabel(with: "短文字时不会滚动")
        view.addSubview(shortTextLabel)
        
        label = generateLabel(with: "QMUIMarqueeLabel 会在添加到界面上后，并且文字超过 label 宽度时自动滚动")
        view.addSubview(label)
        
        noFadeAndQuickLabel = generateLabel(with: "通过 shouldFadeAtEdge = NO 可隐藏文字滚动时边缘的渐隐遮罩，通过 speed 属性可以调节滚动的速度")
        noFadeAndQuickLabel.shouldFadeAtEdge = false // 关闭渐隐遮罩
        noFadeAndQuickLabel.speed = 1.5 // 调节滚动速度
        view.addSubview(noFadeAndQuickLabel)
        
        textStartLabel = generateLabel(with: "通过 textStartAfterFade 属性可控制文字是否要停靠在遮罩的右边")
        textStartLabel.textStartAfterFade = true // 文字停靠在遮罩的右边
        textStartLabel.speed = 1.5 // 调节滚动速度
        view.addSubview(textStartLabel)
        
        separatorLayer = CALayer.qmui_separatorLayer()
        view.layer.addSublayer(separatorLayer)
        
        collectionViewLayout = QMUICollectionViewPagingLayout(with: .default)
        collectionViewLayout.minimumLineSpacing = 20
        collectionViewLayout.minimumInteritemSpacing = 0
        collectionViewLayout.sectionInset = UIEdgeInsets(top: 32, left: 32, bottom: 32, right: 32)
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: collectionViewLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(QDMarqueeCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.backgroundColor = UIColorWhite
        collectionView.showsHorizontalScrollIndicator = false
        view.addSubview(collectionView)
    }

    private func generateLabel(with text: String) -> QMUIMarqueeLabel {
        let label = QMUIMarqueeLabel(with: UIFontMake(16), textColor: UIColorGray1)
        label.textAlignment = .center // 跑马灯文字一般都是居中显示，所以 Demo 里默认使用 center
        label.qmui_calculateHeightAfterSetAppearance()
        label.text = text
        return label
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var minY = qmui_navigationBarMaxYInViewCoordinator
        separatorLayer.frame = CGRectFlat(0, minY + (view.bounds.height - minY) / 2, view.bounds.width, PixelOne)
        
        let paddings = UIEdgeInsets(top: minY + 32, left: 24, bottom: 24, right: 24)
        let labelWidth = fmin(view.bounds.width, QMUIHelper.screenSizeFor47Inch.width) - paddings.horizontalValue
        let labelMinX = view.bounds.width.center(labelWidth)
        let firstSubviewHeight = view.subviews.first?.frame.height ?? 0
        var labelSpacing = (separatorLayer.frame.minY - paddings.top - paddings.bottom - firstSubviewHeight * CGFloat(view.subviews.count)) / CGFloat(view.subviews.count - 1)
        labelSpacing = fmax(fmin(labelSpacing, 32), 10)
        minY = paddings.top
        for subview in view.subviews {
            if let label = subview as? QMUIMarqueeLabel {
                label.frame = CGRect(x: labelMinX, y: minY, width: labelWidth, height: label.frame.height)
                minY = label.frame.maxY + labelSpacing
            }
        }
        
        collectionView.frame = CGRect(x: 0, y: separatorLayer.frame.maxY, width: view.bounds.width, height: view.bounds.height - separatorLayer.frame.maxY)
        collectionViewLayout.itemSize = CGSize(width: collectionView.bounds.width - collectionViewLayout.sectionInset.horizontalValue, height: collectionView.bounds.height - collectionViewLayout.sectionInset.verticalValue)
        collectionView.contentOffset = .zero
    }
}

extension QDMarqueeLabelViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? QDMarqueeCollectionViewCell
        cell?.label?.text = "在可复用的 UIView 里使用 QMUIMarqueeLabel 时，需要手动触发动画、停止动画，否则可能在滚动过程中动画会不正确地被开启/关闭"
        return cell ?? UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // 在 willDisplayCell 里开启动画（不能在 cellForItem 里开启，是因为 cellForItem 的时候，cell 尚未被 add 到 collectionView 上，cell.window 为 nil）
        if let cell = cell as? QDMarqueeCollectionViewCell {
            let _ = cell.label.requestToStartAnimation
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // 在 didEndDisplayingCell 里停止动画，避免资源消耗
        if let cell = cell as? QDMarqueeCollectionViewCell {
            let _ = cell.label.requestToStopAnimation
        }
    }
}

fileprivate class QDMarqueeCollectionViewCell: UICollectionViewCell {
    fileprivate var label: QMUIMarqueeLabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = QDCommonUI.randomThemeColor()
        layer.cornerRadius = 3
        
        label = QMUIMarqueeLabel(with: UIFontMake(16), textColor: UIColorWhite)
        label.qmui_calculateHeightAfterSetAppearance()
        label.fadeStartColor = backgroundColor
        label.fadeEndColor = backgroundColor?.withAlphaComponent(0)
        contentView.addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = CGRect(x: 24, y: contentView.bounds.height.center(label.frame.height), width: contentView.bounds.width - 24 * 2, height: label.frame.height)
    }
}
