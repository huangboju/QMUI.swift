//
//  UIImage+QMUI.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/1/17.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

#if DEBUG
let CGContextInspectContext: (CGContext) -> Void = {
    QMUIHelper.inspectContextIfInvalidatedInDebugMode(context: $0)
}
#else
let CGContextInspectContext: (CGContext) -> Void = {
    if !QMUIHelper.inspectContextIfInvalidatedInReleaseMode(context: $0) {
        return
    }
}
#endif

let CGContextInspectSize: (CGSize) -> Void = {
    QMUIHelper.inspectContext(size: $0)
}

enum QMUIImageShape {
    case oval // 椭圆
    case triangle // 三角形
    case disclosureIndicator // 列表cell右边的箭头
    case checkmark // 列表cell右边的checkmark
    case detailButtonImage // 列表 cell 右边的 i 按钮图片
    case navBack // 返回按钮的箭头
    case navClose // 导航栏的关闭icon
}

struct QMUIImageBorderPosition: OptionSet {
    let rawValue: Int
    
    static let all = QMUIImageBorderPosition(rawValue: 1)
    static let top = QMUIImageBorderPosition(rawValue: 2)
    static let left = QMUIImageBorderPosition(rawValue: 4)
    static let bottom = QMUIImageBorderPosition(rawValue: 8)
    static let right = QMUIImageBorderPosition(rawValue: 32)
}

extension CGSize {
    // 和全局方法重名 flatSpecificScale
    func flatSpecific(scale s: CGFloat) -> CGSize {
        return CGSize(width: flatSpecificScale(width, s), height: flatSpecificScale(height, s))
    }
}

extension UIImage {
    
    /// 获取当前图片的像素大小，如果是多倍图，会被放大到一倍来算
    var qmui_sizeInPixel: CGSize {
        let size = CGSize(width: self.size.width * scale, height: self.size.height * scale)
        return size
    }
    
    
    /**
     *  获取当前图片的均色，原理是将图片绘制到1px*1px的矩形内，再从当前区域取色，得到图片的均色。
     *  @link http://www.bobbygeorgescu.com/2011/08/finding-average-color-of-uiimage/ @/link
     *
     *  @return 代表图片平均颜色的UIColor对象
     */
    var qmui_averageColor: UIColor {
        let rgba = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: 4)
        let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
        let info = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        let context: CGContext = CGContext(data: rgba, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: info.rawValue)!
        
