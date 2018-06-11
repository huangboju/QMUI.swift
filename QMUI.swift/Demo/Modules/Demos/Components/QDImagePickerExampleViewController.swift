//
//  QDImagePickerExampleViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/5/9.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

let kAlbumContentType = QMUIAlbumContentType.all

let MaxSelectedImageCount: UInt = 9
let NormalImagePickingTag = 1045
let ModifiedImagePickingTag = 1046
let MultipleImagePickingTag = 1047
let SingleImagePickingTag = 1048

class QDImagePickerExampleViewController: QDCommonGroupListViewController {

    private var selectedAvatarImage: UIImage?
    
    private var imagesAsset: QMUIAsset?
    
    override func initDataSource() {
        super.initDataSource()
        
        let od1 = QMUIOrderedDictionary(
            dictionaryLiteral:
            ("默认", "选图控件包含相册列表，选图，预览大图三个界面"),
            ("自定义", "修改选图界面列数，预览大图界面 TopBar 背景色")
        )
        let od2 = QMUIOrderedDictionary(
            dictionaryLiteral:
            ("选择多张图片", "模拟聊天发图，预览大图界面增加底部工具栏"),
            ("选择单张图片", "模拟设置头像，预览大图界面右上角增加按钮")
        )
        dataSource = QMUIOrderedDictionary(
            dictionaryLiteral:
            ("选图控件使用示例", od1),
            ("通过重载进行添加 subview 等较大型的改动", od2))
    }
    
    override func didSelectCell(_ title: String) {
        authorizationPresentAlbumViewController(with: title)
    }
    
    private func authorizationPresentAlbumViewController(with title: String) {
        if QMUIAssetsManager.authorizationStatus == .notDetermined {
            QMUIAssetsManager.requestAuthorization { (status) in
                DispatchQueue.main.async {
                    self.presentAlbumViewController(with: title)
                }
            }
        } else {
            presentAlbumViewController(with: title)
        }
    }
    
