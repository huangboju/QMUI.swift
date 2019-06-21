//
//  QMUIEmotionView.swift
//  QMUI.swift
//
//  Created by 黄伯驹 on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

/**
 *  代表一个表情的数据对象
 */
class QMUIEmotion: NSObject {
    /// 当前表情的标识符，可用于区分不同表情
    var identifier: String

    /// 当前表情展示出来的名字，可用于输入框里的占位文字，例如“[委屈]”
    var displayName: String

    /// 表情对应的图片。若表情图片存放于项目内，则建议用当前表情的`identifier`作为图片名
    var image: UIImage?
    
    /// 生成一个`QMUIEmotion`对象，并且以`identifier`为图片名在当前项目里查找，作为表情的图片
    ///
    /// - Parameters:
    ///   - identifier: 表情的标识符，也会被当成图片的名字
    ///   - displayName: 表情展示出来的名字
    ///   - image: 展示的图片
    init(identifier: String, displayName: String, image: UIImage? = nil) {
        self.identifier = identifier
        self.displayName = displayName
        self.image = image
    }

    override var description: String {
        return "\(super.description) identifier: \(identifier), displayName: \(displayName)"
    }
}

@objc fileprivate protocol QMUIEmotionPageViewDelegate: NSObjectProtocol {
    @objc optional func emotionPageView(_ emotionPageView: QMUIEmotionPageView, didSelectEmotion emotion: QMUIEmotion, at index: Int)
    @objc optional func didSelectDeleteButton(in emotionPageView: QMUIEmotionPageView)
}

/**
 *  表情控件，支持任意表情的展示，每个表情以相同的大小显示。
 *
 *  使用方式：
 *
 *  - 通过`initWithFrame:`初始化，如果面板高度不变，建议在init时就设置好，若最终布局以父类的`layoutSubviews`为准，则也可通过`init`方法初始化，再在`layoutSubviews`里计算布局
 *  - 通过调整`paddingInPage`、`emotionSize`等变量来自定义UI
 *  - 通过`emotions`设置要展示的表情
 *  - 通过`didSelectEmotionBlock`设置选中表情时的回调，通过`didSelectDeleteButtonBlock`来响应面板内的删除按钮
 *  - 为`sendButton`添加`addTarget:action:forState:`事件，从而触发发送逻辑
 *
 *  本控件支持通过`UIAppearance`设置全局的默认样式。若要修改控件内的`UIPageControl`的样式，可通过`[UIPageControl appearanceWhenContainedIn:[QMUIEmotionView class], nil]`的方式来修改。
 */
class QMUIEmotionView: UIView {
    /// 要展示的所有表情
    var emotions: [QMUIEmotion] = [] {
        didSet {
            pageEmotions()
        }
    }

    /**
     *  选中表情时的回调
     *  @argv  index   被选中的表情在`emotions`里的索引
     *  @argv  emotion 被选中的表情对应的`QMUIEmotion`对象
     *  @see QMUIEmotion
     */
    var didSelectEmotionClosure: ((Int, QMUIEmotion) -> Void)?

    /// 删除按钮的点击事件回调
    var didSelectDeleteButtonClosure: (() -> Void)?

    /// 用于展示表情面板的横向滚动collectionView，布局撑满整个控件
    private(set) var collectionView: UICollectionView!

    /// 用于横向按页滚动的collectionViewLayout
    private(set) var collectionViewLayout: UICollectionViewFlowLayout!

    /// 控件底部的分页控件，可点击切换表情页面
    private(set) var pageControl: UIPageControl!

    /// 控件右下角的发送按钮
    private(set) var sendButton: QMUIButton!

    /// 每一页表情的上下左右padding，默认为{18, 18, 65, 18}
    var paddingInPage = UIEdgeInsets(top: 18, left: 18, bottom: 65, right: 18)

    /// 每一页表情允许的最大行数，默认为4
    var numberOfRowsPerPage = 4

    /// 表情的图片大小，不管`QMUIEmotion.image.size`多大，都会被缩放到`emotionSize`里显示，默认为{30, 30}
    var emotionSize = CGSize(width: 30, height: 30)

    /// 表情点击时的背景遮罩相对于`emotionSize`往外拓展的区域，负值表示遮罩比表情还大，正值表示遮罩比表情还小，默认为{-3, -3, -3, -3}
    var emotionSelectedBackgroundExtension = UIEdgeInsets(top: -3, left: -3, bottom: -3, right: -3)

    /// 表情与表情之间的最小水平间距，默认为10
    var minimumEmotionHorizontalSpacing: CGFloat = 10

    /// 表情面板右下角的删除按钮的图片，默认为`QMUIHelper.image(name: "QMUI_emotion_delete")`
    var deleteButtonImage = QMUIHelper.image(name: "QMUI_emotion_delete")

