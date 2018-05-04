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

protocol QMUIZoomImageViewDelegate: class {
    func singleTouch(in zoomingImageView: QMUIZoomImageView, location: CGPoint)
    func doubleTouch(in zoomingImageView: QMUIZoomImageView, location: CGPoint)
    func longPress(in zoomingImageView: QMUIZoomImageView)
    /**
     *  告知 delegate 在视频预览界面里，由于用户点击了空白区域或播放视频等导致了底部的视频工具栏被显示或隐藏
     *  @param didHide 如果为 YES 则表示工具栏被隐藏，NO 表示工具栏被显示了出来
     */
    func zoomImageView(_ imageView: QMUIZoomImageView, didHideVideoToolbar didHide: Bool)

    /// 是否支持缩放，默认为 YES
    func enabledZoomView(in zoomImageView: QMUIZoomImageView) -> Bool

    // 可通过此方法调整视频播放时底部 toolbar 的视觉位置，默认为 {25, 25, 25, 18}
    // 如果同时设置了 QMUIZoomImageViewVideoToolbar 实例的 contentInsets 属性，则这里设置的值将不再生效
    func contentInsets(for videoToolbar: QMUIZoomImageViewVideoToolbar, in zoomingImageView: QMUIZoomImageView) -> UIEdgeInsets
}

extension QMUIZoomImageViewDelegate {
    func singleTouch(in _: QMUIZoomImageView, location _: CGPoint) {}
    func doubleTouch(in _: QMUIZoomImageView, location _: CGPoint) {}
    func longPress(in _: QMUIZoomImageView) {}

    func zoomImageView(_: QMUIZoomImageView, didHideVideoToolbar _: Bool) {}

    func enabledZoomView(in _: QMUIZoomImageView) -> Bool {
        return true
    }

    func contentInsets(for _: QMUIZoomImageViewVideoToolbar, in _: QMUIZoomImageView) -> UIEdgeInsets {
        return UIEdgeInsets(top: 25, left: 25, bottom: 25, right: 18)
    }
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

    public weak var delegate: QMUIZoomImageViewDelegate?

    /**
     * 比如常见的上传头像预览界面中间有一个用于裁剪的方框，则 viewportRect 必须被设置为这个方框在 zoomImageView 坐标系内的 frame，否则拖拽图片或视频时无法正确限制它们的显示范围
     * @note 图片或视频的初始位置会位于 viewportRect 正中间
     * @note 如果想要图片覆盖整个 viewportRect，将 contentMode 设置为 UIViewContentModeScaleAspectFill 即可
     * 如果设置为 CGRectZero 则表示使用默认值，默认值为和整个 zoomImageView 一样大
     */
    public var viewportRect: CGRect = .zero

    // Default 2
    public var maximumZoomScale: CGFloat = 2 {
        didSet {
            scrollView.maximumZoomScale = maximumZoomScale
        }
    }

    /// 设置当前要显示的图片，会把 livePhoto/video 相关内容清空，因此注意不要直接通过 imageView.image 来设置图片。
    public weak var image: UIImage? {
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

    private var videoPlayerView: QMUIZoomImageVideoPlayerView?
    private var videoPlayer: AVPlayer?
    private var videoTimeObserver: Any?

    /// 用于显示图片的 UIImageView，注意不要通过 imageView.image 来设置图片，请使用 image 属性。
    public private(set) var imageView: UIImageView? {
        set {
            _imageView = newValue
        }
        get {
            initImageViewIfNeeded()
            return _imageView
        }
    }

    private var _imageView: UIImageView?

    private func initImageViewIfNeeded() {
        if imageView != nil {
            return
        }
        imageView = UIImageView()
        scrollView.addSubview(imageView!)
    }

    /// 设置当前要显示的 Live Photo，会把 image/video 相关内容清空，因此注意不要直接通过 livePhotoView.livePhoto 来设置
    private var livePhotoStorge: Any?
    @available(iOS 9.1, *)
    public weak var livePhoto: PHLivePhoto? {
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
            livePhotoView?.livePhoto = newValue
            livePhotoView?.isHidden = false

            // 更新 livePhotoView 的大小时，livePhotoView 可能已经被缩放过，所以要应用当前的缩放
            livePhotoView?.frame = livePhoto?.size.rect.applying(livePhotoView!.transform) ?? .zero
            revertZooming()
        }
    }

