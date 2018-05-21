//
//  QDCollectionDemoViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/4/19.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

class QDCollectionDemoViewController: QDCommonViewController {

    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = UIColorClear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(QDCollectionViewDemoCell.self, forCellWithReuseIdentifier: "cell")
        return collectionView
    }()

    private(set) var collectionViewLayout: QMUICollectionViewPagingLayout
    
    private var isDebug: Bool = false
    
    private var debugLayer: CALayer?
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    convenience init(style: QMUICollectionViewPagingLayoutStyle) {
        self.init(nibName: nil, bundle: nil)
        collectionViewLayout = QMUICollectionViewPagingLayout(with: style)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        collectionViewLayout = QMUICollectionViewPagingLayout(with: .default)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setNavigationItems(_ isInEditMode: Bool, animated: Bool) {
        super.setNavigationItems(isInEditMode, animated: animated)
        
        titleView.isUserInteractionEnabled = true
        titleView.addTarget(self, action: #selector(handleTitleViewTouchEvent), for: .touchUpInside)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem.item(title: isDebug ? "普通模式" : "调试模式", target: self, action: #selector(handleDebugItemEvent))
    }
    
    override func initSubviews() {
        super.initSubviews()
        
        view.addSubview(collectionView)
        
        collectionViewLayout.sectionInset = sectionInset
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if collectionView.bounds.size != view.bounds.size {
            collectionView.frame = view.bounds
            collectionViewLayout.sectionInset = sectionInset
            collectionViewLayout.invalidateLayout()
        }
        
        if debugLayer != nil {
            debugLayer!.frame = CGRect(x: view.center.x, y: 0, width: PixelOne, height: view.bounds.height)
        }
    }

    @objc func handleDebugItemEvent() {
        isDebug = !isDebug
        
        collectionViewLayout.sectionInset = sectionInset
        collectionViewLayout.invalidateLayout()
        collectionView.qmui_scrollToTopAnimated(true)
        
        if isDebug {
            debugLayer = CALayer()
            debugLayer!.qmui_removeDefaultAnimations()
            debugLayer!.backgroundColor = UIColorRed.cgColor
            view.layer.addSublayer(debugLayer!)
        } else {
            debugLayer?.removeFromSuperlayer()
            debugLayer = nil
        }
        
        setNavigationItems(false, animated: false)
    }
    
    @objc func handleTitleViewTouchEvent() {
        collectionView.qmui_scrollToTopAnimated(true)
    }
    
    private var sectionInset: UIEdgeInsets {
        if isDebug {
            let itemSize = CGSize(width: 100, height: 100)
            let horizontalInset = (collectionView.bounds.width - itemSize.width) / 2
            let verticalInset = (collectionView.bounds.height - collectionView.qmui_contentInset.verticalValue - itemSize.height) / 2
            return UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
        } else {
            return UIEdgeInsets(top: 36, left: 36, bottom: 36, right: 36)
        }
    }
}

extension QDCollectionDemoViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? QDCollectionViewDemoCell
        cell?.contentLabel.text = "\(indexPath.item)"
        cell?.backgroundColor = QDCommonUI.randomThemeColor()
        cell?.setNeedsLayout()
        return cell ?? UICollectionViewCell()
    }
}

extension QDCollectionDemoViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: collectionView.bounds.width - self.collectionViewLayout.sectionInset.horizontalValue, height: collectionView.bounds.height - self.collectionViewLayout.sectionInset.verticalValue - qmui_navigationBarMaxYInViewCoordinator)
        return size
    }
}