        context.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: 1, height: 1))
        
        if rgba[3] > 0 {
            let alpha: CGFloat = CGFloat(rgba[3])/255.0
            let multiplier: CGFloat = alpha/255.0
            
            return UIColor(
                red: CGFloat(rgba[0]) * multiplier,
                green: CGFloat(rgba[1]) * multiplier,
                blue: CGFloat(rgba[2]) * multiplier,
                alpha: alpha
            )
        } else {
            return UIColor(
                red: CGFloat(rgba[0])/255.0,
                green: CGFloat(rgba[1])/255.0,
                blue: CGFloat(rgba[2])/255.0,
                alpha: CGFloat(rgba[3])/255.0
            )
        }
    }

    /**
     *  置灰当前图片
     *
     *  @return 已经置灰的图片
     */
    var qmui_grayImage: UIImage? {
        // CGBitmapContextCreate 是无倍数的，所以要自己换算成1倍
        let width = size.width * scale
        let height = size.height * scale
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
        guard let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else {
            return nil
        }
        CGContextInspectContext(context)
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
    func qmui_image(alpha: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        // TODO: 这个没有用到需不需要取？
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        CGContextInspectContext(context)
        let drawingRect = CGRect(origin: .zero, size: size)
        draw(in: drawingRect, blendMode: .normal, alpha: alpha)
        let imageOut = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return imageOut
    }

    /**
     *  判断一张图是否不存在 alpha 通道，注意 “不存在 alpha 通道” 不等价于 “不透明”。一张不透明的图有可能是存在 alpha 通道但 alpha 值为 1。
     */
    var qmui_opaque: Bool {
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
    func qmui_image(tintColor: UIColor?) -> UIImage? {
        guard let tintColor = tintColor else {
            return nil
        }
        let imageIn = self
        let rect = CGRect(origin: .zero, size: imageIn.size)
        UIGraphicsBeginImageContextWithOptions(imageIn.size, qmui_opaque, imageIn.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return self }
        CGContextInspectContext(context)
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
     *  以 CIColorBlendMode 的模式为当前图片叠加一个颜色，生成一张新图片并返回，在叠加过程中会保留图片内的纹理。
     *
     *  @param blendColor 要叠加的颜色
     *
     *  @return 基于当前图片纹理保持不变的情况下颜色变为指定的叠加颜色的新图片
     *
     *  @warning 这个方法可能比较慢，会卡住主线程，建议异步使用
     */
    func qmui_image(blendColor: UIColor) -> UIImage? {
        guard let coloredImage = qmui_image(tintColor: blendColor) else { return nil }
        guard let filter = CIFilter(name: "CIColorBlendMode")  else { return nil }
        filter.setValue(CIImage(cgImage: cgImage!), forKey: kCIInputBackgroundImageKey)
        filter.setValue(CIImage(cgImage: coloredImage.cgImage!), forKey: kCIInputImageKey)
        if let outputImage = filter.outputImage {
            let context = CIContext(options: nil)
            if let imageRef = context.createCGImage(outputImage, from: outputImage.extent) {
                let resultImage = UIImage(cgImage: imageRef, scale: scale, orientation: imageOrientation)
                return resultImage
            }
        }
        return nil
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
    func qmui_image(imageAbove: UIImage, at point: CGPoint) -> UIImage? {
        let imageIn = self
        var imageOut: UIImage?
        UIGraphicsBeginImageContextWithOptions(imageIn.size, qmui_opaque, imageIn.scale)
        imageIn.draw(in: imageIn.size.rect)
        imageAbove.draw(at: point)
        imageOut = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return imageOut
    }

    /**
     *  在当前图片的上下左右增加一些空白（不支持负值），通常用于调节NSAttributedString里的图片与文字的间距
     *  @param extension 要拓展的大小
     *  @return 拓展后的图片
     */
    func qmui_image(spacingExtensionInsets: UIEdgeInsets) -> UIImage? {
        let contextSize = CGSize(width: size.width + spacingExtensionInsets.horizontalValue, height: size.height + spacingExtensionInsets.verticalValue)
        UIGraphicsBeginImageContextWithOptions(contextSize, qmui_opaque, scale)
        draw(at: CGPoint(x: spacingExtensionInsets.left, y: spacingExtensionInsets.top))
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
    func qmui_image(clippedRect: CGRect) -> UIImage {
        CGContextInspectSize(clippedRect.size)
        let imageRect = size.rect
        if clippedRect.contains(imageRect) {
            // 要裁剪的区域比自身大，所以不用裁剪直接返回自身即可
            return self
        }
        // 由于CGImage是以pixel为单位来计算的，而UIImage是以point为单位，所以这里需要将传进来的point转换为pixel
        let scaledRect = clippedRect.apply(scale: scale)
        let imageRef = cgImage?.cropping(to: scaledRect)

        let imageOut = UIImage(cgImage: imageRef!, scale: scale, orientation: imageOrientation)
        return imageOut
    }
    
    /**
     *  将原图按指定的 UIViewContentMode 缩放，使其缩放后的大小不超过指定的大小，并返回缩放后的图片。
     *  @param size 在这个约束的 size 内进行缩放后的大小，处理后返回的图片的 size 会根据 contentMode 不同而不同，但必定不会超过 size。
     *  @param contentMode 希望使用的缩放模式，目前仅支持 .scaleToFill、.scaleAspectFill、.scaleAspectFill（默认）
     *  @param scale 用于指定缩放后的图片的倍数，默认为 self.scale
     *
     *  @return 处理完的图片
     */
    func qmui_imageResized(in limitedSize: CGSize,
                           contentMode: UIView.ContentMode = .scaleAspectFit,
                           scale:CGFloat = 0) -> UIImage? {
        var tmpScale = scale
        if scale == 0 {
            tmpScale = self.scale
        }
        let size = limitedSize.flatSpecific(scale: tmpScale)
        CGContextInspectSize(size)
        let imageSize = self.size
        var drawingRect = CGRect.zero // 图片绘制的 rect
        var contextSize = CGSize.zero // 画布的大小
        if size == imageSize && tmpScale == self.scale {
            return self
        }
        if contentMode == .scaleToFill {
            drawingRect = size.rect
            contextSize = size
        } else {
            let horizontalRatio = size.width / imageSize.width
            let verticalRatio = size.height / imageSize.height
            var ratio: CGFloat = 0
            if contentMode == .scaleAspectFill {
                ratio = fmax(horizontalRatio, verticalRatio)
            } else {
                // 默认按 UIViewContentModeScaleAspectFit
                ratio = fmin(horizontalRatio, verticalRatio)
            }
            let resizedSize = CGSize(width: flatSpecificScale(imageSize.width * ratio, tmpScale), height: flatSpecificScale(imageSize.height * ratio, tmpScale))
            contextSize = CGSize(width: fmin(size.width, resizedSize.width), height: fmin(size.height, resizedSize.height))
            drawingRect.origin.x = contextSize.width.center(resizedSize.width)
            drawingRect.origin.y = contextSize.height.center(resizedSize.height)
            drawingRect.size = resizedSize
        }
        UIGraphicsBeginImageContextWithOptions(contextSize, qmui_opaque, tmpScale)
        guard let context = UIGraphicsGetCurrentContext() else { return self }
        CGContextInspectContext(context)
        draw(in: drawingRect)
        let imageOut = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return imageOut
    }

    /**
     *  将原图进行旋转，只能选择上下左右四个方向
     *
     *  @param  direction 旋转的方向
     *
     *  @return 处理完的图片
     */
    func qmui_image(orientation: UIImage.Orientation) -> UIImage {
        if orientation == .up {
            return self
        }

        var contextSize = size
        if orientation == .left || orientation == .right {
            contextSize = CGSize(width: contextSize.height, height: contextSize.width)
        }

        contextSize = contextSize.flatSpecific(scale: scale)

        UIGraphicsBeginImageContextWithOptions(contextSize, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return self }
        CGContextInspectContext(context)
        
        // 画布的原点在左上角，旋转后可能图片就飞到画布外了，所以旋转前先把图片摆到特定位置再旋转，图片刚好就落在画布里
        switch orientation {
        case .up:
            // 上
            break
        case .down:
            // 下
            context.translateBy(x: contextSize.width, y: contextSize.height)
            context.rotate(by: AngleWithDegrees(180))
        case .left:
            // 左
            context.translateBy(x: 0, y: contextSize.height)
            context.rotate(by: AngleWithDegrees(-90))
            break
        case .right:
            // 右
            context.translateBy(x: contextSize.width, y: 0)
            context.rotate(by: AngleWithDegrees(90))
            break
        case .downMirrored, .upMirrored:
            // 向上、向下翻转是一样的
            context.translateBy(x: 0, y: contextSize.height)
            context.scaleBy(x: 1, y: -1)
        case .rightMirrored, .leftMirrored:
            // 向左、向右翻转是一样的
            context.translateBy(x: contextSize.width, y: 0)
            context.scaleBy(x: -1, y: 1)
        @unknown default:
            fatalError()
        }

        // 在前面画布的旋转、移动的结果上绘制自身即可，这里不用考虑旋转带来的宽高置换的问题
        draw(in: size.rect)

        let imageOut = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return imageOut ?? self
    }

    /**
     *  为图片加上一个border，border的路径为path
     *
     *  @param borderColor  border的颜色
     *  @param path         border的路径
     *
     *  @return 带border的UIImage
     *  @warning 注意通过`path.lineWidth`设置边框大小，同时注意路径要考虑像素对齐（`path.lineWidth / 2.0`）
     */
    func qmui_image(borderColor: UIColor, path: UIBezierPath) -> UIImage {
        let oldImage = self
        var resultImage: UIImage?
        let rect = oldImage.size.rect
        UIGraphicsBeginImageContextWithOptions(oldImage.size, qmui_opaque, oldImage.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return self }
        CGContextInspectContext(context)
        
        oldImage.draw(in: rect)
        context.setStrokeColor(borderColor.cgColor)
        path.stroke()
        resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resultImage!
    }

    /**
     *  为图片加上一个border，border的路径为borderColor、cornerRadius和borderWidth所创建的path
     *
     *  @param borderColor   border的颜色
     *  @param borderWidth    border的宽度
     *  @param cornerRadius  border的圆角
     *
     *  @param dashedLengths 一个CGFloat的数组，例如`CGFloat dashedLengths[] = {2, 4}`。如果不需要虚线，则传0即可
     *
     *  @return 带border的UIImage
     */
    func qmui_image(borderColor: UIColor, borderWidth: CGFloat, cornerRadius: CGFloat, dashedLengths: [CGFloat]?) -> UIImage {
        var path: UIBezierPath

        let rect = size.rect.insetBy(dx: borderWidth / 2, dy: borderWidth / 2) // 调整rect，从而保证绘制描边时像素对齐
        if cornerRadius > 0 {
            path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        } else {
            path = UIBezierPath(rect: rect)
        }

        path.lineWidth = borderWidth
        if let dashedLengths = dashedLengths {
            path.setLineDash(dashedLengths, count: 2, phase: 0)
        }
        
        return qmui_image(borderColor: borderColor, path: path)
    }

    func qmui_image(borderColor: UIColor, borderWidth: CGFloat, cornerRadius: CGFloat) -> UIImage {
        return qmui_image(borderColor: borderColor, borderWidth: borderWidth, cornerRadius: cornerRadius, dashedLengths: nil)
    }

    /**
     *  为图片加上一个border（可以是任意一条边，也可以是多条组合；只能创建矩形的border，不能添加圆角）
     *
     *  @param borderColor       border的颜色
     *  @param borderWidth        border的宽度
     *  @param borderPosition    border的位置
     *
     *  @return 带border的UIImage
     */
    func qmui_image(borderColor: UIColor, borderWidth: CGFloat, borderPosition: QMUIImageBorderPosition) -> UIImage {
        if borderPosition.contains(.all) {
            return qmui_image(borderColor: borderColor, borderWidth: borderWidth, cornerRadius: 0)
        } else {
            // TODO: 使用bezierPathWithRoundedRect:byRoundingCorners:cornerRadii:这个系统接口
            let path = UIBezierPath()
            if borderPosition.contains(.bottom) {
                path.move(to: CGPoint(x: 0, y: size.height - borderWidth / 2))
                path.addLine(to: CGPoint(x: size.width, y: size.height - borderWidth / 2))
            }
            if borderPosition.contains(.top) {
                path.move(to: CGPoint(x: 0, y: borderWidth / 2))
                path.addLine(to: CGPoint(x: size.width, y: borderWidth / 2))
            }
            if borderPosition.contains(.left) {
                path.move(to: CGPoint(x: borderWidth / 2, y: 0))
                path.addLine(to: CGPoint(x: borderWidth / 2, y: size.height))
            }
            if borderPosition.contains(.right) {
                path.move(to: CGPoint(x: size.width - borderWidth / 2, y: 0))
                path.addLine(to: CGPoint(x: size.width - borderWidth / 2, y: size.height))
            }
            path.lineWidth = borderWidth
            path.close()
            return qmui_image(borderColor: borderColor, path: path)
        }
    }

    /**
     *  返回一个被mask的图片
     *
     *  @param maskImage             mask图片
     *  @param usingMaskImageMode    是否使用“mask image”的方式，若为 YES，则黑色部分显示，白色部分消失，透明部分显示，其他颜色会按照颜色的灰色度对图片做透明处理。若为 NO，则 maskImage 要求必须为灰度颜色空间的图片（黑白图），白色部分显示，黑色部分消失，透明部分消失，其他灰色度对图片做透明处理。
     *
     *  @return 被mask的图片
     */
    func qmui_image(maskImage: UIImage, usingMaskImageMode: Bool) -> UIImage {
        let maskRef = maskImage.cgImage!
        var mask: CGImage
        if usingMaskImageMode {
            // 用CGImageMaskCreate创建生成的 image mask。
            // 黑色部分显示，白色部分消失，透明部分显示，其他颜色会按照颜色的灰色度对图片做透明处理。

            mask = CGImage(
                maskWidth: maskRef.width,
                height: maskRef.height,
                bitsPerComponent: maskRef.bitsPerComponent,
                bitsPerPixel: maskRef.bitsPerPixel,
                bytesPerRow: maskRef.bytesPerRow,
                provider: maskRef.dataProvider!,
                decode: nil,
                shouldInterpolate: true)!
        } else {
            // 用一个纯CGImage作为mask。这个image必须是单色(例如：黑白色、灰色)、没有alpha通道、不能被其他图片mask。系统的文档：If `mask' is an image, then it must be in a monochrome color space (e.g. DeviceGray, GenericGray, etc...), may not have alpha, and may not itself be masked by an image mask or a masking color.
            // 白色部分显示，黑色部分消失，透明部分消失，其他灰色度对图片做透明处理。
            mask = maskRef
        }

        let maskedImage = cgImage?.masking(mask)

        let returnImage = UIImage(cgImage: maskedImage!, scale: scale, orientation: imageOrientation)
        return returnImage
    }

    /**
     *  创建一个带边框路径，没有背景色的路径图片，border的路径为path
     *
     *  @param strokeColor  border的颜色
     *  @param path         border的路径
     *  @param addClip      是否要调path的addClip
     *
     *  @return 带border的UIImage
     */
    static func qmui_image(strokeColor: UIColor, size: CGSize, path: UIBezierPath, addClip: Bool) -> UIImage? {
        let size = size.flatted
        CGContextInspectSize(size)
        var resultImage: UIImage?
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        CGContextInspectContext(context)
        context.setStrokeColor(strokeColor.cgColor)
        if addClip {
            path.addClip()
        }
        path.stroke()
        resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resultImage
    }

    /**
     *  创建一个带边框路径，没有背景色的路径图片，border的路径为strokeColor、cornerRadius和lineWidth所创建的path
     *
     *  @param strokeColor  border的颜色
     *  @param lineWidth    border的宽度
     *  @param cornerRadius border的圆角
     *
     *  @return 带border的UIImage
     */
    static func qmui_image(strokeColor: UIColor, size: CGSize, lineWidth: CGFloat, cornerRadius: CGFloat) -> UIImage? {
        CGContextInspectSize(size)
        // 往里面缩一半的lineWidth，应为stroke绘制线的时候是往两边绘制的
        // 如果cornerRadius为0的时候使用bezierPathWithRoundedRect:cornerRadius:会有问题，左上角老是会多出一点，所以区分开
        var path: UIBezierPath

        let rect = size.rect.insetBy(dx: lineWidth / 2, dy: lineWidth / 2)
        if cornerRadius > 0 {
            path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        } else {
            path = UIBezierPath(rect: rect)
        }
        path.lineWidth = lineWidth

        return UIImage.qmui_image(strokeColor: strokeColor, size: size, path: path, addClip: false)
    }
    
    static func qmui_image(strokeColor: UIColor, size: CGSize, lineWidth: CGFloat, borderPosition: QMUIImageBorderPosition) -> UIImage? {
        CGContextInspectSize(size)

        if borderPosition.contains(.all) {
            return UIImage.qmui_image(strokeColor: strokeColor, size: size, lineWidth: lineWidth, cornerRadius: 0)
        } else {
            // TODO: 使用bezierPathWithRoundedRect:byRoundingCorners:cornerRadii:这个系统接口
            let path = UIBezierPath()
            if borderPosition.contains(.bottom) {
                path.move(to: CGPoint(x: 0, y: size.height - lineWidth / 2))
                path.addLine(to: CGPoint(x: size.width, y: size.height - lineWidth / 2))
            }
            if borderPosition.contains(.top) {
                path.move(to: CGPoint(x: 0, y: lineWidth / 2))
                path.addLine(to: CGPoint(x: size.width, y: lineWidth / 2))
            }
            if borderPosition.contains(.left) {
                path.move(to: CGPoint(x: lineWidth / 2, y: 0))
                path.addLine(to: CGPoint(x: lineWidth / 2, y: size.height))
            }
            if borderPosition.contains(.right) {
                path.move(to: CGPoint(x: size.width - lineWidth / 2, y: 0))
                path.addLine(to: CGPoint(x: size.width - lineWidth / 2, y: size.height))
            }
            path.lineWidth = lineWidth
            path.close()
            return UIImage.qmui_image(strokeColor: strokeColor, size: size, path: path, addClip: false)
        }
    }
    
    /**
     *  创建一个纯色的UIImage
     *
     *  @param  color           图片的颜色
     *  @param  size            图片的大小
     *  @param  cornerRadius    图片的圆角
     *
     * @return 纯色的UIImage
     */
    static func qmui_image(color: UIColor?,
                           size: CGSize = CGSize(width: 4, height: 4),
                           cornerRadius: CGFloat = 0) -> UIImage? {
        let size = size.flatted
        CGContextInspectSize(size)
        
        var resultImage: UIImage?
        let color = color ?? UIColorClear
        
        let opaque = (cornerRadius == 0.0 && color.qmui_alpha == 1.0)
        UIGraphicsBeginImageContextWithOptions(size, opaque, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        CGContextInspectContext(context)
        context.setFillColor(color.cgColor)
        
        if cornerRadius > 0 {
            
            let path = UIBezierPath(roundedRect: size.rect, cornerRadius: cornerRadius)
            path.addClip()
            path.fill()
        } else {
            context.fill(size.rect)
        }
        
        resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resultImage
    }
    
    /**
     *  创建一个纯色的UIImage，支持为四个角设置不同的圆角
     *  @param  color               图片的颜色
     *  @param  size                图片的大小
     *  @param  cornerRadius   四个角的圆角值的数组，长度必须为4，顺序分别为[左上角、左下角、右下角、右上角]
     */
    static func qmui_image(color: UIColor?, size: CGSize, cornerRadiusArray: [CGFloat]) -> UIImage? {
        let size = size.flatted
        CGContextInspectSize(size)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        let color = color ?? UIColorWhite
        context?.setFillColor(color.cgColor)
        
        let path = UIBezierPath(roundedRect: size.rect, cornerRadiusArray: cornerRadiusArray, lineWidth: 0)
        path.addClip()
        path.fill()
        
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resultImage
    }

    /**
     *  创建一个指定大小和颜色的形状图片
     *  @param shape 图片形状
     *  @param size 图片大小
     *  @param tintColor 图片颜色
     */
    static func qmui_image(shape: QMUIImageShape, size: CGSize, tintColor: UIColor?) -> UIImage? {
        var lineWidth: CGFloat = 0
        switch shape {
        case .navBack:
            lineWidth = 2
        case .disclosureIndicator:
            lineWidth = 1.5
        case .checkmark:
            lineWidth = 1.5
        case .detailButtonImage:
            lineWidth = 1
        case .navClose:
            lineWidth = 1.2 // 取消icon默认的lineWidth
        default:
            break
        }
        return qmui_image(shape: shape, size: size, lineWidth: lineWidth, tintColor: tintColor)
    }

    /**
     *  创建一个指定大小和颜色的形状图片
     *  @param shape 图片形状
     *  @param size 图片大小
     *  @param lineWidth 路径大小，不会影响最终size
     *  @param tintColor 图片颜色
     */
    static func qmui_image(shape: QMUIImageShape, size: CGSize, lineWidth: CGFloat, tintColor: UIColor?) -> UIImage? {
        let size = size.flatted
        CGContextInspectSize(size)

        var resultImage: UIImage?
        let tintColor = tintColor ?? UIColor(r: 255, g: 255, b: 255)

        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        CGContextInspectContext(context)
        var path: UIBezierPath
        var drawByStroke = false
        let drawOffset = lineWidth / 2
        switch shape {
        case .oval:
            path = UIBezierPath(ovalIn: size.rect)
        case .triangle:
            path = UIBezierPath()

            path.move(to: CGPoint(x: 0, y: size.height))
            path.addLine(to: CGPoint(x: size.width / 2, y: 0))

            path.addLine(to: CGPoint(x: size.width, y: size.height))
            path.close()
        case .navBack:
            drawByStroke = true
            path = UIBezierPath()
            path.lineWidth = lineWidth
            path.move(to: CGPoint(x: size.width - drawOffset, y: drawOffset))
            path.addLine(to: CGPoint(x: 0 + drawOffset, y: size.height / 2.0))
            path.addLine(to: CGPoint(x: size.width - drawOffset, y: size.height - drawOffset))
        case .disclosureIndicator:
            path = UIBezierPath()
            drawByStroke = true
            path.lineWidth = lineWidth
            path.move(to: CGPoint(x: drawOffset, y: drawOffset))
            path.addLine(to: CGPoint(x: size.width - drawOffset, y: size.height / 2))
            path.addLine(to: CGPoint(x: drawOffset, y: size.height - drawOffset))
        case .checkmark:
            let lineAngle = CGFloat.pi / 4
            path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: size.height / 2))
            path.addLine(to: CGPoint(x: size.width / 3, y: size.height))
            path.addLine(to: CGPoint(x: size.width, y: lineWidth * sin(lineAngle)))
            path.addLine(to: CGPoint(x: size.width - lineWidth * cos(lineAngle), y: 0))
            path.addLine(to: CGPoint(x: size.width / 3, y: size.height - lineWidth / sin(lineAngle)))
            path.addLine(to: CGPoint(x: lineWidth * sin(lineAngle), y: size.height / 2 - lineWidth * sin(lineAngle)))
            path.close()
        case .detailButtonImage:
            drawByStroke = true
            path = UIBezierPath(ovalIn: size.rect.insetBy(dx: drawOffset, dy: drawOffset))
            path.lineWidth = lineWidth
        case .navClose:
            drawByStroke = true
            path = UIBezierPath()
            path.move(to: .zero)
            path.addLine(to: CGPoint(x: size.width, y: size.height))
            path.close()
            path.move(to: CGPoint(x: size.width, y: 0))
            path.addLine(to: CGPoint(x: 0, y: size.height))
            path.close()
            path.lineWidth = lineWidth
            path.lineCapStyle = .round
        }

        if drawByStroke {
            context.setStrokeColor(tintColor.cgColor)
            path.stroke()
        } else {
            context.setFillColor(tintColor.cgColor)
            path.fill()
        }

        if shape == .detailButtonImage {
            let fontPointSize = flat(size.height * 0.8)
            let font = UIFont(name: "Georgia", size: fontPointSize) ?? .systemFont(ofSize: fontPointSize)

            let string = NSAttributedString(string: "i", attributes: [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: tintColor])
            let stringSize = string.boundingRect(with: size, options: .usesFontLeading, context: nil)

            string.draw(at: CGPoint(x: size.width.center(stringSize.width), y: size.height.center(stringSize.height)))
        }

        resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resultImage
    }

    /**
     *  将文字渲染成图片，最终图片和文字一样大
     */
    static func qmui_image(attributedString: NSAttributedString) -> UIImage? {
        // TODO: 归到NSAttributedString的扩展中
        let stringSize = attributedString.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil).size.sizeCeil
        UIGraphicsBeginImageContextWithOptions(stringSize, false, 0)
        guard let context  = UIGraphicsGetCurrentContext() else { return nil }
        CGContextInspectContext(context)
        
        attributedString.draw(in: stringSize.rect)
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resultImage
    }

    /**
     对传进来的 `UIView` 截图，生成一个 `UIImage` 并返回

     @param view 要截图的 `UIView`

     @return `UIView` 的截图
     */
    static func qmui_image(view: UIView) -> UIImage? {
        // TODO: 归到UIView的扩展中
        CGContextInspectSize(view.frame.size)
        // 老方式，因为drawViewHierarchyInRect:afterScreenUpdates:有一定的使用条件，有些情况下不一定截得到图，所有这种情况下可以使用老方式。
        // 如果可以用新方式，则建议使用新方式，性能上好很多
        var resultImage: UIImage?
        // 第二个参数是不透明度，这里默认设置为YES，不用出来alpha通道的事情，可以提高性能
        // 第三个参数是scale，设置为0的时候，意思是使用屏幕的scale
        UIGraphicsBeginImageContextWithOptions(view.frame.size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        CGContextInspectContext(context)
        view.layer.render(in: context)
        resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resultImage
    }

    /**
     对传进来的 `UIView` 截图，生成一个 `UIImage` 并返回

     @param view         要截图的 `UIView`
     @param afterUpdates 是否要在界面更新完成后才截图

     @return `UIView` 的截图
     */
    static func qmui_image(view: UIView, afterScreenUpdates afterUpdates: Bool) -> UIImage? {
        // TODO: 归到UIView的扩展中
        // iOS7截图新方式，性能好会好一点，不过不一定适用，因为这个方法的使用条件是：界面要已经render完，否则截到得图将会是empty。
        // 如果是iOS6调用这个接口，将会使用老的方式。
        var resultImage: UIImage?
        UIGraphicsBeginImageContextWithOptions(view.frame.size, false, 0.0)

        view.drawHierarchy(in: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height), afterScreenUpdates: afterUpdates)
        resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resultImage
    }
}
