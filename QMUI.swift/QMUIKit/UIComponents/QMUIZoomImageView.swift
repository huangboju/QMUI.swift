//
//  QMUIZoomImageView.swift
//  QMUI.swift
//
//  Created by 黄伯驹 on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

import Photos

protocol QMUIZoomImageViewDelegate: class {
    func singleTouch(in zoomingImageView: QMUIZoomImageView, location: CGPoint)
    func doubleTouch(in zoomingImageView: QMUIZoomImageView, location: CGPoint)
    func longPress(in zoomingImageView: QMUIZoomImageView )
    /**
     *  告知 delegate 在视频预览界面里，由于用户点击了空白区域或播放视频等导致了底部的视频工具栏被显示或隐藏
     *  @param didHide 如果为 YES 则表示工具栏被隐藏，NO 表示工具栏被显示了出来
     */
    func zoomImageView(_ imageView: QMUIZoomImageView, didHideVideoToolbar didHide: Bool)
    
    /// 是否支持缩放，默认为 YES
    func enabledZoomView(in zoomImageView: QMUIZoomImageView) -> Bool
    
    // 可通过此方法调整视频播放时底部 toolbar 的视觉位置，默认为 {25, 25, 25, 18}
    // 如果同时设置了 QMUIZoomImageViewVideoToolbar 实例的 contentInsets 属性，则这里设置的值将不再生效
    func contentInsets(for videoToolbar: QMUIZoomImageViewVideoToolbar, in zoomingImageView:QMUIZoomImageView) -> UIEdgeInsets
}

extension QMUIZoomImageViewDelegate {
    func singleTouch(in zoomingImageView: QMUIZoomImageView, location: CGPoint) {}
    func doubleTouch(in zoomingImageView: QMUIZoomImageView, location: CGPoint) {}
    func longPress(in zoomingImageView: QMUIZoomImageView ) {}

    func zoomImageView(_ imageView: QMUIZoomImageView, didHideVideoToolbar didHide: Bool) {}

    func enabledZoomView(in zoomImageView: QMUIZoomImageView) -> Bool {
        return true
    }

    func contentInsets(for videoToolbar: QMUIZoomImageViewVideoToolbar, in zoomingImageView:QMUIZoomImageView) -> UIEdgeInsets {
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

    /// 设置当前要显示的 Live Photo，会把 image/video 相关内容清空，因此注意不要直接通过 livePhotoView.livePhoto 来设置
    @available(iOS 9.1, *)
    public weak var livePhoto: PHLivePhoto?

    /// 设置当前要显示的 video ，会把 image/livePhoto 相关内容清空，因此注意不要直接通过 videoPlayerLayer 来设置
    public weak var videoPlayerItem: AVPlayerItem?

    /// 设置当前要显示的图片，会把 livePhoto/video 相关内容清空，因此注意不要直接通过 imageView.image 来设置图片。
    public weak var image: UIImage?

    public let emptyView = QMUIEmptyView()
    
    /**
     *  显示一个 loading
     *  @info 注意 cell 复用可能导致当前页面显示一张错误的旧图片/视频，所以一般情况下需要视情况同时将 image/livePhoto/videoPlayerItem 等属性置为 nil 以清除图片/视频的显示
     */
    public func showLoading() {

    }

    /**
     *  将 emptyView 隐藏
     */
    public func hideEmptyView() {

    }
    
    /**
     *  重置图片或视频的大小，使用的场景例如：相册控件里放大当前图片、划到下一张、再回来，当前的图片或视频应该恢复到原来大小。
     *  注意子类重写需要调一下super。
     */
    public func revertZooming() {

    }
    
    public func endPlayingVideo() {
        
    }
}

class QMUIZoomImageViewVideoToolbar: UIView {
    // 可通过调整此属性来调整 toolbar 的视觉位置，默认为 {25, 25, 25, 18}
    // 如果同时实现了 QMUIZoomImageViewDelegate 的 contentInsetsForVideoToolbar:inZoomingImageView: 方法，则此处设置的值会覆盖掉 delegate 中返回的值
    public var contentInsets = UIEdgeInsets(top: 25, left: 25, bottom: 25, right: 18)
}
