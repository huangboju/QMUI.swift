//
//  QMUIImagePreviewViewController.swift
//  QMUI.swift
//
//  Created by 黄伯驹 on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

/**
 *  图片预览控件，主要功能由内部自带的 QMUIImagePreviewView 提供，由于以 viewController 的形式存在，所以适用于那种在单独界面里展示图片，或者需要从某张目标图片的位置以动画的形式放大进入预览界面的场景。
 *
 *  使用方式：
 *
 *  1. 使用 init 方法初始化
 *  2. 添加 imagePreviewView 的 delegate
 *  3. 分两种查看方式：
 *      1. 如果是左右 push 进入新界面查看图片，则直接按普通 UIViewController 的方式 push 即可；
 *      2. 如果需要从指定图片位置以动画的形式放大进入预览，则调用 startPreviewFromRectInScreen:，传入一个 rect 即可开始预览，这种模式下会创建一个独立的 UIWindow 用于显示 QMUIImagePreviewViewController，所以可以达到盖住当前界面所有元素（包括顶部状态栏）的效果。
 *
 *  @see QMUIImagePreviewView
 */
class QMUIImagePreviewViewController: QMUICommonViewController {

    private var _imagePreviewView: QMUIImagePreviewView?
    var imagePreviewView: QMUIImagePreviewView? {
        get {
            if #available(iOS 9.0, *) {
                loadViewIfNeeded()
            } else {
                view.alpha = 1
            }
            return _imagePreviewView
        }
    }

    var backgroundColor = UIColorBlack {
        didSet {
            if isViewLoaded {
                view.backgroundColor = backgroundColor
            }
        }
    }

    private var previewWindow: UIWindow?
    private var shouldStartWithFading = false
    private var previewFromRect: CGRect = .zero
    private var transitionCornerRadius: CGFloat = 0
    private var transitionImageView: UIImageView!
    private var backgroundColorTemporarily: UIColor?

    override func didInitialized() {
        super.didInitialized()
        automaticallyAdjustsScrollViewInsets = false
        backgroundColor = UIColorBlack
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = backgroundColor
    }

    override func initSubviews() {
        super.initSubviews()
        _imagePreviewView = QMUIImagePreviewView(frame: view.bounds)
        view.addSubview(imagePreviewView!)
        
        transitionImageView = UIImageView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imagePreviewView?.frame = view.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        imagePreviewView?.collectionView.reloadData()

        if previewWindow != nil && !shouldStartWithFading {
            // 为在 viewDidAppear 做动画做准备
            imagePreviewView?.collectionView.isHidden = true
        } else {
            imagePreviewView?.collectionView.isHidden = false
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // 配合 QMUIImagePreviewViewController (UIWindow) 使用的
        if previewWindow != nil {

            if shouldStartWithFading {
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveOut, animations: {
                    self.view.alpha = 1
                }, completion: { _ in
                    self.imagePreviewView?.collectionView.isHidden = false
                    self.shouldStartWithFading = false
                })
                return
            }

            guard let zoomImageView = imagePreviewView?.zoomImageView(at: imagePreviewView!.currentImageIndex) else {
                assert(false, "第 \(imagePreviewView!.currentImageIndex) 个 zoomImageView 不存在，可能当前还处于非可视区域")
            }
            let transitionFromRect = previewFromRect

            let transitionToRect = view.convert(zoomImageView.imageViewRectInZoomImageView, from: zoomImageView.superview)

            transitionImageView.contentMode = zoomImageView.imageView!.contentMode
            transitionImageView.image = zoomImageView.imageView?.image
            transitionImageView.frame = transitionFromRect
            transitionImageView.clipsToBounds = true
            transitionImageView.layer.cornerRadius = transitionCornerRadius
            view.addSubview(transitionImageView)

            UIView.animate(withDuration: 0.2, delay: 0, options: .curveOut, animations: {
                self.transitionImageView.frame = transitionToRect
                self.transitionImageView.layer.cornerRadius = 0
                self.view.backgroundColor = self.backgroundColorTemporarily
            }, completion: { _ in
                self.transitionImageView.removeFromSuperview()
                self.imagePreviewView?.collectionView.isHidden = false
                self.backgroundColorTemporarily = nil
            })
        }
    }

    // MARK: - 动画
    private func initPreviewWindowIfNeeded() {
        if previewWindow == nil {
            previewWindow = UIWindow()
            previewWindow?.windowLevel = UIWindow.Level(rawValue: UIWindowLevelQMUIImagePreviewView)
            previewWindow?.backgroundColor = UIColorClear
        }
    }

    private func removePreviewWindow() {
        previewWindow?.isHidden = false
        previewWindow?.rootViewController = nil
        previewWindow = nil
    }

    private func startPreviewWithFadingAnimation(_ isFading: Bool, orFromRect rect: CGRect) {
        shouldStartWithFading = isFading

        if isFading {
            // 为动画做准备，先置为透明
            view.alpha = 0

        } else {
            previewFromRect = rect

            // 为动画做准备，先置为透明
            backgroundColorTemporarily = view.backgroundColor
            view.backgroundColor = UIColorClear
        }

        initPreviewWindowIfNeeded()

        previewWindow?.rootViewController = self
        previewWindow?.isHidden = false
    }

    private func endPreviewWithFadingAnimation(_ isFading: Bool, orToRect rect: CGRect) {

        if isFading {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveOut, animations: {
                self.view.alpha = 0
            }, completion: { _ in
                self.removePreviewWindow()
                self.view.alpha = 1
            })
            return
        }

        let zoomImageView = imagePreviewView?.zoomImageView(at: imagePreviewView!.currentImageIndex)
        let transitionFromRect = zoomImageView!.imageViewRectInZoomImageView
        let transitionToRect = rect

        transitionImageView.image = zoomImageView?.image
        transitionImageView.frame = transitionFromRect
        view.addSubview(transitionImageView!)
        imagePreviewView?.collectionView.isHidden = true

        backgroundColorTemporarily = view.backgroundColor

        UIView.animate(withDuration: 0.2, delay: 0, options: .curveOut, animations: {
            self.transitionImageView.frame = transitionToRect
            self.transitionImageView.layer.cornerRadius = self.transitionCornerRadius
            self.view.backgroundColor = UIColorClear
        }, completion: { _ in
            self.removePreviewWindow()
            self.transitionImageView.removeFromSuperview()
            self.imagePreviewView?.collectionView.isHidden = false
            self.view.backgroundColor = self.backgroundColorTemporarily
            self.backgroundColorTemporarily = nil
        })
    }
}

