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
enum QMUIAlbumContentType: Int {
    case all // 展示所有资源（照片和视频）
    case onlyPhoto // 只展示照片
    case onlyVideo // 只展示视频
    case onlyAudio // 只展示音频
}

/// 相册展示内容按日期排序的方式
@objc enum QMUIAlbumSortType: Int {
    case positive = 0 // 日期最新的内容排在后面
    case reverse // 日期最新的内容排在前面
}

class QMUIAssetsGroup: NSObject {

    /// 仅能通过 initWithPHCollection 和 initWithPHCollection:fetchAssetsOption 方法修改 phAssetCollection 的值
    private(set) var phAssetCollection: PHAssetCollection!

    /// 仅能通过 initWithPHCollection 和 initWithPHCollection:fetchAssetsOption 方法修改 phAssetCollection 后，产生一个对应的 PHAssetsFetchResults 保存到 phFetchResult 中
    private(set) var phFetchResult: PHFetchResult<PHAsset>?

    init(phAssetCollection: PHAssetCollection, fetchAssetsOptions: PHFetchOptions? = nil) {
        let phFetchResult = PHAsset.fetchAssets(in: phAssetCollection, options: fetchAssetsOptions)
        self.phFetchResult = phFetchResult
        self.phAssetCollection = phAssetCollection
    }

    /// 相册的名称
    var name: String? {
        let resultName = phAssetCollection?.localizedTitle ?? ""
        return NSLocalizedString(resultName, comment: resultName)
    }

    /// 相册内的资源数量，包括视频、图片、音频（如果支持）这些类型的所有资源
    var numberOfAssets: Int {
        return phFetchResult?.count ?? 0
    }

    /**
     *  相册的缩略图，即系统接口中的相册海报（Poster Image）
     *
     *  @return 相册的缩略图
     */
    func posterImage(with size: CGSize) -> UIImage? {
        var resultImage: UIImage?
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
            QMUIAssetsManager.shared.phCachingImageManager.requestImage(for: asset, targetSize: CGSize(width: size.width * ScreenScale, height: size.height * ScreenScale), contentMode: .aspectFill, options: pHImageRequestOptions, resultHandler: { result, _ in
                resultImage = result
            })
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
    func enumerateAssets(withOptions albumSortType: QMUIAlbumSortType = .positive,
                         usingBlock enumerationBlock: ((_ resultAsset: QMUIAsset?) -> Void)?) {
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
         */
        enumerationBlock?(nil)
    }
}
