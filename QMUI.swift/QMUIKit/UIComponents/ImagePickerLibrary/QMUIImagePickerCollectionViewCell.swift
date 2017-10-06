//
//  QMUIImagePickerCollectionViewCell.swift
//  QMUI.swift
//
//  Created by 黄伯驹 on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

class QMUIImagePickerCollectionViewCell: UICollectionViewCell {
    public private(set) var checkboxButton = UIButton()
    public private(set) var progressView = QMUIPieProgressView()
    public private(set) var downloadRetryButton = UIButton()
    public private(set) var videoDurationLabel = UILabel()
    public private(set) var contentImageView = UIImageView()

    public var isEditing = false
    public var isChecked = false
    public var downloadStatus: QMUIAssetDownloadStatus = .failed // Cell 中对应资源的下载状态，这个值的变动会相应地调整 UI 表现
}
