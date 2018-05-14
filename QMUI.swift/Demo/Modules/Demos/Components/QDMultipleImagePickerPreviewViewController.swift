//
//  QDMultipleImagePickerPreviewViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/5/14.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

protocol QDMultipleImagePickerPreviewViewControllerDelegate: QMUIImagePickerPreviewViewControllerDelegate {
    
    func imagePickerPreviewViewController(_ imagePickerPreviewViewController: QDMultipleImagePickerPreviewViewController, sendImageWithImagesAssetArray imagesAssetArray: [QMUIAsset])
    
}

private let ImageCountLabelSize = CGSize(width: 18, height: 18)

class QDMultipleImagePickerPreviewViewController: QMUIImagePickerPreviewViewController {

    weak var multipleDelegate: QDMultipleImagePickerPreviewViewControllerDelegate? {
        get {
            return delegate as? QDMultipleImagePickerPreviewViewControllerDelegate
        }
        set {
            delegate = newValue
        }
    }
    
    var imageCountLabel: QMUILabel!
    
    var assetsGroup: QMUIAssetsGroup?
    
    var shouldUseOriginImage: Bool = false
    
    private var sendButton: QMUIButton!
    private var originImageCheckboxButton: QMUIButton!
    private var bottomToolBarView: UIView!
    
