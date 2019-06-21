//
//  QMUIImagePickerViewController.swift
//  QMUI.swift
//
//  Created by 黄伯驹 on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

import Photos

// 底部工具栏
private let OperationToolBarViewPaddingHorizontal: CGFloat = 12
private let ImageCountLabelSize = CGSize(width: 18, height: 18)

// CollectionView
private let CollectionViewInsetHorizontal = PreferredVarForDevices((PixelOne * 2), 1, 2, 2)
private let CollectionViewInset = UIEdgeInsets(top: CollectionViewInsetHorizontal, left: CollectionViewInsetHorizontal, bottom: CollectionViewInsetHorizontal, right: CollectionViewInsetHorizontal)
private let CollectionViewCellMargin = CollectionViewInsetHorizontal

@objc protocol QMUIImagePickerViewControllerDelegate: NSObjectProtocol {
    /**
     *  创建一个 ImagePickerPreviewViewController 用于预览图片
     */
    @objc optional func imagePickerPreviewViewController(for imagePickerViewController: QMUIImagePickerViewController) -> QMUIImagePickerPreviewViewController

    /**
     *  控制照片的排序，若不实现，默认为 QMUIAlbumSortTypePositive
     *  @note 注意返回值会决定第一次进来相片列表时列表默认的滚动位置，如果为 QMUIAlbumSortTypePositive，则列表默认滚动到底部，如果为 QMUIAlbumSortTypeReverse，则列表默认滚动到顶部。
     */
    @objc optional func albumSortType(for imagePickerViewController: QMUIImagePickerViewController) -> QMUIAlbumSortType

    /**
     *  多选模式下选择图片完毕后被调用（点击 sendButton 后被调用），单选模式下没有底部发送按钮，所以也不会走到这个delegate
     *
     *  @param imagePickerViewController 对应的 QMUIImagePickerViewController
     *  @param imagesAssetArray          包含被选择的图片的 QMUIAsset 对象的数组。
     */
    @objc optional func imagePickerViewController(_ imagePickerViewController: QMUIImagePickerViewController, didFinishPickingImageWith imagesAssetArray: [QMUIAsset])

    /**
     *  cell 被点击时调用（先调用这个接口，然后才去走预览大图的逻辑），注意这并非指选中 checkbox 事件
     *
     *  @param imagePickerViewController        对应的 QMUIImagePickerViewController
     *  @param imageAsset                       被选中的图片的 QMUIAsset 对象
     *  @param imagePickerPreviewViewController 选中图片后进行图片预览的 viewController
     */
    @objc optional func imagePickerViewController(_ imagePickerViewController: QMUIImagePickerViewController, didSelectImageWith imagesAsset: QMUIAsset, afterImagePickerPreviewViewControllerUpdate imagePickerPreviewViewController: QMUIImagePickerPreviewViewController)

    /// 即将选中 checkbox 时调用
    @objc optional func imagePickerViewController(_ imagePickerViewController: QMUIImagePickerViewController, willCheckImageAt index: Int)

    /// 选中了 checkbox 之后调用
    @objc optional func imagePickerViewController(_ imagePickerViewController: QMUIImagePickerViewController, didCheckImageAt index: Int)

    /// 即将取消选中 checkbox 时调用
    @objc optional func imagePickerViewController(_ imagePickerViewController: QMUIImagePickerViewController, willUncheckImageAt index: Int)

    /// 取消了 checkbox 选中之后调用
    @objc optional func imagePickerViewController(_ imagePickerViewController: QMUIImagePickerViewController, didUncheckImageAt index: Int)

    /**
     *  取消选择图片后被调用
     */
    @objc optional func imagePickerViewControllerDidCancel(_ imagePickerViewController: QMUIImagePickerViewController)

    /**
     *  即将需要显示 Loading 时调用
     *
     *  @see shouldShowDefaultLoadingView
     */
    @objc optional func imagePickerViewControllerWillStartLoad(_ imagePickerViewController: QMUIImagePickerViewController)

