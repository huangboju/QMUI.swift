//
//  QMUIImagePickerHelper.swift
//  QMUI.swift
//
//  Created by 黄伯驹 on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

import AssetsLibrary
import Photos

private let kLastAlbumKeyPrefix = "QMUILastAlbumKeyWith"
private let kContentTypeOfLastAlbumKeyPrefix = "QMUIContentTypeOfLastAlbumKeyWith"

/**
 *  配合 QMUIImagePickerViewController 使用的工具类
 */
struct QMUIImagePickerHelper {

    /**
     *  选中图片数量改变时，展示图片数量的 Label 的动画，动画过程如下：
     *  Label 背景色改为透明，同时产生一个与背景颜色和形状、大小都相同的图形置于 Label 底下，做先缩小再放大的 spring 动画
     *  动画结束后移除该图形，并恢复 Label 的背景色
     *
     *  @warning iOS6 下降级处理不调用动画效果
     *
     *  @param label 需要做动画的 UILabel
     */
    static func springAnimationOfImageSelectedCountChange(with label: UILabel) {
        QMUIHelper.actionSpringAnimation(for: label)
    }

    /**
     *  图片 checkBox 被选中时的动画
     *  @warning iOS6 下降级处理不调用动画效果
     *
     *  @param button 需要做动画的 checkbox 按钮
     */
    static func springAnimationOfImageChecked(with button: UIButton) {
        QMUIHelper.actionSpringAnimation(for: button)
    }

    /**
     * 搭配<i>springAnimationOfImageCheckedWithCheckboxButton:</i>一起使用，添加animation之前建议先remove
     */
    static func removeSpringAnimationOfImageChecked(with button: UIButton) {
        button.layer.removeAnimation(forKey: QMUISpringAnimationKey)
    }