    override func initSubviews() {
        super.initSubviews()
        
        bottomToolBarView = UIView()
        bottomToolBarView.backgroundColor = toolBarBackgroundColor
        view.addSubview(bottomToolBarView)
        
        sendButton = QMUIButton()
        sendButton.adjustsTitleTintColorAutomatically = true
        sendButton.adjustsImageTintColorAutomatically = true
        sendButton.qmui_outsideEdge = UIEdgeInsets(top: -6, left: -6, bottom: -6, right: -6)
        sendButton.setTitle("发送", for: .normal)
        sendButton.titleLabel?.font = UIFontMake(16)
        sendButton.sizeToFit()
        sendButton.addTarget(self, action: #selector(handleSendButtonClick(_:)), for: .touchUpInside)
        bottomToolBarView.addSubview(sendButton)
        
        imageCountLabel = QMUILabel()
        imageCountLabel.backgroundColor = toolBarTintColor
        imageCountLabel.textColor = toolBarTintColor.qmui_colorIsDark ? UIColorWhite : UIColorBlack
        imageCountLabel.font = UIFontMake(12)
        imageCountLabel.textAlignment = .center
        imageCountLabel.lineBreakMode = .byCharWrapping
        imageCountLabel.layer.masksToBounds = true
        imageCountLabel.layer.cornerRadius = ImageCountLabelSize.width / 2
        imageCountLabel.isHidden = true
        bottomToolBarView.addSubview(imageCountLabel)
        
        originImageCheckboxButton = QMUIButton()
        originImageCheckboxButton.adjustsTitleTintColorAutomatically = true
        originImageCheckboxButton.adjustsImageTintColorAutomatically = true
        originImageCheckboxButton.titleLabel?.font = UIFontMake(14)
        originImageCheckboxButton.setImage(UIImageMake("origin_image_checkbox"), for: .normal)
        originImageCheckboxButton.setImage(UIImageMake("origin_image_checkbox_checked"), for: .selected)
        originImageCheckboxButton.setImage(UIImageMake("origin_image_checkbox_checked"), for: [.selected, .highlighted])
        originImageCheckboxButton.setTitle("原图", for: .normal)
        originImageCheckboxButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 5)
        originImageCheckboxButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        originImageCheckboxButton.qmui_outsideEdge = UIEdgeInsets(top: -6, left: -6, bottom: -6, right: -6)
        originImageCheckboxButton.sizeToFit()
        originImageCheckboxButton.addTarget(self, action: #selector(handleOriginImageCheckboxButtonClick(_:)), for: .touchUpInside)
        bottomToolBarView.addSubview(originImageCheckboxButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let imagePreviewView = imagePreviewView {
            updateOriginImageCheckboxButton(with: imagePreviewView.currentImageIndex)
        }
        if selectedImageAssetArray.count > 0 {
            let selectedCount = selectedImageAssetArray.count
            imageCountLabel.text = "\(selectedCount)"
            imageCountLabel.isHidden = false
        } else {
            imageCountLabel.isHidden = true
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let bottomToolBarPaddingHorizontal: CGFloat = 12
        let bottomToolBarContentHeight: CGFloat = 44
        let bottomToolBarHeight = bottomToolBarContentHeight + view.qmui_safeAreaInsets.bottom
        bottomToolBarView.frame = CGRect(x: 0, y: view.bounds.height - bottomToolBarHeight, width: view.bounds.width, height: bottomToolBarHeight)
        sendButton.frame = sendButton.frame.setXY(bottomToolBarView.frame.width - bottomToolBarPaddingHorizontal - sendButton.frame.width, bottomToolBarContentHeight.center(sendButton.frame.height))
        imageCountLabel.frame = CGRect(x: sendButton.frame.minX - 5 - ImageCountLabelSize.width, y: sendButton.frame.minY + sendButton.frame.height.center(ImageCountLabelSize.height), width: ImageCountLabelSize.width, height: ImageCountLabelSize.height)
        originImageCheckboxButton.frame = originImageCheckboxButton.frame.setXY(bottomToolBarPaddingHorizontal, bottomToolBarContentHeight.center(originImageCheckboxButton.frame.height))
    }
    
    override var toolBarTintColor: UIColor {
        didSet {
            bottomToolBarView.tintColor = toolBarTintColor
            imageCountLabel.backgroundColor = toolBarTintColor
            imageCountLabel.textColor = toolBarTintColor.qmui_colorIsDark ?  UIColorWhite : UIColorBlack
        }
    }
    
    override func singleTouch(in zoomImageView: QMUIZoomImageView, location: CGPoint) {
        super.singleTouch(in: zoomImageView, location: location)
        bottomToolBarView.isHidden = !bottomToolBarView.isHidden
    }
    
    override func zoomImageView(_ imageView: QMUIZoomImageView, didHideVideoToolbar didHide: Bool) {
        super.zoomImageView(imageView, didHideVideoToolbar: didHide)
        bottomToolBarView.isHidden = didHide
    }
    
    private func updateOriginImageCheckboxButton(with index: Int) {
        let asset = imagesAssetArray[index]
        if asset.assetType == .audio || asset.assetType == .video {
            originImageCheckboxButton.isHidden = true
        } else {
            originImageCheckboxButton.isHidden = false
            if originImageCheckboxButton.isSelected {
                asset.assetSize { (size) in
                    self.originImageCheckboxButton.setTitle("原图(\(QDUIHelper.humanReadableFileSize(UInt64(size)))", for: .normal)
                    self.originImageCheckboxButton.sizeToFit()
                    self.bottomToolBarView.setNeedsLayout()
                }
            }
        }
    }
    
    @objc private func handleSendButtonClick(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: {
            if self.selectedImageAssetArray.count == 0 , let imagePreviewView = self.imagePreviewView {
                // 如果没选中任何一张，则点击发送按钮直接发送当前这张大图
                let currentAsset = self.imagesAssetArray[imagePreviewView.currentImageIndex]
                self.selectedImageAssetArray.append(currentAsset)
            }
            self.multipleDelegate?.imagePickerPreviewViewController(self, sendImageWithImagesAssetArray: self.selectedImageAssetArray)
        })
    }
    
    @objc private func handleOriginImageCheckboxButtonClick(_ button: UIButton) {
        if button.isSelected {
            button.isSelected = false
            button.setTitle("原图", for: .normal)
            button.sizeToFit()
            bottomToolBarView.setNeedsLayout()
        } else {
            button.isSelected = true
            if let imagePreviewView = imagePreviewView {
                updateOriginImageCheckboxButton(with: imagePreviewView.currentImageIndex)
            }
            if !checkboxButton.isSelected {
                checkboxButton.sendActions(for: .touchUpInside)
            }
            
        }
        
        shouldUseOriginImage = button.isSelected
    }
 
    
}

extension QDMultipleImagePickerPreviewViewController {
    
    override func imagePreviewView(_ imagePreviewView: QMUIImagePreviewView, renderZoomImageView zoomImageView: QMUIZoomImageView, at index: Int) {
        super.imagePreviewView(imagePreviewView, renderZoomImageView: zoomImageView, at: index)
        // videToolbarMargins 是利用 UIAppearance 赋值的，也即意味着要在 addSubview 之后才会被赋值，而在 renderZoomImageView 里，zoomImageView 可能尚未被添加到 view 层级里，所以无法通过 zoomImageView.videoToolbarMargins 获取到原来的值，因此只能通过 [QMUIZoomImageView appearance] 的方式获取
//        zoomImageView.videoToolbarMargins =
//        zoomImageView.videoCenteredPlayButtonImage
    }
    
    override func imagePreviewView(_ imagePreviewView: QMUIImagePreviewView, willScrollHalfTo index: Int) {
        super.imagePreviewView(imagePreviewView, willScrollHalfTo: index)
        updateOriginImageCheckboxButton(with: index)
    }
}