    /// 发送按钮的文字样式，默认为{NSFontAttributeName: UIFontMake(15), NSForegroundColorAttributeName: UIColorWhite}
    var sendButtonTitleAttributes: [NSAttributedString.Key: Any] = [:] {
        didSet {
            if let title = sendButton.currentTitle {
                sendButton.setAttributedTitle(NSAttributedString(string: title, attributes: sendButtonTitleAttributes), for: .normal)
            }
        }
    }

    /// 发送按钮的背景色，默认为`UIColorBlue`
    var sendButtonBackgroundColor = UIColorBlue {
        didSet {
            sendButton.backgroundColor = sendButtonBackgroundColor
        }
    }

    /// 发送按钮的圆角大小，默认为4
    var sendButtonCornerRadius: CGFloat = 4 {
        didSet {
            sendButton.layer.cornerRadius = sendButtonCornerRadius
        }
    }

    /// 发送按钮布局时的外边距，相对于控件右下角。仅right/bottom有效，默认为{0, 0, 16, 16}
    var sendButtonMargins = UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 16)

    /// 分页控件距离底部的间距，默认为22
    var pageControlMarginBottom: CGFloat = 22

    private var pagedEmotions: [[QMUIEmotion]]!
    private var isDebug = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        didInitialized(with: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        didInitialized(with: .zero)
    }

    func didInitialized(with frame: CGRect) {
        isDebug = false
        
        pagedEmotions = [[]]

        collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = .horizontal
        collectionViewLayout.minimumLineSpacing = 0
        collectionViewLayout.minimumInteritemSpacing = 0
        collectionViewLayout.sectionInset = UIEdgeInsets.zero

        collectionView = UICollectionView(frame: CGRect(x: qmui_safeAreaInsets.left, y: qmui_safeAreaInsets.top, width: frame.width - qmui_safeAreaInsets.horizontalValue, height: frame.height - qmui_safeAreaInsets.verticalValue), collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = UIColorClear
        collectionView.scrollsToTop = false
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(QMUIEmotionPageView.self, forCellWithReuseIdentifier: "page")
        addSubview(collectionView)

        pageControl = UIPageControl()
        pageControl.addTarget(self, action: #selector(handlePageControlEvent(_:)), for: .valueChanged)
        pageControl.pageIndicatorTintColor = UIColor(r: 210, g: 210, b: 210)
        pageControl.currentPageIndicatorTintColor = UIColor(r: 162, g: 162, b: 162)
        addSubview(pageControl)

        sendButton = QMUIButton()
        sendButton.setTitle("发送", for: .normal)
        sendButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 17, bottom: 5, right: 17)
        sendButton.sizeToFit()
        addSubview(sendButton)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let collectionViewFrame = bounds.insetEdges(qmui_safeAreaInsets)
        let collectionViewSizeChanged = collectionView.bounds.size != collectionViewFrame.size
        collectionViewLayout.itemSize = collectionView.bounds.size // 先更新 itemSize 再设置 collectionView.frame，否则会触发系统的 UICollectionViewFlowLayoutBreakForInvalidSizes 断点
        collectionView.frame = collectionViewFrame
        
        if collectionViewSizeChanged {
            pageEmotions()
        }
        
        sendButton.qmui_right = qmui_width - qmui_safeAreaInsets.right - sendButtonMargins.right
        sendButton.qmui_bottom = qmui_height - qmui_safeAreaInsets.bottom - sendButtonMargins.bottom
        

        let pageControlHeight: CGFloat = 16
        let pageControlMaxX: CGFloat = sendButton.qmui_left
        let pageControlMinX: CGFloat = qmui_width - pageControlMaxX
        
        pageControl.frame = CGRect(x: pageControlMinX, y: qmui_height - qmui_safeAreaInsets.bottom - pageControlMarginBottom - pageControlHeight, width: pageControlMaxX - pageControlMinX, height: pageControlHeight)
    }

    private func pageEmotions() {
        pagedEmotions.removeAll(keepingCapacity: true)
        pageControl.numberOfPages = 0

        if !collectionView.bounds.isEmpty && !emotions.isEmpty && !emotionSize.isEmpty {
            let contentWidthInPage = collectionView.bounds.width - paddingInPage.horizontalValue
            let maximumEmotionCountPerRowInPage = (contentWidthInPage + minimumEmotionHorizontalSpacing) / (emotionSize.width + minimumEmotionHorizontalSpacing)
            let maximumEmotionCountPerPage = Int(maximumEmotionCountPerRowInPage * CGFloat(numberOfRowsPerPage) - 1) // 删除按钮占一个表情位置
            let pageCount = Int(ceil(Float(emotions.count) / Float(maximumEmotionCountPerPage)))
            for i in 0 ..< pageCount {
                let startIdx = maximumEmotionCountPerPage * i
                // 最后一页可能不满一整页，所以取剩余的所有表情即可
                var endIdx = maximumEmotionCountPerPage
                if maximumEmotionCountPerPage > emotions.count {
                    endIdx = emotions.count - startIdx
                }
                let emotionForPage = emotions[startIdx ..< endIdx]
                pagedEmotions.append(Array(emotionForPage))
            }
            pageControl.numberOfPages = pageCount
        }

        collectionView.reloadData()
        collectionView.qmui_scrollToTop()
    }

    @objc func handlePageControlEvent(_ pageControl: UIPageControl) {
        collectionView.scrollToItem(at: IndexPath(row: pageControl.currentPage, section: 0), at: .centeredHorizontally, animated: true)
    }
}

