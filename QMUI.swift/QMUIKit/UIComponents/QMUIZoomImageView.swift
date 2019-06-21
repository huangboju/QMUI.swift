//
//  QMUIZoomImageView.swift
//  QMUI.swift
//
//  Created by 黄伯驹 on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

import Photos
import PhotosUI

private let kTagForCenteredPlayButton = 1

private let kIconsColor = UIColor(r: 255, g: 255, b: 255, a: 0.75)

@objc protocol QMUIZoomImageViewDelegate: NSObjectProtocol {
    
    @objc optional func singleTouch(in zoomingImageView: QMUIZoomImageView, location: CGPoint)
    @objc optional func doubleTouch(in zoomingImageView: QMUIZoomImageView, location: CGPoint)
    @objc optional func longPress(in zoomingImageView: QMUIZoomImageView)
    
    /**
     *  告知 delegate 用户点击了 iCloud 图片的重试按钮
     */
    @objc optional func didTouchICloudRetryButton(in zoomImageView: QMUIZoomImageView)
    
    /**
     *  告知 delegate 在视频预览界面里，由于用户点击了空白区域或播放视频等导致了底部的视频工具栏被显示或隐藏
     *  @param didHide 如果为 YES 则表示工具栏被隐藏，NO 表示工具栏被显示了出来
     */
    @objc optional func zoomImageView(_ imageView: QMUIZoomImageView, didHideVideoToolbar didHide: Bool)

    /// 是否支持缩放，默认为 YES
    @objc optional func enabledZoomView(in zoomImageView: QMUIZoomImageView) -> Bool
}

/**
 *  支持缩放查看静态图片、live photo、视频的控件
 *  默认显示完整图片或视频，可双击查看原始大小，再次双击查看放大后的大小，第三次双击恢复到初始大小。
 *
 *  支持通过修改 contentMode 来控制静态图片和 live photo 默认的显示模式，目前仅支持 UIViewContentModeCenter、UIViewContentModeScaleAspectFill、UIViewContentModeScaleAspectFit，默认为 UIViewContentModeCenter。注意这里的显示模式是基于 viewportRect 而言的而非整个 zoomImageView
 *  @see viewportRect
 *
 *  QMUIZoomImageView 提供最基础的图片预览和缩放功能以及 loading、错误等状态的展示支持，其他功能请通过继承来实现。
 */

class QMUIZoomImageView: UIView {

    weak var delegate: QMUIZoomImageViewDelegate?

    /**
     * 比如常见的上传头像预览界面中间有一个用于裁剪的方框，则 viewportRect 必须被设置为这个方框在 zoomImageView 坐标系内的 frame，否则拖拽图片或视频时无法正确限制它们的显示范围
     * @note 图片或视频的初始位置会位于 viewportRect 正中间
     * @note 如果想要图片覆盖整个 viewportRect，将 contentMode 设置为 UIViewContentModeScaleAspectFill 即可
     * 如果设置为 CGRectZero 则表示使用默认值，默认值为和整个 zoomImageView 一样大
     */
    var viewportRect: CGRect = .zero

    // Default 2
    var maximumZoomScale: CGFloat = 2 {
        didSet {
            scrollView.maximumZoomScale = maximumZoomScale
        }
    }