    /**
     *  即将需要隐藏 Loading 时调用
     *
     *  @see shouldShowDefaultLoadingView
     */
    @objc optional func imagePickerViewControllerWillFinishLoad(_ imagePickerViewController: QMUIImagePickerViewController)
}

class QMUIImagePickerViewController: QMUICommonViewController {
    /**
     *  图片的最小尺寸，布局时如果有剩余空间，会将空间分配给图片大小，所以最终显示出来的大小不一定等于minimumImageWidth。默认是75。
     */
    var minimumImageWidth: CGFloat = 75 {
        didSet {
            referenceImageSize()
            collectionView.collectionViewLayout.invalidateLayout()
        }
    }

    weak var imagePickerViewControllerDelegate: QMUIImagePickerViewControllerDelegate?

    private(set) var collectionViewLayout: UICollectionViewFlowLayout!
    private(set) var collectionView: UICollectionView!
    private(set) var operationToolBarView: UIView!
    private(set) var previewButton: QMUIButton!
    private(set) var sendButton: QMUIButton!
    private(set) var imageCountLabel: UILabel!

    private(set) var imagesAssetArray: [QMUIAsset] = []
    private(set) var assetsGroup: QMUIAssetsGroup?
    var selectedImageAssetArray: [QMUIAsset] = [] // 当前被选择的图片对应的 QMUIAsset 对象数组

    var allowsMultipleSelection = true // 是否允许图片多选，默认为 YES。如果为 NO，则不显示 checkbox 和底部工具栏。
    var maximumSelectImageCount = UInt.max // 最多可以选择的图片数，默认为无符号整形数的最大值，相当于没有限制
    var minimumSelectImageCount: UInt = 0 // 最少需要选择的图片数，默认为 0
    var alertTitleWhenExceedMaxSelectImageCount: String = "" // 选择图片超出最大图片限制时 alertView 的标题
    var alertButtonTitleWhenExceedMaxSelectImageCount: String = "" // 选择图片超出最大图片限制时 alertView 底部按钮的标题

    private var imagePickerPreviewViewController: QMUIImagePickerPreviewViewController?

    private var isImagesAssetLoaded: Bool = false // 这个属性的作用描述：https://github.com/QMUI/QMUI_iOS/issues/219
    
    private var hasScrollToInitialPosition = false
    private var canScrollToInitialPosition = false

    private let kVideoCellIdentifier = "video"
    private let kImageOrUnknownCellIdentifier = "imageorunknown"

    /**
     *  加载相册列表时会出现 loading，若需要自定义 loading 的形式，可将该属性置为 NO，默认为 YES。
     *  @see imagePickerViewControllerWillStartLoad: & imagePickerViewControllerWillFinishLoad:
     */
    var shouldShowDefaultLoadingView = true