extension QMUIEmotionView: QMUIEmotionPageViewDelegate {
    fileprivate func emotionPageView(_: QMUIEmotionPageView, didSelectEmotion emotion: QMUIEmotion, at _: Int) {
        guard let i = emotions.firstIndex(of: emotion) else { return }
        didSelectEmotionClosure?(i, emotion)
    }

    fileprivate func didSelectDeleteButton(in _: QMUIEmotionPageView) {
        didSelectDeleteButtonClosure?()
    }
}

extension QMUIEmotionView: UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return pagedEmotions.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "page", for: indexPath)
        let pageView = cell as? QMUIEmotionPageView
        pageView?.delegate = self
        pageView?.emotions = pagedEmotions[indexPath.item]
        pageView?.padding = paddingInPage
        pageView?.numberOfRows = numberOfRowsPerPage
        pageView?.emotionSize = emotionSize
        pageView?.emotionSelectedBackgroundExtension = emotionSelectedBackgroundExtension
        pageView?.minimumEmotionHorizontalSpacing = minimumEmotionHorizontalSpacing
        pageView?.deleteButton.setImage(deleteButtonImage, for: .normal)
        pageView?.deleteButton.setImage(deleteButtonImage?.qmui_image(alpha: ButtonHighlightedAlpha), for: .highlighted)
        pageView?.isDebug = isDebug
        pageView?.setNeedsDisplay()
        return cell
    }
}

extension QMUIEmotionView: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            let currentPage = round(scrollView.contentOffset.x / scrollView.bounds.width)
            pageControl.currentPage = Int(currentPage)
        }
    }
}