    private func presentAlbumViewController(with title: String) {
        // 创建一个 QMUIAlbumViewController 实例用于呈现相簿列表
        let albumViewController = QMUIAlbumViewController()
        albumViewController.albumViewControllerDelegate = self
        albumViewController.contentType = kAlbumContentType
        albumViewController.title = title
        if title == "选择单张图片" {
            albumViewController.view.tag = SingleImagePickingTag
        } else if title == "选择多张图片" {
            albumViewController.view.tag = MultipleImagePickingTag
        } else if title == "调整界面" {
            albumViewController.view.tag = ModifiedImagePickingTag
            albumViewController.albumTableViewCellHeight = 70
        } else {
            albumViewController.view.tag = NormalImagePickingTag
        }
        
        let navigationController = QDNavigationController(rootViewController: albumViewController)
        // 获取最近发送图片时使用过的相簿，如果有则直接进入该相簿
        albumViewController.pickLastAlbumGroupDirectlyIfCan()
        present(navigationController, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        let title = keyName(at: indexPath)
        if title == "选择单张图片" {
            let accessoryView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            accessoryView.layer.borderColor = UIColorSeparator.cgColor
            accessoryView.layer.borderWidth = PixelOne
            accessoryView.contentMode = .scaleAspectFill
            accessoryView.clipsToBounds = true
            accessoryView.image = selectedAvatarImage
            cell.accessoryView = accessoryView
        } else {
            cell.accessoryType = .disclosureIndicator
        }
        return cell
    }
    
    // MARK: 业务方法
    fileprivate func startLoading(text: String? = nil) {
        QMUITips.showLoading(text: text, in: view)
    }
    
    fileprivate func stopLoading() {
        QMUITips.hideAllToast(in: view, animated: true)
    }
    
    @objc fileprivate func showTipLabel(_ text: String) {
        DispatchQueue.main.async {
            self.stopLoading()
            QMUITips.show(text: text, in: self.view, hideAfterDelay: 1.0)
        }
    }
    
    fileprivate func hideTipLabel() {
        QMUITips.hideAllToast(in: view, animated: true)
    }
    
    fileprivate func sendImageWithImagesAssetArrayIfDownloadStatusSucceed(_ imagesAssetArray: [QMUIAsset]) {
        if QMUIImagePickerHelper.imageAssetsDownloaded(imagesAssetArray: imagesAssetArray) {
            // 所有资源从 iCloud 下载成功，模拟发送图片到服务器
            // 显示发送中
            showTipLabel("发送中")
            // 使用 delay 模拟网络请求时长
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                Thread.detachNewThreadSelector(#selector(self.showTipLabel(_:)), toTarget:self, with: "成功发送\(imagesAssetArray.count)个资源")
            }
        }
    }
    
    fileprivate func sendImage(with imagesAssetArray: [QMUIAsset]) {
        for asset in imagesAssetArray {
            QMUIImagePickerHelper.requestImageAssetIfNeeded(asset: asset) { [weak self]  (downloadStatus, error) in
                if downloadStatus == .downloading {
                    self?.startLoading(text: "从 iCloud 加载中")
                } else if downloadStatus == .succeed {
                    self?.sendImageWithImagesAssetArrayIfDownloadStatusSucceed(imagesAssetArray)
                } else {
                    self?.showTipLabel("iCloud 下载错误，请重新选图")
                }
            }
        }
    }
    
    @objc fileprivate func setAvatar(with avatarImage: UIImage) {
        DispatchQueue.main.async {
            self.stopLoading()
            self.selectedAvatarImage = avatarImage
            let indexPath = IndexPath(row: 1, section: 1)
            self.tableView.reloadRows(at: [indexPath], with: .fade)
        }
    }
}

extension QDImagePickerExampleViewController: QMUIAlbumViewControllerDelegate {
    func imagePickerViewController(for albumViewController: QMUIAlbumViewController) -> QMUIImagePickerViewController {
        let imagePickerViewController = QMUIImagePickerViewController()
        imagePickerViewController.imagePickerViewControllerDelegate = self
        imagePickerViewController.maximumSelectImageCount = MaxSelectedImageCount
        imagePickerViewController.view.tag = albumViewController.view.tag
        if albumViewController.view.tag == SingleImagePickingTag {
            imagePickerViewController.allowsMultipleSelection = false
        }
        if albumViewController.view.tag == ModifiedImagePickingTag {
            imagePickerViewController.minimumImageWidth = 65
        }
        return imagePickerViewController
    }
    
}

extension QDImagePickerExampleViewController: QMUIImagePickerViewControllerDelegate {
    
    func imagePickerViewController(_ imagePickerViewController: QMUIImagePickerViewController, didFinishPickingImageWith imagesAssetArray: [QMUIAsset]) {
        // 储存最近选择了图片的相册，方便下次直接进入该相册
        if let assetsGroup = imagePickerViewController.assetsGroup {
            QMUIImagePickerHelper.updateLastestAlbum(with: assetsGroup, albumContentType: kAlbumContentType, userIdentify: nil)
        }
        sendImage(with: imagesAssetArray)
    }
    
    func imagePickerPreviewViewController(for imagePickerViewController: QMUIImagePickerViewController) -> QMUIImagePickerPreviewViewController {
        if imagePickerViewController.view.tag == MultipleImagePickingTag {
            let imagePickerPreviewViewController = QDMultipleImagePickerPreviewViewController()
            imagePickerPreviewViewController.multipleDelegate = self
            imagePickerPreviewViewController.maximumSelectImageCount = MaxSelectedImageCount
            imagePickerPreviewViewController.assetsGroup = imagePickerViewController.assetsGroup
            imagePickerPreviewViewController.view.tag = imagePickerViewController.view.tag
            return imagePickerPreviewViewController
        } else if imagePickerViewController.view.tag == SingleImagePickingTag {
            let imagePickerPreviewViewController = QDSingleImagePickerPreviewViewController()
            imagePickerPreviewViewController.singleDelegate = self
            imagePickerPreviewViewController.assetsGroup = imagePickerViewController.assetsGroup
            imagePickerPreviewViewController.view.tag = imagePickerViewController.view.tag
            return imagePickerPreviewViewController
        } else if imagePickerViewController.view.tag == ModifiedImagePickingTag {
            let imagePickerPreviewViewController = QMUIImagePickerPreviewViewController()
            imagePickerPreviewViewController.delegate = self
            imagePickerPreviewViewController.view.tag = imagePickerViewController.view.tag
            imagePickerPreviewViewController.toolBarBackgroundColor = UIColor(r: 66, g: 66, b: 66)
            return imagePickerPreviewViewController
        } else {
            let imagePickerPreviewViewController = QMUIImagePickerPreviewViewController()
            imagePickerPreviewViewController.delegate = self
            imagePickerPreviewViewController.view.tag = imagePickerViewController.view.tag
            return imagePickerPreviewViewController
        }
    }
    
    
    
}

extension QDImagePickerExampleViewController: QMUIImagePickerPreviewViewControllerDelegate {
    