    /**
     *  获取最近一次调用 updateLastAlbumWithAssetsGroup 方法调用时储存的 QMUIAssetsGroup 对象
     *
     *  @param userIdentify 用户标识，由于每个用户可能需要分开储存一个最近调用过的 QMUIAssetsGroup，因此增加一个标识区分用户。
     *  一个常见的应用场景是选择图片时保存图片所在相册的对应的 QMUIAssetsGroup，并使用用户的 user id 作为区分不同用户的标识，
     *  当用户再次选择图片时可以根据已经保存的 QMUIAssetsGroup 直接进入上次使用过的相册。
     */
    static func assetsGroupOfLastPickerAlbum(with userIdentify: String?) -> QMUIAssetsGroup? {
        // 获取 NSUserDefaults，里面储存了所有 updateLastestAlbumWithAssetsGroup 的结果
        let userDefaults = UserDefaults.standard
        // 使用特定的前缀和可以标记不同用户的字符串拼接成 key，用于获取当前用户最近调用 updateLastestAlbumWithAssetsGroup 储存的相册以及对于的 QMUIAlbumContentType 值

        let lastAlbumKey = kLastAlbumKeyPrefix + (userIdentify ?? "")
        let contentTypeOflastAlbumKey = kContentTypeOfLastAlbumKeyPrefix + (userIdentify ?? "")

        var assetsGroup: QMUIAssetsGroup?

        let albumContentType = QMUIAlbumContentType(rawValue: userDefaults.integer(forKey: contentTypeOflastAlbumKey))

        let groupIdentifier = userDefaults.value(forKey: lastAlbumKey) as? String
        /**
         *  如果获取到的 PHAssetCollection localIdentifier 不为空，则获取该 URL 对应的相册。
         *  用户升级设备的系统后，这里会从原来的 AssetsLibrary 改为用 PhotoKit，
         *  因此原来储存的 groupIdentifier 实际上会是一个 NSURL 而不是我们需要的 NSString。
         *  所以这里还需要判断一下实际拿到的数据的类型是否为 NSString，如果是才继续进行。
         */
        if let groupIdentifier = groupIdentifier {
            let phFetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [groupIdentifier], options: nil)
            if phFetchResult.count > 0 {
                // 创建一个 PHFetchOptions，用于对内容类型进行控制
                var phFetchOptions: PHFetchOptions?
                // 旧版本中没有存储 albumContentType，因此为了防止 crash，这里做一下判断
                if let type = albumContentType {
                    phFetchOptions = PHPhotoLibrary.createFetchOptions(withAlbumContentType: type)
                }

                let phAssetCollection = phFetchResult[0]
                assetsGroup = QMUIAssetsGroup(phAssetCollection: phAssetCollection, fetchAssetsOptions: phFetchOptions)
            }
        } else {
            print("QMUIImagePickerLibrary: Group For localIdentifier is not found! groupIdentifier is \(String(describing: groupIdentifier))")
        }
        return assetsGroup
    }

    /**
     *  储存一个 QMUIAssetsGroup，从而储存一个对应的相册，与 assetsGroupOfLatestPickerAlbumWithUserIdentify 方法对应使用
     *
     *  @param assetsGroup   要被储存的 QMUIAssetsGroup
     *  @param albumContentType 相册的内容类型
     *  @param userIdentify 用户标识，由于每个用户可能需要分开储存一个最近调用过的 QMUIAssetsGroup，因此增加一个标识区分用户
     */
    static func updateLastestAlbum(with assetsGroup: QMUIAssetsGroup, albumContentType: QMUIAlbumContentType, userIdentify: String?) {
        let userDefaults = UserDefaults.standard
        // 使用特定的前缀和可以标记不同用户的字符串拼接成 key，用于为当前用户储存相册对应的 QMUIAssetsGroup 与 QMUIAlbumContentType

        let lastAlbumKey = kLastAlbumKeyPrefix + (userIdentify ?? "")
        let contentTypeOflastAlbumKey = kContentTypeOfLastAlbumKeyPrefix + (userIdentify ?? "")
        
        userDefaults.setValue(assetsGroup.phAssetCollection?.localIdentifier, forKey: lastAlbumKey)
        userDefaults.set(albumContentType.rawValue, forKey: contentTypeOflastAlbumKey)
        userDefaults.synchronize()
    }
    
    /**
     * 检测一组资源是否全部下载成功，如果有资源仍未从 iCloud 中下载成功，则返回 NO
     *
     * 可以用于选择图片后，业务需要自行处理 iCloud 下载的场景。
     */
    static func imageAssetsDownloaded(imagesAssetArray: [QMUIAsset]) -> Bool {
        for asset in imagesAssetArray {
            if asset.downloadStatus != .succeed {
                return false
            }
        }
        return true
    }
    
    /**
     * 检测资源是否已经在本地，如果资源仍未从 iCloud 中成功下载，则会发出请求从 iCloud 加载资源，并通过多次调用 block 返回请求结果
     *
     * 可以用于选择图片后，业务需要自行处理 iCloud 下载的场景。
     */
    static func requestImageAssetIfNeeded(asset: QMUIAsset, completion: ((QMUIAssetDownloadStatus, NSError?) -> Void)?) {
        if asset.downloadStatus != .succeed {
            // 资源加载中
            completion?(.downloading, nil)
            
            asset.requestOriginImage(with: { (result, info) in
                let cancel = info?[PHImageCancelledKey] as? Bool ?? false//排除取消
                let error = info?[PHImageErrorKey] as? Bool ?? false//排除错误
                let resultIsDegraded = info?[PHImageResultIsDegradedKey] as? Bool ?? false
                let downloadSucceed = (result != nil && info == nil) || (!cancel && !error && !resultIsDegraded)
                if downloadSucceed {
                    // 资源资源已经在本地或下载成功
                    asset.updateDownloadStatus(withDownloadResult: true)
                    
                    completion?(.succeed, nil)
                } else {
                    // 下载错误
                    asset.updateDownloadStatus(withDownloadResult: false)
                    
                    completion?(.failed, info![PHImageErrorKey] as? NSError)
                }
            }) { (progress, error, stop, info) in
                print("QMUIImagePickerLibrary: current progress is \(progress)")
                asset.downloadProgress = progress
            }
        } else {
            // 资源资源已经在本地或下载成功
            completion?(.succeed, nil)
        }
        
    }
}
