//
//  QMUIImagePreviewView.swift
//  QMUI.swift
//
//  Created by 黄伯驹 on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

@objc enum QMUIImagePreviewMediaType: UInt {
    case image = 0
    case livePhoto
    case video
    case others
}

@objc protocol QMUIImagePreviewViewDelegate: QMUIZoomImageViewDelegate {

    @objc func numberOfImages(in imagePreviewView: QMUIImagePreviewView) -> Int
    @objc func imagePreviewView(_ imagePreviewView: QMUIImagePreviewView, renderZoomImageView zoomImageView: QMUIZoomImageView, at index: Int)

    // 返回要展示的媒体资源的类型（图片、live photo、视频），如果不实现此方法，则 QMUIImagePreviewView 将无法选择最合适的 cell 来复用从而略微增大系统开销
    @objc optional func imagePreviewView(_ imagePreviewView: QMUIImagePreviewView, assetTypeAt index: Int) -> QMUIImagePreviewMediaType

    /**
     *  当左右的滚动停止时会触发这个方法
     *  @param  imagePreviewView 当前预览的 QMUIImagePreviewView
     *  @param  index 当前滚动到的图片所在的索引
     */
    @objc optional func imagePreviewView(_ imagePreviewView: QMUIImagePreviewView, didScrollToIndex: Int)

    /**
     *  在滚动过程中，如果某一张图片的边缘（左/右）经过预览控件的中心点时，就会触发这个方法
     *  @param  imagePreviewView 当前预览的 QMUIImagePreviewView
     *  @param  index 当前滚动到的图片所在的索引
     */
    @objc optional func imagePreviewView(_ imagePreviewView: QMUIImagePreviewView, willScrollHalfTo index: Int)
}

/**
 *  查看图片的控件，支持横向滚动、放大缩小、loading 及错误语展示，内部使用 UICollectionView 实现横向滚动及 cell 复用，因此与其他普通的 UICollectionView 一样，也可使用 reloadData、collectionViewLayout 等常用方法。
 *
 *  使用方式：
 *
 *  1. 使用 initWithFrame: 或 init 方法初始化。
 *  2. 设置 delegate。
 *  3. 在 delegate 的 numberOfImagesInImagePreviewView: 方法里返回图片总数。
 *  4. 在 delegate 的 imagePreviewView:renderZoomImageView:atIndex: 方法里为 zoomImageView.image 设置图片，如果需要，也可调用 [zoomImageView showLoading] 等方法来显示 loading。
 *  5. 由于 QMUIImagePreviewViewDelegate 继承自 QMUIZoomImageViewDelegate，所以若需要响应单击、双击、长按事件，请实现 QMUIZoomImageViewDelegate 里的对应方法。
 *  6. 若需要从指定的某一张图片开始查看，可使用 currentImageIndex 属性。
 *
 *  @see QMUIImagePreviewViewController
 */
class QMUIImagePreviewView: UIView {
    weak var delegate: QMUIImagePreviewViewDelegate?

    private(set) var collectionView: UICollectionView!
    private(set) var collectionViewLayout: QMUICollectionViewPagingLayout!

    /// 获取当前正在查看的图片 index，也可强制将图片滚动到指定的 index
    var currentImageIndex: Int {
        set {
            set(currentImageIndex: newValue)
        }
        get {
            return _currentImageIndex
        }
    }

    private var _currentImageIndex = 0

    /// 每一页里的 loading 的颜色，默认为 UIColorWhite
    var loadingColor: UIColor? = UIColorWhite {
        didSet {
            let isLoadingColorChanged = loadingColor != nil && loadingColor != oldValue
            if isLoadingColorChanged {
                collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
            }
        }
    }

    private var isChangingCollectionViewBounds = false
    private var previousIndexWhenScrolling: CGFloat = 0

    private let kLivePhotoCellIdentifier = "livephoto"
    private let kVideoCellIdentifier = "video"
    private let kImageOrUnknownCellIdentifier = "imageorunknown"

