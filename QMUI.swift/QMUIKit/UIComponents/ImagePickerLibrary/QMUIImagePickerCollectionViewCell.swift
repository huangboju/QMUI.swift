//
//  QMUIImagePickerCollectionViewCell.swift
//  QMUI.swift
//
//  Created by 黄伯驹 on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

// checkbox 的 margin 默认值
let QMUIImagePickerCollectionViewCellDefaultCheckboxButtonMargins = UIEdgeInsets(top: 2, left: 0, bottom: 0, right: 2)
let QMUIImagePickerCollectionViewCellDefaultVideoMarkImageViewMargins = UIEdgeInsets(top: 0, left: 8, bottom: 8, right: 0)

/**
 *  图片选择空间里的九宫格 cell，支持显示 checkbox、饼状进度条及重试按钮（iCloud 图片需要）
 */
class QMUIImagePickerCollectionViewCell: UICollectionViewCell {
    /// checkbox 未被选中时显示的图片
    public var checkboxImage = QMUIHelper.image(name: "QMUI_pickerImage_checkbox") {
        didSet {
            if checkboxImage != oldValue {
                checkboxButton.setImage(checkboxImage, for: .normal)
                checkboxButton.sizeToFit()
            }
        }
    }

    /// checkbox 被选中时显示的图片
    public var checkboxCheckedImage = QMUIHelper.image(name: "QMUI_pickerImage_checkbox_checked") {
        didSet {
            if checkboxCheckedImage != oldValue {
                checkboxButton.setImage(checkboxCheckedImage, for: .selected)
                checkboxButton.setImage(checkboxCheckedImage, for: [.selected, .highlighted])
                checkboxButton.sizeToFit()
            }
        }
    }

    /// checkbox 的 margin，定位从每个 cell（即每张图片）的最右边开始计算
    public var checkboxButtonMargins = QMUIImagePickerCollectionViewCellDefaultCheckboxButtonMargins

    /// progressView tintColor
    public var progressViewTintColor = UIColorWhite {
        didSet {
            progressView.tintColor = progressViewTintColor
        }
    }

    /// downloadRetryButton 的 icon
    public var downloadRetryImage = QMUIHelper.image(name: "QMUI_icloud_download_fault_small") {
        didSet {
            if downloadRetryImage != oldValue {
                downloadRetryButton.setImage(downloadRetryImage, for: .normal)
            }
        }
    }

    /// videoMarkImageView 的 icon
    public var videoMarkImage = QMUIHelper.image(name: "QMUI_pickerImage_video_mark") {
        didSet {
            _videoMarkImageView?.image = videoMarkImage
            _videoMarkImageView?.sizeToFit()
        }
    }

    /// videoMarkImageView 的 margin，定位从每个 cell（即每张图片）的左下角开始计算
    public var videoMarkImageViewMargins = QMUIImagePickerCollectionViewCellDefaultVideoMarkImageViewMargins

    /// videoDurationLabel 的字号
    public var videoDurationLabelFont = UIFontMake(12) {
        didSet {
            _videoDurationLabel?.font = videoDurationLabelFont
            _videoDurationLabel?.qmui_calculateHeightAfterSetAppearance()
        }
    }

    /// videoDurationLabel 的字体颜色
    public var videoDurationLabelTextColor = UIColorWhite {
        didSet {
            if videoDurationLabelTextColor != oldValue {
                _videoDurationLabel?.textColor = videoDurationLabelTextColor
            }
        }
    }

    /// videoDurationLabel 布局是对齐右下角再做 margins 偏移
    public var videoDurationLabelMargins = UIEdgeInsets(top: 0, left: 0, bottom: 6, right: 6)

    public let contentImageView = UIImageView()

    public let checkboxButton = UIButton()

    public let progressView = QMUIPieProgressView()

    public let downloadRetryButton = UIButton()

    public var videoMarkImageView: UIImageView? {
        initVideoRelatedViewsIfNeeded()
        return _videoMarkImageView
    }

    private var _videoMarkImageView: UIImageView?

    public var videoDurationLabel: UILabel? {
        initVideoRelatedViewsIfNeeded()
        return _videoDurationLabel
    }

    private var _videoDurationLabel: UILabel?

    public var videoBottomShadowLayer: CAGradientLayer? {
        initVideoRelatedViewsIfNeeded()
        return _videoBottomShadowLayer
    }

    private var _videoBottomShadowLayer: CAGradientLayer?

    public var isEditing = false {
        didSet {
            if downloadStatus == .succeed {
                checkboxButton.isHidden = !isEditing
            }
        }
    }

    public var isChecked = false {
        didSet {
            if isEditing {
                checkboxButton.isSelected = isChecked
                QMUIImagePickerHelper.removeSpringAnimationOfImageChecked(with: checkboxButton)
                if isChecked {
                    QMUIImagePickerHelper.springAnimationOfImageChecked(with: checkboxButton)
                }
            }
        }
    }

