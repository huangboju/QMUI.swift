//
//  QMUIImagePickerCollectionViewCell.swift
//  QMUI.swift
//
//  Created by 黄伯驹 on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

// checkbox 的 margin 默认值
let QMUIImagePickerCollectionViewCellDefaultCheckboxButtonMargins = UIEdgeInsets(top: 6, left: 0, bottom: 0, right: 6)
private let QMUIImagePickerCollectionViewCellDefaultVideoMarkImageViewMargins = UIEdgeInsets(top: 0, left: 8, bottom: 8, right: 0)

/**
 *  图片选择空间里的九宫格 cell，支持显示 checkbox、饼状进度条及重试按钮（iCloud 图片需要）
 */
class QMUIImagePickerCollectionViewCell: UICollectionViewCell {
    /// checkbox 未被选中时显示的图片
    var checkboxImage: UIImage! {
        didSet {
            if checkboxImage != oldValue {
                checkboxButton.setImage(checkboxImage, for: .normal)
                checkboxButton.sizeToFit()
            }
        }
    }

    /// checkbox 被选中时显示的图片
    var checkboxCheckedImage: UIImage! {
        didSet {
            if checkboxCheckedImage != oldValue {
                checkboxButton.setImage(checkboxCheckedImage, for: .selected)
                checkboxButton.setImage(checkboxCheckedImage, for: [.selected, .highlighted])
                checkboxButton.sizeToFit()
            }
        }
    }

    /// checkbox 的 margin，定位从每个 cell（即每张图片）的最右边开始计算
    var checkboxButtonMargins = QMUIImagePickerCollectionViewCellDefaultCheckboxButtonMargins

    /// videoMarkImageView 的 icon
    var videoMarkImage: UIImage! = QMUIHelper.image(name: "QMUI_pickerImage_video_mark") {
        didSet {
            if videoMarkImage != oldValue {
                videoMarkImageView?.image = videoMarkImage
                videoMarkImageView?.sizeToFit()
            }
        }
    }

    /// videoMarkImageView 的 margin，定位从每个 cell（即每张图片）的左下角开始计算
    var videoMarkImageViewMargins: UIEdgeInsets = QMUIImagePickerCollectionViewCellDefaultVideoMarkImageViewMargins

    /// videoDurationLabel 的字号
    var videoDurationLabelFont: UIFont = UIFontMake(12) {
        didSet {
            if videoDurationLabelFont != oldValue {
                videoDurationLabel?.font = videoDurationLabelFont
                videoDurationLabel?.qmui_calculateHeightAfterSetAppearance()
            }
        }
    }

    /// videoDurationLabel 的字体颜色
    var videoDurationLabelTextColor: UIColor = UIColorWhite {
        didSet {
            if videoDurationLabelTextColor != oldValue {
                videoDurationLabel?.textColor = videoDurationLabelTextColor
            }
        }
    }

    /// videoDurationLabel 布局是对齐右下角再做 margins 偏移
    var videoDurationLabelMargins: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 6, right: 6)

    private(set) var contentImageView: UIImageView!

    private(set) var checkboxButton: UIButton!

    private var _videoMarkImageView: UIImageView?
    var videoMarkImageView: UIImageView? {
        initVideoRelatedViewsIfNeeded()
        return _videoMarkImageView
    }
    
    private var _videoDurationLabel: UILabel?
    var videoDurationLabel: UILabel? {
        initVideoRelatedViewsIfNeeded()
        return _videoDurationLabel
    }

    private var _videoBottomShadowLayer: CAGradientLayer?
    var videoBottomShadowLayer: CAGradientLayer? {
        initVideoRelatedViewsIfNeeded()
        return _videoBottomShadowLayer
    }
    
    
    var isSelectable: Bool = false {
        didSet {
            if downloadStatus == .succeed {
                checkboxButton.isHidden = !isSelectable
            }
        }
    }

    var isChecked: Bool = false {
        didSet {
            if isSelectable {
                checkboxButton.isSelected = isChecked
                QMUIImagePickerHelper.removeSpringAnimationOfImageChecked(with: checkboxButton)
                if isChecked {
                    QMUIImagePickerHelper.springAnimationOfImageChecked(with: checkboxButton)
                }
            }
        }
    }

    // Cell 中对应资源的下载状态，这个值的变动会相应地调整 UI 表现
    var downloadStatus: QMUIAssetDownloadStatus = .succeed {
        didSet {
            if isSelectable {
                checkboxButton.isHidden = !isSelectable
            }
        }
    }
    
    var assetIdentifier: String? // 当前这个 cell 正在展示的 QMUIAsset 的 identifier

    override init(frame: CGRect) {
        super.init(frame: frame)

        initImagePickerCollectionViewCellUI()
    }

    private func initImagePickerCollectionViewCellUI() {
        contentImageView = UIImageView()
        contentImageView.contentMode = .scaleAspectFill
        contentImageView.clipsToBounds = true
        contentView.addSubview(contentImageView)

        checkboxButton = QMUIButton()
        checkboxButton.qmui_automaticallyAdjustTouchHighlightedInScrollView = true
        checkboxButton.qmui_outsideEdge = UIEdgeInsets(top: -6, left: -6, bottom: -6, right: -6)
        checkboxButton.isHidden = true
        contentView.addSubview(checkboxButton)
        
        checkboxImage = QMUIHelper.image(name: "QMUI_pickerImage_checkbox")
        checkboxCheckedImage = QMUIHelper.image(name: "QMUI_pickerImage_checkbox_checked")
    }

    private func initVideoBottomShadowLayerIfNeeded() {
        if _videoBottomShadowLayer == nil {
            _videoBottomShadowLayer = CAGradientLayer()
            _videoBottomShadowLayer!.qmui_removeDefaultAnimations()
            _videoBottomShadowLayer!.colors = [
                UIColor(r: 0, g: 0, b: 0).cgColor,
                UIColor(r: 0, g: 0, b: 0, a: 0.6).cgColor,
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
        if isSelectable {
            checkboxButton.frame = checkboxButton.frame.setXY(contentView.bounds.width - checkboxButtonMargins.right - checkboxButton.frame.width,
                                                              checkboxButtonMargins.top)
        }

        if let videoBottomShadowLayer = _videoBottomShadowLayer, let videoMarkImageView = _videoMarkImageView, let videoDurationLabel = _videoDurationLabel {
            videoMarkImageView.frame = videoMarkImageView.frame.setXY(videoMarkImageViewMargins.left, contentView.bounds.height - videoMarkImageView.bounds.height - videoMarkImageViewMargins.bottom)
            
            videoDurationLabel.sizeToFit()
            let minX = contentView.bounds.width - videoDurationLabelMargins.right - videoDurationLabel.bounds.width
            let minY = contentView.bounds.height - videoDurationLabelMargins.bottom - videoDurationLabel.bounds.height
            videoDurationLabel.frame = videoDurationLabel.frame.setXY(minX, minY)
            
            let videoBottomShadowLayerHeight = contentView.bounds.height - videoMarkImageView.frame.minY + videoMarkImageViewMargins.bottom // 背景阴影遮罩的高度取决于（视频 icon 的高度 + 上下 margin）
            videoBottomShadowLayer.frame = CGRectFlat(0, contentView.bounds.height - videoBottomShadowLayerHeight, contentView.bounds.width, videoBottomShadowLayerHeight)
        }
        
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
