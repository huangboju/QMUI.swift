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
    case unknow                              // 未知类型的 Asset
    case image                               // 图片类型的 Asset
    case video                               // 视频类型的 Asset
    case audio    // 音频类型的 Asset，仅被 PhotoKit 支持，因此只适用于 iOS 8.0
    @available(iOS 9.1, *)
    case livePhoto  // Live Photo 类型的 Asset，仅被 PhotoKit 支持，因此只适用于 iOS 9.1
}

/// 从 iCloud 请求 Asset 大图的状态
enum QMUIAssetDownloadStatus {
    case succeed     // 下载成功或资源本来已经在本地
    case downloading // 下载中
    case canceled    // 取消下载
    case failed      // 下载失败
}

private let kAssetInfoImageData = "imageData"
private let kAssetInfoOriginInfo = "originInfo"
private let kAssetInfoDataUTI = "dataUTI"
private let kAssetInfoOrientation = "orientation"
private let kAssetInfoSize = "size"

class QMUIAsset: NSObject {
    public private (set) var assetType: QMUIAssetType = .unknow
    
    public private (set) var downloadStatus: QMUIAssetDownloadStatus = .failed // 从 iCloud 下载资源大图的状态
    
    public var downloadProgress: Double = 0 // 从 iCloud 下载资源大图的进度
    public var requestID = 0 // 从 iCloud 请求获得资源的大图的请求 ID
    
    private var usePhotoKit = false

    private var phAsset: PHAsset?

    private var alAsset: ALAsset?
    private var alAssetRepresentation: ALAssetRepresentation?
    private var phAssetInfo: [String: Any]?
    private var imageSize = 0.0
    private var assetIdentityHash: String?

