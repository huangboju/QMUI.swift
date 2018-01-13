//
//  QMUICollectionViewPagingLayout.swift
//  QMUI.swift
//
//  Created by xnxin on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

enum QMUICollectionViewPagingLayoutStyle {
    case `default` // 普通模式，水平滑动
    case scale // 缩放模式，两边的item会小一点，逐渐向中间放大
    case rotation // 旋转模式，围绕底部某个点为中心旋转
}

public let QMUICollectionViewPagingLayoutRotationRadiusAutomatic: CGFloat = -1.0

class QMUICollectionViewPagingLayout: UICollectionViewFlowLayout {

    public private(set) var style: QMUICollectionViewPagingLayoutStyle

    /**
     *  规定超过这个滚动速度就强制翻页，从而使翻页更容易触发。默认为 0.4
     */
    public var velocityForEnsurePageDown: CGFloat = 0.4

    /**
     *  是否支持一次滑动可以滚动多个 item，默认为 true
     */
    public var allowsMultipleItemScroll = true

    /**
     *  规定了当支持一次滑动允许滚动多个 item 的时候，滑动速度要达到多少才会滚动多个 item，默认为 0.7
     *
     *  仅当 allowsMultipleItemScroll 为 YES 时生效
     */
    public var mutipleItemScrollVelocityLimit: CGFloat = 0.7

    // MARK: - ScaleStyle

    /**
     *  中间那张卡片基于初始大小的缩放倍数，默认为 1.0
     */
    public var maximumScale: CGFloat = 1.0

    /**
     *  除了中间之外的其他卡片基于初始大小的缩放倍数，默认为 0.9
     */
    public var minimumScale: CGFloat = 0.9

    // MARK: - RotationStyle

    /**
     *  旋转卡片相关
     *  左右两个卡片最终旋转的角度有 rotationRadius * 90 计算出来
     *  rotationRadius表示旋转的半径
     *  @warning 仅当 style 为 QMUICollectionViewPagingLayoutStyleRotation 时才生效
     */
    private var _rotationRatio: CGFloat = 0
    public var rotationRatio: CGFloat {
        get {
            return validated(rotationRatio: _rotationRatio)
        }
        set {
            _rotationRatio = newValue
        }
    }

    public var rotationRadius: CGFloat = QMUICollectionViewPagingLayoutRotationRadiusAutomatic

    private var finalItemSize: CGSize = .zero

    init(with style: QMUICollectionViewPagingLayoutStyle = .default) {
        self.style = style
        super.init()

        rotationRatio = 0.5
        minimumLineSpacing = 0
        scrollDirection = .horizontal
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepare() {
        super.prepare()

        var itemSize = self.itemSize
        guard let layoutDelegate = self.collectionView?.delegate as? UICollectionViewDelegateFlowLayout,
            let collectionView = self.collectionView else {
            return
        }
        if layoutDelegate.responds(to: #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:sizeForItemAt:))) {
            itemSize = layoutDelegate
                .collectionView?(collectionView, layout: self, sizeForItemAt: IndexPath(row: 0, section: 0)) ?? .zero
        }

        finalItemSize = itemSize
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if style == .scale || style == .rotation {
            return true
        }

        guard let notNilCollectionView = collectionView else {
            return true
        }
        return !notNilCollectionView.bounds.size.equalTo(newBounds.size)
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        if style == .default {
            return super.layoutAttributesForElements(in: rect)
        }

        var resultAttributes = super.layoutAttributesForElements(in: rect)
        let offset = collectionView?.bounds.midX ?? 0
        let itemSize = finalItemSize

        if style == .scale {
            let distanceForMinimumScale = itemSize.width + minimumLineSpacing
            let distanceForMaximumScale: CGFloat = 0.0

            resultAttributes = resultAttributes?.map { attribute in
                var scale: CGFloat = 0
                let distance = fabs(offset - attribute.center.x)
                if distance >= distanceForMinimumScale {
                    scale = self.minimumScale
                } else if distance == distanceForMaximumScale {
                    scale = self.maximumScale
                } else {
                    scale = self.minimumScale + (distanceForMinimumScale - distance) * (self.maximumScale - self.minimumScale) / (distanceForMinimumScale - distanceForMaximumScale)
                }

                attribute.transform3D = CATransform3DMakeScale(scale, scale, 1)
                attribute.zIndex = 1
                return attribute
            }

            return resultAttributes
        }

        if style == .rotation {
            if rotationRadius == QMUICollectionViewPagingLayoutRotationRadiusAutomatic {
                rotationRadius = itemSize.height
            }

            var centerAttribute: UICollectionViewLayoutAttributes?
            var centerMin: CGFloat = 10000

            resultAttributes = resultAttributes?.map { attribute in
                let distance = self.collectionView?.contentOffset.x ?? 0 +
                    (self.collectionView?.bounds.width ?? 0) / 2.0 -
                    attribute.center.x
                let degress = -90 * self.rotationRatio * (distance / (self.collectionView?.bounds.width ?? 1))

                let cosValue = abs(cos(AngleWithDegrees(degress)))
                let translateY = self.rotationRadius - self.rotationRadius * cosValue
                var transform = CGAffineTransform(translationX: 0, y: translateY)
                transform = transform.rotated(by: AngleWithDegrees(degress))
                attribute.transform = transform
                attribute.zIndex = 1
                if fabs(distance) < centerMin {
                    centerMin = fabs(distance)
                    centerAttribute = attribute
                }
                return attribute
            }
            centerAttribute?.zIndex = 10
            return resultAttributes
        }

        return resultAttributes
    }

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {

        var proposedContentOffset = proposedContentOffset
        let itemSpacing = finalItemSize.width + minimumLineSpacing

        if !allowsMultipleItemScroll || fabs(velocity.x) <= fabs(mutipleItemScrollVelocityLimit) {
            // 只滚动一页

            let contentOffset = collectionView?.contentOffset ?? .zero

            if fabs(velocity.x) > velocityForEnsurePageDown {
                // 为了更容易触发翻页，这里主动增加滚动位置
                let scrollingToRight = proposedContentOffset.x < contentOffset.x
                proposedContentOffset = CGPoint(x: contentOffset.x + (itemSpacing / 2) * (scrollingToRight ? -1 : 1), y: contentOffset.y)
            } else {
                proposedContentOffset = contentOffset
            }
        }

        proposedContentOffset.x = round(proposedContentOffset.x / itemSpacing) * itemSpacing

        return proposedContentOffset
    }

    private func validated(rotationRatio: CGFloat) -> CGFloat {
        return max(min(1.0, rotationRatio), 0.0)
    }
}
