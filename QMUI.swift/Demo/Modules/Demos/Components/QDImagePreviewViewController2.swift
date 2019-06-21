//
//  QDImagePreviewViewController2.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/5/15.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

class QDImagePreviewViewController2: QDCommonViewController {

    private var imagePreviewViewController: QMUIImagePreviewViewController?

    private var images: [UIImage] = [UIImageMake("image0")!,
                                     UIImageMake("image1")!,
                                     UIImageMake("image2")!,
                                     UIImageMake("image3")!,
                                     UIImageMake("image4")!,
                                     UIImageMake("image5")!,
                                     UIImageMake("image6")!]
    
    private var imageButton: UIButton!
    
    private var tipsLabel: UILabel!
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func initSubviews() {
        super.initSubviews()
        
        imageButton = UIButton()
        imageButton.setImage(images[2], for: .normal)
        imageButton.addTarget(self, action: #selector(handleImageButtonEvent(_:)), for: .touchUpInside)
        imageButton.layer.cornerRadius = 20
        imageButton.clipsToBounds = true
        view.addSubview(imageButton)
        
        tipsLabel = UILabel()
        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font : UIFontMake(12), NSAttributedString.Key.foregroundColor: UIColorGray6, NSAttributedString.Key.paragraphStyle: NSMutableParagraphStyle(lineHeight: 16, lineBreakMode: .byWordWrapping, textAlignment: .center)]
        let attributedText = NSAttributedString(string: "点击图片后可左右滑动，期间也可尝试横竖屏", attributes: attributes)
        tipsLabel.attributedText = attributedText
        tipsLabel.numberOfLines = 0
        view.addSubview(tipsLabel)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let imageButtonSize = CGSize(width: images.first!.size.width / 2, height: images.first!.size.height / 2)
        imageButton.frame = CGRectFlat(view.bounds.width.center(imageButtonSize.width), qmui_navigationBarMaxYInViewCoordinator + 24, imageButtonSize.width, imageButtonSize.height)
        
        let labelWidth = view.bounds.width - 32 * 2
        let tipsLabelHeight = tipsLabel.sizeThatFits(CGSize(width: labelWidth, height: CGFloat.greatestFiniteMagnitude)).height
        
        tipsLabel.frame = CGRectFlat(32, imageButton.frame.maxY + 8, labelWidth, tipsLabelHeight)
    }
    
    @objc private func handleImageButtonEvent(_ sender: Any?) {
        if imagePreviewViewController == nil {
            imagePreviewViewController = QMUIImagePreviewViewController()
            imagePreviewViewController?.imagePreviewView?.delegate = self
            imagePreviewViewController?.imagePreviewView?.currentImageIndex = 2 // 默认查看的图片的 index
        }
        let rect = imageButton.convert(imageButton.imageView!.frame, to: nil)
        imagePreviewViewController?.startPreviewFromRectInScreen(rect, cornerRadius: imageButton.layer.cornerRadius)
    }
}

extension QDImagePreviewViewController2: QMUIImagePreviewViewDelegate {
    func numberOfImages(in imagePreviewView: QMUIImagePreviewView) -> Int {
        return images.count
    }
    
    func imagePreviewView(_ imagePreviewView: QMUIImagePreviewView, renderZoomImageView zoomImageView: QMUIZoomImageView, at index: Int) {
        zoomImageView.image = images[index]
    }
    
    func imagePreviewView(_ imagePreviewView: QMUIImagePreviewView, assetTypeAt index: Int) -> QMUIImagePreviewMediaType {
        return .image
    }
}

extension QDImagePreviewViewController2: QMUIZoomImageViewDelegate {
    func singleTouch(in zoomingImageView: QMUIZoomImageView, location: CGPoint) {
        imageButton.setImage(zoomingImageView.image, for: .normal)
        let rect = imageButton.convert(imageButton.imageView!.frame, to: nil)
        imagePreviewViewController?.endPreviewToRectInScreen(rect)
    }
}
