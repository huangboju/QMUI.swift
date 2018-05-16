//
//  QDImagePreviewViewController1.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/5/15.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

class QDImagePreviewViewController1: QDCommonViewController {

    private var imagePreviewView: QMUIImagePreviewView!
    private var images: [UIImage] = [UIImageMake("image0")!,
                                     UIImageMake("image1")!,
                                     UIImageMake("image2")!,
                                     UIImageMake("image3")!,
                                     UIImageMake("image4")!,
                                     UIImageMake("image5")!,
                                     UIImageMake("image6")!]
    
    init() {
        super.init(nibName: nil, bundle: nil)
        automaticallyAdjustsScrollViewInsets = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func initSubviews() {
        super.initSubviews()
        
        imagePreviewView = QMUIImagePreviewView()
        imagePreviewView.delegate = self
        imagePreviewView.loadingColor = UIColorGray// 设置每张图片里的 loading 的颜色，需根据业务场景来修改
        imagePreviewView.collectionViewLayout.minimumLineSpacing = 0 // 去掉每张图片之间的间隙
        view.addSubview(imagePreviewView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let originY = qmui_navigationBarMaxYInViewCoordinator
        let imageSize = images.first?.size ?? .zero
        var imagePreviewViewSize = CGSize(width: view.bounds.width, height: view.bounds.width * imageSize.height / imageSize.width)
        imagePreviewViewSize.height = fmin(view.bounds.height - originY, imagePreviewViewSize.height)
        imagePreviewView.frame = CGRectFlat(view.bounds.width.center(imagePreviewViewSize.width), originY, imagePreviewViewSize.width, imagePreviewViewSize.height)
    }
    
    override func setNavigationItems(_ isInEditMode: Bool, animated: Bool) {
        super.setNavigationItems(isInEditMode, animated: animated)
        title = title(for: imagePreviewView.currentImageIndex)
    }
    
    private func title(for index: Int) -> String {
        return "\(index + 1) / \(images.count)"
    }
}

extension QDImagePreviewViewController1: QMUIImagePreviewViewDelegate {
    
    func numberOfImages(in imagePreviewView: QMUIImagePreviewView) -> Int {
        return images.count
    }
    
    func imagePreviewView(_ imagePreviewView: QMUIImagePreviewView, renderZoomImageView zoomImageView: QMUIZoomImageView, at index: Int) {
        zoomImageView.contentMode = .scaleAspectFit
        if index == 1 {
            zoomImageView.image = nil // 第 2 张图将图片清空，模拟延迟加载的场景
            zoomImageView.showLoading()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                // 由于 cell 是复用的，所以之前的 zoomImageView 可能已经被用于显示其他 index 的图片了，所以这里要重新判断一下 index
                let indexForZoomImageView = imagePreviewView.index(for: zoomImageView)
                if indexForZoomImageView == index {
                    zoomImageView.image = self.images[index]
                    zoomImageView.hideEmptyView()
                }
            }
        } else {
            // 设置图片，此时会按默认的缩放来显示（所谓的默认缩放指如果图片比容器小则显示原大小，如果图片比容器大，则缩放到完整显示图片）
            zoomImageView.image = images[index]
            zoomImageView.hideEmptyView()
        }
    }
  
    func imagePreviewView(_ imagePreviewView: QMUIImagePreviewView, assetTypeAt index: Int) -> QMUIImagePreviewMediaType {
        return .image
    }
    
    func imagePreviewView(_ imagePreviewView: QMUIImagePreviewView, willScrollHalfTo index: Int) {
        title = title(for: index)
    }
}
