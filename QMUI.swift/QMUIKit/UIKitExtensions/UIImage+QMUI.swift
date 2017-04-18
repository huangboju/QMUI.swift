//
//  UIImage+QMUI.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/1/17.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

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
     *  判断一张图是否不存在 alpha 通道，注意 “不存在 alpha 通道” 不等价于 “不透明”。一张不透明的图有可能是存在 alpha 通道但 alpha 值为 1。
     */
    public var qmui_opaque: Bool {
        let alphaInfo = cgImage!.alphaInfo
        let opaque = alphaInfo == .noneSkipLast
            || alphaInfo == .noneSkipFirst
            || alphaInfo == .none
        return opaque
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
