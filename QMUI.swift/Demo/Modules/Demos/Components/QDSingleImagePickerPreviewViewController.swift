//
//  QDSingleImagePickerPreviewViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/5/14.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

protocol QDSingleImagePickerPreviewViewControllerDelegate: QMUIImagePickerPreviewViewControllerDelegate {
    
    func imagePickerPreviewViewController(_ imagePickerPreviewViewController: QDSingleImagePickerPreviewViewController, didSelectImageWithImagesAsset imagesAsset: QMUIAsset)
    
}

class QDSingleImagePickerPreviewViewController: QMUIImagePickerPreviewViewController {

    weak var singleDelegate: QDSingleImagePickerPreviewViewControllerDelegate? {
        get {
            return delegate as? QDSingleImagePickerPreviewViewControllerDelegate
        }
        set {
            delegate = newValue
        }
    }
    
    var assetsGroup: QMUIAssetsGroup?
    
    private var confirmButton: QMUIButton!
    
    override func initSubviews() {
        super.initSubviews()
        
        confirmButton = QMUIButton()
        confirmButton.qmui_outsideEdge = UIEdgeInsets(top: -6, left: -6, bottom: -6, right: -6)
        confirmButton.setTitle("使用", for: .normal)
        confirmButton.setTitleColor(toolBarTintColor, for: .normal)
        confirmButton.sizeToFit()
        confirmButton.addTarget(self, action: #selector(handleUserAvatarButtonClick(_:)), for: .touchUpInside)
        topToolBarView.addSubview(confirmButton)
    }

    override var downloadStatus: QMUIAssetDownloadStatus {
        didSet {
            switch downloadStatus {
            case .succeed:
                confirmButton.isHidden = false
            case .downloading:
                confirmButton.isHidden = true
            case .canceled:
                confirmButton.isHidden = false
            case .failed:
                confirmButton.isHidden = true
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        confirmButton.frame = confirmButton.frame.setXY(topToolBarView.frame.width - confirmButton.frame.width - 10, backButton.frame.minY + backButton.frame.height.center(confirmButton.frame.height))
    }
    
    @objc private func handleUserAvatarButtonClick(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: {
            if let imagePreviewView = self.imagePreviewView {
                let imageAsset = self.imagesAssetArray[imagePreviewView.currentImageIndex]
                self.singleDelegate?.imagePickerPreviewViewController(self, didSelectImageWithImagesAsset: imageAsset)
            }
        })
    }
}
