//
//  QMUIAsset.swift
//  QMUI.swift
//
//  Created by 黄伯驹 on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

import AssetsLibrary
import MobileCoreServices
import Photos

/// Asset 的类型
enum QMUIAssetType {
    case unknow // 未知类型的 Asset
    case image // 图片类型的 Asset
    case video // 视频类型的 Asset
    case audio // 音频类型的 Asset，仅被 PhotoKit 支持，因此只适用于 iOS 8.0
    @available(iOS 9.1, *)
    case livePhoto // Live Photo 类型的 Asset，仅被 PhotoKit 支持，因此只适用于 iOS 9.1
}

enum QMUIAssetSubType {
    case unknow // 未知类型
    case image // 图片类型
    case gif   // GIF类型
    @available(iOS 9.1, *)
    case livePhoto // Live Photo 类型的 Asset，仅被 PhotoKit 支持，因此只适用于 iOS 9.1
}

/// 从 iCloud 请求 Asset 大图的状态
enum QMUIAssetDownloadStatus {
    case succeed // 下载成功或资源本来已经在本地
    case downloading // 下载中
    case canceled // 取消下载
    case failed // 下载失败
}

private let kAssetInfoImageData = "imageData"
private let kAssetInfoOriginInfo = "originInfo"
private let kAssetInfoDataUTI = "dataUTI"
private let kAssetInfoOrientation = "orientation"
private let kAssetInfoSize = "size"

/**
 *  相册里某一个资源的包装对象，该资源可能是图片、视频等。
 *  @note QMUIAsset 重写了 isEqual: 方法，只要两个 QMUIAsset 的 adentifier 相同，则认为是同一个对象，以方便在数组、字典等容器中对大量 QMUIAsset 进行遍历查找等操作。
 */
class QMUIAsset: NSObject {
    private(set) var assetType: QMUIAssetType = .unknow
    
    private(set) var assetSubType: QMUIAssetSubType = .unknow

    private(set) var phAsset: PHAsset
    
    private(set) var downloadStatus: QMUIAssetDownloadStatus = .failed // 从 iCloud 下载资源大图的状态
    
    var downloadProgress: Double = 0 {
        didSet {
            downloadStatus = .downloading
        }
    } // 从 iCloud 下载资源大图的进度
    
    var requestID: Int = 0 // 从 iCloud 请求获得资源的大图的请求 ID

    // Asset 的标识，每个 QMUIAsset 的 identifier 都不同。只要两个 QMUIAsset 的 identifier 相同则认为它们是同一个 asset
    var identifier: String {
        get {
            return phAsset.localIdentifier
        }
    }
    
    private var phAssetInfo: [String: Any]?
    private var imageSize = 0.0

