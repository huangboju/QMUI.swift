//
//  QMUIAssetsGroup.swift
//  QMUI.swift
//
//  Created by 黄伯驹 on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

import AssetsLibrary
import Photos

/// 相册展示内容的类型
enum QMUIAlbumContentType {
    case all                                  // 展示所有资源（照片和视频）
    case onlyPhoto                            // 只展示照片
    case onlyVideo                            // 只展示视频
    case onlyAudio                            // 只展示音频
}

/// 相册展示内容按日期排序的方式
enum QMUIAlbumSortType {
    case positive   // 日期最新的内容排在后面
    case reverse    // 日期最新的内容排在前面
}

class QMUIAssetsGroup {
    /// 仅能通过 initWithALAssetsGroup 方法修改 alAssetsGroup 的值
    private(set) var alAssetsGroup: ALAssetsGroup?

    /// 仅能通过 initWithPHCollection 和 initWithPHCollection:fetchAssetsOption 方法修改 phAssetCollection 的值
    private(set) var phAssetCollection: PHAssetCollection?

    /// 仅能通过 initWithPHCollection 和 initWithPHCollection:fetchAssetsOption 方法修改 phAssetCollection 后，产生一个对应的 PHAssetsFetchResults 保存到 phFetchResult 中
    private(set) var phFetchResult: PHFetchResult<PHAsset>?

    private var usePhotoKit = false

    public init(alAssetsGroup: ALAssetsGroup) {
        self.alAssetsGroup = alAssetsGroup
    }

    public init(phAssetCollection: PHAssetCollection, fetchAssetsOptions: PHFetchOptions? = nil) {
        
        let phFetchResult = PHAsset.fetchAssets(in: phAssetCollection, options: fetchAssetsOptions)
        self.phFetchResult = phFetchResult
        self.phAssetCollection = phAssetCollection
        usePhotoKit = true
    }

    /// 相册的名称
    public var name: String? {
        let resultName: String?
        if usePhotoKit {
            resultName = phAssetCollection?.localizedTitle
        } else {
            resultName = alAssetsGroup?.value(forProperty: ALAssetsGroupPropertyName) as? String
        }
        guard let tmp = resultName else {
            return nil
        }
        return NSLocalizedString(tmp, comment: tmp)
    }

    /// 相册内的资源数量，包括视频、图片、音频（如果支持）这些类型的所有资源
    public var numberOfAssets: Int {
        return (usePhotoKit ? phFetchResult?.count : alAssetsGroup?.numberOfAssets()) ?? 0
    }

    /**
     *  相册的缩略图，即系统接口中的相册海报（Poster Image）
     *
     *  @param size 缩略图的 size，仅在 iOS 8.0 及以上的版本有效，其他版本则调用 ALAsset 的接口由系统返回一个固定大小的缩略图
     *
     *  @return 相册的缩略图
     */
    public func posterImage(with size: CGSize) -> UIImage? {
        var resultImage: UIImage?
        if usePhotoKit {
            guard let phFetchResult = phFetchResult else {
                return nil
            }
            let count = phFetchResult.count
            if count > 0 {
                let asset = phFetchResult[count - 1]
                let pHImageRequestOptions = PHImageRequestOptions()
                pHImageRequestOptions.isSynchronous = true // 同步请求
                pHImageRequestOptions.resizeMode = .exact
                // targetSize 中对传入的 Size 进行处理，宽高各自乘以 ScreenScale，从而得到正确的图片
                QMUIAssetsManager.shared.phCachingImageManager.requestImage(for: asset, targetSize: CGSize(width: size.width * ScreenScale, height: size.height * ScreenScale), contentMode: .aspectFill, options: pHImageRequestOptions, resultHandler: { (result, info) in
                    resultImage = result
                })
            }
        } else {
            guard let posterImageRef = alAssetsGroup?.posterImage().takeUnretainedValue() else {
                return nil
            }
            resultImage = UIImage(cgImage: posterImageRef)
        }
        return resultImage
    }

    /**
     *  枚举相册内所有的资源
     *
     *  @param albumSortType    相册内资源的排序方式，可以选择日期最新的排在最前面，也可以选择日期最新的排在最后面
     *  @param enumerationBlock 枚举相册内资源时调用的 block，参数 result 表示每次枚举时对应的资源。
     *                          枚举所有资源结束后，enumerationBlock 会被再调用一次，这时 result 的值为 nil。
     *                          可以以此作为判断枚举结束的标记
     */
    public func enumerateAssetsWithOptions(_ albumSortType: QMUIAlbumSortType = .positive, usingBlock enumerationBlock: ((_ resultAsset: QMUIAsset?) -> Void)?) {
        if usePhotoKit {
            guard let phFetchResult = phFetchResult else {
                return
            }
            let range = 0 ..< phFetchResult.count
            if albumSortType == .reverse {
                for i in range.reversed() {
                    let pHAsset = phFetchResult[i]
                    let asset = QMUIAsset(phAsset: pHAsset)
                    enumerationBlock?(asset)
                }
            } else {
                for i in range {
                    let pHAsset = phFetchResult[i]
                    let asset = QMUIAsset(phAsset: pHAsset)
                    enumerationBlock?(asset)
                }
            }
            /**
             *  For 循环遍历完毕，这时再调用一次 enumerationBlock，并传递 nil 作为实参，作为枚举资源结束的标记。
             *  该处理方式也是参照系统 ALAssetGroup 枚举结束的处理。
             */
            enumerationBlock?(nil)
        } else {
            let enumerationOptions: NSEnumerationOptions
            if albumSortType == .reverse {
                enumerationOptions = .reverse
            } else {
                enumerationOptions = .concurrent
            }
            alAssetsGroup?.enumerateAssets(options: enumerationOptions, using: { (result, index, stop) in
                if let result = result {
                    let asset = QMUIAsset(alAsset: result)
                    enumerationBlock?(asset)
                } else {
                    /**
                     *  ALAssetGroup 枚举结束。
                     *  与上面 PHAssetsFetchResults 相似，再调用一次 enumerationBlock，并传递 nil 作为实参，作为枚举资源结束的标记。
                     *  与 ALAssetGroup 本身处理枚举结束的方式保持一致。
                     */
                    enumerationBlock?(nil)
                }
            })
        }
    }
}
