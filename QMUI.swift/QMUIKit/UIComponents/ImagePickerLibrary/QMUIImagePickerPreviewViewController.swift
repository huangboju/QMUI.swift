//
//  QMUIImagePickerPreviewViewController.swift
//  QMUI.swift
//
//  Created by 黄伯驹 on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

import Photos

private let TopToolBarViewHeight: CGFloat = 64

@objc protocol QMUIImagePickerPreviewViewControllerDelegate: NSObjectProtocol {
    /**
     *  取消选择图片后被调用
     */
    @objc optional func imagePickerPreviewViewControllerDidCancel(_ imagePickerPreviewViewController: QMUIImagePickerPreviewViewController)

    @objc optional func imagePickerPreviewViewController(_ imagePickerPreviewViewController: QMUIImagePickerPreviewViewController, willCheckImageAt index: Int)

    @objc optional func imagePickerPreviewViewController(_ imagePickerPreviewViewController: QMUIImagePickerPreviewViewController, didCheckImageAt index: Int)

    @objc optional func imagePickerPreviewViewController(_ imagePickerPreviewViewController: QMUIImagePickerPreviewViewController, willUncheckImageAt index: Int)
    @objc optional func imagePickerPreviewViewController(_ imagePickerPreviewViewController: QMUIImagePickerPreviewViewController, didUncheckImageAtIndex: Int)
}

class QMUIImagePickerPreviewViewController: QMUIImagePreviewViewController {
    
    var toolBarBackgroundColor = UIColorMakeWithRGBA(27, 27, 27, 0.9) {
        didSet {
            topToolBarView.backgroundColor = toolBarBackgroundColor
        }
    }

    var toolBarTintColor = UIColorWhite {
        didSet {
            topToolBarView.tintColor = toolBarTintColor
        }
    }

    weak var delegate: QMUIImagePickerPreviewViewControllerDelegate?

    private(set) var topToolBarView: UIView!
    private(set) var backButton: QMUIButton!
    private(set) var checkboxButton: QMUIButton!

    /**
     *  由于组件需要通过本地图片的 QMUIAsset 对象读取图片的详细信息，因此这里的需要传入的是包含一个或多个 QMUIAsset 对象的数组
     */
    var imagesAssetArray: [QMUIAsset] = []
    var selectedImageAssetArray: [QMUIAsset] = []

    var downloadStatus: QMUIAssetDownloadStatus = .failed {
        didSet {
            if !_singleCheckMode {
                checkboxButton.isHidden = false
            }
        }
    }

    var maximumSelectImageCount = UInt.max // 最多可以选择的图片数，默认为无穷大
    var minimumSelectImageCount: UInt = 0 // 最少需要选择的图片数，默认为 0
    var alertTitleWhenExceedMaxSelectImageCount: String? // 选择图片超出最大图片限制时 alertView 的标题
    var alertButtonTitleWhenExceedMaxSelectImageCount: String? // 选择图片超出最大图片限制时 alertView 的标题

    private var _singleCheckMode: Bool = false