    public init(phAsset: PHAsset) {
        self.phAsset = phAsset
        usePhotoKit = true

        switch phAsset.mediaType {
        case .image:
            if #available(iOS 9.1, *) {
                if (phAsset.mediaSubtypes.rawValue & PHAssetMediaSubtype.photoLive.rawValue) > 1 {
                    self.assetType = .livePhoto
                } else {
                    self.assetType = .image
                }
            } else {
                self.assetType = .image
            }
        case .video:
            assetType = .video
        case .audio:
            assetType = .audio
        default:
            assetType = .unknow
        }
    }

    public init(alAsset: ALAsset) {
        self.alAsset = alAsset
        alAssetRepresentation = alAsset.defaultRepresentation()
        usePhotoKit = false

        let propertyType = alAsset.value(forProperty: ALAssetPropertyType) as? String ?? ""
        if propertyType == ALAssetTypePhoto {
            self.assetType = .image
        } else if propertyType == ALAssetTypeVideo {
            self.assetType = .video
        } else {
            self.assetType = .unknow
        }
    }

    /// Asset 的原图（包含系统相册“编辑”功能处理后的效果）
    public var originImage: UIImage? {
        var resultImage: UIImage?
        if usePhotoKit {
            guard let phAsset = phAsset else { return nil }
            let phImageRequestOptions = PHImageRequestOptions()
            phImageRequestOptions.isSynchronous = true
            QMUIAssetsManager.shared.phCachingImageManager.requestImage(for: phAsset, targetSize: PHImageManagerMaximumSize, contentMode: .default, options: phImageRequestOptions, resultHandler: { (image, info) in
                resultImage = image
            })
        } else {
            
            guard let alAssetRepresentation = alAssetRepresentation else { return nil }
            var fullResolutionImageRef = alAssetRepresentation.fullScreenImage().takeUnretainedValue()
            // 通过 fullResolutionImage 获取到的的高清图实际上并不带上在照片应用中使用“编辑”处理的效果，需要额外在 AlAssetRepresentation 中获取这些信息

            if let adjustment = alAssetRepresentation.metadata()["AdjustmentXMP"] as? String {
                // 如果有在照片应用中使用“编辑”效果，则需要获取这些编辑后的滤镜，手工叠加到原图中
                let xmpData = adjustment.data(using: .utf8)
                var tempImage = CIImage(cgImage: fullResolutionImageRef)

                var error: NSError?

                let filterArray = CIFilter.filterArray(fromSerializedXMP: xmpData!, inputImageExtent: tempImage.extent, error: &error)
                let context = CIContext(options: nil)
                if !filterArray.isEmpty && error == nil {
                    for filter in filterArray {
                        filter.setValue(tempImage, forKey: kCIInputImageKey)
                        tempImage = filter.outputImage!
                    }
                    fullResolutionImageRef = context.createCGImage(tempImage, from: tempImage.extent)!
                }
            }
            // 生成最终返回的 UIImage，同时把图片的 orientation 也补充上去
            resultImage = UIImage(cgImage: fullResolutionImageRef, scale: CGFloat(alAssetRepresentation.scale()), orientation: alAssetRepresentation.orientation().imageOrientation)
        }
        return resultImage
    }
    
    /**
     *  Asset 的缩略图
     *
     *  @param size 指定返回的缩略图的大小，仅在 iOS 8.0 及以上的版本有效，其他版本则调用 ALAsset 的接口由系统返回一个合适当前平台的图片
     *
     *  @return Asset 的缩略图
     */
    public func thumbnail(with size: CGSize) -> UIImage? {
        var resultImage: UIImage?
        if usePhotoKit {
            guard let phAsset = phAsset else { return nil }
            let phImageRequestOptions = PHImageRequestOptions()
            phImageRequestOptions.resizeMode = .exact
            // 在 PHImageManager 中，targetSize 等 size 都是使用 px 作为单位，因此需要对targetSize 中对传入的 Size 进行处理，宽高各自乘以 ScreenScale，从而得到正确的图片
            QMUIAssetsManager.shared.phCachingImageManager.requestImage(for: phAsset, targetSize: CGSize(width: size.width * ScreenScale, height: size.height * ScreenScale), contentMode: .aspectFill, options: phImageRequestOptions, resultHandler: { (result, info) in
                resultImage = result
            })
        } else {
            if let thumbnailImage = alAsset?.thumbnail().takeUnretainedValue() {
                resultImage = UIImage(cgImage: thumbnailImage)
            }
        }
        return resultImage
    }
    
    /**
     *  Asset 的预览图
     *
     *  @warning 仿照 ALAssetsLibrary 的做法输出与当前设备屏幕大小相同尺寸的图片，如果图片原图小于当前设备屏幕的尺寸，则只输出原图大小的图片
     *  @return Asset 的全屏图
     */
    public var previewImage: UIImage? {
        var resultImage: UIImage?
        if usePhotoKit {
            guard let phAsset = phAsset else { return nil }
            let imageRequestOptions = PHImageRequestOptions()
            imageRequestOptions.isSynchronous = true
            QMUIAssetsManager.shared.phCachingImageManager.requestImage(for: phAsset, targetSize: CGSize(width: SCREEN_WIDTH, height: SCREEN_HEIGHT), contentMode: .aspectFill, options: imageRequestOptions, resultHandler: { (result, info) in
                resultImage = result
            })
        } else {
            guard let fullScreenImage = alAssetRepresentation?.fullScreenImage().takeUnretainedValue() else { return nil }
            resultImage = UIImage(cgImage: fullScreenImage)
        }
        return resultImage
    }

    /**
     *  异步请求 Asset 的原图，包含了系统照片“编辑”功能处理后的效果（剪裁，旋转和滤镜等），可能会有网络请求
     *
     *  @param completion        完成请求后调用的 block，参数中包含了请求的原图以及图片信息，在 iOS 8.0 或以上版本中，
     *                           这个 block 会被多次调用，其中第一次调用获取到的尺寸很小的低清图，然后不断调用，直到获取到高清图。
     *  @param phProgressHandler 处理请求进度的 handler，不在主线程上执行，在 block 中修改 UI 时注意需要手工放到主线程处理。
     *
     *  @wraning iOS 8.0 以下中并没有异步请求预览图的接口，因此实际上为同步请求，这时 block 中的第二个参数（图片信息）返回的为 nil。
     *
     *  @return 返回请求图片的请求 id
     */
    public func requestOriginImage(with completion: ((_ result: UIImage?, _ info: [String: Any]?) -> Void)?, with progressHandler: @escaping PHAssetImageProgressHandler) -> Int {
        if usePhotoKit {
            guard let phAsset = phAsset else { return 0 }
            let imageRequestOptions = PHImageRequestOptions()
            imageRequestOptions.isNetworkAccessAllowed = true // 允许访问网络
            imageRequestOptions.progressHandler = progressHandler
            return Int(QMUIAssetsManager.shared.phCachingImageManager.requestImage(for: phAsset, targetSize: PHImageManagerMaximumSize, contentMode: .default, options: imageRequestOptions, resultHandler: { (result, info) in
                completion?(result!, info as? [String : Any])
            }))
        } else {
            completion?(originImage, nil)
            return 0
        }
    }

    /**
     *  异步请求 Asset 的缩略图，不会产生网络请求
     *
     *  @param size       指定返回的缩略图的大小，仅在 iOS 8.0 及以上的版本有效，其他版本则调用 ALAsset 的接口由系统返回一个合适当前平台的图片
     *  @param completion 完成请求后调用的 block，参数中包含了请求的缩略图以及图片信息，在 iOS 8.0 或以上版本中，这个 block 会被多次调用，
     *                    其中第一次调用获取到的尺寸很小的低清图，然后不断调用，直到获取到高清图，这时 block 中的第二个参数（图片信息）返回的为 nil。
     *
     *  @return 返回请求图片的请求 id
     */
    public func requestThumbnailImage(with size: CGSize, completion:((_ result: UIImage?, _ info: [String: Any]?) -> Void)?) -> Int {
        if usePhotoKit {
            guard let phAsset = phAsset else { return 0 }
            let imageRequestOptions = PHImageRequestOptions()
            imageRequestOptions.resizeMode = .fast
            // 在 PHImageManager 中，targetSize 等 size 都是使用 px 作为单位，因此需要对targetSize 中对传入的 Size 进行处理，宽高各自乘以 ScreenScale，从而得到正确的图片
            return Int(QMUIAssetsManager.shared.phCachingImageManager.requestImage(for: phAsset, targetSize: CGSize(width: size.width * ScreenScale, height: size.height * ScreenScale), contentMode: .aspectFill, options: imageRequestOptions, resultHandler: { (result, info) in
                completion?(result, info as? [String : Any])
            }))
        } else {
            completion?(thumbnail(with: size), nil)
            return 0
        }
    }
    
    /**
     *  异步请求 Asset 的预览图，可能会有网络请求
     *
     *  @param completion        完成请求后调用的 block，参数中包含了请求的预览图以及图片信息，在 iOS 8.0 或以上版本中，
     *                           这个 block 会被多次调用，其中第一次调用获取到的尺寸很小的低清图，然后不断调用，直到获取到高清图。
     *  @param phProgressHandler 处理请求进度的 handler，不在主线程上执行，在 block 中修改 UI 时注意需要手工放到主线程处理。
     *
     *  @wraning iOS 8.0 以下中并没有异步请求预览图的接口，因此实际上为同步请求，这时 block 中的第二个参数（图片信息）返回的为 nil。
     *
     *  @return 返回请求图片的请求 id
     */
    public func requestPreviewImage(with completion:((_ result: UIImage?, _ info: [String: Any]?) -> Void)?, with progressHandler: @escaping PHAssetImageProgressHandler) -> Int {
        if usePhotoKit {
            guard let phAsset = phAsset else { return 0 }
            let imageRequestOptions = PHImageRequestOptions()
            imageRequestOptions.isNetworkAccessAllowed = true // 允许访问网络
            imageRequestOptions.progressHandler = progressHandler
            return Int(QMUIAssetsManager.shared.phCachingImageManager.requestImage(for: phAsset, targetSize: CGSize(width: SCREEN_WIDTH, height: SCREEN_HEIGHT), contentMode: .aspectFill, options: imageRequestOptions, resultHandler: { (result, info) in
                completion?(result, info as? [String : Any])
            }))
        } else {
            completion?(previewImage, nil)
            return 0
        }
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
    @available(iOS 9.1, *)
    public func requestLivePhoto(with completion: ((_ livePhoto: PHLivePhoto?, _ info: [String: Any]?) -> Void)?, with progressHandler: @escaping PHAssetImageProgressHandler) -> Int {
        if usePhotoKit {
            guard let phAsset = phAsset else { return 0 }
            let livePhotoRequestOptions = PHLivePhotoRequestOptions()
            livePhotoRequestOptions.isNetworkAccessAllowed = true // 允许访问网络
            livePhotoRequestOptions.progressHandler = progressHandler
            return Int(QMUIAssetsManager.shared.phCachingImageManager.requestLivePhoto(for: phAsset, targetSize: CGSize(width: SCREEN_WIDTH, height: SCREEN_HEIGHT), contentMode: .default, options: livePhotoRequestOptions, resultHandler: { (reuslt, info) in
                completion?(reuslt, info as? [String : Any])
            }))
        } else {
            return 0
        }
    }
    
    /**
     *  异步请求 AVPlayerItem，可能会有网络请求
     *
     *  @param completion        完成请求后调用的 block，参数中包含了请求的 AVPlayerItem 以及相关信息，若 assetType 不是 QMUIAssetTypeVideo 则为 nil
     *  @param phProgressHandler 处理请求进度的 handler，不在主线程上执行，在 block 中修改 UI 时注意需要手工放到主线程处理。
     *
     *  @wraning iOS 8.0 以下中并没有异步请求 AVPlayerItem 的接口，因此实际上为同步请求，这时 block 中的第二个参数（AVPlayerItem 相关信息）返回的为 nil。
     *
     *  @return 返回请求 AVPlayerItem 的请求 id
     */
    
    public func requestPlayerItem(with completion: ((_ playerItem: AVPlayerItem?, _ info: [String: Any]?) -> Void)?, with progressHandler: @escaping PHAssetVideoProgressHandler) -> Int     {
        if usePhotoKit {
            guard let phAsset = phAsset else { return 0 }
            let videoRequestOptions = PHVideoRequestOptions()
            videoRequestOptions.isNetworkAccessAllowed = true // 允许访问网络
            videoRequestOptions.progressHandler = progressHandler
            return Int(QMUIAssetsManager.shared.phCachingImageManager.requestPlayerItem(forVideo: phAsset, options: videoRequestOptions, resultHandler: { (playerItem, info) in
                completion?(playerItem, info as? [String : Any])
            }))
        } else {
            guard let url = alAssetRepresentation?.url() else {
                return 0
            }
            let playerItem = AVPlayerItem(url: url)
            completion?(playerItem, nil)
            return 0
        }
    }
    
    /**
     *  异步请求图片的 Data
     *
     *  @param completion 完成请求后调用的 block，参数中包含了请求的图片 Data（若 assetType 不是 QMUIAssetTypeImage 或 QMUIAssetTypeLivePhoto 则为 nil），以及该图片是否为 GIF 的判断值
     *
     *  @wraning iOS 8.0 以下中并没有异步请求 Data 的接口，因此实际上为同步请求，这时 block 中的第二个参数（图片信息）返回的为 nil。
     */
    
    public func requestImageData(_ completion: ((_ imageData: Data?, _ info: [String: Any]?, _ isGif: Bool) -> Void)?) {
        if #available(iOS 9.1, *) {
            if assetType != .image && assetType != .livePhoto {
                completion?(nil, nil, false)
                return
            }
        } else {
            // Fallback on earlier versions
        }
        if usePhotoKit {
            if let phAssetInfo = phAssetInfo {
                if let completion = completion {
                    let dataUTI = phAssetInfo[kAssetInfoDataUTI] as? String
                    let isGif = dataUTI == (kUTTypeGIF as String)
                    let originInfo = phAssetInfo[kAssetInfoOriginInfo] as? [String: Any]
                    completion(phAssetInfo[kAssetInfoImageData] as? Data, originInfo, isGif)
                }
            } else {
                // PHAsset 的 UIImageOrientation 需要调用过 requestImageDataForAsset 才能获取
                requestPhAssetInfo(completion: { phAssetInfo in
                    self.phAssetInfo = phAssetInfo
                    if let completion = completion {
                        let dataUTI = phAssetInfo[kAssetInfoDataUTI] as? String
                        let isGif = dataUTI == (kUTTypeGIF as String)
                        let originInfo = phAssetInfo[kAssetInfoOriginInfo] as? [String: Any]
                        /**
                         *  这里不在主线程执行，若用户在该 block 中操作 UI 时会产生一些问题，
                         *  为了避免这种情况，这里该 block 主动放到主线程执行。
                         */
                        DispatchQueue.main.async {
                            completion(phAssetInfo[kAssetInfoImageData] as? Data, originInfo, isGif)
                        }
                    }
                })
            }
        } else {
            guard let completion = completion else {
                return
            }
            assetSize(completion: { size in
                // 获取 NSData 数据
                var buffer = [UInt8](repeating: 0, count: Int(size))
                var error: NSError?
                guard let bytes = self.alAssetRepresentation?.getBytes(&buffer, fromOffset: 0, length: Int(size), error: &error) else { return }
                let imageData = Data(bytes: buffer, count: bytes)
                free(&buffer)
                // 判断是否为 GIF 图
                if let gifRepresentation = self.alAsset?.representation(forUTI: kUTTypeGIF as String) {
                    completion(imageData, nil, true)
                } else {
                    completion(imageData, nil, false)
                }
            })
        }
    }
    
    /**
     * 获取图片的 UIImageOrientation 值，仅 assetType 为 QMUIAssetTypeImage 或 QMUIAssetTypeLivePhoto 时有效
     */
    public var imageOrientation: UIImageOrientation? {
        var orientation: UIImageOrientation?
        if #available(iOS 9.1, *) {
            if assetType == .image || assetType == .livePhoto {
                if usePhotoKit {
                    if phAssetInfo == nil {
                        // PHAsset 的 UIImageOrientation 需要调用过 requestImageDataForAsset 才能获取
                        requestImagePhAssetInfo(synchronous: true, completion: { (info) in
                            self.phAssetInfo = info
                        })
                    }
                    // 从 PhAssetInfo 中获取 UIImageOrientation 对应的字段
                    orientation = phAssetInfo?[kAssetInfoOrientation] as? UIImageOrientation
                } else {
                    orientation = alAsset?.value(forProperty: "ALAssetPropertyOrientation") as? UIImageOrientation
                }
            } else {
                orientation = .up
            }
        } else {

        }
        return orientation
    }

    private func requestPhAssetInfo(completion: (([String: Any]) -> Void)?) {
        if assetType == .video {
            guard let phAsset = phAsset else { return }
            QMUIAssetsManager.shared.phCachingImageManager.requestAVAsset(forVideo: phAsset, options: nil, resultHandler: { (asset, audioMix, info) in
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
            requestImagePhAssetInfo(synchronous: false, completion: completion)
        }
    }
    
    private func requestImagePhAssetInfo(synchronous: Bool, completion: (([String: Any]) -> Void)?) {
        guard let phAsset = phAsset else { return }
        let imageRequestOptions = PHImageRequestOptions()
        imageRequestOptions.isSynchronous = synchronous
        imageRequestOptions.isNetworkAccessAllowed = true
        QMUIAssetsManager.shared.phCachingImageManager.requestImageData(for: phAsset, options: imageRequestOptions) { (imageData, dataUTI, orientation, info) in
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
    
    /**
     *  Asset 的标识，每个 QMUIAsset 的标识值不相同，该标识值经过 md5 处理，避免了特殊字符
     *
     *  @return Asset 的标识字符串
     */
    public var assetIdentity: String? {
        if assetIdentityHash == nil || !assetIdentityHash!.isEmpty {
            return assetIdentityHash
        }
        let identity: String?
        if usePhotoKit {
            identity = phAsset?.localIdentifier
        } else {
            identity = alAssetRepresentation?.url().absoluteString
        }
        // 系统输出的 identity 可能包含特殊字符，为了避免引起问题，统一使用 md5 转换
        assetIdentityHash = identity?.qmui_md5
        return assetIdentityHash
    }
    
    /// 更新下载资源的结果
    public func updateDownloadStatusWithDownloadResult(_ succeed: Bool) {
        downloadStatus = succeed ? .succeed : .failed
    }
    
    /**
     * 获取 Asset 的体积（数据大小）
     */
    public func assetSize(completion: ((Int64) -> Void)?) {
        guard usePhotoKit else {
            completion?(alAssetRepresentation?.size() ?? 0)
            return
        }
        guard let phAssetInfo = phAssetInfo else {
            // PHAsset 的 UIImageOrientation 需要调用过 requestImageDataForAsset 才能获取
            requestPhAssetInfo(completion: { phAssetInfo in
                self.phAssetInfo = phAssetInfo
                guard let completion = completion else {
                    return
                }
                /**
                 *  这里不在主线程执行，若用户在该 block 中操作 UI 时会产生一些问题，
                 *  为了避免这种情况，这里该 block 主动放到主线程执行。
                 */
                DispatchQueue.main.async {
                    completion((phAssetInfo[kAssetInfoSize] as? Int64) ?? 0)
                }
            })
            return
        }
        completion?((phAssetInfo[kAssetInfoSize] as? Int64) ?? 0)
    }

    public var duration: TimeInterval {
        if assetType != .video {
            return 0
        }
        if usePhotoKit {
            return phAsset?.duration ?? 0
        } else {
            return alAsset?.value(forProperty: ALAssetPropertyDuration) as? TimeInterval ?? 0
        }
    }
}

extension ALAssetOrientation {

    var imageOrientation: UIImageOrientation {
        switch self {
        case .up:
            return .up
        case .down:
            return .down
        case .left:
            return .left
        case .right:
            return .right
        case .upMirrored:
            return .upMirrored
        case .downMirrored:
            return .downMirrored
        case .leftMirrored:
            return .leftMirrored
        case .rightMirrored:
            return .rightMirrored
        }
    }
}

extension UIImageOrientation {
    var assetOrientation: ALAssetOrientation {
        switch self {
        case .up:
            return .up
        case .down:
            return .down
        case .left:
            return .left
        case .right:
            return .right
        case .upMirrored:
            return .upMirrored
        case .downMirrored:
            return .downMirrored
        case .leftMirrored:
            return .leftMirrored
        case .rightMirrored:
            return .rightMirrored
        }
    }
}