    override init(frame: CGRect) {
        super.init(frame: frame)
        didInitialized(with: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        didInitialized(with: .zero)
    }

    private func didInitialized(with frame: CGRect) {
        collectionViewLayout = QMUICollectionViewPagingLayout(with: .default)
        collectionViewLayout.allowsMultipleItemScroll = false

        collectionView = UICollectionView(frame: frame.size.rect, collectionViewLayout: collectionViewLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColorClear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.scrollsToTop = false
        collectionView.delaysContentTouches = false
        collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        if #available(iOS 11, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        collectionView.register(QMUIImagePreviewCell.self, forCellWithReuseIdentifier: kImageOrUnknownCellIdentifier)
        collectionView.register(QMUIImagePreviewCell.self, forCellWithReuseIdentifier: kVideoCellIdentifier)
        collectionView.register(QMUIImagePreviewCell.self, forCellWithReuseIdentifier: kLivePhotoCellIdentifier)

        addSubview(collectionView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let isCollectionViewSizeChanged = collectionView.bounds.size != bounds.size
        if isCollectionViewSizeChanged {
            isChangingCollectionViewBounds = true

            // 必须先 invalidateLayout，再更新 collectionView.frame，否则横竖屏旋转前后的图片不一致（因为 scrollViewDidScroll: 时 contentSize、contentOffset 那些是错的）
            collectionViewLayout.invalidateLayout()
            collectionView.frame = bounds
            collectionView.scrollToItem(at: IndexPath(row: currentImageIndex, section: 0), at: .centeredHorizontally, animated: false)

            isChangingCollectionViewBounds = false
        }
    }

    func set(currentImageIndex: Int, animated: Bool = false) {
        _currentImageIndex = currentImageIndex
        collectionView.reloadData()

        if currentImageIndex < collectionView.numberOfItems(inSection: 0) {
            collectionView.scrollToItem(at: IndexPath(row: currentImageIndex, section: 0), at: .centeredHorizontally, animated: animated)
        } else {
            // dataSource 里的图片数量和当前 View 层的图片数量不匹配
            print("\(type(of: self)) \(#function)，collectionView.numberOfItems = \(collectionView.numberOfItems(inSection: 0)), collectionViewDataSource.numberOfItems = \(collectionView.dataSource?.numberOfSections?(in: collectionView) ?? 0), currentImageIndex = \(currentImageIndex)")
        }
    }
}

extension QMUIImagePreviewView: UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return delegate?.numberOfImages(in: self) ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var identifier = kImageOrUnknownCellIdentifier

        if let type = delegate?.imagePreviewView?(self, assetTypeAt: indexPath.item) {
            if type == .livePhoto {
                identifier = kLivePhotoCellIdentifier
            } else if type == .video {
                identifier = kVideoCellIdentifier
            }
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? QMUIImagePreviewCell
        let zoomView = cell?.zoomImageView

        if let loadingView = zoomView?.emptyView.loadingView as? UIActivityIndicatorView {
            loadingView.color = loadingColor
        }
        zoomView?.cloudProgressView?.tintColor = loadingColor
        zoomView?.cloudDownloadRetryButton?.tintColor = loadingColor
        zoomView?.delegate = self

        // 因为 cell 复用的问题，很可能此时会显示一张错误的图片，因此这里要清空所有图片的显示
        zoomView?.image = nil
        if #available(iOS 9.1, *) {
            zoomView?.livePhoto = nil
        }

        delegate?.imagePreviewView(self, renderZoomImageView: zoomView!, at: indexPath.item)
        
        return cell ?? QMUIImagePreviewCell()
    }
}

extension QMUIImagePreviewView: UICollectionViewDelegateFlowLayout {
    func collectionView(_: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt _: IndexPath) {
        let previewCell = cell as? QMUIImagePreviewCell
        previewCell?.zoomImageView.revertZooming()
    }

    func collectionView(_: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt _: IndexPath) {
        let previewCell = cell as? QMUIImagePreviewCell
        previewCell?.zoomImageView.endPlayingVideo()
    }

    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }

    // MARK: - UIScrollViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView != collectionView {
            return
        }
        // 当前滚动到的页数
        delegate?.imagePreviewView?(self, didScrollToIndex: currentImageIndex)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView != collectionView {
            return
        }

        if isChangingCollectionViewBounds {
            return
        }

        let pageWidth = collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: IndexPath(row: 0, section: 0)).width

        let pageHorizontalMargin = collectionViewLayout.minimumLineSpacing
        let contentOffsetX = collectionView.contentOffset.x
        var index = contentOffsetX / (pageWidth + pageHorizontalMargin)

        // 在滑动过临界点的那一次才去调用 delegate，避免过于频繁的调用
        let isFirstDidScroll = previousIndexWhenScrolling == 0
        let turnPageToRight = betweenOrEqual(previousIndexWhenScrolling, floor(index) + 0.5, index)
        let turnPageToLeft = betweenOrEqual(index, floor(index) + 0.5, previousIndexWhenScrolling)
        if !isFirstDidScroll && (turnPageToRight || turnPageToLeft) {
            index = round(index)
            if 0 <= index && index < CGFloat(collectionView.numberOfItems(inSection: 0)) {

                // 不调用 setter，避免又走一次 scrollToItem
                _currentImageIndex = Int(index)

                delegate?.imagePreviewView?(self, willScrollHalfTo: Int(index))
            }
        }
        previousIndexWhenScrolling = index
    }
}

extension QMUIImagePreviewView: QMUIZoomImageViewDelegate {
    /**
     *  获取某个 QMUIZoomImageView 所对应的 index
     *  @return zoomImageView 对应的 index，若当前的 zoomImageView 不可见，会返回 0
     */
    func index(for zoomImageView: QMUIZoomImageView) -> Int {
        if let cell = zoomImageView.superview?.superview as? QMUIImagePreviewCell {
            return collectionView.indexPath(for: cell)?.item ?? 0
        } else {
            assert(false, "尝试通过 \(#function) 获取 QMUIZoomImageView 所在的 index，但找不到 QMUIZoomImageView 所在的 cell，index 获取失败。\(zoomImageView)")
        }
        return Int.max
    }

    /**
     *  获取某个 index 对应的 zoomImageView
     *  @return 指定的 index 所在的 zoomImageView，若该 index 对应的图片当前不可见（不处于可视区域），则返回 nil
     */
    func zoomImageView(at index: Int) -> QMUIZoomImageView? {
        let cell = collectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? QMUIImagePreviewCell
        return cell?.zoomImageView
    }

    private func checkIfDelegateMissing() {
        #if DEBUG
            // TODO:
            //            NSObject.qmui_enumerateProtocolMethods(ptc: Protocol(QMUIZoomImageViewDelegate), using: { selector in
            //                if !responds(to: selector) {
            //                    assert(false, "\(type(of: self)) 需要响应 \(QMUIZoomImageViewDelegate) 的方法 -\(selector)")
            //                }
            //            })
        #endif
    }

    func singleTouch(in zoomingImageView: QMUIZoomImageView, location: CGPoint) {
        checkIfDelegateMissing()
        delegate?.singleTouch?(in: zoomingImageView, location: location)
    }

    func doubleTouch(in zoomingImageView: QMUIZoomImageView, location: CGPoint) {
        checkIfDelegateMissing()
        delegate?.doubleTouch?(in: zoomingImageView, location: location)
    }

    func longPress(in zoomingImageView: QMUIZoomImageView) {
        checkIfDelegateMissing()
        delegate?.longPress?(in: zoomingImageView)
    }

    func zoomImageView(_ imageView: QMUIZoomImageView, didHideVideoToolbar didHide: Bool) {
        checkIfDelegateMissing()
        delegate?.zoomImageView?(imageView, didHideVideoToolbar: didHide)
    }

    func enabledZoomView(in zoomImageView: QMUIZoomImageView) -> Bool {
        checkIfDelegateMissing()
        return delegate?.enabledZoomView?(in: zoomImageView) ?? true
    }

    func didTouchICloudRetryButton(in zoomImageView: QMUIZoomImageView) {
        checkIfDelegateMissing()
        delegate?.didTouchICloudRetryButton?(in: zoomImageView)
    }
}

fileprivate class QMUIImagePreviewCell: UICollectionViewCell {
    fileprivate var zoomImageView: QMUIZoomImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColorClear
        zoomImageView = QMUIZoomImageView()
        contentView.addSubview(zoomImageView)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        zoomImageView.frame = contentView.bounds
    }
}