// MARK: - UIWindow
/**
 *  以 UIWindow 的形式来预览图片，优点是能盖住界面上所有元素（包括状态栏），缺点是无法进行 viewController 的界面切换（因为被 UIWindow 盖住了）
 */
extension QMUIImagePreviewViewController {
    /**
     *  从指定 rect 的位置以动画的形式进入预览
     *  @param rect 在当前屏幕坐标系里的 rect，注意传进来的 rect 要做坐标系转换，例如：[view.superview convertRect:view.frame toView:nil]
     *  @param cornerRadius 做打开动画时是否要从某个圆角渐变到 0
     */
    func startPreviewFromRectInScreen(_ rect: CGRect, cornerRadius: CGFloat = 0) {
        transitionCornerRadius = cornerRadius
        startPreviewWithFadingAnimation(false, orFromRect: rect)
    }

    /**
     *  将当前图片缩放到指定 rect 的位置，然后退出预览
     *  @param rect 在当前屏幕坐标系里的 rect，注意传进来的 rect 要做坐标系转换，例如：[view.superview convertRect:view.frame toView:nil]
     */
    func endPreviewToRectInScreen(_ rect: CGRect) {
        endPreviewWithFadingAnimation(false, orToRect: rect)
        transitionCornerRadius = 0
    }

    /**
     *  以渐现的方式开始图片预览
     */
    func startPreviewFading() {
        transitionCornerRadius = 0
        startPreviewWithFadingAnimation(true, orFromRect: .zero)
    }

    /**
     *  使用渐隐的动画退出图片预览
     */
    func endPreviewFading() {
        endPreviewWithFadingAnimation(true, orToRect: .zero)
        transitionCornerRadius = 0
    }
}