    /// 设置当前要显示的图片，会把 livePhoto/video 相关内容清空，因此注意不要直接通过 imageView.image 来设置图片。
    weak var image: UIImage? {
        didSet {
            // 释放以节省资源
            if #available(iOS 9.1, *) {
                livePhotoView?.removeFromSuperview()
                livePhotoView = nil
            }
            destroyVideoRelatedObjectsIfNeeded()

            guard let image = image else {
                imageView?.image = nil
                return
            }
            initImageViewIfNeeded()
            imageView?.image = image

            // 更新 imageView 的大小时，imageView 可能已经被缩放过，所以要应用当前的缩放
            imageView?.frame = image.size.rect.applying(imageView!.transform)

            hideViews()
            imageView?.isHidden = false

            revertZooming()
        }
    }

    /// 用于显示图片的 UIImageView，注意不要通过 imageView.image 来设置图片，请使用 image 属性。
    private(set) var imageView: UIImageView? {
        set {
            _imageView = newValue
        }
        get {
            initImageViewIfNeeded()
            return _imageView
        }
    }

    private var _imageView: UIImageView?
    
    // 视频底部控制条的 margins，会在此基础上自动叠加 QMUIZoomImageView.qmui_safeAreaInsets，因此无需考虑在 iPhone X 下的兼容
    // 默认值为 {0, 25, 25, 18}
    var videoToolbarMargins: UIEdgeInsets = UIEdgeInsets(top: 0, left: 25, bottom: 25, right: 18) {
        didSet {
            setNeedsLayout()
        }
    }

    /// 设置当前要显示的 Live Photo，会把 image/video 相关内容清空，因此注意不要直接通过 livePhotoView.livePhoto 来设置
    private var livePhotoStorge: Any?
    @available(iOS 9.1, *)
    weak var livePhoto: PHLivePhoto? {
        get {
            return livePhotoStorge as? PHLivePhoto
        }
        set {
            livePhotoStorge = newValue

            imageView?.removeFromSuperview()
            imageView = nil
            destroyVideoRelatedObjectsIfNeeded()

            if newValue == nil {
                livePhotoView?.livePhoto = nil
                return
            }

            initLivePhotoViewIfNeeded()
            
            livePhotoView?.isHidden = false

            // 更新 livePhotoView 的大小时，livePhotoView 可能已经被缩放过，所以要应用当前的缩放
            livePhotoView?.frame = newValue!.size.rect.applying(livePhotoView!.transform)
            revertZooming()
        }
    }

    /// 用于显示 Live Photo 的 view，仅在 iOS 9.1 及以后才有效
    @available(iOS 9.1, *)
    private(set) var livePhotoView: PHLivePhotoView? {
        set {
            _livePhotoView = newValue
        }
        get {
            initLivePhotoViewIfNeeded()
            return _livePhotoView as? PHLivePhotoView
        }
    }

    private var _livePhotoView: Any?

    private func initLivePhotoViewIfNeeded() {
        if #available(iOS 9.1, *), _livePhotoView == nil {
            _livePhotoView = PHLivePhotoView()
            scrollView.addSubview(_livePhotoView! as! UIView)
        }
    }
    
    /// 设置当前要显示的 video ，会把 image/livePhoto 相关内容清空，因此注意不要直接通过 videoPlayerLayer 来设置
    weak var videoPlayerItem: AVPlayerItem? {
        didSet {
            if #available(iOS 9.1, *) {
                livePhotoView?.removeFromSuperview()
                livePhotoView = nil
            }
            imageView?.removeFromSuperview()
            imageView = nil
            
            if videoPlayerItem == nil {
                hideViews()
                return
            }
            
            // 获取视频尺寸
            if let tracksArray = videoPlayerItem?.asset.tracks {
                for track in tracksArray where track.mediaType == .video {
                    let size = track.naturalSize.applying(track.preferredTransform)
                    videoSize = CGSize(width: abs(size.width), height: abs(size.height))
                    break
                }
            }
            
            videoPlayer = AVPlayer(playerItem: videoPlayerItem)
            initVideoRelatedViewsIfNeeded()
            videoPlayerLayer?.player = videoPlayer
            // 更新 videoPlayerView 的大小时，videoView 可能已经被缩放过，所以要应用当前的缩放
            videoPlayerView?.frame = videoSize.rect.applying(videoPlayerView!.transform)
            
            NotificationCenter.default.addObserver(self, selector: #selector(handleVideoPlayToEndEvent), name: .AVPlayerItemDidPlayToEndTime, object: videoPlayerItem)
            NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
            
            configVideoProgressSlider()
            
            hideViews()
            videoPlayerLayer?.isHidden = false
            videoCenteredPlayButton?.isHidden = false
            videoToolbar?.playButton.isHidden = false
            
            revertZooming()
        }
    }

    /// 用于显示 video 的 layer
    private(set) weak var videoPlayerLayer: AVPlayerLayer? {
        set {
            _videoPlayerLayer = newValue
        }
        get {
            initVideoPlayerLayerIfNeeded()
            return _videoPlayerLayer
        }
    }

    private var _videoPlayerLayer: AVPlayerLayer?

    // 播放 video 时底部的工具栏，你可通过此属性来拿到并修改上面的播放/暂停按钮、进度条、Label 等的样式
    // @see QMUIZoomImageViewVideoToolbar
    private(set) var videoToolbar: QMUIZoomImageViewVideoToolbar? {
        get {
            initVideoToolbarIfNeeded()
            return _videoToolbar
        }
        set {
            _videoToolbar = newValue
        }
    }
    private var _videoToolbar: QMUIZoomImageViewVideoToolbar?

    // 播放 video 时屏幕中央的播放按钮
    private(set) var videoCenteredPlayButton: QMUIButton? {
        set {
            _videoCenteredPlayButton = newValue
        }
        get {
            initVideoCenteredPlayButtonIfNeeded()
            return _videoCenteredPlayButton
        }
    }

    private var _videoCenteredPlayButton: QMUIButton?

    // 可通过此属性修改 video 播放时屏幕中央的播放按钮图片
    var videoCenteredPlayButtonImage = QMUIZoomImageViewImageGenerator.largePlayImage {
        didSet {
            if videoCenteredPlayButton == nil {
                return
            }
            videoCenteredPlayButton!.setImage(videoCenteredPlayButtonImage, for: .normal)
            setNeedsLayout()
        }
    }
    
    // 从 iCloud 加载资源的进度展示
    var cloudProgressView: QMUIPieProgressView? {
        get {
            initCloudRelatedViewsIfNeeded()
            return _cloudProgressView
        }
        set {
            _cloudProgressView = newValue
        }
    }
  
    private var _cloudProgressView: QMUIPieProgressView?
    
    // 从 iCloud 加载资源失败的重试按钮
    var cloudDownloadRetryButton: QMUIButton? {
        get {
            initCloudRelatedViewsIfNeeded()
            return _cloudDownloadRetryButton
        }
        set {
            _cloudDownloadRetryButton = newValue
        }
    }
    
    private var _cloudDownloadRetryButton: QMUIButton?
    
    // 当前展示的资源的下载状态
    var cloudDownloadStatus: QMUIAssetDownloadStatus = .succeed {
        didSet {
            let statusChanged = cloudDownloadStatus != oldValue
            switch cloudDownloadStatus {
            case .succeed:
                cloudProgressView?.isHidden = true
                cloudDownloadRetryButton?.isHidden = true
            case .downloading:
                cloudProgressView?.isHidden = false
                cloudProgressView?.superview?.bringSubviewToFront(cloudProgressView!)
                cloudDownloadRetryButton?.isHidden = true
            case .canceled:
                cloudProgressView?.isHidden = true
                cloudDownloadRetryButton?.isHidden = true
            case .failed:
                cloudProgressView?.isHidden = true
                cloudDownloadRetryButton?.isHidden = false
                cloudDownloadRetryButton?.superview?.bringSubviewToFront(cloudDownloadRetryButton!)
            }
            if statusChanged {
                setNeedsLayout()
            }
        }
    }
    
    private(set) var emptyView: QMUIEmptyView!

    // MARK: - private

    private var scrollView: UIScrollView!
    
    private var videoPlayerView: QMUIZoomImageVideoPlayerView?
    private var videoPlayer: AVPlayer?
    private var videoTimeObserver: Any?
    private var isSeekingVideo = false
    private var videoSize: CGSize = .zero

    override func didMoveToWindow() {
        // 当 self.window 为 nil 时说明此 view 被移出了可视区域（比如所在的 controller 被 pop 了），此时应该停止视频播放
        if window == nil {
            endPlayingVideo()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentMode = .center

        scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.minimumZoomScale = 0
        scrollView.maximumZoomScale = maximumZoomScale
        scrollView.delegate = self
        if #available(iOS 11, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        addSubview(scrollView)
        
        emptyView = QMUIEmptyView()
        if let loadingView = emptyView.loadingView as? UIActivityIndicatorView {
            loadingView.color = UIColorWhite
        }
        emptyView.isHidden = true
        addSubview(emptyView)

        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSingleTapGestureWithPoint(_:)))
        singleTapGesture.delegate = self
        singleTapGesture.numberOfTapsRequired = 1
        singleTapGesture.numberOfTouchesRequired = 1
        addGestureRecognizer(singleTapGesture)

        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapGestureWithPoint(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.numberOfTouchesRequired = 1
        addGestureRecognizer(doubleTapGesture)

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
        addGestureRecognizer(longPressGesture)

        // 双击失败后才出发单击
        singleTapGesture.require(toFail: doubleTapGesture)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if bounds.isEmpty {
            return
        }

        scrollView.frame = bounds
        emptyView.frame = bounds

        let viewportRect = finalViewportRect
        videoCenteredPlayButton?.sizeToFit()
        videoCenteredPlayButton?.center = CGPoint(x: viewportRect.midX, y: viewportRect.midY)

        if let videoToolbar = videoToolbar {
            let margins = videoToolbarMargins.concat(insets: qmui_safeAreaInsets)
            let width = bounds.width - margins.horizontalValue
            let height = videoToolbar.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)).height
            videoToolbar.frame = CGRect(x: margins.left, y: bounds.height - margins.bottom - height, width: width, height: height)
        }
        
        if let cloudProgressView = cloudProgressView, let cloudDownloadRetryButton = cloudDownloadRetryButton {
            let origin = CGPoint(x: 12, y: 12)
            cloudDownloadRetryButton.frame = cloudDownloadRetryButton.frame.setXY(origin.x, 20 + NavigationBarHeight + IPhoneXSafeAreaInsets.top + origin.y)
            cloudProgressView.frame = cloudProgressView.frame.setSize(size: cloudDownloadRetryButton.currentImage?.size ?? .zero)
            cloudProgressView.center = cloudDownloadRetryButton.center
        }
        
    }

    override var frame: CGRect {
        didSet {
            let isBoundsChanged = frame.size != oldValue.size
            if isBoundsChanged {
                revertZooming()
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override var contentMode: UIView.ContentMode {
        didSet {
            if contentMode != oldValue {
                revertZooming()
            }
        }
    }

    private var minimumZoomScale: CGFloat {
        if image == nil && videoPlayerItem == nil {
            if #available(iOS 9.1, *) {
                if livePhoto == nil {
                    return 1
                }
            } else {
                return 1
            }
        }

        let viewport = finalViewportRect
        var mediaSize: CGSize = .zero
        if let image = image {
            mediaSize = image.size
        } else if videoPlayerItem != nil {
            mediaSize = videoSize
        }
            
        if #available(iOS 9.1, *) {
            if let livePhoto = livePhoto {
                mediaSize = livePhoto.size
            }
        }

        var minScale: CGFloat = 1
        let scaleX = viewport.width / mediaSize.width
        let scaleY = viewport.height / mediaSize.height
        if contentMode == .scaleAspectFit {
            minScale = fmin(scaleX, scaleY)
        } else if contentMode == .scaleAspectFill {
            minScale = fmax(scaleX, scaleY)
        } else if contentMode == .center {
            if scaleX >= 1 && scaleY >= 1 {
                minScale = 1
            } else {
                minScale = fmin(scaleX, scaleY)
            }
        }
        return minScale
    }

    /**
     *  重置图片或视频的大小，使用的场景例如：相册控件里放大当前图片、划到下一张、再回来，当前的图片或视频应该恢复到原来大小。
     *  注意子类重写需要调一下super。
     */
    func revertZooming() {
        if bounds.isEmpty {
            return
        }

        var maximumZoomScale = enabledZoomImageView ? self.maximumZoomScale : minimumZoomScale
        maximumZoomScale = fmax(minimumZoomScale, maximumZoomScale) // 可能外部通过 contentMode = UIViewContentModeScaleAspectFit 的方式来让小图片撑满当前的 zoomImageView，所以算出来 minimumZoomScale 会很大（至少比 maximumZoomScale 大），所以这里要做一个保护
        let zoomScale = minimumZoomScale
        let shouldFireDidZoomingManual = zoomScale == scrollView.zoomScale
        scrollView.panGestureRecognizer.isEnabled = enabledZoomImageView
        scrollView.pinchGestureRecognizer?.isEnabled = enabledZoomImageView
        scrollView.minimumZoomScale = minimumZoomScale
        scrollView.maximumZoomScale = maximumZoomScale
        setZoomScale(zoomScale, animated: false)

        // 只有前后的 zoomScale 不相等，才会触发 UIScrollViewDelegate scrollViewDidZoom:，因此对于相等的情况要自己手动触发
        if shouldFireDidZoomingManual {
            handleDidEndZooming()
        }

        // 当内容比 viewport 的区域更大时，要把内容放在 viewport 正中间
        scrollView.contentOffset = {
            var x = scrollView.contentOffset.x
            var y = scrollView.contentOffset.y
            let viewport = finalViewportRect
            if !viewport.isEmpty {
                let contentViewFrame = currentContentView?.frame ?? .zero
                let width = viewport.width
                if width < contentViewFrame.width {
                    x = (contentViewFrame.width - width) / 2 - viewport.minX
                }
                let height = viewport.height
                if height < contentViewFrame.height {
                    y = (contentViewFrame.height - height) / 2 - viewport.minY
                }
            }
            return CGPoint(x: x, y: y)
        }()
    }

    private func setZoomScale(_ zoomScale: CGFloat, animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveOut, animations: {
                self.scrollView.zoomScale = zoomScale
            }, completion: nil)
        } else {
            scrollView.zoomScale = zoomScale
        }
    }

    private func zoom(to rect: CGRect, animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveOut, animations: {
                self.scrollView.zoom(to: rect, animated: false)
            }, completion: nil)
        } else {
            scrollView.zoom(to: rect, animated: false)
        }
    }

    /**
     *  获取当前正在显示的图片/视频在整个 QMUIZoomImageView 坐标系里的 rect（会按照当前的缩放状态来计算）
     */
    var imageViewRectInZoomImageView: CGRect {
        let imageView = currentContentView
        return convert(imageView?.frame ?? .zero, from: imageView?.superview)
    }

    private func handleDidEndZooming() {
        let viewport = finalViewportRect

        let contentView = currentContentView
        // 强制 layout 以确保下面的一堆计算依赖的都是最新的 frame 的值
        layoutIfNeeded()
        let contentViewFrame = contentView != nil ? convert(contentView!.frame, to: contentView!.superview) : CGRect.zero
        var contentInset = UIEdgeInsets.zero

        contentInset.top = viewport.minY
        contentInset.left = viewport.minX
        contentInset.right = bounds.width - viewport.maxX
        contentInset.bottom = bounds.height - viewport.maxY

        // 图片 height 比选图框(viewport)的 height 小，这时应该把图片纵向摆放在选图框中间，且不允许上下移动
        if viewport.height > contentViewFrame.height {
            // 用 floor 而不是 flat，是因为 flat 本质上是向上取整，会导致 top + bottom 比实际的大，然后 scrollView 就认为可滚动了
            contentInset.top = floor(viewport.midY - contentViewFrame.height / 2.0)
            contentInset.bottom = floor(bounds.height - viewport.midY - contentViewFrame.height / 2.0)
        }

        // 图片 width 比选图框的 width 小，这时应该把图片横向摆放在选图框中间，且不允许左右移动
        if viewport.width > contentViewFrame.width {
            contentInset.left = floor(viewport.midX - contentViewFrame.width / 2.0)
            contentInset.right = floor(bounds.width - viewport.midX - contentViewFrame.width / 2.0)
        }

        scrollView.contentInset = contentInset
        scrollView.contentSize = contentView?.frame.size ?? .zero
    }

    private var enabledZoomImageView: Bool {
        var enabledZoom = delegate?.enabledZoomView?(in: self) ?? true
        if #available(iOS 9.1, *) {
            if image == nil && livePhoto == nil && videoPlayerItem == nil {
                enabledZoom = false
            }
        }
        return enabledZoom
    }

    @objc func handlePlayButton(_ button: UIButton) {
        addPlayerTimeObserver()
        videoPlayer?.play()
        videoCenteredPlayButton?.isHidden = true
        videoToolbar?.playButton.isHidden = true
        videoToolbar?.pauseButton.isHidden = false
        if button.tag == kTagForCenteredPlayButton {
            videoToolbar?.isHidden = true
            delegate?.zoomImageView?(self, didHideVideoToolbar: true)
        }
    }

    @objc func handlePauseButton() {
        videoPlayer?.pause()
        videoToolbar?.playButton.isHidden = false
        videoToolbar?.pauseButton.isHidden = true
    }

    @objc func handleVideoPlayToEndEvent() {
        videoPlayer?.seek(to: CMTimeMake(value: 0, timescale: 1))
        videoCenteredPlayButton?.isHidden = false
        videoToolbar?.playButton.isHidden = false
        videoToolbar?.pauseButton.isHidden = true
    }

    @objc func handleStartDragVideoSlider(_: UISlider) {
        videoPlayer?.pause()
        removePlayerTimeObserver()
    }

    @objc func handleDraggingVideoSlider(_ slider: UISlider) {
        if !isSeekingVideo {
            isSeekingVideo = true
            updateVideoSliderLeftLabel()

            let currentValue = slider.value

            videoPlayer?.seek(to: CMTimeMakeWithSeconds(Float64(currentValue), preferredTimescale: Int32(NSEC_PER_SEC)), completionHandler: { _ in
                DispatchQueue.main.async {
                    self.isSeekingVideo = false
                }
            })
        }
    }

    @objc func handleFinishDragVideoSlider(_: UISlider) {
        videoPlayer?.play()
        videoCenteredPlayButton?.isHidden = true
        videoToolbar?.playButton.isHidden = true
        videoToolbar?.pauseButton.isHidden = false

        addPlayerTimeObserver()
    }
    
    @objc func handleICloudDownloadRetryEvent() {
        delegate?.didTouchICloudRetryButton?(in: self)
    }

    private func syncVideoProgressSlider() {
        let currentSeconds = CMTimeGetSeconds(videoPlayer!.currentTime())
        videoToolbar?.slider.value = Float(currentSeconds)
        updateVideoSliderLeftLabel()
    }

    private func configVideoProgressSlider() {

        videoToolbar?.sliderLeftLabel.text = timeString(from: 0)
        let duration = CMTimeGetSeconds(videoPlayerItem!.asset.duration)
        videoToolbar?.sliderRightLabel.text = timeString(from: Int(duration))

        videoToolbar?.slider.minimumValue = 0.0
        videoToolbar?.slider.maximumValue = Float(duration)
        videoToolbar?.slider.value = 0
        videoToolbar?.slider.addTarget(self, action: #selector(handleStartDragVideoSlider(_:)), for: .touchDown)
        videoToolbar?.slider.addTarget(self, action: #selector(handleDraggingVideoSlider(_:)), for: .valueChanged)
        videoToolbar?.slider.addTarget(self, action: #selector(handleFinishDragVideoSlider(_:)), for: .touchUpInside)

        addPlayerTimeObserver()
    }

    private func addPlayerTimeObserver() {
        if videoTimeObserver != nil {
            return
        }
        let interval = 0.1
        videoPlayer?.addPeriodicTimeObserver(forInterval: CMTime(seconds: interval, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), queue: nil, using: { [weak self] _ in
            self?.syncVideoProgressSlider()
        })
    }

    private func removePlayerTimeObserver() {
        guard let videoTimeObserver = videoTimeObserver else {
            return
        }
        videoPlayer?.removeTimeObserver(videoTimeObserver)
        self.videoTimeObserver = nil
    }

    private func updateVideoSliderLeftLabel() {
        let currentSeconds = CMTimeGetSeconds(videoPlayer!.currentTime())
        videoToolbar?.sliderLeftLabel.text = timeString(from: Int(currentSeconds))
    }

    // convert "100" to "01:40"
    private func timeString(from seconds: Int) -> String {
        let min = seconds / 60
        let sec = seconds - min * 60
        return "\(min):\(sec)"
    }

    /// 暂停视频播放
    func pauseVideo() {
        if videoPlayer == nil {
            return
        }
        handlePauseButton()
        removePlayerTimeObserver()
    }

    /// 停止视频播放，将播放状态重置到初始状态
    func endPlayingVideo() {
        if videoPlayer == nil {
            return
        }
        videoPlayer?.seek(to: CMTimeMake(value: 0, timescale: 1))
        pauseVideo()
        syncVideoProgressSlider()
        videoToolbar?.isHidden = true
        videoCenteredPlayButton?.isHidden = false
    }

    private func initVideoRelatedViewsIfNeeded() {
        initVideoPlayerLayerIfNeeded()
        initVideoToolbarIfNeeded()
        initVideoCenteredPlayButtonIfNeeded()
        setNeedsLayout()
    }

    private func initVideoToolbarIfNeeded() {
        if _videoToolbar != nil {
            return
        }
        _videoToolbar = {
            let b = QMUIZoomImageViewVideoToolbar()
            b.playButton.addTarget(self, action: #selector(handlePlayButton(_:)), for: .touchUpInside)
            b.pauseButton.addTarget(self, action: #selector(handlePauseButton), for: .touchUpInside)
            insertSubview(b, belowSubview: emptyView)
            b.isHidden = true
            return b
        }()
    }

    private func initVideoCenteredPlayButtonIfNeeded() {
        if _videoCenteredPlayButton != nil {
            return
        }

        _videoCenteredPlayButton = {
            let b = QMUIButton()
            b.qmui_outsideEdge = UIEdgeInsets(top: -60, left: -60, bottom: -60, right: -60)
            b.tag = kTagForCenteredPlayButton
            b.setImage(videoCenteredPlayButtonImage, for: .normal)
            b.sizeToFit()
            b.addTarget(self, action: #selector(handlePlayButton(_:)), for: .touchUpInside)
            b.isHidden = true
            insertSubview(b, belowSubview: emptyView)
            return b
        }()
    }
    
    private func initVideoPlayerLayerIfNeeded() {
        if videoPlayerView != nil {
            return
        }
        videoPlayerView = QMUIZoomImageVideoPlayerView()
        videoPlayerLayer = videoPlayerView?.layer as? AVPlayerLayer
        videoPlayerView?.isHidden = true
        scrollView.addSubview(videoPlayerView!)
    }
    
    private func initImageViewIfNeeded() {
        if _imageView != nil {
            return
        }
        _imageView = UIImageView()
        scrollView.addSubview(_imageView!)
    }
    
    private func initCloudRelatedViewsIfNeeded() {
        initCloudProgressViewIfNeeded()
        initCloudDownloadRetryButtonIfNeeded()
    }
    
    private func initCloudProgressViewIfNeeded() {
        if _cloudProgressView != nil {
            return
        }
        _cloudProgressView = QMUIPieProgressView()
        _cloudProgressView!.tintColor = (emptyView.loadingView as? UIActivityIndicatorView)?.color ?? UIColorBlue
        _cloudProgressView!.isHidden = true
        addSubview(_cloudProgressView!)
    }
    
    private func initCloudDownloadRetryButtonIfNeeded() {
        if _cloudDownloadRetryButton != nil {
            return
        }
        _cloudDownloadRetryButton = QMUIButton()
        _cloudDownloadRetryButton!.setImage(QMUIHelper.image(name: "QMUI_icloud_download_fault"), for: .normal)
        _cloudDownloadRetryButton!.sizeToFit()
        _cloudDownloadRetryButton!.qmui_outsideEdge = UIEdgeInsets(top: -6, left: -6, bottom: -6, right: -6)
        _cloudDownloadRetryButton!.isHidden = true
        _cloudDownloadRetryButton!.addTarget(self, action: #selector(handleICloudDownloadRetryEvent), for: .touchUpInside)
        addSubview(_cloudDownloadRetryButton!)
    }

    private func destroyVideoRelatedObjectsIfNeeded() {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)

        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        removePlayerTimeObserver()

        videoPlayerView?.removeFromSuperview()
        videoPlayerView = nil

        videoToolbar?.removeFromSuperview()
        videoToolbar = nil

        videoCenteredPlayButton?.removeFromSuperview()
        videoCenteredPlayButton = nil

        videoPlayer = nil
    }

    @objc
    private func applicationDidEnterBackground() {
        pauseVideo()
    }

    // MARK: - GestureRecognizers

    @objc
    private func handleSingleTapGestureWithPoint(_ gestureRecognizer: UITapGestureRecognizer) {
        let gesturePoint = gestureRecognizer.location(in: gestureRecognizer.view)
        delegate?.singleTouch?(in: self, location: gesturePoint)
        if videoPlayerItem != nil {
            videoToolbar?.isHidden = !videoToolbar!.isHidden
            delegate?.zoomImageView?(self, didHideVideoToolbar: videoToolbar?.isHidden ?? true)
        }
    }

    @objc
    private func handleDoubleTapGestureWithPoint(_ gestureRecognizer: UITapGestureRecognizer) {
        let gesturePoint = gestureRecognizer.location(in: gestureRecognizer.view)
        delegate?.doubleTouch?(in: self, location: gesturePoint)

        if !enabledZoomImageView {
            return
        }

        // 如果图片被压缩了，则第一次放大到原图大小，第二次放大到最大倍数
        if scrollView.zoomScale >= scrollView.maximumZoomScale {
            setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            var newZoomScale: CGFloat = 0
            if scrollView.zoomScale < 1 {
                // 如果目前显示的大小比原图小，则放大到原图
                newZoomScale = 1
            } else {
                // 如果当前显示原图，则放大到最大的大小
                newZoomScale = scrollView.maximumZoomScale
            }

            var zoomRect = CGRect.zero
            let tapPoint = currentContentView?.convert(gesturePoint, to: gestureRecognizer.view) ?? .zero
            zoomRect.size.width = bounds.width / newZoomScale
            zoomRect.size.height = bounds.height / newZoomScale
            zoomRect.origin.x = tapPoint.x - zoomRect.width / 2
            zoomRect.origin.y = tapPoint.y - zoomRect.height / 2
            zoom(to: zoomRect, animated: true)
        }
    }

    @objc
    private func handleLongPressGesture(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if enabledZoomImageView && longPressGestureRecognizer.state == .began {
            delegate?.longPress?(in: self)
        }
    }

    // MARK: - EmptyView

    /**
     *  显示一个 loading
     *  @info 注意 cell 复用可能导致当前页面显示一张错误的旧图片/视频，所以一般情况下需要视情况同时将 image/livePhoto/videoPlayerItem 等属性置为 nil 以清除图片/视频的显示
     */
    func showLoading() {
        // 挪到最前面
        insertSubview(emptyView, at: subviews.count - 1)
        emptyView.setLoadingViewHidden(false)
        emptyView.setTextLabel(nil)
        emptyView.setDetailTextLabel(nil)
        emptyView.setActionButtonTitle(nil)
        emptyView.isHidden = false
    }

    /**
     *  显示一句提示语
     *  @info 注意 cell 复用可能导致当前页面显示一张错误的旧图片/视频，所以一般情况下需要视情况同时将 image/livePhoto/videoPlayerItem 等属性置为 nil 以清除图片/视频的显示
     */
    func showEmptyView(with text: String) {
        insertSubview(emptyView, at: subviews.count - 1)
        emptyView.setLoadingViewHidden(true)
        emptyView.setTextLabel(text)
        emptyView.setDetailTextLabel(nil)
        emptyView.setActionButtonTitle(nil)
        emptyView.isHidden = false
    }

    /**
     *  将 emptyView 隐藏
     */
    func hideEmptyView() {
        emptyView.isHidden = true
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 工具方法
    private var finalViewportRect: CGRect {
        var rect = viewportRect
        if rect.isEmpty && !bounds.isEmpty {
            // 有可能此时还没有走到过 layoutSubviews 因此拿不到正确的 scrollView 的 size，因此这里要强制 layout 一下
            if scrollView.bounds.size != bounds.size {
                setNeedsLayout()
                layoutIfNeeded()
            }
            rect = scrollView.bounds.size.rect
        }
        return rect
    }

    private func hideViews() {
        if #available(iOS 9.1, *) {
            livePhotoView?.isHidden = true
        }
        imageView?.isHidden = true
        videoCenteredPlayButton?.isHidden = true
        videoPlayerLayer?.isHidden = true
        videoToolbar?.isHidden = true
        videoToolbar?.pauseButton.isHidden = true
        videoToolbar?.playButton.isHidden = true
        videoCenteredPlayButton?.isHidden = true
    }

    private var currentContentView: UIView? {
        if let imageView = imageView {
            return imageView
        }
        if #available(iOS 9.1, *) {
            if let livePhotoView = livePhotoView {
                return livePhotoView
            }
        }
        if let videoPlayerView = videoPlayerView {
            return videoPlayerView
        }
        return nil
    }
}

// MARK: - UIGestureRecognizerDelegate
extension QMUIZoomImageView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is UISlider {
            return false
        }
        return true
    }
}

extension QMUIZoomImageView: UIScrollViewDelegate {
    func viewForZooming(in _: UIScrollView) -> UIView? {
        return currentContentView
    }

    func scrollViewDidZoom(_: UIScrollView) {
        handleDidEndZooming()
    }
}

class QMUIZoomImageViewVideoToolbar: UIView {
    private(set) var playButton: QMUIButton!
    private(set) var pauseButton: QMUIButton!
    private(set) var slider: QMUISlider!
    private(set) var sliderLeftLabel: UILabel!
    private(set) var sliderRightLabel: UILabel!

    // 可通过调整此属性来调整 toolbar 内部的间距，默认为 {0, 0, 0, 0}
    var paddings = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) {
        didSet {
            setNeedsLayout()
        }
    }

    // 可通过这些属性修改 video 播放时屏幕底部工具栏的播放/暂停图标
    var playButtonImage = QMUIZoomImageViewImageGenerator.smallPlayImage {
        didSet {
            playButton.setImage(playButtonImage, for: .normal)
            setNeedsLayout()
        }
    }

    var pauseButtonImage = QMUIZoomImageViewImageGenerator.pauseImage {
        didSet {
            pauseButton.setImage(pauseButtonImage, for: .normal)
            setNeedsLayout()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = UIColor(r: 0.5, g: 255, b: 0, a: 0)

        playButton = QMUIButton()
        playButton.qmui_outsideEdge = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)
        playButton.setImage(playButtonImage, for: .normal)
        addSubview(playButton)

        pauseButton = QMUIButton()
        pauseButton.qmui_outsideEdge = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)
        pauseButton.setImage(pauseButtonImage, for: .normal)
        addSubview(pauseButton)

        slider = QMUISlider()
        slider.minimumTrackTintColor = UIColor(r: 195, g: 195, b: 195)
        slider.maximumTrackTintColor = UIColor(r: 95, g: 95, b: 95)
        slider.thumbSize = CGSize(width: 12, height: 12)
        slider.thumbColor = UIColorWhite
        addSubview(slider)

        sliderLeftLabel = UILabel(with: UIFontMake(12), textColor: UIColorWhite)
        sliderLeftLabel.textAlignment = .center
        addSubview(sliderLeftLabel)

        sliderRightLabel = UILabel()
        sliderRightLabel.qmui_setTheSameAppearance(as: sliderLeftLabel)
        addSubview(sliderRightLabel)

        layer.shadowColor = UIColorBlack.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = .zero
        layer.shadowRadius = 10
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let contentHeight = maxHeightAmongViews([playButton, pauseButton, sliderLeftLabel, sliderRightLabel, slider])

        let playButtonSize = playButton.sizeThatFits(CGSize.max)
        playButton.frame = CGRect(x: paddings.left, y: contentHeight.center(playButtonSize.height) + paddings.top, width: playButtonSize.width, height: playButtonSize.height)

        let pauseButtonSize = pauseButton.sizeThatFits(CGSize.max)
        pauseButton.frame = CGRect(origin: CGPoint(x: playButton.frame.midX - pauseButtonSize.width / 2, y: playButton.frame.midX - pauseButtonSize.height / 2), size: pauseButtonSize).flatted

        let timeLabelWidth: CGFloat = 55
        let marginLeft: CGFloat = 19
        sliderLeftLabel.frame = CGRect(x: playButton.frame.maxX + marginLeft, y: paddings.top, width: timeLabelWidth, height: contentHeight).flatted

        sliderRightLabel.frame = CGRect(x: bounds.width - paddings.right - timeLabelWidth, y: paddings.top, width: timeLabelWidth, height: contentHeight).flatted

        let marginToLabel: CGFloat = 4
        let x = sliderLeftLabel.frame.maxX + marginToLabel
        slider.frame = CGRect(x: x, y: paddings.top, width: sliderRightLabel.frame.minX - marginToLabel - x, height: contentHeight).flatted
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var result = size
        let contentHeight = maxHeightAmongViews([playButton, pauseButton, sliderLeftLabel, sliderRightLabel, slider])
        result.height = contentHeight + paddings.verticalValue
        return result
    }

    // 返回一堆 view 中高度最大的那个的高度
    func maxHeightAmongViews(_ views: [UIView]) -> CGFloat {
        var maxValue: CGFloat = 0

        for view in views {
            let height = view.sizeThatFits(CGSize.max).height
            maxValue = max(height, maxValue)
        }
        return maxValue
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - QMUIZoomImageVideoPlayerView
class QMUIZoomImageVideoPlayerView: UIView {
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
}

// MARK: - QMUIZoomImageViewImageGenerator

fileprivate class QMUIZoomImageViewImageGenerator {

    fileprivate static var largePlayImage: UIImage? {
        let width: CGFloat = 60

        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: width), false, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }

        let color = kIconsColor
        context.setStrokeColor(color.cgColor)

        // circle outside
        context.setFillColor(UIColor(r: 255, g: 255, b: 255, a: 0.75).cgColor)
        let circleLineWidth: CGFloat = 1
        // consider line width to avoid edge clip
        let circle = UIBezierPath(ovalIn: CGRect(x: circleLineWidth / 2,
                                                 y: circleLineWidth / 2,
                                                 width: width - circleLineWidth,
                                                 height: width - circleLineWidth))
        circle.lineWidth = circleLineWidth
        circle.stroke()
        circle.fill()

        // triangle inside
        context.setFillColor(color.cgColor)
        let triangleLength: CGFloat = width / 2.5
        let triangle = trianglePath(with: triangleLength)
        let offset = UIOffset(horizontal: width / 2 - triangleLength * tan(.pi / 6) / 2, vertical: width / 2 - triangleLength / 2)
        triangle.apply(CGAffineTransform(translationX: offset.horizontal, y: offset.vertical))
        triangle.fill()

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    // @param length of the triangle side
    private static func trianglePath(with length: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: length * cos(.pi / 6), y: length / 2))
        path.addLine(to: CGPoint(x: 0, y: length))
        path.close()
        return path
    }

    fileprivate static var smallPlayImage: UIImage? {
        // width and height are equal
        let width: CGFloat = 17

        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: width), false, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }

        let color = kIconsColor
        context.setFillColor(color.cgColor)
        let path = trianglePath(with: width)
        path.fill()

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    fileprivate static var pauseImage: UIImage? {
        let size = CGSize(width: 12, height: 18)

        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }

        let color = kIconsColor
        context.setStrokeColor(color.cgColor)
        let lineWidth: CGFloat = 2
        let path = UIBezierPath()
        path.move(to: CGPoint(x: lineWidth / 2, y: 0))
        path.addLine(to: CGPoint(x: lineWidth / 2, y: size.height))
        path.move(to: CGPoint(x: size.width - lineWidth / 2, y: 0))
        path.addLine(to: CGPoint(x: size.width - lineWidth / 2, y: size.height))
        path.lineWidth = lineWidth
        path.stroke()

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
