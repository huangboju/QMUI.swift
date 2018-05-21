//
//  QDImageViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/4/24.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

class QDImageViewController: QDCommonListViewController {

    private var contentView: UIView!
    private var scrollView: UIScrollView!
    private var methodNameLabel: UILabel!
    
    override func initDataSource() {
        super.initDataSource()
        
        dataSourceWithDetailText = QMUIOrderedDictionary(
            dictionaryLiteral:
            ("- qmui_averageColor", "获取整张图片的平均颜色"),
            ("- qmui_grayImage", "将图片置灰"),
            ("- qmui_imageWithAlpha:", "调整图片的alpha值，返回一张新图片"),
            ("- qmui_imageWithTintColor:", "更改图片的颜色，只支持按路径来渲染图片"),
            ("- qmui_imageWithBlendColor:", "更改图片的颜色，保持图片内容纹理不变"),
            ("- qmui_imageWithImageAbove:atPoint:", "将一张图片叠在当前图片上方的指定位置"),
            ("- qmui_imageWithSpacingExtensionInsets:", "拓展当前图片外部边距，拓展的区域填充透明"),
            ("- qmui_imageWithClippedRect:", "将图片内指定区域的矩形裁剪出来，返回裁剪出来的区域"),
            ("- qmui_imageResizedInLimitedSize:contentMode:", "将当前图片缩放到指定的大小，缩放策略可以指定不同的contentMode，经过缩放后的图片倍数保持不变"),
            ("- qmui_imageResizedInLimitedSize:contentMode:scale:", "同上，只是可以指定倍数"),
            ("- qmui_imageWithOrientation:", "将图片旋转到指定方向，支持上下左右、水平&垂直翻转"),
            ("- qmui_imageWithBorderColor:path:", "在当前图片上叠加绘制一条路径"),
            ("- qmui_imageWithBorderColor:borderWidth:cornerRadius:", "在当前图片上加上一条外边框，可指定边框大小和圆角"),
            ("- qmui_imageWithBorderColor:borderWidth:cornerRadius:dashedLengths:", "同上，但可额外指定边框为虚线"),
            ("- qmui_imageWithBorderColor:borderWidth:borderPosition:", "在当前图片上加上一条边框，可指定边框的位置，支持上下左右"),
            ("- qmui_imageWithMaskImage:usingMaskImageMode:", "用一张图片作为当前图片的遮罩，并返回遮罩后的图片"),
            ("+ qmui_imageWithColor:", "生成一张纯色的矩形图片，默认大小为(4, 4)"),
            ("+ qmui_imageWithColor:size:cornerRadius:", "生成一张纯色的矩形图片，可指定图片的大小和圆角"),
            ("+ qmui_imageWithColor:size:cornerRadiusArray:", "同上，但四个角的圆角值允许不相等"),
            ("+ qmui_imageWithStrokeColor:size:path:addClip:", "将一条路径绘制到指定大小的画图里，并返回生成的图片"),
            ("+ qmui_imageWithStrokeColor:size:lineWidth:cornerRadius:", "生成一张指定大小的矩形图片，背景透明，带描边和圆角"),
            ("+ qmui_imageWithStrokeColor:size:lineWidth:borderPosition:", "生成一张指定大小的矩形图片，允许在各个方向选择添加边框"),
            ("+ qmui_imageWithShape:size:tintColor:", "用预先提供的若干种形状生成一张图片，可选择大小和颜色"),
            ("+ qmui_imageWithShape:size:lineWidth:tintColor:", "同上，但可指定图片内的线条粗细"),
            ("+ qmui_imageWithAttributedString:", "将给定的NSAttributedString渲染为图片（单行）"),
            ("+ qmui_imageWithView:", "生成给定View的截图"),
            ("+ qmui_imageWithView:afterScreenUpdates:", "在当前runloop更新后再生成给定View的截图"))
    }
    
