//
//  UIImage+QMUI.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/1/17.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

let CGContextInspectSize: (CGSize) -> () = {
    QMUIHelper.inspectContext(size: $0)
}


public enum QMUIImageShape {
    case oval // 椭圆
    case triangle // 三角形
    case disclosureIndicator // 列表cell右边的箭头
    case checkmark // 列表cell右边的checkmark
    case navBack // 返回按钮的箭头
    case navClose // 导航栏的关闭icon
}

public enum QMUIImageBorderPosition: Int {
    case all = 0
    case top
    case left
    case bottom
    case right
}

extension CGSize {
    // 和全局方法重名 flatSpecificScale
    func flatSpecific(scale s: CGFloat) -> CGSize {
        return CGSize(width: flatSpecificScale(width, s), height: flatSpecificScale(height, s))
    }
}

extension UIImage {
    /**
     *  获取当前图片的均色，原理是将图片绘制到1px*1px的矩形内，再从当前区域取色，得到图片的均色。
     *  @link http://www.bobbygeorgescu.com/2011/08/finding-average-color-of-uiimage/ @/link
     *
     *  @return 代表图片平均颜色的UIColor对象
     */
    public var qmui_averageColor: UIColor {
        var rgba: [CGFloat] = Array(repeating: 0, count: 4)
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        guard let context = CGContext(data: &rgba, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue) else {
            print("context is nil")
            return .black
        }
        context.draw(cgImage!, in: CGRect(x: 0, y: 0, width: 1, height: 1))
        if rgba[3] > 0 {
            return UIColor(red: rgba[0] / rgba[3],
                           green: rgba[1] / rgba[3],
                           blue: rgba[2] / rgba[3],
                           alpha: rgba[3] / 255.0)
        } else {
            return UIColor(red: rgba[0] / 255.0,
                           green: rgba[1] / 255.0,
                           blue: rgba[2] / 255.0,
                           alpha: rgba[3] / 255.0)
        }
    }


    /**
     *  置灰当前图片
     *
     *  @return 已经置灰的图片
     */
    public var qmui_grayImage: UIImage? {
        // CGBitmapContextCreate 是无倍数的，所以要自己换算成1倍
        let width = size.width * scale
        let height = size.height * scale
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
        guard let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else {
            return nil
        }
        let imageRect = CGRect(x: 0, y: 0, width: width, height: height)
        context.draw(cgImage!, in: imageRect)

        var grayImage: UIImage?
        let imageRef = context.makeImage()
        if qmui_opaque {
            grayImage = UIImage(cgImage: imageRef!, scale: scale, orientation: imageOrientation)
        } else {
            let alphaContext = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.alphaOnly.rawValue)
            alphaContext?.draw(cgImage!, in: imageRect)
            let mask = alphaContext!.makeImage()
            let maskedGrayImageRef = imageRef?.masking(mask!)
            grayImage = UIImage(cgImage: maskedGrayImageRef!, scale: scale, orientation: imageOrientation)

            // 用 CGBitmapContextCreateImage 方式创建出来的图片，CGImageAlphaInfo 总是为 CGImageAlphaInfoNone，导致 qmui_opaque 与原图不一致，所以这里再做多一步
            UIGraphicsBeginImageContextWithOptions((grayImage?.size)!, false, (grayImage?.scale)!)
            grayImage?.draw(in: imageRect)
            grayImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }

        return grayImage
    }
    

    /**
     *  设置一张图片的透明度
     *
     *  @param alpha 要用于渲染透明度
     *
     *  @return 设置了透明度之后的图片
     */
    public func qmui_imageWith(alpha: CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        // TODO: 这个没有用到需不需要取？
//        let context = UIGraphicsGetCurrentContext()
        let drawingRect = CGRect(origin: .zero, size: size)
        draw(in: drawingRect, blendMode: .normal, alpha: alpha)
        let imageOut = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return imageOut!
    }


    /**
     *  判断一张图是否不存在 alpha 通道，注意 “不存在 alpha 通道” 不等价于 “不透明”。一张不透明的图有可能是存在 alpha 通道但 alpha 值为 1。
     */
    public var qmui_opaque: Bool {
        let alphaInfo = cgImage!.alphaInfo
        let opaque = alphaInfo == .noneSkipLast
            || alphaInfo == .noneSkipFirst
            || alphaInfo == .none
        return opaque
    }


    /**
     *  保持当前图片的形状不变，使用指定的颜色去重新渲染它，生成一张新图片并返回
     *
     *  @param tintColor 要用于渲染的新颜色
     *
     *  @return 与当前图片形状一致但颜色与参数tintColor相同的新图片
     */
    public func qmui_imageWith(tintColor: UIColor) -> UIImage? {
        let imageIn = self
        let rect = CGRect(origin: .zero, size: imageIn.size)
        UIGraphicsBeginImageContextWithOptions(imageIn.size, qmui_opaque, imageIn.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return self }
        context.translateBy(x: 0, y: imageIn.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.setBlendMode(.normal)
        context.clip(to: rect, mask: imageIn.cgImage!)
        context.setFillColor(tintColor.cgColor)
        context.fill(rect)
        let imageOut = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return imageOut
    }


    /**
     *  在当前图片的基础上叠加一张图片，并指定绘制叠加图片的起始位置
     *
     *  叠加上去的图片将保持原图片的大小不变，不被压缩、拉伸
     *
     *  @param image 要叠加的图片
     *  @param point 所叠加图片的绘制的起始位置
     *
     *  @return 返回一张与原图大小一致的图片，所叠加的图片若超出原图大小，则超出部分被截掉
     */
    public func qmui_imageWithImageAbove(_ image: UIImage, at point: CGPoint) -> UIImage? {
        let imageIn = self
        var imageOut: UIImage?
        UIGraphicsBeginImageContextWithOptions(imageIn.size, qmui_opaque, imageIn.scale)
        imageIn.draw(in: imageIn.size.rect)
        image.draw(at: point)
        imageOut = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return imageOut
    }


    /**
     *  在当前图片的上下左右增加一些空白（不支持负值），通常用于调节NSAttributedString里的图片与文字的间距
     *  @param extension 要拓展的大小
     *  @return 拓展后的图片
     */
    func qmui_imageWithSpacingExtensionInsets(_ insets: UIEdgeInsets) -> UIImage? {
        let contextSize = CGSize(width: size.width + insets.horizontalValue, height: size.height + insets.verticalValue)
        UIGraphicsBeginImageContextWithOptions(contextSize, qmui_opaque, scale)
        draw(at: CGPoint(x: insets.left, y: insets.top))
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return finalImage
    }
    
    
    /**
     *  切割出在指定位置中的图片
     *
     *  @param rect 要切割的rect
     *
     *  @return 切割后的新图片
     */
    public func qmui_imageWithClippedRect(_ rect: CGRect) -> UIImage {
        CGContextInspectSize(rect.size)
        let imageRect = size.rect
        if rect.contains(imageRect) {
            // 要裁剪的区域比自身大，所以不用裁剪直接返回自身即可
            return self
        }
        // 由于CGImage是以pixel为单位来计算的，而UIImage是以point为单位，所以这里需要将传进来的point转换为pixel
        let scaledRect = rect.apply(scale: scale)
        let imageRef = cgImage?.cropping(to: scaledRect)

        let imageOut = UIImage(cgImage: imageRef!, scale: scale, orientation: imageOrientation)
        return imageOut
    }

    
    /**
     *  将原图按 UIViewContentModeScaleAspectFit 的方式进行缩放，并返回缩放后的图片，处理完的图片的 scale 保持与原图一致。
     *  @param size 缩放后的图片尺寸不超过这个尺寸
     *
     *  @return 处理完的图片
     *  @see qmui_imageWithScaleToSize:contentMode:scale:
     */
    public func qmui_imageWithScale(to size: CGSize) -> UIImage {
        return qmui_imageWithScale(to: size, contentMode: .scaleAspectFit)
    }
    

    /**
     *  将原图按指定的 UIViewContentMode 缩放到指定的大小，返回处理完的图片，处理完的图片的 scale 保持与原图一致
     *  @param size 在这个约束的 size 内进行缩放后的大小，处理后返回的图片的 size 会根据 contentMode 不同而不同
     *  @param contentMode 希望使用的缩放模式，目前仅支持 UIViewContentModeScaleToFill、UIViewContentModeScaleAspectFill、UIViewContentModeScaleAspectFit（默认）
     *
     *  @return 处理完的图片
     *  @see qmui_imageWithScaleToSize:contentMode:scale:
     */
    public func qmui_imageWithScale(to size: CGSize, contentMode: UIViewContentMode) -> UIImage {
        return qmui_imageWithScale(to: size, contentMode: contentMode, scale: scale)
    }

    
    /**
     *  将原图按指定的 UIViewContentMode 缩放到指定的大小，返回处理完的图片
     *  @param size 在这个约束的 size 内进行缩放后的大小，处理后返回的图片的 size 会根据 contentMode 不同而不同
     *  @param contentMode 希望使用的缩放模式，目前仅支持 UIViewContentModeScaleToFill、UIViewContentModeScaleAspectFill、UIViewContentModeScaleAspectFit（默认）
     *  @param scale 处理后返回的图片的 scale
     *
     *  @return 处理完的图片
     */
    public func qmui_imageWithScale(to size:CGSize, contentMode: UIViewContentMode, scale: CGFloat) -> UIImage {

        let size = size.flatSpecific(scale: scale)
        CGContextInspectSize(size)
        let imageSize = self.size
        var drawingRect = CGRect.zero
        
        if contentMode == .scaleToFill {
            drawingRect = size.rect
        } else {
            let horizontalRatio = size.width / imageSize.width
            let verticalRatio = size.height / imageSize.height
            var ratio: CGFloat = 0
            if contentMode == .scaleAspectFill {
                ratio = max(horizontalRatio, verticalRatio)
            } else {
                // 默认按 UIViewContentModeScaleAspectFit
                ratio = min(horizontalRatio, verticalRatio)
            }
            drawingRect.size.width = flatSpecificScale(imageSize.width * ratio, scale)
            drawingRect.size.height = flatSpecificScale(imageSize.height * ratio, scale)
        }

        UIGraphicsBeginImageContextWithOptions(drawingRect.size, self.qmui_opaque, scale)
        guard UIGraphicsGetCurrentContext() != nil else {
            return self
        }
        draw(in: drawingRect)
        let imageOut = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return imageOut ?? self
    }
    

    public static func qmui_image(with shape: QMUIImageShape, size: CGSize, tintColor: UIColor) -> UIImage {
        var lineWidth: CGFloat = 0
        switch shape {
        case .navBack:
            lineWidth = 2.0
        case .disclosureIndicator:
            lineWidth = 1.5
        case .checkmark:
            lineWidth = 1.5
        case .navClose:
            lineWidth = 1.2 // 取消icon默认的lineWidth
        default:
            break
        }
        return qmui_image(with: shape, size: size, lineWidth: lineWidth, tintColor: tintColor)
    }
    

    public static func qmui_image(with _: QMUIImageShape, size _: CGSize, lineWidth _: CGFloat, tintColor _: UIColor) -> UIImage {
        return UIImage()
    }

    
    public func qmui_image(with _: UIImageOrientation) -> UIImage {
        return UIImage()
    }

    
    public static func qmui_image(with _: UIColor, size _: CGSize, cornerRadius _: CGFloat) -> UIImage {
        return UIImage()
    }
}