    // Cell 中对应资源的下载状态，这个值的变动会相应地调整 UI 表现
    public var downloadStatus: QMUIAssetDownloadStatus = .failed {
        didSet {
            switch downloadStatus {
            case .succeed:
                if isEditing {
                    checkboxButton.isHidden = !isEditing
                }
                progressView.isHidden = true
                downloadRetryButton.isHidden = true
            case .downloading:
                checkboxButton.isHidden = true
                progressView.isHidden = false
                downloadRetryButton.isHidden = true
            case .canceled:
                checkboxButton.isHidden = false
                progressView.isHidden = true
                downloadRetryButton.isHidden = true
            case .failed:
                progressView.isHidden = true
                checkboxButton.isHidden = true
                downloadRetryButton.isHidden = false
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        initImagePickerCollectionViewCellUI()
    }

    private func initImagePickerCollectionViewCellUI() {
        contentImageView.contentMode = .scaleAspectFill
        contentImageView.clipsToBounds = true
        contentView.addSubview(contentImageView)

        checkboxButton.qmui_outsideEdge = UIEdgeInsets(top: -6, left: -6, bottom: -6, right: -6)
        checkboxButton.isHidden = true
        contentView.addSubview(checkboxButton)

        progressView.isHidden = true
        contentView.addSubview(progressView)

        downloadRetryButton.qmui_outsideEdge = UIEdgeInsets(top: -6, left: -6, bottom: -6, right: -6)
        downloadRetryButton.isHidden = true
        contentView.addSubview(downloadRetryButton)
    }

    private func initVideoBottomShadowLayerIfNeeded() {
        if _videoBottomShadowLayer == nil {
            _videoBottomShadowLayer = CAGradientLayer()
            _videoBottomShadowLayer?.qmui_removeDefaultAnimations()
            _videoBottomShadowLayer?.colors = [
                UIColorMake(0, 0, 0).cgColor,
                UIColorMakeWithRGBA(0, 0, 0, 0.6).cgColor,
            ]
            contentView.layer.addSublayer(_videoBottomShadowLayer!)
            setNeedsLayout()
        }
    }

    private func initVideoMarkImageViewIfNeed() {
        if _videoMarkImageView != nil {
            return
        }
        _videoMarkImageView = UIImageView()
        _videoMarkImageView?.image = videoMarkImage
        _videoMarkImageView?.sizeToFit()
        contentView.addSubview(_videoMarkImageView!)
        setNeedsLayout()
    }

    private func initVideoDurationLabelIfNeed() {
        if _videoDurationLabel != nil {
            return
        }
        _videoDurationLabel = UILabel()
        _videoDurationLabel?.font = videoDurationLabelFont
        _videoDurationLabel?.textColor = videoDurationLabelTextColor
        contentView.addSubview(_videoDurationLabel!)

        setNeedsLayout()
    }

    private func initVideoRelatedViewsIfNeeded() {
        initVideoBottomShadowLayerIfNeeded()
        initVideoMarkImageViewIfNeed()
        initVideoDurationLabelIfNeed()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        contentImageView.frame = contentView.bounds
        if isEditing {
            checkboxButton.frame = checkboxButton.frame.setXY(contentView.bounds.width - checkboxButtonMargins.right - checkboxButton.frame.width,
                                                              checkboxButtonMargins.top).flatted
        }

        /* 理论上 downloadRetryButton 应该在 setImage 后 sizeToFit 计算大小，
         * 但因为当图片小于某个高度时， UIButton sizeToFit 时会自动改写 height 值，
         * 因此，这里 downloadRetryButton 直接拿 downloadRetryButton 的 image 图片尺寸作为 frame size
         */
        let downloadRetryImageSize = downloadRetryImage?.size ?? .zero
        downloadRetryButton.frame = CGRect(x: contentView.bounds.width - checkboxButtonMargins.right - downloadRetryImageSize.width,
                                           y: checkboxButtonMargins.top,
                                           width: downloadRetryImageSize.width,
                                           height: downloadRetryImageSize.height).flatted
        progressView.frame = CGRect(x: downloadRetryButton.frame.minX,
                                    y: downloadRetryButton.frame.minY + downloadRetryButton.contentEdgeInsets.top,
                                    width: downloadRetryButton.frame.width,
                                    height: downloadRetryButton.frame.height)

        guard let _videoBottomShadowLayer = _videoBottomShadowLayer,
            let _videoMarkImageView = _videoMarkImageView,
            let _videoDurationLabel = _videoDurationLabel else {
            return
        }

        _videoMarkImageView.frame = _videoMarkImageView.frame.setXY(videoMarkImageViewMargins.left, contentView.bounds.height - _videoMarkImageView.frame.height - videoMarkImageViewMargins.bottom).flatted

        _videoDurationLabel.sizeToFit()
        let minX = contentView.bounds.width - videoDurationLabelMargins.right - _videoDurationLabel.frame.width
        let minY = contentView.bounds.height - videoDurationLabelMargins.bottom - _videoDurationLabel.frame.height

        _videoDurationLabel.frame = _videoDurationLabel.frame.setXY(minX, minY).flatted

        let videoBottomShadowLayerHeight = contentView.bounds.height - _videoMarkImageView.frame.minY + videoMarkImageViewMargins.bottom // 背景阴影遮罩的高度取决于（视频 icon 的高度 + 上下 margin）
        _videoBottomShadowLayer.frame = CGRect(x: 0,
                                               y: contentView.bounds.height - videoBottomShadowLayerHeight,
                                               width: contentView.bounds.width,
                                               height: videoBottomShadowLayerHeight)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
