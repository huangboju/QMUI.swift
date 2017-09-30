//
//  QMUIImagePreviewView.swift
//  QMUI.swift
//
//  Created by 黄伯驹 on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

enum QMUIImagePreviewMediaType {
    case image
    case livePhoto
    case video
    case others
};

protocol QMUIImagePreviewViewDelegate: QMUIZoomImageViewDelegate {

func numberOfImages(in imagePreviewView: QMUIImagePreviewView) -> Int
func imagePreviewView(_ imagePreviewView: QMUIImagePreviewView, renderZoomImageView zoomImageView:QMUIZoomImageView, at index: Int)

// 返回要展示的媒体资源的类型（图片、live photo、视频），如果不实现此方法，则 QMUIImagePreviewView 将无法选择最合适的 cell 来复用从而略微增大系统开销
    func imagePreviewView(_ imagePreviewView: QMUIImagePreviewView, assetTypeAt index: Int) -> QMUIImagePreviewMediaType


/**
 *  当左右的滚动停止时会触发这个方法
 *  @param  imagePreviewView 当前预览的 QMUIImagePreviewView
 *  @param  index 当前滚动到的图片所在的索引
 */
    func imagePreviewView(_ imagePreviewView: QMUIImagePreviewView, didScrollToIndex: Int)

/**
 *  在滚动过程中，如果某一张图片的边缘（左/右）经过预览控件的中心点时，就会触发这个方法
 *  @param  imagePreviewView 当前预览的 QMUIImagePreviewView
 *  @param  index 当前滚动到的图片所在的索引
 */
    func imagePreviewView(_ imagePreviewView: QMUIImagePreviewView, willScrollHalfTo index: Int)

}

extension QMUIImagePreviewViewDelegate {
    func imagePreviewView(_ imagePreviewView: QMUIImagePreviewView, assetTypeAt index: Int) -> QMUIImagePreviewMediaType {
        return .others
    }

    func imagePreviewView(_ imagePreviewView: QMUIImagePreviewView, didScrollToIndex: Int) {}

    func imagePreviewView(_ imagePreviewView: QMUIImagePreviewView, willScrollHalfTo index: Int) {}
}

class QMUIImagePreviewView: UIView {
    public weak var delegate: QMUIImagePreviewViewDelegate?

    /// 获取当前正在查看的图片 index，也可强制将图片滚动到指定的 index
    public var currentImageIndex = 0

    /**
     *  获取某个 index 对应的 zoomImageView
     *  @return 指定的 index 所在的 zoomImageView，若该 index 对应的图片当前不可见（不处于可视区域），则返回 nil
     */
    func zoomImageView(at index: Int) -> QMUIZoomImageView {
//        let cell = (QMUIImagePreviewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
        return QMUIZoomImageView()
    }
}