    func imagePickerPreviewViewController(_ imagePickerPreviewViewController: QMUIImagePickerPreviewViewController, didCheckImageAt index: Int) {
        updateImageCountLabel(for: imagePickerPreviewViewController)
    }
    
    func imagePickerPreviewViewController(_ imagePickerPreviewViewController: QMUIImagePickerPreviewViewController, didUncheckImageAtIndex: Int) {
        updateImageCountLabel(for: imagePickerPreviewViewController)
    }
    
    
    // 更新选中的图片数量
    private func updateImageCountLabel(for imagePickerPreviewViewController: QMUIImagePickerPreviewViewController) {
        if imagePickerPreviewViewController.view.tag == MultipleImagePickingTag {
            guard let customImagePickerPreviewViewController = imagePickerPreviewViewController as? QDMultipleImagePickerPreviewViewController else {
                return
            }
            let selectedCount = imagePickerPreviewViewController.selectedImageAssetArray.pointee.count
            if selectedCount > 0 {
                customImagePickerPreviewViewController.imageCountLabel.text = "\(selectedCount)"
                customImagePickerPreviewViewController.imageCountLabel.isHidden = false
                QMUIImagePickerHelper.springAnimationOfImageSelectedCountChange(with: customImagePickerPreviewViewController.imageCountLabel)
            } else {
                customImagePickerPreviewViewController.imageCountLabel.isHidden = true
            }
        }
    }
}

extension QDImagePickerExampleViewController: QDMultipleImagePickerPreviewViewControllerDelegate {
    
    func imagePickerPreviewViewController(_ imagePickerPreviewViewController: QDMultipleImagePickerPreviewViewController, sendImageWithImagesAssetArray imagesAssetArray: [QMUIAsset]) {
        // 储存最近选择了图片的相册，方便下次直接进入该相册
        QMUIImagePickerHelper.updateLastestAlbum(with: imagePickerPreviewViewController.assetsGroup!, albumContentType: kAlbumContentType, userIdentify: nil)
        sendImage(with: imagesAssetArray)
    }
}

extension QDImagePickerExampleViewController: QDSingleImagePickerPreviewViewControllerDelegate {
    func imagePickerPreviewViewController(_ imagePickerPreviewViewController: QDSingleImagePickerPreviewViewController, didSelectImageWithImagesAsset imagesAsset: QMUIAsset) {
        // 储存最近选择了图片的相册，方便下次直接进入该相册
        QMUIImagePickerHelper.updateLastestAlbum(with: imagePickerPreviewViewController.assetsGroup!, albumContentType: kAlbumContentType, userIdentify: nil)
        // 显示 loading
        startLoading()
        self.imagesAsset = imagesAsset
        imagesAsset.requestImageData { (imageData, info, isGif, isHEIC) in
            guard let imageData = imageData else {
                return
            }
            var targetImage = UIImage(data: imageData)
            if isHEIC {
                // iOS 11 中新增 HEIF/HEVC 格式的资源，直接发送新格式的照片到不支持新格式的设备，照片可能会无法识别，可以先转换为通用的 JPEG 格式再进行使用。
                // 详细请浏览：https://github.com/QMUI/QMUI_iOS/issues/224
                guard let tmpImage = targetImage, let data = UIImageJPEGRepresentation(tmpImage, 1) else {
                    return
                }
                targetImage = UIImage(data: data)
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                    Thread.detachNewThreadSelector(#selector(self.setAvatar(with:)), toTarget:self, with: targetImage)
                }
            }
        }
    }
}
