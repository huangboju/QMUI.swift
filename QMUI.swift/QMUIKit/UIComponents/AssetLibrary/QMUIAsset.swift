//
//  QMUIAsset.swift
//  QMUI.swift
//
//  Created by 黄伯驹 on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

import Photos
import AssetsLibrary

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

class QMUIAsset {
    public private (set) var assetType: QMUIAssetType = .unknow
    
    public private (set) var downloadStatus: QMUIAssetDownloadStatus = .failed // 从 iCloud 下载资源大图的状态
    
    public var downloadProgress: Double = 0 // 从 iCloud 下载资源大图的进度
    public var requestID = 0 // 从 iCloud 请求获得资源的大图的请求 ID

    public init(phAsset: PHAsset) {
        
    }
    
    public init(alAsset: ALAsset) {
        
    }
    
    /// Asset 的原图（包含系统相册“编辑”功能处理后的效果）
    public var originImage: UIImage {
    
    }
    
    /**
     *  Asset 的缩略图
     *
     *  @param size 指定返回的缩略图的大小，仅在 iOS 8.0 及以上的版本有效，其他版本则调用 ALAsset 的接口由系统返回一个合适当前平台的图片
     *
     *  @return Asset 的缩略图
     */
    public func thumbnail(with size: CGSize) -> UIImage {
    
    }
    
    /**
     *  Asset 的预览图
     *
     *  @warning 仿照 ALAssetsLibrary 的做法输出与当前设备屏幕大小相同尺寸的图片，如果图片原图小于当前设备屏幕的尺寸，则只输出原图大小的图片
     *  @return Asset 的全屏图
     */
    public var previewImage: UIImage {
    
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
    public func requestOriginImage(with completion: ((_ result: UIImage, _ info: [String: Any]) -> Void)?, with progressHandler: PHAssetImageProgressHandler) -> Int {
    
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
    public func requestThumbnailImage(with size: CGSize, completion:((_ result: UIImage, _ info: [String: Any]) -> Void)?) -> Int {
    
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
    public func requestPreviewImage(with completion:((_ result: UIImage, _ info: [String: Any]) -> Void)?, with progressHandler: PHAssetImageProgressHandler) -> Int {
    
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
    public func requestLivePhoto(with completion: ((_ livePhoto: PHLivePhoto, _ info: [String: Any]) -> Void)?, with progressHandler: PHAssetImageProgressHandler) -> Int {
    
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
    
    public func requestPlayerItem(with completion: ((_ playerItem: AVPlayerItem, _ info: [String: Any]) -> Void)?, with progressHandler: PHAssetVideoProgressHandler) -> Int     {
    
    }
    
    /**
     *  异步请求图片的 Data
     *
     *  @param completion 完成请求后调用的 block，参数中包含了请求的图片 Data（若 assetType 不是 QMUIAssetTypeImage 或 QMUIAssetTypeLivePhoto 则为 nil），以及该图片是否为 GIF 的判断值
     *
     *  @wraning iOS 8.0 以下中并没有异步请求 Data 的接口，因此实际上为同步请求，这时 block 中的第二个参数（图片信息）返回的为 nil。
     */
    
    public func requestImageData(_ completion: ((_ imageData: Data, _ info: [String: Any], _ isGif: Bool) -> Void)?) {
    
    }
    
    /**
     * 获取图片的 UIImageOrientation 值，仅 assetType 为 QMUIAssetTypeImage 或 QMUIAssetTypeLivePhoto 时有效
     */
    public var imageOrientation: UIImageOrientation {
    
    }
    
    /**
     *  Asset 的标识，每个 QMUIAsset 的标识值不相同，该标识值经过 md5 处理，避免了特殊字符
     *
     *  @return Asset 的标识字符串
     */
    public var assetIdentity: String {
    
    }
    
    /// 更新下载资源的结果
    public func updateDownloadStatusWithDownloadResult(_ succeed: Bool) {
    
    }
    
    /**
     * 获取 Asset 的体积（数据大小）
     */
//    func assetSize:(completion void (^)(long long size))completion
    
    public var duration: TimeInterval {
    
    }
}