    override func didInitialized() {
        super.didInitialized()

        // 为了让使用者可以在 init 完就可以直接改 UI 相关的 property，这里提前触发 loadView
        if #available(iOS 9.0, *) {
            loadViewIfNeeded()
        } else {
            view.alpha = 1
        }
    }

    deinit {
        collectionView?.dataSource = nil
        collectionView?.delegate = nil
    }

    override func initSubviews() {
        super.initSubviews()

        collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.sectionInset = CollectionViewInset
        collectionViewLayout.minimumLineSpacing = CollectionViewCellMargin
        collectionViewLayout.minimumInteritemSpacing = CollectionViewCellMargin

        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: collectionViewLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.delaysContentTouches = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = false
        collectionView.backgroundColor = UIColorClear
        collectionView.register(QMUIImagePickerCollectionViewCell.self, forCellWithReuseIdentifier: kVideoCellIdentifier)
        collectionView.register(QMUIImagePickerCollectionViewCell.self, forCellWithReuseIdentifier: kImageOrUnknownCellIdentifier)
        view.addSubview(collectionView)

        // 只有允许多选时，才显示底部工具
        if allowsMultipleSelection {
            
            operationToolBarView = UIView()
            operationToolBarView.backgroundColor = UIColorWhite
            operationToolBarView.qmui_borderPosition = .top
            view.addSubview(operationToolBarView)

            sendButton = QMUIButton()
            sendButton.isEnabled = false
            sendButton.titleLabel?.font = UIFontMake(16)
            sendButton.contentHorizontalAlignment = .right
            sendButton.setTitleColor(UIColor(r: 124, g: 124, b: 124), for: .normal)
            sendButton.setTitleColor(UIColorGray, for: .disabled)
            sendButton.setTitle("发送", for: .normal)
            sendButton.qmui_outsideEdge = UIEdgeInsets(top: -12, left: -20, bottom: -12, right: -20)
            sendButton.sizeToFit()
            sendButton.addTarget(self, action: #selector(handleSendButtonClick), for: .touchUpInside)
            operationToolBarView.addSubview(sendButton)

            previewButton = QMUIButton()
            previewButton.isEnabled = false
            previewButton.titleLabel?.font = sendButton.titleLabel?.font
            previewButton.setTitleColor(sendButton.titleColor(for: .normal), for: .normal)
            previewButton.setTitleColor(sendButton.titleColor(for: .disabled), for: .disabled)
            previewButton.setTitle("预览", for: .normal)
            previewButton.qmui_outsideEdge = UIEdgeInsets(top: -12, left: -20, bottom: -12, right: -20)
            previewButton.sizeToFit()
            previewButton.addTarget(self, action: #selector(handlePreviewButtonClick), for: .touchUpInside)
            operationToolBarView.addSubview(previewButton)

            imageCountLabel = UILabel()
            imageCountLabel.isUserInteractionEnabled = false // 不要影响 sendButton 的事件
            imageCountLabel.backgroundColor = ButtonTintColor
            imageCountLabel.textColor = UIColorWhite
            imageCountLabel.font = UIFontMake(12)
            imageCountLabel.textAlignment = .center
            imageCountLabel.lineBreakMode = .byCharWrapping
            imageCountLabel.layer.masksToBounds = true
            imageCountLabel.layer.cornerRadius = ImageCountLabelSize.width / 2
            imageCountLabel.isHidden = true
            operationToolBarView.addSubview(imageCountLabel)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColorWhite
    }

    override func setNavigationItems(_ isInEditMode: Bool, animated: Bool) {
        super.setNavigationItems(isInEditMode, animated: animated)
        navigationItem.rightBarButtonItem = UIBarButtonItem.item(title: "取消", target: self, action: #selector(handleCancelPickerImage(_:)))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 由于被选中的图片 selectedImageAssetArray 是 property，所以可以由外部改变，
        // 因此 viewWillAppear 时检查一下图片被选中的情况，并刷新 collectionView
        if allowsMultipleSelection {
            // 只有允许多选，即底部工具栏显示时，需要重新设置底部工具栏的元素
            let selectedImageCount = selectedImageAssetArray.count
            if selectedImageCount > 0 {
                // 如果有图片被选择，则预览按钮和发送按钮可点击，并刷新当前被选中的图片数量
                previewButton.isEnabled = true
                sendButton.isEnabled = true
                imageCountLabel.text = "\(selectedImageCount)"
                imageCountLabel.isHidden = false
            } else {
                // 如果没有任何图片被选择，则预览和发送按钮不可点击，并且隐藏显示图片数量的 Label
                previewButton.isEnabled = false
                sendButton.isEnabled = false
                imageCountLabel.isHidden = true
            }
        }
        collectionView.reloadData()
    }

    override func showEmptyView() {
        super.showEmptyView()
        emptyView?.backgroundColor = view.backgroundColor // 为了盖住背后的 collectionView，这里加个背景色（不盖住的话会看到 collectionView 先滚到列表顶部然后跳到列表底部）
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if collectionView.frame.size != view.bounds.size {
            collectionView.frame = view.bounds
        }

        var operationToolBarViewHeight: CGFloat = 0
        if allowsMultipleSelection {
            operationToolBarViewHeight = ToolBarHeight
            operationToolBarView.frame = CGRect(x: 0, y: view.bounds.height - operationToolBarViewHeight, width: view.bounds.width, height: operationToolBarViewHeight)
            previewButton.frame = previewButton.frame.setXY(OperationToolBarViewPaddingHorizontal, (operationToolBarView.frame.height - IPhoneXSafeAreaInsets.bottom).center(previewButton.frame.height))
            sendButton.frame = CGRect(x: operationToolBarView.frame.width - OperationToolBarViewPaddingHorizontal - sendButton.frame.width, y: (operationToolBarView.frame.height - IPhoneXSafeAreaInsets.bottom).center(sendButton.frame.height), width: sendButton.frame.width, height: sendButton.frame.height)
            imageCountLabel.frame = CGRect(x: sendButton.frame.minX - ImageCountLabelSize.width - 5, y: sendButton.frame.minY + sendButton.frame.height.center(ImageCountLabelSize.height), width: ImageCountLabelSize.width, height: ImageCountLabelSize.height)
            operationToolBarViewHeight = operationToolBarView.frame.height
        }

        let contentInsetBottom = operationToolBarViewHeight - collectionView.qmui_safeAreaInsets.bottom // 由于 behavior 的特性，底部会自动加上 safeAreaInsets.bottom，所以这里去掉它，因为 toolbarViewHeight 里已经包含了
        
        if collectionView.contentInset.bottom != contentInsetBottom {
            collectionView.contentInset.bottom = contentInsetBottom
            collectionView.scrollIndicatorInsets = collectionView.contentInset
            // 放在这里是因为有时候会先走完 refreshWithAssetsGroup 里的 completion 再走到这里，此时前者不会导致 scollToInitialPosition 的滚动，所以在这里再调用一次保证一定会滚
            scrollToInitialPositionIfNeeded()
        }
    }

    /**
     *  也可以直接传入 QMUIAssetsGroup，然后读取其中的 QMUIAsset 并储存到 imagesAssetArray 中，传入后会赋值到 QMUIAssetsGroup，并自动刷新 UI 展示
     */
    func refresh(with assetsGroup: QMUIAssetsGroup) {
        self.assetsGroup = assetsGroup
        
        imagesAssetArray.removeAll(keepingCapacity: true)
        // 这里不用 remove 选中的图片，因为支持跨相簿选图
//      selectedImageAssetArray.removeAll(keepingCapacity: true)
        
        // 通过 QMUIAssetsGroup 获取该相册所有的图片 QMUIAsset，并且储存到数组中
        var albumSortType: QMUIAlbumSortType = .positive
        // 从 delegate 中获取相册内容的排序方式，如果没有实现这个 delegate，则使用 QMUIAlbumSortType 的默认值，即最新的内容排在最后面
        albumSortType = imagePickerViewControllerDelegate?.albumSortType?(for: self) ?? .positive

        // 遍历相册内的资源较为耗时，交给子线程去处理，因此这里需要显示 Loading
        imagePickerViewControllerDelegate?.imagePickerViewControllerWillStartLoad?(self)
        if shouldShowDefaultLoadingView {
            showEmptyViewWithLoading()
        }
        
        DispatchQueue.global().async {
            assetsGroup.enumerateAssets(withOptions: albumSortType, usingBlock: { resultAsset in
                DispatchQueue.main.async {
                    // 这里需要对 UI 进行操作，因此放回主线程处理
                    if let resultAsset = resultAsset {
                        self.isImagesAssetLoaded = false
                        self.imagesAssetArray.append(resultAsset)
                    } else { // result 为 nil，即遍历相片或视频完毕
                        self.isImagesAssetLoaded = true
                        self.collectionView.reloadData()
                        self.collectionView.performBatchUpdates(nil, completion: { _ in
                            self.scrollToInitialPositionIfNeeded()
                            if self.shouldShowDefaultLoadingView {
                                self.hideEmptyView()
                            }
                            self.imagePickerViewControllerDelegate?.imagePickerViewControllerWillFinishLoad?(self)
                        })
                    }
                }
            })
        }
    }

    private func initPreviewViewControllerIfNeeded() {
        if imagePickerPreviewViewController == nil {
            imagePickerPreviewViewController = imagePickerViewControllerDelegate?.imagePickerPreviewViewController?(for: self)
            imagePickerPreviewViewController?.maximumSelectImageCount = maximumSelectImageCount
            imagePickerPreviewViewController?.minimumSelectImageCount = minimumSelectImageCount
        }
    }

    @discardableResult
    func referenceImageSize() -> CGSize {
        let collectionViewWidth = collectionView.bounds.width
        let collectionViewContentSpacing = collectionViewWidth - collectionView.contentInset.horizontalValue
        var columnCount = floor(collectionViewContentSpacing / minimumImageWidth)
        var referenceImageWidth = minimumImageWidth

        let isSpacingEnoughWhenDisplayInMinImageSize = collectionViewLayout.sectionInset.horizontalValue + (minimumImageWidth + collectionViewLayout.minimumInteritemSpacing) * columnCount - collectionViewLayout.minimumInteritemSpacing <= collectionViewContentSpacing
        if !isSpacingEnoughWhenDisplayInMinImageSize {
            // 算上图片之间的间隙后发现其实还是放不下啦，所以得把列数减少，然后放大图片以撑满剩余空间
            columnCount -= 1
        }
        referenceImageWidth = (collectionViewContentSpacing - collectionViewLayout.sectionInset.horizontalValue - collectionViewLayout.minimumInteritemSpacing * (columnCount - 1)) / columnCount
        return CGSize(width: referenceImageWidth, height: referenceImageWidth)
    }

    private func scrollToInitialPositionIfNeeded() {
        if collectionView.window != nil && isImagesAssetLoaded && !hasScrollToInitialPosition {
            if imagePickerViewControllerDelegate?.albumSortType?(for: self) == .reverse {
                collectionView.qmui_scrollToTop()
            } else {
                collectionView.qmui_scrollToBottom()
            }
            hasScrollToInitialPosition = true
        }
    }

    func willPopInNavigationController(with _: Bool) {
        hasScrollToInitialPosition = false
    }

    // MARK: - 按钮点击回调
    @objc func handleSendButtonClick(_: QMUIButton) {
        imagePickerViewControllerDelegate?.imagePickerViewController?(self, didFinishPickingImageWith: selectedImageAssetArray)
        selectedImageAssetArray.removeAll(keepingCapacity: true)
        navigationController?.dismiss(animated: true, completion: nil)
    }

    @objc func handlePreviewButtonClick(_: QMUIButton) {
        initPreviewViewControllerIfNeeded()
        // 手工更新图片预览界面
        imagePickerPreviewViewController?.updateImagePickerPreviewView(with: selectedImageAssetArray, selectedImageAssetArray: &selectedImageAssetArray, currentImageIndex: 0, singleCheckMode: false)
        navigationController?.pushViewController(imagePickerPreviewViewController!, animated: true)
    }

    @objc func handleCancelPickerImage(_: QMUIButton) {
        navigationController?.dismiss(animated: true, completion: {
            self.imagePickerViewControllerDelegate?.imagePickerViewControllerDidCancel?(self)
            self.selectedImageAssetArray.removeAll(keepingCapacity: true)
        })
    }

    @objc func handleCheckBoxButtonClick(_ sender: UIButton) {
        let checkBoxButton = sender
        guard let indexPath = collectionView.qmui_indexPathForItem(at: checkBoxButton) else {
            return
        }

        guard let cell = collectionView.cellForItem(at: indexPath) as? QMUIImagePickerCollectionViewCell else {
            return
        }
        let imageAsset = imagesAssetArray[indexPath.item]
        if cell.isChecked {
            // 移除选中状态
            imagePickerViewControllerDelegate?.imagePickerViewController?(self, willUncheckImageAt: indexPath.item)

            cell.isChecked = false
            selectedImageAssetArray.remove(object: imageAsset)

            imagePickerViewControllerDelegate?.imagePickerViewController?(self, didUncheckImageAt: indexPath.item)

            // 根据选择图片数控制预览和发送按钮的 enable，以及修改已选中的图片数
            updateImageCountAndCheckLimited()
        } else {
            // 选中该资源
            if selectedImageAssetArray.count >= maximumSelectImageCount {
                if alertTitleWhenExceedMaxSelectImageCount.isEmpty {
                    alertTitleWhenExceedMaxSelectImageCount = "你最多只能选择\(maximumSelectImageCount)张图片"
                }
                if alertButtonTitleWhenExceedMaxSelectImageCount.isEmpty {
                    alertButtonTitleWhenExceedMaxSelectImageCount = "我知道了"
                }
                
                let alertController = QMUIAlertController(title: alertButtonTitleWhenExceedMaxSelectImageCount, message: nil, preferredStyle: .alert)
                alertController.add(action: QMUIAlertAction(title: alertButtonTitleWhenExceedMaxSelectImageCount, style: .cancel, handler: nil))
                alertController.show(true)
            }
            
            imagePickerViewControllerDelegate?.imagePickerViewController?(self, willCheckImageAt: indexPath.item)
            
            cell.isChecked = true
            selectedImageAssetArray.append(imageAsset)
            
            imagePickerViewControllerDelegate?.imagePickerViewController?(self, didCheckImageAt: indexPath.item)
            
            // 根据选择图片数控制预览和发送按钮的 enable，以及修改已选中的图片数
            updateImageCountAndCheckLimited()
            
            // 发出请求获取大图，如果图片在 iCloud，则会发出网络请求下载图片。这里同时保存请求 id，供取消请求使用
            requestImage(with: indexPath)
        }
    }

    @objc func handleProgressViewClick(_ sender: UIControl) {
        let progressView = sender
        guard let indexPath = collectionView.qmui_indexPathForItem(at: progressView) else {
            return
        }
        let imageAsset = imagesAssetArray[indexPath.item]
        if imageAsset.downloadStatus == .downloading {
            // 下载过程中点击，取消下载，理论上能点击 progressView 就肯定是下载中，这里只是做个保护
            let cell = collectionView.cellForItem(at: indexPath) as? QMUIImagePickerCollectionViewCell
            QMUIAssetsManager.shared.phCachingImageManager.cancelImageRequest(PHImageRequestID(imageAsset.requestID))
            print("Cancel download asset image with request ID \(imageAsset.requestID)")
            cell?.downloadStatus = .canceled
            imageAsset.updateDownloadStatus(withDownloadResult: false)
        }
    }

    @objc func handleDownloadRetryButtonClick(_ sender: UIButton) {
        let downloadRetryButton = sender
        guard let indexPath = collectionView.qmui_indexPathForItem(at: downloadRetryButton) else { return }
        requestImage(with: indexPath)
    }

    func updateImageCountAndCheckLimited() {
        let selectedImageCount = selectedImageAssetArray.count
        if selectedImageCount > 0 && selectedImageCount >= minimumSelectImageCount {
            previewButton.isEnabled = true
            sendButton.isEnabled = true
            imageCountLabel.text = "\(selectedImageCount)"
            imageCountLabel.isHidden = false
            QMUIImagePickerHelper.springAnimationOfImageSelectedCountChange(with: imageCountLabel)
        } else {
            previewButton.isEnabled = false
            sendButton.isEnabled = false
            imageCountLabel.isHidden = true
        }
    }

    // MARK: - Request Image

    func requestImage(with indexPath: IndexPath) {
        // 发出请求获取大图，如果图片在 iCloud，则会发出网络请求下载图片。这里同时保存请求 id，供取消请求使用
        let imageAsset = imagesAssetArray[indexPath.item]
        let cell = collectionView.cellForItem(at: indexPath) as? QMUIImagePickerCollectionViewCell
        
        imageAsset.requestID = imageAsset.requestPreviewImage(with: { result, info in
            let cancel = info?[PHImageCancelledKey] as? Bool ?? false//排除取消
            let error = info?[PHImageErrorKey] as? Bool ?? false//排除错误
            let resultIsDegraded = info?[PHImageResultIsDegradedKey] as? Bool ?? false
            let downloadSucceed = (result != nil && info == nil) || (!cancel && !error && !resultIsDegraded)
            if downloadSucceed {
                // 资源资源已经在本地或下载成功
                imageAsset.updateDownloadStatus(withDownloadResult: true)
                cell?.downloadStatus = .succeed
            } else {
                // 下载错误
                imageAsset.updateDownloadStatus(withDownloadResult: false)
                cell?.downloadStatus = .failed
            }
        }, with: { progress, error, _, _ in
            imageAsset.downloadProgress = progress

            if self.collectionView.qmui_itemVisible(at: indexPath) {
                /**
                 *  withProgressHandler 不在主线程执行，若用户在该 block 中操作 UI 时会产生一些问题，
                 *  为了避免这种情况，这里该 block 主动放到主线程执行。
                 */
                DispatchQueue.main.async {
                    print("Download iCloud image, current progress is : \(progress)")

                    if cell?.downloadStatus != .downloading {
                        cell?.downloadStatus = .downloading
                        // 预先设置预览界面的下载状态
                        self.imagePickerPreviewViewController?.downloadStatus = .downloading
                    }
                    if error != nil {
                        print("Download iCloud image Failed, current progress is: \(progress)")
                        cell?.downloadStatus = .failed
                    }
                }
            }
        })
    }
}

extension QMUIImagePickerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return imagesAssetArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var identifier = kImageOrUnknownCellIdentifier
        // 获取需要显示的资源
        let imageAsset = imagesAssetArray[indexPath.item]
        if imageAsset.assetType == .video {
            identifier = kVideoCellIdentifier
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? QMUIImagePickerCollectionViewCell
        cell?.assetIdentifier = imageAsset.identifier
        
        // 异步请求资源对应的缩略图
        imageAsset.requestThumbnailImage(with: referenceImageSize()) { result, info in
            if cell?.assetIdentifier == imageAsset.identifier {
                cell?.contentImageView.image = result
            } else  {
                cell?.contentImageView.image = nil
            }
        }

        if imageAsset.assetType == .video {
            cell?.videoDurationLabel?.text = String(seconds: imageAsset.duration)
        }

        cell?.checkboxButton.addTarget(self, action: #selector(handleCheckBoxButtonClick(_:)), for: .touchUpInside)
        cell?.isSelectable = allowsMultipleSelection

        if cell?.isSelectable ?? false {
            // 如果该图片的 QMUIAsset 被包含在已选择图片的数组中，则控制该图片被选中
            cell?.isChecked = selectedImageAssetArray.contains(imageAsset)
        }
        cell?.setNeedsLayout()
        return cell ?? UICollectionViewCell()
    }
}

extension QMUIImagePickerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return referenceImageSize()
    }
}

extension QMUIImagePickerViewController: UICollectionViewDelegate {
    
    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let imageAsset = imagesAssetArray[indexPath.item]
        imagePickerViewControllerDelegate?.imagePickerViewController?(self, didSelectImageWith: imageAsset, afterImagePickerPreviewViewControllerUpdate: imagePickerPreviewViewController!)

        initPreviewViewControllerIfNeeded()
        if !allowsMultipleSelection {
            // 单选的情况下
            var tmpArray = [QMUIAsset]()
            imagePickerPreviewViewController?.updateImagePickerPreviewView(with: [imageAsset], selectedImageAssetArray: &tmpArray, currentImageIndex: 0, singleCheckMode: true)
        } else {
            // cell 处于编辑状态，即图片允许多选
            imagePickerPreviewViewController?.updateImagePickerPreviewView(with: imagesAssetArray, selectedImageAssetArray: &selectedImageAssetArray, currentImageIndex: indexPath.item, singleCheckMode: false)
        }
        navigationController?.pushViewController(imagePickerPreviewViewController!, animated: true)
    }
}
