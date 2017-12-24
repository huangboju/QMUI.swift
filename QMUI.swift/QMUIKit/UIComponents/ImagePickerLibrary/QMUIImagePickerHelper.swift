//
//  QMUIImagePickerHelper.swift
//  QMUI.swift
//
//  Created by 黄伯驹 on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

import AssetsLibrary
import Photos

let kLastAlbumKeyPrefix = "QMUILastAlbumKeyWith"
let kContentTypeOfLastAlbumKeyPrefix = "QMUIContentTypeOfLastAlbumKeyWith"

/**
 *  配合 QMUIImagePickerViewController 使用的工具类
 */
struct QMUIImagePickerHelper {
    /**
     *  判断一个由 QMUIAsset 对象组成的数组中是否包含特定的 QMUIAsset 对象
     *
     *  @param imageAssetArray  一个由 QMUIAsset 对象组成的数组
     *  @param targetImageAsset 需要被判断的 QMUIAsset 对象
     *
     */
    public static func imageAssetArray(_ imageAssetArray: [QMUIAsset], containsImageAsset targetImageAsset: QMUIAsset) -> Bool {
        let targetAssetIdentify = targetImageAsset.assetIdentity
        for imageAsset in imageAssetArray {
            if imageAsset.assetIdentity == targetAssetIdentify {
                return true
            }
        }
        return false
    }
    
    /**
     *  从一个由 QMUIAsset 对象组成的数组中移除特定的 QMUIAsset 对象（如果这个 QMUIAsset 对象不在该数组中，则不作处理）
     *
     *  @param imageAssetArray  一个由 QMUIAsset 对象组成的数组
     *  @param targetImageAsset 需要被移除的 QMUIAsset 对象
     */
    public static func imageAssetArray(_ imageAssetArray: inout [QMUIAsset], removeImageAsset targetImageAsset: QMUIAsset) {
        let targetAssetIdentify = targetImageAsset.assetIdentity
        for imageAsset in imageAssetArray {
            guard imageAsset.assetIdentity == targetAssetIdentify else { continue }
            imageAssetArray.remove(object: imageAsset)
            break
        }
    }

    /**
     *  选中图片数量改变时，展示图片数量的 Label 的动画，动画过程如下：
     *  Label 背景色改为透明，同时产生一个与背景颜色和形状、大小都相同的图形置于 Label 底下，做先缩小再放大的 spring 动画
     *  动画结束后移除该图形，并恢复 Label 的背景色
     *
     *  @warning iOS6 下降级处理不调用动画效果
     *
     *  @param label 需要做动画的 UILabel
     */
    public static func springAnimationOfImageSelectedCountChangeWithCountLabel(_ label: UILabel) {
        QMUIHelper.actionSpringAnimation(for: label)
    }
    
    /**
     *  图片 checkBox 被选中时的动画
     *  @warning iOS6 下降级处理不调用动画效果
     *
     *  @param button 需要做动画的 checkbox 按钮
     */
    public static func springAnimationOfImageChecked(with button: UIButton) {
        QMUIHelper.actionSpringAnimation(for: button)
    }

    /**
     * 搭配<i>springAnimationOfImageCheckedWithCheckboxButton:</i>一起使用，添加animation之前建议先remove
     */
    public static func removeSpringAnimationOfImageChecked(with button: UIButton) {
        button.layer.removeAnimation(forKey: QMUISpringAnimationKey)
    }
    
    
    /**
     *  获取最近一次调用 updateLastAlbumWithAssetsGroup 方法调用时储存的 QMUIAssetsGroup 对象
     *
     *  @param userIdentify 用户标识，由于每个用户可能需要分开储存一个最近调用过的 QMUIAssetsGroup，因此增加一个标识区分用户。
     *  一个常见的应用场景是选择图片时保存图片所在相册的对应的 QMUIAssetsGroup，并使用用户的 user id 作为区分不同用户的标识，
     *  当用户再次选择图片时可以根据已经保存的 QMUIAssetsGroup 直接进入上次使用过的相册。
     */
    public static func assetsGroupOfLastestPickerAlbum(with userIdentify: String) -> QMUIAssetsGroup? {
        // 获取 NSUserDefaults，里面储存了所有 updateLastestAlbumWithAssetsGroup 的结果
        let userDefaults = UserDefaults.standard
        // 使用特定的前缀和可以标记不同用户的字符串拼接成 key，用于获取当前用户最近调用 updateLastestAlbumWithAssetsGroup 储存的相册以及对于的 QMUIAlbumContentType 值
        
        let lastAlbumKey = kLastAlbumKeyPrefix + userIdentify
        let contentTypeOflastAlbumKey = kContentTypeOfLastAlbumKeyPrefix + userIdentify
        
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
                    phFetchOptions = PHPhotoLibrary.createFetchOptionsWithAlbumContentType(type)
                }

                let phAssetCollection = phFetchResult[0]
                assetsGroup = QMUIAssetsGroup(phAssetCollection: phAssetCollection, fetchAssetsOptions: phFetchOptions)
            }
        } else {
            print("Group For localIdentifier is not found!")
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
    public static func updateLastestAlbum(with assetsGroup: QMUIAssetsGroup, albumContentType:QMUIAlbumContentType, userIdentify: String) {
        let userDefaults = UserDefaults .standard
        // 使用特定的前缀和可以标记不同用户的字符串拼接成 key，用于为当前用户储存相册对应的 QMUIAssetsGroup 与 QMUIAlbumContentType

        let lastAlbumKey = kLastAlbumKeyPrefix + userIdentify
        let contentTypeOflastAlbumKey = kContentTypeOfLastAlbumKeyPrefix + userIdentify
        if let group = assetsGroup.alAssetsGroup {
            let url = group.value(forProperty: ALAssetsGroupPropertyURL) as? URL
            userDefaults.set(url, forKey: lastAlbumKey)
        } else {
            // 使用 PhotoKit
            userDefaults.setValue(assetsGroup.phAssetCollection?.localIdentifier , forKey: lastAlbumKey)
        }

        userDefaults.set(albumContentType.rawValue, forKey: contentTypeOflastAlbumKey)

        userDefaults.synchronize()
    }
}
