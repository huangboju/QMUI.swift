//
//  QMUIAssetsManager.swift
//  QMUI.swift
//
//  Created by 黄伯驹 on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

import Photos

class QMUIAssetsManager {
    static let shared = QMUIAssetsManager()
    
    private init() {}

    private var _phCachingImageManager: PHCachingImageManager?

    /// 获取一个 PHCachingImageManager 的实例
    var phCachingImageManager: PHCachingImageManager {
        if _phCachingImageManager == nil {
            _phCachingImageManager = PHCachingImageManager()
        }
        return _phCachingImageManager!
    }
}