    override func initSubviews() {
        super.initSubviews()
        
        let maximumContentViewWidth = fmin(view.bounds.width, QMUIHelper.screenSizeFor47Inch.width) - 20 * 2
        contentView = UIView(frame: CGRect(x: 0, y: 0, width: maximumContentViewWidth, height: 0))
        contentView.backgroundColor = UIColorWhite
        contentView.layer.cornerRadius = 6
        
        scrollView = UIScrollView(frame: contentView.bounds)
        scrollView.contentInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        scrollView.alwaysBounceHorizontal = false
        scrollView.alwaysBounceVertical = false
        scrollView.scrollsToTop = false
        contentView.addSubview(scrollView)
        
        if #available(iOS 11, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        
        methodNameLabel = UILabel(with: CodeFontMake(16), textColor: QDThemeManager.shared.currentTheme?.themeCodeColor ?? UIColorBlue)
        methodNameLabel.numberOfLines = 0
        methodNameLabel.lineBreakMode = .byCharWrapping
        scrollView.addSubview(methodNameLabel)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = contentView.bounds
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath) as? QMUITableViewCell
        cell?.textLabel?.font = CodeFontMake(14)
        cell?.textLabel?.textColor = QDThemeManager.shared.currentTheme?.themeCodeColor
        cell?.detailTextLabel?.font = UIFontMake(12)
        cell?.detailTextLabel?.textColor = UIColorGray
        cell?.detailTextLabelEdgeInsets = UIEdgeInsets(top: 2, left: 0, bottom: 0, right: 0)
        return cell ?? UITableViewCell()
    }
    
    override func didSelectCell(_ title: String) {
        let contentLimitWidth = contentViewLimitWidth
        methodNameLabel.text = title
        let methodLabelSize = methodNameLabel.sizeThatFits(CGSize(width: contentLimitWidth, height: CGFloat.greatestFiniteMagnitude))
        methodNameLabel.frame = CGRect(x: 0, y: 0, width: contentLimitWidth, height: methodLabelSize.height)
        
        var contentSizeHeight: CGFloat = 0
        if title == "- qmui_averageColor" {
            contentSizeHeight = generateExampleViewForAverageColor()
        } else if title == "- qmui_grayImage" {
            contentSizeHeight = generateExampleViewForGrayImage()
        } else if title == "- qmui_imageWithAlpha:" {
            contentSizeHeight = generateExampleViewForImageWithAlpha()
        } else if title == "- qmui_imageWithTintColor:" {
            contentSizeHeight = generateExampleViewForImageWithTintColor()
        } else if title == "- qmui_imageWithBlendColor:" {
            contentSizeHeight = generateExampleViewForImageWithBlendColor()
        } else if title == "- qmui_imageWithImageAbove:atPoint:" {
            contentSizeHeight = generateExampleViewForImageWithImageAbove()
        } else if title == "- qmui_imageWithSpacingExtensionInsets:" {
            contentSizeHeight = generateExampleViewForImageWithSpacingExtensionInsets()
        } else if title == "- qmui_imageWithClippedRect:" {
            contentSizeHeight = generateExampleViewForImageWithClippedRect()
        } else if title == "- qmui_imageResizedInLimitedSize:contentMode:" || title == "- qmui_imageResizedInLimitedSize:contentMode:scale:" {
            contentSizeHeight = generateExampleViewForResizedImage()
        } else if title == "- qmui_imageWithOrientation:" {
            contentSizeHeight = generateExampleViewForImageWithDirection()
        } else if title == "- qmui_imageWithBorderColor:path:" {
            contentSizeHeight = generateExampleViewForImageWithBorder()
        } else if title == "- qmui_imageWithBorderColor:borderWidth:cornerRadius:" {
            contentSizeHeight = generateExampleViewForImageWithBorderColorAndCornerRadius(with: false)
        } else if title == "- qmui_imageWithBorderColor:borderWidth:cornerRadius:dashedLengths:" {
            contentSizeHeight = generateExampleViewForImageWithBorderColorAndCornerRadius(with: true)
        } else if title == "- qmui_imageWithBorderColor:borderWidth:borderPosition:" {
            contentSizeHeight = generateExampleViewForImageWithBorderColorAndCornerRadiusAndPosition()
        } else if title == "- qmui_imageWithMaskImage:usingMaskImageMode:" {
            contentSizeHeight = generateExampleViewForImageWithMaskImage()
        } else if title == "+ qmui_imageWithColor:" || title == "+ qmui_imageWithColor:size:cornerRadius:" {
            contentSizeHeight = generateExampleViewForImageWithColor()
        } else if title == "+ qmui_imageWithColor:size:cornerRadiusArray:" {
            contentSizeHeight = generateExampleViewForImageWithColorAndCornerRadiusArray()
        } else if title == "+ qmui_imageWithStrokeColor:size:path:addClip:" {
            contentSizeHeight = generateExampleViewForImageWithStrokeColorAndPath()
        } else if title == "+ qmui_imageWithStrokeColor:size:lineWidth:cornerRadius:" {
            contentSizeHeight = generateExampleViewForImageWithStrokeColorAndCornerRadius()
        } else if title == "+ qmui_imageWithStrokeColor:size:lineWidth:borderPosition:" {
            contentSizeHeight = generateExampleViewForImageWithStrokeColorAndBorderPosition()
        } else if title == "+ qmui_imageWithShape:size:tintColor:" || title == "+ qmui_imageWithShape:size:lineWidth:tintColor:" {
            contentSizeHeight = generateExampleViewForImageWithShape()
        } else if title == "+ qmui_imageWithAttributedString:" {
            contentSizeHeight = generateExampleViewForImageWithAttributedString()
        } else if title == "+ qmui_imageWithView:" || title == "+ qmui_imageWithView:afterScreenUpdates:" {
            contentSizeHeight = generateExampleViewForImageWithView()
        }
        
        scrollView.contentSize = CGSize(width: contentLimitWidth, height: contentSizeHeight)
        let contentViewPreferHeight = scrollView.contentInset.verticalValue + scrollView.contentSize.height
        let contentViewLimitHeight = view.bounds.height - 40 * 2
        contentView.frame = contentView.frame.setHeight(fmin(contentViewLimitHeight, contentViewPreferHeight))
        scrollView.frame = contentView.bounds
        
        let modalPresentationViewController = QMUIModalPresentationViewController()
        modalPresentationViewController.maximumContentViewWidth = CGFloat.greatestFiniteMagnitude
        modalPresentationViewController.contentView = contentView
        modalPresentationViewController.didHideByDimmingViewTappedClosure = {[weak self] () -> Void in
            if let strongSelf = self {
                for subview in strongSelf.scrollView.subviews {
                    if (subview != strongSelf.methodNameLabel) {
                        subview.removeFromSuperview()
                    }
                }
            }
        }
        
        modalPresentationViewController.show(true, completion: nil)
        tableView.qmui_clearsSelection()
    }
    
    private var contentViewLimitWidth: CGFloat {
        return scrollView.bounds.width - scrollView.contentInset.horizontalValue
    }
    
    private var contentViewLayoutStartingMinY: CGFloat {
        return methodNameLabel.frame.maxY + 16
    }
    
    // MARK: Example
    private func generateExampleViewForAverageColor() -> CGFloat {
        let contentWidth = contentViewLimitWidth
        var minY = contentViewLayoutStartingMinY
        
        let originImageLabel = UILabel(with: UIFontMake(14), textColor: UIColorBlack)
        originImageLabel.text = "处理前的原图"
        originImageLabel.sizeToFit()
        originImageLabel.frame = originImageLabel.frame.setY(minY)
        scrollView.addSubview(originImageLabel)
        minY = originImageLabel.frame.maxY + 6
        
        let originImageView = UIImageView(image: UIImageMake("image0"))
        originImageView.contentMode = .scaleAspectFit
        originImageView.frame = CGRect(x: 0, y: minY, width: contentWidth, height: flat(contentWidth * (originImageView.image?.size.height ?? 0) / (originImageView.image?.size.width ?? 1)))
        scrollView.addSubview(originImageView)
        minY = originImageView.frame.maxY + 16
        
        let qmui_averageColor = originImageView.image?.qmui_averageColor
        
        let afterLabel = UILabel()
        afterLabel.qmui_setTheSameAppearance(as: originImageLabel)
        afterLabel.text = "计算出的平均色：RGB(\(Int(qmui_averageColor!.qmui_red * 255)), \(Int(qmui_averageColor!.qmui_green * 255)), \(Int(qmui_averageColor!.qmui_blue * 255)))"
        afterLabel.sizeToFit()
        afterLabel.frame = afterLabel.frame.setY(minY)
        scrollView.addSubview(afterLabel)
        minY = afterLabel.frame.maxY + 6
        
        let averageColorView = UIView(frame: CGRect(x: 0, y: minY, width: contentWidth, height: 100))
        averageColorView.backgroundColor = originImageView.image?.qmui_averageColor
        scrollView.addSubview(averageColorView)
        minY = averageColorView.frame.maxY
        
        return minY
    }
    
    private func generateExampleViewForGrayImage() -> CGFloat {
        let contentWidth = contentViewLimitWidth
        var minY = contentViewLayoutStartingMinY
        
        let originImageLabel = UILabel(with: UIFontMake(14), textColor: UIColorBlack)
        originImageLabel.text = "处理前的原图"
        originImageLabel.sizeToFit()
        originImageLabel.frame = originImageLabel.frame.setY(minY)
        scrollView.addSubview(originImageLabel)
        minY = originImageLabel.frame.maxY + 6
        
        let originImageView = UIImageView(image: UIImageMake("image0"))
        originImageView.contentMode = .scaleAspectFit
        originImageView.qmui_sizeToFitKeepingImageAspectRatio(in: CGSize(width: contentWidth, height: CGFloat.greatestFiniteMagnitude))
        originImageView.frame = originImageView.frame.setY(minY)
        scrollView.addSubview(originImageView)
        minY = originImageView.frame.maxY + 16
        
        let afterLabel = UILabel()
        afterLabel.qmui_setTheSameAppearance(as: originImageLabel)
        afterLabel.text = "置灰后的图片"
        afterLabel.sizeToFit()
        afterLabel.frame = afterLabel.frame.setY(minY)
        scrollView.addSubview(afterLabel)
        minY = afterLabel.frame.maxY + 6
        
        let afterImageView = UIImageView(frame: originImageView.frame.setY(minY))
        afterImageView.contentMode = originImageView.contentMode
        afterImageView.image = originImageView.image?.qmui_grayImage
        scrollView.addSubview(afterImageView)
        minY = afterImageView.frame.maxY
        
        return minY
    }
    
    private func generateExampleViewForImageWithAlpha() -> CGFloat {
        let contentWidth = contentViewLimitWidth
        var minY = contentViewLayoutStartingMinY
        
        let originImageLabel = UILabel(with: UIFontMake(14), textColor: UIColorBlack)
        originImageLabel.text = "处理前的原图"
        originImageLabel.sizeToFit()
        originImageLabel.frame = originImageLabel.frame.setY(minY)
        scrollView.addSubview(originImageLabel)
        minY = originImageLabel.frame.maxY + 6
        
        let originImageView = UIImageView(image: UIImageMake("image0"))
        originImageView.contentMode = .scaleAspectFit
        originImageView.qmui_sizeToFitKeepingImageAspectRatio(in: CGSize(width: contentWidth, height: CGFloat.greatestFiniteMagnitude))
        originImageView.frame = originImageView.frame.setY(minY)
        scrollView.addSubview(originImageView)
        minY = originImageView.frame.maxY + 16
        
        let afterLabel = UILabel()
        afterLabel.qmui_setTheSameAppearance(as: originImageLabel)
        afterLabel.text = "叠加0.5的apha之后"
        afterLabel.sizeToFit()
        afterLabel.frame = afterLabel.frame.setY(minY)
        scrollView.addSubview(afterLabel)
        minY = afterLabel.frame.maxY + 6
        
        let imageAddedAlpha = originImageView.image?.qmui_image(alpha: 0.5)
        var imageViewSize = CGSize(width: originImageView.frame.width - 20, height: 0)
        imageViewSize.height = flat(imageViewSize.width * originImageView.frame.height / originImageView.frame.width)
        
        let afterImageView = UIImageView(frame: CGRect(x: 0, y: minY, width: imageViewSize.width, height: imageViewSize.height))
        afterImageView.contentMode = originImageView.contentMode
        afterImageView.image = imageAddedAlpha
        scrollView.addSubview(afterImageView)
        
        let afterImageView2 = UIImageView(frame: CGRect(x: 20, y: afterImageView.frame.minY + 20, width: imageViewSize.width, height: imageViewSize.height))
        afterImageView2.contentMode = afterImageView.contentMode
        afterImageView2.image = imageAddedAlpha
        scrollView.addSubview(afterImageView2)
        
        minY = afterImageView2.frame.maxY
        
        return minY
    }
    
    private func generateExampleViewForImageWithTintColor() -> CGFloat {
        var minY = contentViewLayoutStartingMinY
        
        let originImageLabel = UILabel(with: UIFontMake(14), textColor: UIColorBlack)
        originImageLabel.text = "处理前的原图"
        originImageLabel.sizeToFit()
        originImageLabel.frame = originImageLabel.frame.setY(minY)
        scrollView.addSubview(originImageLabel)
        minY = originImageLabel.frame.maxY + 6
        
        let originImageView = UIImageView(image: UIImageMake("icon_emotion"))
        originImageView.contentMode = .scaleAspectFit
        originImageView.frame = originImageView.frame.setY(minY)
        scrollView.addSubview(originImageView)
        minY = originImageView.frame.maxY + 16
        
        let afterLabel = UILabel()
        afterLabel.qmui_setTheSameAppearance(as: originImageLabel)
        afterLabel.text = "将图片换个颜色"
        afterLabel.sizeToFit()
        afterLabel.frame = afterLabel.frame.setY(minY)
        scrollView.addSubview(afterLabel)
        minY = afterLabel.frame.maxY + 6
        
        let afterImage = originImageView.image?.qmui_image(tintColor: QDCommonUI.randomThemeColor())
        let afterImageView = UIImageView(image: afterImage)
        afterImageView.contentMode = originImageView.contentMode
        afterImageView.frame = afterImageView.frame.setY(minY)
        scrollView.addSubview(afterImageView)
        minY = afterImageView.frame.maxY + 6
        
        return minY
    }
    
    private func generateExampleViewForImageWithBlendColor() -> CGFloat {
        let contentWidth = contentViewLimitWidth
        var minY = contentViewLayoutStartingMinY
        
        let originImageLabel = UILabel(with: UIFontMake(14), textColor: UIColorBlack)
        originImageLabel.text = "处理前的原图"
        originImageLabel.sizeToFit()
        originImageLabel.frame = originImageLabel.frame.setY(minY)
        scrollView.addSubview(originImageLabel)
        minY = originImageLabel.frame.maxY + 6
        
        let originImageView = UIImageView(image: UIImageMake("image0")?.qmui_imageResized(in: CGSize(width: contentWidth, height: contentWidth)))
        originImageView.contentMode = .scaleAspectFit
        originImageView.frame = originImageView.frame.setY(minY)
        scrollView.addSubview(originImageView)
        minY = originImageView.frame.maxY + 16
        
        let afterLabel = UILabel()
        afterLabel.qmui_setTheSameAppearance(as: originImageLabel)
        afterLabel.text = "将图片换个颜色"
        afterLabel.sizeToFit()
        afterLabel.frame = afterLabel.frame.setY(minY)
        scrollView.addSubview(afterLabel)
        minY = afterLabel.frame.maxY + 6
        
        let afterImage = originImageView.image?.qmui_image(blendColor: QDCommonUI.randomThemeColor())
        let afterImageView = UIImageView(image: afterImage)
        afterImageView.contentMode = originImageView.contentMode
        afterImageView.frame = afterImageView.frame.setY(minY)
        scrollView.addSubview(afterImageView)
        minY = afterImageView.frame.maxY + 6
        
        return minY
    }
    
    private func generateExampleViewForImageWithImageAbove() -> CGFloat {
        var minY = contentViewLayoutStartingMinY
        
        let originImageLabel = UILabel(with: UIFontMake(14), textColor: UIColorBlack)
        originImageLabel.text = "处理前的原图"
        originImageLabel.sizeToFit()
        originImageLabel.frame = originImageLabel.frame.setY(minY)
        scrollView.addSubview(originImageLabel)
        minY = originImageLabel.frame.maxY + 6
        
        let originImageView = UIImageView(image: UIImageMake("icon_emotion")?.qmui_image(tintColor: QDThemeManager.shared.currentTheme?.themeTintColor ?? UIColorBlue))
        originImageView.contentMode = .scaleAspectFit
        originImageView.frame = originImageView.frame.setY(minY)
        scrollView.addSubview(originImageView)
        minY = originImageView.frame.maxY + 16
        
        let afterLabel = UILabel()
        afterLabel.qmui_setTheSameAppearance(as: originImageLabel)
        afterLabel.text = "在图片上叠加一张未读红点的图片"
        afterLabel.sizeToFit()
        afterLabel.frame = afterLabel.frame.setY(minY)
        scrollView.addSubview(afterLabel)
        minY = afterLabel.frame.maxY + 6
        
        let redDotImage = UIImage.qmui_image(color: UIColorRed, size: CGSize(width: 6, height: 6), cornerRadius:6.0 / 2.0)
        let afterImage = originImageView.image?.qmui_image(imageAbove: redDotImage!, at: CGPoint(x: originImageView.image!.size.width - redDotImage!.size.width - 1, y: 1))
        let afterImageView = UIImageView(image: afterImage)
        afterImageView.contentMode = originImageView.contentMode
        afterImageView.frame = afterImageView.frame.setY(minY)
        scrollView.addSubview(afterImageView)
        minY = afterImageView.frame.maxY
        
        return minY
    }
    
    private func generateExampleViewForImageWithSpacingExtensionInsets() -> CGFloat {
        var minY = contentViewLayoutStartingMinY
        
        let originImageLabel = UILabel(with: UIFontMake(14), textColor: UIColorBlack)
        originImageLabel.text = "处理前的原图（UIImageView带边框）"
        originImageLabel.sizeToFit()
        originImageLabel.frame = originImageLabel.frame.setY(minY)
        scrollView.addSubview(originImageLabel)
        minY = originImageLabel.frame.maxY + 6
        
        let originImageView = UIImageView(image: UIImageMake("icon_emotion"))
        originImageView.layer.borderWidth = PixelOne
        originImageView.layer.borderColor = QDCommonUI.randomThemeColor().cgColor
        originImageView.frame = originImageView.frame.setY(minY)
        scrollView.addSubview(originImageView)
        minY = originImageView.frame.maxY + 16
        
        let afterLabel = UILabel()
        afterLabel.qmui_setTheSameAppearance(as: originImageLabel)
        afterLabel.text = "在图片右边加了padding之后"
        afterLabel.sizeToFit()
        afterLabel.frame = afterLabel.frame.setY(minY)
        scrollView.addSubview(afterLabel)
        minY = afterLabel.frame.maxY + 6
        
        
        let afterImage = originImageView.image?.qmui_image(spacingExtensionInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10))
        let afterImageView = UIImageView(image: afterImage)
        afterImageView.layer.borderWidth = originImageView.layer.borderWidth
        afterImageView.layer.borderColor = originImageView.layer.borderColor
        afterImageView.frame = afterImageView.frame.setY(minY)
        scrollView.addSubview(afterImageView)
        minY = afterImageView.frame.maxY
        
        return minY
    }
    
    private func generateExampleViewForImageWithClippedRect() -> CGFloat {
        let contentWidth = contentViewLimitWidth
        var minY = contentViewLayoutStartingMinY
        
        let originImageLabel = UILabel(with: UIFontMake(14), textColor: UIColorBlack)
        originImageLabel.text = "处理前的原图"
        originImageLabel.sizeToFit()
        originImageLabel.frame = originImageLabel.frame.setY(minY)
        scrollView.addSubview(originImageLabel)
        minY = originImageLabel.frame.maxY + 6
        
        let originImageView = UIImageView(image: UIImageMake("image0"))
        originImageView.contentMode = .scaleAspectFit
        originImageView.qmui_sizeToFitKeepingImageAspectRatio(in: CGSize(width: contentWidth, height: CGFloat.greatestFiniteMagnitude))
        originImageView.frame = originImageView.frame.setY(minY)
        originImageView.clipsToBounds = true
        scrollView.addSubview(originImageView)
        minY = originImageView.frame.maxY + 16
        
        let afterLabel = UILabel()
        afterLabel.qmui_setTheSameAppearance(as: originImageLabel)
        afterLabel.text = "裁剪出中间的区域"
        afterLabel.sizeToFit()
        afterLabel.frame = afterLabel.frame.setY(minY)
        scrollView.addSubview(afterLabel)
        minY = afterLabel.frame.maxY + 6
        
        let afterImage = originImageView.image?.qmui_image(clippedRect: CGRect(x: originImageView.image!.size.width / 4, y: originImageView.image!.size.height / 4, width: originImageView.image!.size.width / 2, height: originImageView.image!.size.height / 2))
        let afterImageView = UIImageView(image: afterImage)
        afterImageView.contentMode = originImageView.contentMode
        afterImageView.frame = afterImageView.frame.setY(minY)
        scrollView.addSubview(afterImageView)
        minY = afterImageView.frame.maxY
        
        return minY
    }
    
    private func generateExampleViewForResizedImage() -> CGFloat {
        let contentWidth = contentViewLimitWidth
        var minY = contentViewLayoutStartingMinY
        
        let originImageLabel = UILabel(with: UIFontMake(14), textColor: UIColorBlack)
        originImageLabel.text = "处理前的原图"
        originImageLabel.sizeToFit()
        originImageLabel.frame = originImageLabel.frame.setY(minY)
        scrollView.addSubview(originImageLabel)
        minY = originImageLabel.frame.maxY + 6
        
        let originImageView = UIImageView(image: UIImageMake("image0"))
        originImageView.contentMode = .scaleAspectFit
        originImageView.qmui_sizeToFitKeepingImageAspectRatio(in: CGSize(width: contentWidth, height: CGFloat.greatestFiniteMagnitude))
        originImageView.frame = originImageView.frame.setY(minY)
        originImageView.clipsToBounds = true
        scrollView.addSubview(originImageView)
        minY = originImageView.frame.maxY + 16
        
        let afterLabel = UILabel()
        afterLabel.qmui_setTheSameAppearance(as: originImageLabel)
        afterLabel.text = "缩小之后的图"
        afterLabel.sizeToFit()
        afterLabel.frame = afterLabel.frame.setY(minY)
        scrollView.addSubview(afterLabel)
        minY = afterLabel.frame.maxY + 6
        
        // 对原图进行缩放操作，以保证缩放后的图的 size 不超过 limitedSize 的大小，至于缩放策略则由 contentMode 决定。contentMode 默认是 UIViewContentModeScaleAspectFit。
        // 特别的，对于 ScaleAspectFit 类型，你可以对不关心大小的那一边传 CGFLOAT_MAX 来表示“我不关心这一边缩放后的大小限制”，但对其他类型的 contentMode 则宽高都必须传一个确切的值。
        let afterImage = originImageView.image?.qmui_imageResized(in: CGSize(width: 80, height: CGFloat.greatestFiniteMagnitude))
        let afterImageView = UIImageView(image: afterImage)
        afterImageView.contentMode = originImageView.contentMode
        afterImageView.frame = afterImageView.frame.setY(minY)
        scrollView.addSubview(afterImageView)
        minY = afterImageView.frame.maxY
        
        return minY
    }
    
    private func generateExampleViewForImageWithDirection() -> CGFloat {
        var minY = contentViewLayoutStartingMinY
        
        let originImageLabel = UILabel(with: UIFontMake(14), textColor: UIColorBlack)
        originImageLabel.text = "处理前的原图"
        originImageLabel.sizeToFit()
        originImageLabel.frame = originImageLabel.frame.setY(minY)
        scrollView.addSubview(originImageLabel)
        minY = originImageLabel.frame.maxY + 6
        
        let originImageView = UIImageView(image: UIImageMake("icon_emotion"))
        originImageView.contentMode = .center
        originImageView.frame = originImageView.frame.setY(minY)
        originImageView.clipsToBounds = true
        scrollView.addSubview(originImageView)
        minY = originImageView.frame.maxY + 16
        
        let afterLabel = UILabel()
        afterLabel.qmui_setTheSameAppearance(as: originImageLabel)
        afterLabel.text = "吓得我旋转了360°图"
        afterLabel.sizeToFit()
        afterLabel.frame = afterLabel.frame.setY(minY)
        scrollView.addSubview(afterLabel)
        minY = afterLabel.frame.maxY + 6
        
        let rightImge = originImageView.image?.qmui_image(orientation: .right)
        let leftImage = originImageView.image?.qmui_image(orientation: .left)
        let bottomImage = originImageView.image?.qmui_image(orientation: .down)
        let afterImageView = UIImageView(frame: originImageView.frame.setY(minY))
        afterImageView.contentMode = originImageView.contentMode
        afterImageView.animationImages = [originImageView.image, rightImge, bottomImage, leftImage] as? [UIImage]
        afterImageView.animationDuration = 2
        afterImageView.frame = afterImageView.frame.setY(minY)
        scrollView.addSubview(afterImageView)
        afterImageView.startAnimating()
        minY = afterImageView.frame.maxY
        
        return minY
    }
    
    private func generateExampleViewForImageWithBorder() -> CGFloat {
        var minY = contentViewLayoutStartingMinY
        
        let originImageLabel = UILabel(with: UIFontMake(14), textColor: UIColorBlack)
        originImageLabel.text = "处理前的原图"
        originImageLabel.sizeToFit()
        originImageLabel.frame = originImageLabel.frame.setY(minY)
        scrollView.addSubview(originImageLabel)
        minY = originImageLabel.frame.maxY + 6
        
        let originImageView = UIImageView(image: UIImageMake("icon_emotion"))
        originImageView.frame = originImageView.frame.setY(minY)
        scrollView.addSubview(originImageView)
        minY = originImageView.frame.maxY + 16
        
        let afterLabel = UILabel()
        afterLabel.qmui_setTheSameAppearance(as: originImageLabel)
        afterLabel.text = "加了边框之后的图（边框路径要考虑像素对齐）"
        afterLabel.sizeToFit()
        afterLabel.frame = afterLabel.frame.setY(minY)
        scrollView.addSubview(afterLabel)
        minY = afterLabel.frame.maxY + 6
        
        let lineWidth = PixelOne
        let roundedBorderPath = UIBezierPath(roundedRect: originImageView.image!.size.rect.insetBy(dx: lineWidth / 2.0, dy: lineWidth / 2.0), cornerRadius: 4)
        roundedBorderPath.lineWidth = lineWidth
        let afterImage = originImageView.image?.qmui_image(borderColor: QDCommonUI.randomThemeColor(), path: roundedBorderPath)
        
        let afterImageView = UIImageView(image: afterImage)
        afterImageView.frame = afterImageView.frame.setY(minY)
        scrollView.addSubview(afterImageView)
        minY = afterImageView.frame.maxY
        
        return minY
    }
    
    private func generateExampleViewForImageWithBorderColorAndCornerRadius(with dashedBorder: Bool) -> CGFloat {
        var minY = contentViewLayoutStartingMinY
        
        let originImageLabel = UILabel(with: UIFontMake(14), textColor: UIColorBlack)
        originImageLabel.text = "处理前的原图"
        originImageLabel.sizeToFit()
        originImageLabel.frame = originImageLabel.frame.setY(minY)
        scrollView.addSubview(originImageLabel)
        minY = originImageLabel.frame.maxY + 6
        
        let originImageView = UIImageView(image: UIImageMake("icon_emotion"))
        originImageView.frame = originImageView.frame.setY(minY)
        scrollView.addSubview(originImageView)
        minY = originImageView.frame.maxY + 16
        
        let afterLabel = UILabel()
        afterLabel.qmui_setTheSameAppearance(as: originImageLabel)
        afterLabel.text = "加了边框之后的图"
        afterLabel.sizeToFit()
        afterLabel.frame = afterLabel.frame.setY(minY)
        scrollView.addSubview(afterLabel)
        minY = afterLabel.frame.maxY + 6
        
        var afterImage: UIImage?
        if dashedBorder {
            let dashedLengths: [CGFloat] = [2, 4]
            afterImage = originImageView.image?.qmui_image(borderColor: QDCommonUI.randomThemeColor(), borderWidth: PixelOne, cornerRadius: 4, dashedLengths: dashedLengths)
        } else {
            afterImage = originImageView.image?.qmui_image(borderColor: QDCommonUI.randomThemeColor(), borderWidth: PixelOne, cornerRadius: 4)
        }
        
        let afterImageView = UIImageView(image: afterImage)
        afterImageView.frame = afterImageView.frame.setY(minY)
        scrollView.addSubview(afterImageView)
        minY = afterImageView.frame.maxY
        
        return minY
    }
    
    private func generateExampleViewForImageWithBorderColorAndCornerRadiusAndPosition() -> CGFloat {
        var minY = contentViewLayoutStartingMinY
        
        let originImageLabel = UILabel(with: UIFontMake(14), textColor: UIColorBlack)
        originImageLabel.text = "处理前的原图"
        originImageLabel.sizeToFit()
        originImageLabel.frame = originImageLabel.frame.setY(minY)
        scrollView.addSubview(originImageLabel)
        minY = originImageLabel.frame.maxY + 6
        
        let originImageView = UIImageView(image: UIImageMake("icon_emotion"))
        originImageView.frame = originImageView.frame.setY(minY)
        scrollView.addSubview(originImageView)
        minY = originImageView.frame.maxY + 16
        
        let afterLabel = UILabel()
        afterLabel.qmui_setTheSameAppearance(as: originImageLabel)
        afterLabel.text = "加了下边框之后的图"
        afterLabel.sizeToFit()
        afterLabel.frame = afterLabel.frame.setY(minY)
        scrollView.addSubview(afterLabel)
        minY = afterLabel.frame.maxY + 6
        
        let afterImage = originImageView.image?.qmui_image(borderColor: QDCommonUI.randomThemeColor(), borderWidth: PixelOne, borderPosition: [.bottom])
        
        let afterImageView = UIImageView(image: afterImage)
        afterImageView.frame = afterImageView.frame.setY(minY)
        scrollView.addSubview(afterImageView)
        minY = afterImageView.frame.maxY
        
        return minY
    }
    
    private func generateExampleViewForImageWithMaskImage() -> CGFloat {
        let contentWidth = contentViewLimitWidth
        var minY = contentViewLayoutStartingMinY
        
        let originImageLabel = UILabel(with: UIFontMake(14), textColor: UIColorBlack)
        originImageLabel.text = "处理前的原图"
        originImageLabel.sizeToFit()
        originImageLabel.frame = originImageLabel.frame.setY(minY)
        scrollView.addSubview(originImageLabel)
        minY = originImageLabel.frame.maxY + 6
        
        let originImageView = UIImageView(image: UIImageMake("image0"))
        originImageView.contentMode = .scaleAspectFit
        originImageView.qmui_sizeToFitKeepingImageAspectRatio(in: CGSize(width: contentWidth, height: CGFloat.greatestFiniteMagnitude))
        originImageView.frame = originImageView.frame.setY(minY)
        originImageView.clipsToBounds = true
        scrollView.addSubview(originImageView)
        minY = originImageView.frame.maxY + 16
        
        let maskImageLabel = UILabel(with: UIFontMake(14), textColor: UIColorBlack)
        maskImageLabel.text = "A.用来做遮罩的图片"
        maskImageLabel.sizeToFit()
        maskImageLabel.frame = maskImageLabel.frame.setY(minY)
        scrollView.addSubview(maskImageLabel)
        minY = maskImageLabel.frame.maxY + 6
        
        let maskImageView = UIImageView(image: UIImageMake("image1"))
        maskImageView.contentMode = .scaleAspectFit
        maskImageView.qmui_sizeToFitKeepingImageAspectRatio(in: CGSize(width: contentWidth, height: CGFloat.greatestFiniteMagnitude))
        maskImageView.frame = maskImageView.frame.setY(minY)
        maskImageView.clipsToBounds = true
        scrollView.addSubview(maskImageView)
        minY = maskImageView.frame.maxY + 16
        
        let afterLabel = UILabel()
        afterLabel.qmui_setTheSameAppearance(as: originImageLabel)
        afterLabel.text = "A.加了遮罩后的图片"
        afterLabel.sizeToFit()
        afterLabel.frame = afterLabel.frame.setY(minY)
        scrollView.addSubview(afterLabel)
        minY = afterLabel.frame.maxY + 6
        
        let afterImage = originImageView.image?.qmui_image(maskImage: maskImageView.image!, usingMaskImageMode: true)
        
        let afterImageView = UIImageView(frame: originImageView.frame.setY(minY))
        afterImageView.image = afterImage
        scrollView.addSubview(afterImageView)
        minY = afterImageView.frame.maxY + 16
        
        let maskImageLabel2 = UILabel(with: UIFontMake(14), textColor: UIColorBlack)
        maskImageLabel2.text = "B.用来做遮罩的图片"
        maskImageLabel2.sizeToFit()
        maskImageLabel2.frame = maskImageLabel2.frame.setY(minY)
        scrollView.addSubview(maskImageLabel2)
        minY = maskImageLabel2.frame.maxY + 6
        
        let maskImageView2 = UIImageView(image: UIImageMake("image1")?.qmui_grayImage)
        maskImageView2.contentMode = .scaleAspectFit
        maskImageView2.qmui_sizeToFitKeepingImageAspectRatio(in: CGSize(width: contentWidth, height: CGFloat.greatestFiniteMagnitude))
        maskImageView2.frame = maskImageView2.frame.setY(minY)
        maskImageView2.clipsToBounds = true
        scrollView.addSubview(maskImageView2)
        minY = maskImageView2.frame.maxY + 16
        
        let afterLabel2 = UILabel()
        afterLabel2.qmui_setTheSameAppearance(as: originImageLabel)
        afterLabel2.text = "B.加了遮罩后的图片"
        afterLabel2.sizeToFit()
        afterLabel2.frame = afterLabel.frame.setY(minY)
        scrollView.addSubview(afterLabel2)
        minY = afterLabel2.frame.maxY + 6
        
        let afterImage2 = originImageView.image?.qmui_image(maskImage: maskImageView2.image!, usingMaskImageMode: false)
        
        let afterImageView2 = UIImageView(frame: originImageView.frame.setY(minY))
        afterImageView2.image = afterImage2
        scrollView.addSubview(afterImageView2)
        minY = afterImageView2.frame.maxY
        
        return minY
    }
    
    private func generateExampleViewForImageWithColor() -> CGFloat {
        let contentWidth = contentViewLimitWidth
        var minY = contentViewLayoutStartingMinY
        
        let originImageLabel = UILabel(with: UIFontMake(14), textColor: UIColorBlack)
        originImageLabel.text = "生成一张圆角图片"
        originImageLabel.sizeToFit()
        originImageLabel.frame = originImageLabel.frame.setY(minY)
        scrollView.addSubview(originImageLabel)
        minY = originImageLabel.frame.maxY + 6
        
        let originImage = UIImage.qmui_image(color: QDCommonUI.randomThemeColor(), size: CGSize(width: contentWidth / 2, height: 40), cornerRadius: 10)
        
        let originImageView = UIImageView(image: originImage)
        originImageView.contentMode = .scaleAspectFit
        originImageView.frame = originImageView.frame.setY(minY)
        scrollView.addSubview(originImageView)
        minY = originImageView.frame.maxY + 16
        
        return minY
    }
    
    private func generateExampleViewForImageWithColorAndCornerRadiusArray() -> CGFloat {
        let contentWidth = contentViewLimitWidth
        var minY = contentViewLayoutStartingMinY
        
        let originImageLabel = UILabel(with: UIFontMake(14), textColor: UIColorBlack)
        originImageLabel.text = "生成一张图片，右边带圆角"
        originImageLabel.sizeToFit()
        originImageLabel.frame = originImageLabel.frame.setY(minY)
        scrollView.addSubview(originImageLabel)
        minY = originImageLabel.frame.maxY + 6
        
        let originImage = UIImage.qmui_image(color: QDCommonUI.randomThemeColor(), size: CGSize(width: contentWidth / 2, height: 40), cornerRadiusArray: [0, 0, 10, 10])
        
        let originImageView = UIImageView(image: originImage)
        originImageView.contentMode = .scaleAspectFit
        originImageView.frame = originImageView.frame.setY(minY)
        scrollView.addSubview(originImageView)
        minY = originImageView.frame.maxY + 16
        
        return minY
    }
    
    private func generateExampleViewForImageWithStrokeColorAndPath() -> CGFloat {
        let contentWidth = contentViewLimitWidth
        var minY = contentViewLayoutStartingMinY
        
        let originImageLabel = UILabel(with: UIFontMake(14), textColor: UIColorBlack)
        originImageLabel.text = "用椭圆路径生成一张图"
        originImageLabel.sizeToFit()
        originImageLabel.frame = originImageLabel.frame.setY(minY)
        scrollView.addSubview(originImageLabel)
        minY = originImageLabel.frame.maxY + 6
        
        let lineWidth: CGFloat = 1
        let path = UIBezierPath(ovalIn: CGRect(x: lineWidth / 2.0, y: lineWidth / 2.0, width: contentWidth / 2 - lineWidth, height: 40 - lineWidth))
        path.lineWidth = lineWidth
        
        let originImage = UIImage.qmui_image(strokeColor: QDCommonUI.randomThemeColor(), size: CGSize(width: contentWidth / 2, height: 40), path: path, addClip: false)
        
        let originImageView = UIImageView(image: originImage)
        originImageView.contentMode = .scaleAspectFit
        originImageView.frame = originImageView.frame.setY(minY)
        scrollView.addSubview(originImageView)
        minY = originImageView.frame.maxY + 16
        
        return minY
    }
    
    private func generateExampleViewForImageWithStrokeColorAndCornerRadius() -> CGFloat {
        let contentWidth = contentViewLimitWidth
        var minY = contentViewLayoutStartingMinY
        
        let originImageLabel = UILabel(with: UIFontMake(14), textColor: UIColorBlack)
        originImageLabel.text = "在给定的大小里绘制一条带圆角的路径"
        originImageLabel.sizeToFit()
        originImageLabel.frame = originImageLabel.frame.setY(minY)
        scrollView.addSubview(originImageLabel)
        minY = originImageLabel.frame.maxY + 6
    
        
        let originImage = UIImage.qmui_image(strokeColor: QDCommonUI.randomThemeColor(), size: CGSize(width: contentWidth / 2, height: 40), lineWidth: 1, cornerRadius:10)
        
        let originImageView = UIImageView(image: originImage)
        originImageView.contentMode = .scaleAspectFit
        originImageView.frame = originImageView.frame.setY(minY)
        scrollView.addSubview(originImageView)
        minY = originImageView.frame.maxY + 16
        
        return minY
    }
    
    private func generateExampleViewForImageWithStrokeColorAndBorderPosition() -> CGFloat {
        let contentWidth = contentViewLimitWidth
        var minY = contentViewLayoutStartingMinY
        
        let originImageLabel = UILabel(with: UIFontMake(14), textColor: UIColorBlack)
        originImageLabel.text = "在左、下、右绘制一条边框"
        originImageLabel.sizeToFit()
        originImageLabel.frame = originImageLabel.frame.setY(minY)
        scrollView.addSubview(originImageLabel)
        minY = originImageLabel.frame.maxY + 6
        
        let originImage = UIImage.qmui_image(strokeColor: QDCommonUI.randomThemeColor(), size: CGSize(width: contentWidth / 2, height: 40), lineWidth: 1, borderPosition: [.left, .right, .bottom])
        
        let originImageView = UIImageView(image: originImage)
        originImageView.contentMode = .scaleAspectFit
        originImageView.frame = originImageView.frame.setY(minY)
        scrollView.addSubview(originImageView)
        minY = originImageView.frame.maxY + 16
        
        return minY
    }
    
    private func generateExampleViewForImageWithShape() -> CGFloat {
        let contentWidth = contentViewLimitWidth
        var minY = contentViewLayoutStartingMinY
        
        let titleLabel = UILabel(with: UIFontMake(14), textColor: UIColorBlack)
        titleLabel.text = "生成预设的形状图片"
        titleLabel.sizeToFit()
        titleLabel.frame = titleLabel.frame.setY(minY)
        scrollView.addSubview(titleLabel)
        minY = titleLabel.frame.maxY + 6
        
        let tintColor = QDThemeManager.shared.currentTheme?.themeTintColor
        let ovalImage = UIImage.qmui_image(shape: .oval, size: CGSize(width: contentWidth / 4, height: 20), tintColor: tintColor)
        let triangleImage = UIImage.qmui_image(shape: .triangle, size: CGSize(width: 6, height: 6), tintColor: tintColor)
        let disclosureIndicatorImage = UIImage.qmui_image(shape: .disclosureIndicator, size: CGSize(width: 8, height: 13), tintColor: tintColor)
        let checkmarkImage = UIImage.qmui_image(shape: .checkmark, size: CGSize(width: 15, height: 12), tintColor: tintColor)
        let detailButtonImage = UIImage.qmui_image(shape: .detailButtonImage, size: CGSize(width: 20, height: 20), tintColor: tintColor)
        let navBackImage = UIImage.qmui_image(shape: .navBack, size: CGSize(width: 12, height: 20), tintColor: tintColor)
        let navCloseImage = UIImage.qmui_image(shape: .navClose, size: CGSize(width: 16, height: 16), tintColor: tintColor)
        
        minY = generateExampleLabelAndImageView(ovalImage!, shapeName:"QMUIImageShapeOval", minY:minY)
        minY = generateExampleLabelAndImageView(triangleImage!, shapeName:"QMUIImageShapeTriangle", minY:minY)
        minY = generateExampleLabelAndImageView(disclosureIndicatorImage!, shapeName:"QMUIImageShapeDisclosureIndicator", minY:minY)
        minY = generateExampleLabelAndImageView(checkmarkImage!, shapeName:"QMUIImageShapeCheckmark", minY:minY)
        minY = generateExampleLabelAndImageView(detailButtonImage!, shapeName:"QMUIImageShapeDetailButtonImage", minY:minY)
        minY = generateExampleLabelAndImageView(navBackImage!, shapeName:"QMUIImageShapeNavBack", minY:minY)
        minY = generateExampleLabelAndImageView(navCloseImage!, shapeName:"QMUIImageShapeNavClose", minY:minY)

        return minY
    }
    
    private func generateExampleLabelAndImageView(_ image: UIImage, shapeName: String, minY: CGFloat) -> CGFloat {
        var result = minY
        
        let exampleLabel = UILabel(with: UIFontMake(12), textColor: UIColorGrayDarken)
        exampleLabel.text = shapeName
        exampleLabel.sizeToFit()
        exampleLabel.frame = exampleLabel.frame.setY(result)
        scrollView.addSubview(exampleLabel)
        result = exampleLabel.frame.maxY + 6
        
        let exampleImageView = UIImageView(image: image)
        exampleImageView.frame = exampleImageView.frame.setY(result)
        scrollView.addSubview(exampleImageView)
        result = exampleImageView.frame.maxY + 16
        
        return result
    }
    
    private func generateExampleViewForImageWithAttributedString() -> CGFloat {
        var minY = contentViewLayoutStartingMinY
        
        let originImageLabel = UILabel(with: UIFontMake(14), textColor: UIColorBlack)
        originImageLabel.text = "将NSAttributedString生成为一张图"
        originImageLabel.sizeToFit()
        originImageLabel.frame = originImageLabel.frame.setY(minY)
        scrollView.addSubview(originImageLabel)
        minY = originImageLabel.frame.maxY + 6
        
        let attributes: [NSAttributedStringKey: Any] = [NSAttributedStringKey.font : UIFontMake(16), NSAttributedStringKey.foregroundColor: QDCommonUI.randomThemeColor()]
        let attributedString1 = NSAttributedString(string: "这是UILabel的显示效果", attributes: attributes)
        let attributedString2 = NSAttributedString(string: "这是UIImage的显示效果", attributes: attributes)
        
        let exampleLabel = UILabel(with: UIFontMake(12), textColor: UIColorGrayDarken)
        exampleLabel.attributedText = attributedString1
        exampleLabel.sizeToFit()
        exampleLabel.frame = exampleLabel.frame.setY(minY)
        scrollView.addSubview(exampleLabel)
        minY = exampleLabel.frame.maxY + 16
        
        let exampleImage = UIImage.qmui_image(attributedString: attributedString2)
        let exampleImageView = UIImageView(image: exampleImage)
        exampleImageView.frame = exampleImageView.frame.setY(minY)
        exampleImageView.backgroundColor = UIColorTestRed
        scrollView.addSubview(exampleImageView)
        minY = exampleImageView.frame.maxY + 16

        return minY
    }
    
    private func generateExampleViewForImageWithView() -> CGFloat {
        let contentWidth = contentViewLimitWidth
        var minY = contentViewLayoutStartingMinY
        
        let originImageLabel = UILabel(with: UIFontMake(14), textColor: UIColorBlack)
        originImageLabel.text = "将当前UINavigationController.view截图"
        originImageLabel.sizeToFit()
        originImageLabel.frame = originImageLabel.frame.setY(minY)
        scrollView.addSubview(originImageLabel)
        minY = originImageLabel.frame.maxY + 6
        
        let originImage = UIImage.qmui_image(view: navigationController!.view)
        
        let originImageView = UIImageView(image: originImage)
        originImageView.contentMode = .scaleAspectFit
        originImageView.frame = originImageView.frame.setY(minY)
        originImageView.layer.borderWidth = PixelOne
        originImageView.layer.borderColor = UIColorGrayLighten.cgColor
        originImageView.qmui_sizeToFitKeepingImageAspectRatio(in: CGSize(width: contentWidth, height: CGFloat.greatestFiniteMagnitude))
        scrollView.addSubview(originImageView)
        minY = originImageView.frame.maxY + 16
        
        return minY
    }
}