    override func initSubviews() {
        super.initSubviews()
        imagePreviewView?.delegate = self

        topToolBarView = UIView()
        topToolBarView.backgroundColor = toolBarBackgroundColor
        topToolBarView.tintColor = toolBarTintColor
        view.addSubview(topToolBarView)

        backButton = QMUIButton()
        backButton.adjustsImageTintColorAutomatically = true
        backButton.setImage(NavBarBackIndicatorImage, for: .normal)
        backButton.tintColor = topToolBarView.tintColor
        backButton.sizeToFit()
        backButton.addTarget(self, action: #selector(handleCancelPreviewImage), for: .touchUpInside)
        backButton.qmui_outsideEdge = UIEdgeInsets(top: -30, left: -20, bottom: -50, right: -80)
        topToolBarView.addSubview(backButton)

        checkboxButton = QMUIButton()
        checkboxButton?.adjustsImageTintColorAutomatically = true
        checkboxButton?.setImage(QMUIHelper.image(name: "QMUI_previewImage_checkbox"), for: .normal)
        checkboxButton?.setImage(QMUIHelper.image(name: "QMUI_previewImage_checkbox_checked"), for: .selected)
        checkboxButton?.setImage(QMUIHelper.image(name: "QMUI_previewImage_checkbox_checked"), for: [.selected, .highlighted])
        checkboxButton?.setImage(QMUIHelper.image(name: "QMUI_previewImage_checkbox_checked"), for: [.selected, .highlighted])
        checkboxButton?.tintColor = topToolBarView.tintColor
        checkboxButton?.sizeToFit()
        checkboxButton?.addTarget(self, action: #selector(handleCheckButtonClick), for: .touchUpInside)
        checkboxButton?.qmui_outsideEdge = UIEdgeInsets(top: -6, left: -6, bottom: -6, right: -6)
        topToolBarView.addSubview(checkboxButton)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = false
        navigationController?.setNavigationBarHidden(true, animated: false)
        if !_singleCheckMode {
            let imageAsset = imagesAssetArray[imagePreviewView!.currentImageIndex]
            checkboxButton.isSelected = selectedImageAssetArray.contains(imageAsset)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isStatusBarHidden = false
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        topToolBarView.frame = CGSize(width: view.bounds.width, height: TopToolBarViewHeight).rect

        let topToolbarPaddingTop = IPhoneXSafeAreaInsets.top
        let topToolbarContentHeight = topToolBarView.bounds.height - topToolbarPaddingTop

        backButton.frame = backButton.frame.setXY(16, topToolbarPaddingTop + topToolbarContentHeight.center(backButton.frame.height))
        if !checkboxButton.isHidden {
            checkboxButton.frame = checkboxButton.frame.setXY(topToolBarView.frame.width - 10 - checkboxButton.frame.width, topToolbarPaddingTop + topToolbarContentHeight.center(checkboxButton.frame.height))
        }
    }

    /**
     *  更新数据并刷新 UI，手工调用
     *
     *  @param imageAssetArray         包含所有需要展示的图片的数组
     *  @param selectedImageAssetArray 包含所有需要展示的图片中已经被选中的图片的数组
     *  @param currentImageIndex       当前展示的图片在 imageAssetArray 的索引
     *  @param singleCheckMode         是否为单选模式，如果是单选模式，则不显示 checkbox
     */
    func updateImagePickerPreviewView(with imagesAssetArray: [QMUIAsset], selectedImageAssetArray: [QMUIAsset], currentImageIndex: Int, singleCheckMode: Bool) {
        self.imagesAssetArray = imagesAssetArray
        self.selectedImageAssetArray = selectedImageAssetArray
        imagePreviewView?.currentImageIndex = currentImageIndex
        _singleCheckMode = singleCheckMode
        if singleCheckMode {
            checkboxButton.isHidden = true
        }
    }

    // MARK: - 按钮点击回调
    @objc func handleCancelPreviewImage() {
        navigationController?.popViewController(animated: true)
        delegate?.imagePickerPreviewViewControllerDidCancel?(self)
    }

    @objc func handleCheckButtonClick(_ sender: QMUIButton) {
        QMUIImagePickerHelper.removeSpringAnimationOfImageChecked(with: sender)

        let index = imagePreviewView?.currentImageIndex ?? 0
        if sender.isSelected {

            delegate?.imagePickerPreviewViewController?(self, willUncheckImageAt: index)

            sender.isSelected = false
            let imageAsset = imagesAssetArray[index]
            selectedImageAssetArray.remove(object: imageAsset)

            delegate?.imagePickerPreviewViewController?(self, didUncheckImageAtIndex: index)
        } else {
            if selectedImageAssetArray.count >= maximumSelectImageCount {
                if alertTitleWhenExceedMaxSelectImageCount == nil {
                    alertTitleWhenExceedMaxSelectImageCount = "你最多只能选择\(maximumSelectImageCount)张图片"
                }
                if alertButtonTitleWhenExceedMaxSelectImageCount == nil {
                    alertButtonTitleWhenExceedMaxSelectImageCount = "我知道了"
                }

                let alertController = QMUIAlertController(title: alertTitleWhenExceedMaxSelectImageCount, preferredStyle: .alert)
                alertController.add(action: QMUIAlertAction(title: alertButtonTitleWhenExceedMaxSelectImageCount, style: .cancel))
                alertController.show()
                return
            }

            delegate?.imagePickerPreviewViewController?(self, willCheckImageAt: index)

            sender.isSelected = true
            QMUIImagePickerHelper.springAnimationOfImageChecked(with: sender)
            let imageAsset = imagesAssetArray[index]
            selectedImageAssetArray.append(imageAsset)

            delegate?.imagePickerPreviewViewController?(self, didCheckImageAt: index)
        }
    }

    @objc func handleDownloadRetryButtonClick() {
        requestImage(for: nil, with: imagePreviewView!.currentImageIndex)
    }

    // MARK: - Request Image
    func requestImage(for zoomImageView: QMUIZoomImageView?, with index: Int) {
        let imageView = zoomImageView ?? imagePreviewView?.zoomImageView(at: index)

        // 如果是走 PhotoKit 的逻辑，那么这个 block 会被多次调用，并且第一次调用时返回的图片是一张小图，
        // 拉取图片的过程中可能会多次返回结果，且图片尺寸越来越大，因此这里调整 contentMode 以防止图片大小跳动
        imageView?.contentMode = .scaleAspectFit
        let imageAsset = imagesAssetArray[index]

        // 获取资源图片的预览图，这是一张适合当前设备屏幕大小的图片，最终展示时把图片交给组件控制最终展示出来的大小。
        // 系统相册本质上也是这么处理的，因此无论是系统相册，还是这个系列组件，由始至终都没有显示照片原图，
        // 这也是系统相册能加载这么快的原因。
        // 另外这里采用异步请求获取图片，避免获取图片时 UI 卡顿
        let phProgressHandler: PHAssetImageProgressHandler = { progress, error, _, _ in
            imageAsset.downloadProgress = progress
            DispatchQueue.main.async {
                if index == self.imagePreviewView?.currentImageIndex {
                    // 只有当前显示的预览图才会展示下载进度
                    print("Download iCloud image in preview, current progress is: \(progress)")

                    if self.downloadStatus != .downloading {
                        self.downloadStatus = .downloading
                        // 重置 progressView 的显示的进度为 0
                        imageView?.cloudProgressView?.setProgress(0, animated: false)
                    }
                    // 拉取资源的初期，会有一段时间没有进度，猜测是发出网络请求以及与 iCloud 建立连接的耗时，这时预先给个 0.02 的进度值，看上去好看些
                    let targetProgress = fmax(0.02, CGFloat(progress))
                    if targetProgress < imageView?.cloudProgressView?.progress ?? 0 {
                        imageView?.cloudProgressView?.setProgress(targetProgress, animated: false)
                    } else {
                        imageView?.cloudProgressView?.progress = fmax(0.02, CGFloat(progress))
                    }
                    if error != nil {
                        print("Download iCloud image Failed, current progress is: \(progress)")
                        self.downloadStatus = .failed
                        imageView?.cloudDownloadStatus = .failed
                    }
                }
            }
        }

        if #available(iOS 9.1, *) {
            if imageAsset.assetType == .livePhoto {
                imageView?.tag = -1
                imageAsset.requestID = imageAsset.requestLivePhoto(with: { livePhoto, info in
                    // 这里可能因为 imageView 复用，导致前面的请求得到的结果显示到别的 imageView 上，
                    // 因此判断如果是新请求（无复用问题）或者是当前的请求才把获得的图片结果展示出来
                    let isNewRequest = (imageView?.tag == -1 && imageAsset.requestID == 0)
                    let isCurrentRequest = imageView?.tag == imageAsset.requestID
                    let loadICloudImageFault = livePhoto == nil || info?[PHImageErrorKey] != nil
                    if !loadICloudImageFault && (isNewRequest || isCurrentRequest) {
                        // 如果是走 PhotoKit 的逻辑，那么这个 block 会被多次调用，并且第一次调用时返回的图片是一张小图，
                        // 这时需要把图片放大到跟屏幕一样大，避免后面加载大图后图片的显示会有跳动
                        DispatchQueue.main.async {
                            imageView?.livePhoto = livePhoto
                        }
                    }

                    let downloadSucceed = (livePhoto != nil && info == nil) || (!(info?[PHLivePhotoInfoCancelledKey] as? Bool ?? false) && info?[PHLivePhotoInfoErrorKey] == nil && !(info?[PHLivePhotoInfoIsDegradedKey] as? Bool ?? false))

                    if downloadSucceed {
                        // 资源资源已经在本地或下载成功
                        imageAsset.updateDownloadStatus(withDownloadResult: true)
                        self.downloadStatus = .succeed

                    } else if info?[PHLivePhotoInfoErrorKey] != nil {
                        // 下载错误
                        imageAsset.updateDownloadStatus(withDownloadResult: false)
                        self.downloadStatus = .failed
                    }
                }, with: phProgressHandler)
                imageView?.tag = imageAsset.requestID
            }
            return
        }

        if imageAsset.assetType == .video {
            imageView?.tag = -1
            imageAsset.requestID = imageAsset.requestPlayerItem(with: { playerItem, info in
                // 这里可能因为 imageView 复用，导致前面的请求得到的结果显示到别的 imageView 上，
                // 因此判断如果是新请求（无复用问题）或者是当前的请求才把获得的图片结果展示出来
                let isNewRequest = (imageView?.tag == -1 && imageAsset.requestID == 0)
                let isCurrentRequest = imageView?.tag == imageAsset.requestID
                let loadICloudImageFault = (playerItem != nil) || info?[PHImageErrorKey] != nil
                if !loadICloudImageFault && (isNewRequest || isCurrentRequest) {
                    DispatchQueue.main.async {
                        imageView?.videoPlayerItem = playerItem
                    }
                }
            }, with: phProgressHandler)
            imageView?.tag = imageAsset.requestID
        } else {
            imageView?.tag = -1
            imageAsset.requestID = imageAsset.requestPreviewImage(with: { result, info in
                // 这里可能因为 imageView 复用，导致前面的请求得到的结果显示到别的 imageView 上，
                // 因此判断如果是新请求（无复用问题）或者是当前的请求才把获得的图片结果展示出来
                let isNewRequest = (imageView?.tag == -1 && imageAsset.requestID == 0)
                let isCurrentRequest = imageView?.tag == imageAsset.requestID
                let loadICloudImageFault = result == nil || info?[PHImageErrorKey] != nil
                if !loadICloudImageFault && (isNewRequest || isCurrentRequest) {
                    DispatchQueue.main.async {
                        imageView?.image = result
                    }
                }

                let downloadSucceed = ((result != nil) && info == nil) || (!(info?[PHImageCancelledKey] as? Bool ?? false) && info?[PHImageErrorKey] == nil && !(info?[PHImageResultIsDegradedKey] as? Bool ?? false))

                if downloadSucceed {
                    // 资源资源已经在本地或下载成功
                    imageAsset.updateDownloadStatus(withDownloadResult: true)
                    self.downloadStatus = .succeed

                } else if info?[PHImageErrorKey] != nil {
                    // 下载错误
                    imageAsset.updateDownloadStatus(withDownloadResult: false)
                    self.downloadStatus = .failed
                }
            }, with: phProgressHandler)

            imageView?.tag = imageAsset.requestID
        }
    }

    // MARK: - QMUINavigationControllerDelegate
//    override var preferredNavigationBarHiddenState: QMUINavigationBarHiddenState {
//        return NavigationBarHiddenInitially
//    }
}

extension QMUIImagePickerPreviewViewController: QMUIImagePreviewViewDelegate {
    func numberOfImages(in _: QMUIImagePreviewView) -> Int {
        return imagesAssetArray.count
    }

    func imagePreviewView(_: QMUIImagePreviewView, renderZoomImageView zoomImageView: QMUIZoomImageView, at index: Int) {
        requestImage(for: zoomImageView, with: index)
    }

    func imagePreviewView(_: QMUIImagePreviewView, assetTypeAt index: Int) -> QMUIImagePreviewMediaType {
        let imageAsset = imagesAssetArray[index]
        if #available(iOS 9.1, *) {
            if imageAsset.assetType == .livePhoto {
                return .livePhoto
            }
        }
        if imageAsset.assetType == .image {
            return .image
        } else if imageAsset.assetType == .video {
            return .video
        } else {
            return .others
        }
    }

    func imagePreviewView(_: QMUIImagePreviewView, willScrollHalfTo index: Int) {
        if !_singleCheckMode {
            let imageAsset = imagesAssetArray[index]
            checkboxButton.isSelected = selectedImageAssetArray.contains(imageAsset)
        }
    }
}

extension QMUIImagePickerPreviewViewController: QMUIZoomImageViewDelegate {
    func singleTouch(in _: QMUIZoomImageView, location _: CGPoint) {
        topToolBarView.isHidden = !topToolBarView.isHidden
    }
    
    func zoomImageView(_: QMUIZoomImageView, didHideVideoToolbar didHide: Bool) {
        topToolBarView.isHidden = didHide
    }
}