/// 表情面板每一页的cell，在drawRect里将所有表情绘制上去，同时自带一个末尾的删除按钮
fileprivate class QMUIEmotionPageView: UICollectionViewCell {
    fileprivate weak var delegate: (QMUIEmotionView & QMUIEmotionPageViewDelegate)?

    /// 表情被点击时盖在表情上方用于表示选中的遮罩
    fileprivate var emotionSelectedBackgroundView: UIView!

    /// 表情面板右下角的删除按钮
    fileprivate var deleteButton: QMUIButton!

    /// 分配给当前pageView的所有表情
    fileprivate var emotions: [QMUIEmotion]?

    /// 记录当前pageView里所有表情的可点击区域的rect，在drawRect:里更新，在tap事件里使用
    fileprivate var emotionHittingRects: [CGRect]!

    /// 负责实现表情的点击
    fileprivate var tapGestureRecognizer: UITapGestureRecognizer!

    /// 整个pageView内部的padding
    fileprivate var padding: UIEdgeInsets = .zero

    /// 每个pageView能展示表情的行数
    fileprivate var numberOfRows: Int = 0

    /// 每个表情的绘制区域大小，表情图片最终会以UIViewContentModeScaleAspectFit的方式撑满这个大小。表情计算布局时也是基于这个大小来算的。
    fileprivate var emotionSize: CGSize = .zero

    /// 点击表情时出现的遮罩要在表情所在的矩形位置拓展多少空间，负值表示遮罩比emotionSize更大，正值表示遮罩比emotionSize更小。最终判断表情点击区域时也是以拓展后的区域来判定的
    fileprivate var emotionSelectedBackgroundExtension: UIEdgeInsets = .zero

    /// 表情与表情之间的水平间距的最小值，实际值可能比这个要大一点（pageView会把剩余空间分配到表情的水平间距里）
    fileprivate var minimumEmotionHorizontalSpacing: CGFloat = 0

    /// debug模式会把表情的绘制矩形显示出来
    fileprivate var isDebug = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColorClear

        emotionSelectedBackgroundView = UIView()
        emotionSelectedBackgroundView.isUserInteractionEnabled = false
        emotionSelectedBackgroundView.backgroundColor = UIColor(r: 0, g: 0, b: 0, a: 0.16)
        emotionSelectedBackgroundView.layer.cornerRadius = 3
        emotionSelectedBackgroundView.alpha = 0
        addSubview(emotionSelectedBackgroundView)

        deleteButton = QMUIButton()
        deleteButton.adjustsButtonWhenDisabled = false // 去掉QMUIButton默认的高亮动画，从而加快连续快速点击的响应速度
        deleteButton.qmui_automaticallyAdjustTouchHighlightedInScrollView = true
        deleteButton.addTarget(self, action: #selector(handleDeleteButtonEvent), for: .touchUpInside)
        addSubview(deleteButton)

        emotionHittingRects = []
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGestureRecognizer))
        addGestureRecognizer(tapGestureRecognizer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // 删除按钮必定布局到最后一个表情的位置，且与表情上下左右居中
        deleteButton.sizeToFit()

        let deleteButtonW = deleteButton.frame.width
        let deleteButtonH = deleteButton.frame.height

        deleteButton.frame = deleteButton.frame.setXY(flat(bounds.width - padding.right - deleteButtonW - (emotionSize.width - deleteButtonW) / 2.0), flat(bounds.height - padding.bottom - deleteButtonH - (emotionSize.height - deleteButtonH) / 2.0))
    }

    override func draw(_: CGRect) {
        emotionHittingRects.removeAll(keepingCapacity: true)

        let contentSize = bounds.insetEdges(padding).size
        let emotionCountPerRow = (contentSize.width + minimumEmotionHorizontalSpacing) / (emotionSize.width + minimumEmotionHorizontalSpacing)
        let emotionHorizontalSpacing = flat((contentSize.width - emotionCountPerRow * emotionSize.width) / (emotionCountPerRow - 1))
        let numberOfRows = CGFloat(self.numberOfRows)
        let emotionVerticalSpacing = flat((contentSize.height - numberOfRows * emotionSize.height) / (numberOfRows - 1))

        var emotionOrigin = CGPoint.zero

        guard let emotions = emotions else {
            return
        }
        for (index, emotion) in emotions.enumerated() {
            let i = CGFloat(index)
            let row = CGFloat(Int(i / emotionCountPerRow))
            emotionOrigin.x = padding.left + (emotionSize.width + emotionHorizontalSpacing) * i.truncatingRemainder(dividingBy: emotionCountPerRow)
            emotionOrigin.y = padding.top + (emotionSize.height + emotionVerticalSpacing) * row
            let emotionRect = CGRect(origin: emotionOrigin, size: emotionSize)
            let emotionHittingRect = emotionRect.insetEdges(emotionSelectedBackgroundExtension)
            emotionHittingRects.append(emotionHittingRect)
            drawImage(emotion.image, in: emotionRect)
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func drawImage(_ image: UIImage?, in contextRect: CGRect) {
        guard let image = image else { return }
        let imageSize = image.size

        let horizontalRatio = contextRect.width / imageSize.width
        let verticalRatio = contextRect.height / imageSize.height
        // 表情图片按UIViewContentModeScaleAspectFit的方式来绘制
        let ratio = min(horizontalRatio, verticalRatio)
        var drawingRect = CGRect.zero
        drawingRect.size.width = imageSize.width * ratio
        drawingRect.size.height = imageSize.height * ratio
        drawingRect = drawingRect.setXY(contextRect.minXHorizontallyCenter(drawingRect), contextRect.minYVerticallyCenter(drawingRect))
        if isDebug {
            let context = UIGraphicsGetCurrentContext()
            context?.setLineWidth(PixelOne)
            context?.setStrokeColor(UIColorTestRed.cgColor)
            context?.stroke(contextRect.insetBy(dx: PixelOne / 2.0, dy: PixelOne / 2.0))
        }
        image.draw(in: drawingRect)
    }

    @objc func handleDeleteButtonEvent(_: QMUIButton) {
        delegate?.didSelectDeleteButton(in: self)
    }

    @objc func handleTapGestureRecognizer(_ gestureRecognizer: UITapGestureRecognizer) {

        let location = gestureRecognizer.location(in: self)

        guard let emotions = emotions else {
            return
        }
        
        for i in 0 ..< emotionHittingRects.count {

            let rect = emotionHittingRects[i]
            if rect.contains(location) {
                let emotion = emotions[i]
                emotionSelectedBackgroundView.frame = rect
                UIView.animate(withDuration: 0.08, animations: {
                    self.emotionSelectedBackgroundView.alpha = 1
                }, completion: { _ in
                    UIView.animate(withDuration: 0.08, animations: {
                        self.emotionSelectedBackgroundView.alpha = 0
                    })
                })

                delegate?.emotionPageView(self, didSelectEmotion: emotion, at: i)
                if isDebug {
                    print("最终确定了点击的是当前页里的第 %\(i) 个表情，\(emotion)")
                }
                return
            }
        }
    }
}