    init(phAsset: PHAsset) {
        self.phAsset = phAsset

        switch phAsset.mediaType {
        case .image:
            assetType = .image
            let value = phAsset.value(forKey: "uniformTypeIdentifier")
            if value as? String == kUTTypeGIF as String {
                assetSubType = .gif
            } else {
                if #available(iOS 9.1, *) {
                    if (phAsset.mediaSubtypes.rawValue & PHAssetMediaSubtype.photoLive.rawValue) > 1 {
                        assetSubType = .livePhoto
                    } else {
                        assetSubType = .image
                    }
                } else {
                    assetSubType = .image
                }
            }
        case .video:
            assetType = .video
        case .audio:
            assetType = .audio
        default:
            assetType = .unknow
        }
    }

    /// Asset 的原图（包含系统相册“编辑”功能处理后的效果）
    var originImage: UIImage? {
        var resultImage: UIImage?
        
        let phImageRequestOptions = PHImageRequestOptions()
        phImageRequestOptions.deliveryMode = .highQualityFormat
        phImageRequestOptions.isNetworkAccessAllowed = true
        phImageRequestOptions.isSynchronous = true
        QMUIAssetsManager.shared.phCachingImageManager.requestImage(
            for: phAsset,
            targetSize: PHImageManagerMaximumSize,
            contentMode: .default,
            options: phImageRequestOptions,
            resultHandler: { image, _ in
            resultImage = image
        })
        return resultImage
    }

    /**
     *  Asset 的缩略图
     *
     *  @param size 指定返回的缩略图的大小，仅在 iOS 8.0 及以上的版本有效，其他版本则调用 ALAsset 的接口由系统返回一个合适当前平台的图片
     *
     *  @return Asset 的缩略图
     */
    func thumbnail(with size: CGSize) -> UIImage? {
        var resultImage: UIImage?
        let phImageRequestOptions = PHImageRequestOptions()
        phImageRequestOptions.resizeMode = .fast
        // 在 PHImageManager 中，targetSize 等 size 都是使用 px 作为单位，因此需要对targetSize 中对传入的 Size 进行处理，宽高各自乘以 ScreenScale，从而得到正确的图片
        QMUIAssetsManager.shared.phCachingImageManager.requestImage(
            for: phAsset,
            targetSize: CGSize(width: size.width * ScreenScale, height: size.height * ScreenScale),
            contentMode: .aspectFill,
            options: phImageRequestOptions,
            resultHandler: { result, _ in
            resultImage = result
        })
        return resultImage
    }

    /**
     *  Asset 的预览图
     *
     *  @warning 仿照 ALAssetsLibrary 的做法输出与当前设备屏幕大小相同尺寸的图片，如果图片原图小于当前设备屏幕的尺寸，则只输出原图大小的图片
     *  @return Asset 的全屏图
     */
    var previewImage: UIImage? {
        var resultImage: UIImage?
        let imageRequestOptions = PHImageRequestOptions()
        imageRequestOptions.isNetworkAccessAllowed = true
        imageRequestOptions.isSynchronous = true
        QMUIAssetsManager.shared.phCachingImageManager.requestImage(
            for: phAsset,
            targetSize: CGSize(width: SCREEN_WIDTH, height: SCREEN_HEIGHT),
            contentMode: .aspectFill,
            options: imageRequestOptions,
            resultHandler: { result, _ in
            resultImage = result
        })
        return resultImage
    }

    /**
     *  异步请求 Asset 的原图，包含了系统照片“编辑”功能处理后的效果（剪裁，旋转和滤镜等），可能会有网络请求
     *
     *  @param completion        完成请求后调用的 block，参数中包含了请求的原图以及图片信息，这个 block 会被多次调用，
     *                           其中第一次调用获取到的尺寸很小的低清图，然后不断调用，直到获取到高清图。
     *  @param phProgressHandler 处理请求进度的 handler，不在主线程上执行，在 block 中修改 UI 时注意需要手工放到主线程处理。
     *
     *  @return 返回请求图片的请求 id
     */
    @discardableResult
    func requestOriginImage(with completion: ((_ result: UIImage?, _ info: [String: Any]?) -> Void)?, with progressHandler: @escaping PHAssetImageProgressHandler) -> Int {
        let imageRequestOptions = PHImageRequestOptions()
        imageRequestOptions.isNetworkAccessAllowed = true // 允许访问网络
        imageRequestOptions.progressHandler = progressHandler
        let resultValue = QMUIAssetsManager.shared.phCachingImageManager.requestImage(
            for: phAsset,
            targetSize: PHImageManagerMaximumSize,
            contentMode: .default,
            options: imageRequestOptions,
            resultHandler: { result, info in
            completion?(result, info as? [String: Any])
        })
        return Int(resultValue)
    }

    /**
     *  异步请求 Asset 的缩略图，不会产生网络请求
     *
     *  @param size       指定返回的缩略图的大小
     *  @param completion 完成请求后调用的 block，参数中包含了请求的缩略图以及图片信息，这个 block 会被多次调用，
     *                    其中第一次调用获取到的尺寸很小的低清图，然后不断调用，直到获取到高清图，这时 block 中的第二个参数（图片信息）返回的为 nil。
     *
     *  @return 返回请求图片的请求 id
     */
    @discardableResult
    func requestThumbnailImage(with size: CGSize, completion: ((_ result: UIImage?, _ info: [String: Any]?) -> Void)?) -> Int {
        let imageRequestOptions = PHImageRequestOptions()
        imageRequestOptions.resizeMode = .fast
        // 在 PHImageManager 中，targetSize 等 size 都是使用 px 作为单位，因此需要对targetSize 中对传入的 Size 进行处理，宽高各自乘以 ScreenScale，从而得到正确的图片
        let resultValue = QMUIAssetsManager.shared.phCachingImageManager.requestImage(
            for: phAsset,
            targetSize: CGSize(width: size.width * ScreenScale, height: size.height * ScreenScale),
            contentMode: .aspectFill,
            options: imageRequestOptions,
            resultHandler: { result, info in
            completion?(result, info as? [String: Any])
        })
        return Int(resultValue)
    }

    /**
     *  异步请求 Asset 的预览图，可能会有网络请求
     *
     *  @param completion        完成请求后调用的 block，参数中包含了请求的预览图以及图片信息，这个 block 会被多次调用，
     *                           其中第一次调用获取到的尺寸很小的低清图，然后不断调用，直到获取到高清图。
     *  @param phProgressHandler 处理请求进度的 handler，不在主线程上执行，在 block 中修改 UI 时注意需要手工放到主线程处理。
     *
     *  @return 返回请求图片的请求 id
     */
    func requestPreviewImage(with completion: ((_ result: UIImage?, _ info: [String: Any]?) -> Void)?, with progressHandler: @escaping PHAssetImageProgressHandler) -> Int {
        let imageRequestOptions = PHImageRequestOptions()
        imageRequestOptions.isNetworkAccessAllowed = true // 允许访问网络
        imageRequestOptions.progressHandler = progressHandler
        let resultValue = QMUIAssetsManager.shared.phCachingImageManager.requestImage(
            for: phAsset,
            targetSize: CGSize(width: SCREEN_WIDTH, height: SCREEN_HEIGHT),
            contentMode: .aspectFill,
            options: imageRequestOptions,
            resultHandler: { result, info in
            completion?(result, info as? [String: Any])
        })
        return Int(resultValue)
    }

    /**
     *  异步请求 Live Photo，可能会有网络请求
     *
     *  @param completion        完成请求后调用的 block，参数中包含了请求的 Live Photo 以及相关信息，若 assetType 不是 QMUIAssetTypeLivePhoto 则为 nil
     *  @param phProgressHandler 处理请求进度的 handler，不在主线程上执行，在 block 中修改 UI 时注意需要手工放到主线程处理。
     *
     *  @wraning iOS 9.1 以下中并没有 Live Photo，因此无法获取有效结果。
     *
     *  @return 返回请求图片的请求 id
     */
    @objc @available(iOS 9.1, *)
    func requestLivePhoto(with completion: ((_ livePhoto: PHLivePhoto?, _ info: [String: Any]?) -> Void)?, with progressHandler: @escaping PHAssetImageProgressHandler) -> Int {
        if PHCachingImageManager.instancesRespond(to: #selector(PHCachingImageManager.requestLivePhoto(for:targetSize:contentMode:options:resultHandler:))) {
            let livePhotoRequestOptions = PHLivePhotoRequestOptions()
            livePhotoRequestOptions.isNetworkAccessAllowed = true // 允许访问网络
            livePhotoRequestOptions.progressHandler = progressHandler
            let resultValue = QMUIAssetsManager.shared.phCachingImageManager.requestLivePhoto(for: phAsset, targetSize: CGSize(width: SCREEN_WIDTH, height: SCREEN_HEIGHT), contentMode: .default, options: livePhotoRequestOptions, resultHandler: { reuslt, info in
                completion?(reuslt, info as? [String: Any])
            })
            return Int(resultValue)
        } else {
            completion?(nil, nil)
            return 0
        }
    }

    /**
     *  异步请求 AVPlayerItem，可能会有网络请求
     *
     *  @param completion        完成请求后调用的 block，参数中包含了请求的 AVPlayerItem 以及相关信息，若 assetType 不是 QMUIAssetTypeVideo 则为 nil
     *  @param phProgressHandler 处理请求进度的 handler，不在主线程上执行，在 block 中修改 UI 时注意需要手工放到主线程处理。
     *
     *  @return 返回请求 AVPlayerItem 的请求 id
     */
    func requestPlayerItem(with completion: ((_ playerItem: AVPlayerItem?, _ info: [String: Any]?) -> Void)?, with progressHandler: @escaping PHAssetVideoProgressHandler) -> Int {
        if PHCachingImageManager.instancesRespond(to: #selector(PHCachingImageManager.requestPlayerItem(forVideo:options:resultHandler:))) {
            let videoRequestOptions = PHVideoRequestOptions()
            videoRequestOptions.isNetworkAccessAllowed = true // 允许访问网络
            videoRequestOptions.progressHandler = progressHandler
            let resultValue = QMUIAssetsManager.shared.phCachingImageManager.requestPlayerItem(forVideo: phAsset, options: videoRequestOptions, resultHandler: { playerItem, info in
                completion?(playerItem, info as? [String: Any])
            })
            return Int(resultValue)
        } else {
            completion?(nil, nil)
            return 0
        }
    }

    /**
     *  异步请求图片的 Data
     *
     *  @param completion 完成请求后调用的 block，参数中包含了请求的图片 Data（若 assetType 不是 QMUIAssetTypeImage 或 QMUIAssetTypeLivePhoto 则为 nil），该图片是否为 GIF 的判断值，以及该图片的文件格式是否为 HEIC
     */
    func requestImageData(_ completion: ((_ imageData: Data?, _ info: [String: Any]?, _ isGif: Bool, _ isHEIC: Bool) -> Void)?) {
        if assetType != .image {
            completion?(nil, nil, false, false)
            return
        }
        
        if let phAssetInfo = phAssetInfo {
            if let completion = completion {
                let dataUTI = phAssetInfo[kAssetInfoDataUTI] as? String
                let isGif = assetSubType == .gif
                let isHEIC = dataUTI == "public.heic"
                let originInfo = phAssetInfo[kAssetInfoOriginInfo] as? [String: Any]
                completion(phAssetInfo[kAssetInfoImageData] as? Data, originInfo, isGif, isHEIC)
            }
        } else {
            // PHAsset 的 UIImageOrientation 需要调用过 requestImageDataForAsset 才能获取
            requestPhAssetInfo(completion: { [weak self] phAssetInfo in
                self?.phAssetInfo = phAssetInfo
                if let completion = completion, let strongSelf = self {
                    let dataUTI = phAssetInfo?[kAssetInfoDataUTI] as? String
                    let isGif = strongSelf.assetSubType == .gif
                    let isHEIC = dataUTI == "public.heic"
                    let originInfo = phAssetInfo?[kAssetInfoOriginInfo] as? [String: Any]
                    /**
                     *  这里不在主线程执行，若用户在该 block 中操作 UI 时会产生一些问题，
                     *  为了避免这种情况，这里该 block 主动放到主线程执行。
                     */
                    DispatchQueue.main.async {
                        completion(phAssetInfo?[kAssetInfoImageData] as? Data, originInfo, isGif, isHEIC)
                    }
                }
            })
        }
    }

    /**
     * 获取图片的 UIImageOrientation 值，仅 assetType 为 QMUIAssetTypeImage 或 QMUIAssetTypeLivePhoto 时有效
     */
    var imageOrientation: UIImage.Orientation? {
        var orientation: UIImage.Orientation?
        if assetType == .image {
            if phAssetInfo == nil {
                // PHAsset 的 UIImageOrientation 需要调用过 requestImageDataForAsset 才能获取
                requestImagePhAssetInfo(synchronous: true, completion: { [weak self] info in
                    self?.phAssetInfo = info
                })
            }
            // 从 PhAssetInfo 中获取 UIImageOrientation 对应的字段
            orientation = phAssetInfo?[kAssetInfoOrientation] as? UIImage.Orientation ?? .up
        } else {
            orientation = .up
        }
        
         return orientation
    }

    private func requestPhAssetInfo(completion: (([String: Any]?) -> Void)?) {
        if assetType == .video {
            QMUIAssetsManager.shared.phCachingImageManager.requestAVAsset(
                forVideo: phAsset,
                options: nil,
                resultHandler: { asset, _ , info in
                if let urlAsset = asset as? AVURLAsset {
                    var tempInfo: [String: Any] = [:]
                    if let info = info {
                        tempInfo[kAssetInfoOriginInfo] = info
                    }
                    do {
                        let size = try urlAsset.url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
                        tempInfo[kAssetInfoSize] = Int64(size)
                        completion?(tempInfo)
                    } catch let error {
                        print(error, #function)
                    }
                }
            })
        } else {
            requestImagePhAssetInfo(synchronous: false) { (phAssetInfo) in
                completion?(phAssetInfo)
            }
        }
    }

    private func requestImagePhAssetInfo(synchronous: Bool, completion: (([String: Any]) -> Void)?) {
        let imageRequestOptions = PHImageRequestOptions()
        imageRequestOptions.isSynchronous = synchronous
        imageRequestOptions.isNetworkAccessAllowed = true
        QMUIAssetsManager.shared.phCachingImageManager.requestImageData(
        for: phAsset,
        options: imageRequestOptions) { imageData, dataUTI, orientation, info in
            guard let info = info else {
                return
            }
            var tempInfo: [String: Any] = [:]
            if let imageData = imageData {
                tempInfo[kAssetInfoImageData] = imageData
                tempInfo[kAssetInfoSize] = imageData.count
            }

            tempInfo[kAssetInfoOriginInfo] = info
            if let dataUTI = dataUTI {
                tempInfo[kAssetInfoDataUTI] = dataUTI
            }
            tempInfo[kAssetInfoOrientation] = orientation
            completion?(tempInfo)
        }
    }

    /// 更新下载资源的结果
    func updateDownloadStatus(withDownloadResult succeed: Bool) {
        downloadStatus = succeed ? .succeed : .failed
    }

    /**
     * 获取 Asset 的体积（数据大小）
     */
    func assetSize(completion: ((Double) -> Void)?) {
        guard let phAssetInfo = phAssetInfo else {
            // PHAsset 的 UIImageOrientation 需要调用过 requestImageDataForAsset 才能获取
            requestPhAssetInfo(completion: { [weak self] phAssetInfo in
                self?.phAssetInfo = phAssetInfo
                /**
                 *  这里不在主线程执行，若用户在该 block 中操作 UI 时会产生一些问题，
                 *  为了避免这种情况，这里该 block 主动放到主线程执行。
                 */
                DispatchQueue.main.async {
                    let result = Double(phAssetInfo?[kAssetInfoSize] as! Int)
                    completion?(result)
                }
            })
            return
        }
        let result = Double(phAssetInfo[kAssetInfoSize] as! Int)
        completion?(result)
    }

    var duration: TimeInterval {
        if assetType != .video {
            return 0
        }
        return phAsset.duration
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let asset = object as? QMUIAsset else {
            return false
        }
        return identifier == asset.identifier
    }
}