    /// 用于显示 Live Photo 的 view，仅在 iOS 9.1 及以后才有效
    @available(iOS 9.1, *)
    public var livePhotoView: PHLivePhotoView? {
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
        if #available(iOS 9.1, *), livePhotoView == nil {
            livePhotoView = PHLivePhotoView()
            scrollView.addSubview(livePhotoView!)
        }
    }

    /// 用于显示 video 的 layer
    public weak var videoPlayerLayer: AVPlayerLayer? {
        set {
            _videoPlayerLayer = newValue
        }
        get {
            initVideoPlayerLayerIfNeeded()
            return _videoPlayerLayer
        }
    }

    private var _videoPlayerLayer: AVPlayerLayer?

    private func initVideoPlayerLayerIfNeeded() {
        if videoPlayerView != nil {
            return
        }
        videoPlayerView = QMUIZoomImageVideoPlayerView()
        videoPlayerLayer = videoPlayerView?.layer as? AVPlayerLayer
        videoPlayerView?.isHidden = true
        scrollView.addSubview(videoPlayerView!)
    }

    // 播放 video 时底部的工具栏，你可通过此属性来拿到并修改上面的播放/暂停按钮、进度条、Label 等的样式
    // @see QMUIZoomImageViewVideoToolbar
    public private(set) weak var videoToolbar: QMUIZoomImageViewVideoToolbar?

    // 播放 video 时屏幕中央的播放按钮
    public var videoCenteredPlayButton: QMUIButton? {
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
    public var videoCenteredPlayButtonImage = QMUIZoomImageViewImageGenerator.largePlayImage {
        didSet {
            if videoCenteredPlayButton == nil {
                return
            }
            videoCenteredPlayButton?.setImage(videoCenteredPlayButtonImage, for: .normal)
            setNeedsLayout()
        }
    }

    // MARK: - private

    private var videoSize: CGSize = .zero

    private let scrollView = UIScrollView()

    private var isSeekingVideo = false

    public let emptyView = QMUIEmptyView()

    override func didMoveToWindow() {
        // 当 self.window 为 nil 时说明此 view 被移出了可视区域（比如所在的 controller 被 pop 了），此时应该停止视频播放
        if window == nil {
            endPlayingVideo()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentMode = .center

        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.minimumZoomScale = 0
        scrollView.maximumZoomScale = maximumZoomScale
        scrollView.delegate = self
        addSubview(scrollView)

        if let loadingView = emptyView.loadingView as? UIActivityIndicatorView {
            loadingView.color = UIColorWhite
        }
        emptyView.isHidden = true
        addSubview(emptyView)

        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSingleTapGestureWithPoint))
        singleTapGesture.delegate = self
        singleTapGesture.numberOfTapsRequired = 1
        singleTapGesture.numberOfTouchesRequired = 1
        addGestureRecognizer(singleTapGesture)

        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapGestureWithPoint))
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.numberOfTouchesRequired = 1
        addGestureRecognizer(doubleTapGesture)

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture))
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
        videoCenteredPlayButton?.center = CGPoint(x: viewportRect.midX, y: viewportRect.midY)

        let height = videoToolbar?.sizeThatFits(CGSize.max).height ?? 0
        videoToolbar?.frame = CGRect(x: 0, y: bounds.height - height, width: bounds.width, height: height)
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

    override var contentMode: UIViewContentMode {
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
            minScale = min(scaleX, scaleY)
        } else if contentMode == .scaleAspectFill {
            minScale = max(scaleX, scaleY)
        } else if contentMode == .center {
            if scaleX >= 1 && scaleY >= 1 {
                minScale = 1
            } else {
                minScale = min(scaleX, scaleY)
            }
        }
        return minScale
    }

    /**
     *  重置图片或视频的大小，使用的场景例如：相册控件里放大当前图片、划到下一张、再回来，当前的图片或视频应该恢复到原来大小。
     *  注意子类重写需要调一下super。
     */
    public func revertZooming() {
        if bounds.isEmpty {
            return
        }

        let enabledZoomImageView = self.enabledZoomImageView
        let minimumZoomScale = self.minimumZoomScale
        var maximumZoomScale = enabledZoomImageView ? self.maximumZoomScale : minimumZoomScale
        maximumZoomScale = max(minimumZoomScale, maximumZoomScale) // 可能外部通过 contentMode = UIViewContentModeScaleAspectFit 的方式来让小图片撑满当前的 zoomImageView，所以算出来 minimumZoomScale 会很大（至少比 maximumZoomScale 大），所以这里要做一个保护
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
    public var imageViewRectInZoomImageView: CGRect {
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
        var enabledZoom = true
        if let delegate = delegate {
            enabledZoom = delegate.enabledZoomView(in: self)
            return enabledZoom
        }
        if #available(iOS 9.1, *) {
            if image == nil && livePhoto == nil && videoPlayerItem == nil {
                enabledZoom = false
            }
        }
        return enabledZoom
    }

    /// 设置当前要显示的 video ，会把 image/livePhoto 相关内容清空，因此注意不要直接通过 videoPlayerLayer 来设置
    public weak var videoPlayerItem: AVPlayerItem? {
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
            NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: .UIApplicationDidEnterBackground, object: nil)

            configVideoProgressSlider()

            hideViews()
            videoPlayerLayer?.isHidden = false
            videoCenteredPlayButton?.isHidden = false
            videoToolbar?.playButton.isHidden = false

            revertZooming()
        }
    }

    @objc
    private func handlePlayButton(_ button: UIButton) {
        addPlayerTimeObserver()
        videoPlayer?.play()
        videoCenteredPlayButton?.isHidden = true
        videoToolbar?.playButton.isHidden = true
        videoToolbar?.pauseButton.isHidden = false
        if button.tag == kTagForCenteredPlayButton {
            videoToolbar?.isHidden = true
            delegate?.zoomImageView(self, didHideVideoToolbar: true)
        }
    }

    @objc
    private func handlePauseButton() {
        videoPlayer?.pause()
        videoToolbar?.playButton.isHidden = false
        videoToolbar?.pauseButton.isHidden = true
    }

    @objc
    private func handleVideoPlayToEndEvent() {
        videoPlayer?.seek(to: CMTimeMake(0, 1))
        videoCenteredPlayButton?.isHidden = false
        videoToolbar?.playButton.isHidden = false
        videoToolbar?.pauseButton.isHidden = true
    }

    @objc
    private func handleStartDragVideoSlider(_: UISlider) {
        videoPlayer?.pause()
        removePlayerTimeObserver()
    }

    @objc
    private func handleDraggingVideoSlider(_ slider: UISlider) {
        if !isSeekingVideo {
            isSeekingVideo = true
            updateVideoSliderLeftLabel()

            let currentValue = slider.value

            videoPlayer?.seek(to: CMTimeMakeWithSeconds(Float64(currentValue), Int32(NSEC_PER_SEC)), completionHandler: { _ in
                DispatchQueue.main.async {
                    self.isSeekingVideo = false
                }
            })
        }
    }

    @objc
    private func handleFinishDragVideoSlider(_: UISlider) {
        videoPlayer?.play()
        videoCenteredPlayButton?.isHidden = true
        videoToolbar?.playButton.isHidden = true
        videoToolbar?.pauseButton.isHidden = false

        addPlayerTimeObserver()
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
        videoToolbar?.slider.addTarget(self, action: #selector(handleStartDragVideoSlider), for: .touchDown)
        videoToolbar?.slider.addTarget(self, action: #selector(handleDraggingVideoSlider), for: .valueChanged)
        videoToolbar?.slider.addTarget(self, action: #selector(handleFinishDragVideoSlider), for: .touchUpInside)

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
    public func pauseVideo() {
        if videoPlayer == nil {
            return
        }
        handlePauseButton()
        removePlayerTimeObserver()
    }

    /// 停止视频播放，将播放状态重置到初始状态
    public func endPlayingVideo() {
        if videoPlayer == nil {
            return
        }
        videoPlayer?.seek(to: CMTimeMake(0, 1))
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
        if videoToolbar != nil {
            return
        }
        videoToolbar = {
            let b = QMUIZoomImageViewVideoToolbar()
            if let delegate = delegate {
                b.contentInsets = delegate.contentInsets(for: b, in: self)
            }
            b.playButton.addTarget(self, action: #selector(handlePlayButton), for: .touchUpInside)
            b.pauseButton.addTarget(self, action: #selector(handlePauseButton), for: .touchUpInside)
            insertSubview(b, belowSubview: emptyView)
            b.isHidden = true
            return b
        }()
    }

    private func initVideoCenteredPlayButtonIfNeeded() {
        if videoCenteredPlayButton != nil {
            return
        }

        videoCenteredPlayButton = {
            let b = QMUIButton()
            b.qmui_outsideEdge = UIEdgeInsets(top: -60, left: -60, bottom: -60, right: -60)
            b.tag = kTagForCenteredPlayButton
            b.setImage(videoCenteredPlayButtonImage, for: .normal)
            b.sizeToFit()
            b.addTarget(self, action: #selector(handlePlayButton), for: .touchUpInside)
            b.isHidden = true
            insertSubview(b, belowSubview: emptyView)
            return b
        }()
    }

    private func destroyVideoRelatedObjectsIfNeeded() {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)

        NotificationCenter.default.removeObserver(self, name: .UIApplicationDidEnterBackground, object: nil)
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
        delegate?.singleTouch(in: self, location: gesturePoint)
        if videoPlayerItem != nil {
            videoToolbar?.isHidden = !videoToolbar!.isHidden
            delegate?.zoomImageView(self, didHideVideoToolbar: videoToolbar?.isHidden ?? true)
        }
    }

    @objc
    private func handleDoubleTapGestureWithPoint(_ gestureRecognizer: UITapGestureRecognizer) {
        let gesturePoint = gestureRecognizer.location(in: gestureRecognizer.view)
        delegate?.doubleTouch(in: self, location: gesturePoint)

        guard enabledZoomImageView else {
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
            delegate?.longPress(in: self)
        }
    }

    // MARK: - EmptyView

    /**
     *  显示一个 loading
     *  @info 注意 cell 复用可能导致当前页面显示一张错误的旧图片/视频，所以一般情况下需要视情况同时将 image/livePhoto/videoPlayerItem 等属性置为 nil 以清除图片/视频的显示
     */
    public func showLoading() {
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
    public func showEmptyView(with text: String) {
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
    public func hideEmptyView() {
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
    public let playButton = QMUIButton()
    public let pauseButton = QMUIButton()
    public let slider = QMUISlider()
    public let sliderLeftLabel = UILabel()
    public let sliderRightLabel = UILabel()

    // 可通过调整此属性来调整 toolbar 的视觉位置，默认为 {25, 25, 25, 18}
    // 如果同时实现了 QMUIZoomImageViewDelegate 的 contentInsetsForVideoToolbar:inZoomingImageView: 方法，则此处设置的值会覆盖掉 delegate 中返回的值
    public var contentInsets = UIEdgeInsets(top: 25, left: 25, bottom: 25, right: 18) {
        didSet {
            setNeedsLayout()
        }
    }

    // 可通过这些属性修改 video 播放时屏幕底部工具栏的播放/暂停图标
    public var playButtonImage = QMUIZoomImageViewImageGenerator.smallPlayImage {
        didSet {
            playButton.setImage(playButtonImage, for: .normal)
            setNeedsLayout()
        }
    }

    public var pauseButtonImage = QMUIZoomImageViewImageGenerator.pauseImage {
        didSet {
            pauseButton.setImage(pauseButtonImage, for: .normal)
            setNeedsLayout()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = UIColorMakeWithRGBA(0.5, 255, 0, 0)

        playButton.qmui_outsideEdge = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)
        playButton.setImage(playButtonImage, for: .normal)
        addSubview(playButton)

        pauseButton.qmui_outsideEdge = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)
        pauseButton.setImage(pauseButtonImage, for: .normal)
        addSubview(pauseButton)

        slider.minimumTrackTintColor = UIColorMake(195, 195, 195)
        slider.maximumTrackTintColor = UIColorMake(95, 95, 95)
        slider.thumbSize = CGSize(width: 12, height: 12)
        slider.thumbColor = UIColorWhite
        addSubview(slider)

        sliderLeftLabel.font = UIFontMake(12)
        sliderLeftLabel.textColor = UIColorWhite
        sliderLeftLabel.textAlignment = .center
        addSubview(sliderLeftLabel)

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
        playButton.frame = CGRect(origin: CGPoint(x: contentInsets.left, y: contentHeight / 2 - playButtonSize.height / 2 + contentInsets.top), size: playButtonSize).flatted

        let pauseButtonSize = pauseButton.sizeThatFits(CGSize.max)
        pauseButton.frame = CGRect(origin: CGPoint(x: playButton.frame.midX - pauseButtonSize.width / 2, y: playButton.frame.midX - pauseButtonSize.height / 2), size: pauseButtonSize).flatted

        let timeLabelWidth: CGFloat = 55
        let marginLeft: CGFloat = 19
        sliderLeftLabel.frame = CGRect(x: playButton.frame.maxX + marginLeft, y: contentInsets.top, width: timeLabelWidth, height: contentHeight).flatted

        sliderRightLabel.frame = CGRect(x: bounds.width - contentInsets.right - timeLabelWidth, y: contentInsets.top, width: timeLabelWidth, height: contentHeight).flatted

        let marginToLabel: CGFloat = 4
        let x = sliderLeftLabel.frame.maxX + marginToLabel
        slider.frame = CGRect(x: x, y: contentInsets.top, width: sliderRightLabel.frame.minX - marginToLabel - x, height: contentHeight).flatted
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var result = size
        let contentHeight = maxHeightAmongViews([playButton, pauseButton, sliderLeftLabel, sliderRightLabel, slider])
        result.height = contentHeight + contentInsets.verticalValue
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

class QMUIZoomImageViewImageGenerator {

    private static let iconsColor = UIColorMakeWithRGBA(0, 0, 0, 0.25)

    static var largePlayImage: UIImage? {
        let width: CGFloat = 60

        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: width), false, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }

        context.setStrokeColor(UIColorMakeWithRGBA(255, 255, 255, 0.75).cgColor)

        // circle outside
        context.setFillColor(iconsColor.cgColor)
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
        context.setFillColor(iconsColor.cgColor)
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

    static var smallPlayImage: UIImage? {
        // width and height are equal
        let width: CGFloat = 17

        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: width), false, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }

        context.setFillColor(iconsColor.cgColor)
        let path = trianglePath(with: width)
        path.fill()

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    static var pauseImage: UIImage? {
        let size = CGSize(width: 12, height: 18)

        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }

        context.setStrokeColor(iconsColor.cgColor)
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
