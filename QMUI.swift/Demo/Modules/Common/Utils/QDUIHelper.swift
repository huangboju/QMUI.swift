//
//  QDUIHelper.swift
//  QMUI.swift
//
//  Created by TonyHan on 2018/3/7.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

class QDUIHelper {

    static func forceInterfaceOrientationPortrait() {
        
    }
    
}

// MARK: - QMUIMoreOperationAppearance
extension QDUIHelper {
    static func customMoreOperationAppearance() {
        // 如果需要统一修改全局的 QMUIMoreOperationController 样式，在这里修改 appearance 的值即可
    }
}

// MARK: - QMUIAlertControllerAppearance
extension QDUIHelper {
    static func customAlertControllerAppearance() {
        
    }
}

// MARK: - QMUIDialogViewControllerAppearance
extension QDUIHelper {
    static func customDialogViewControllerAppearance() {
        
    }
}

// MARK: - QMUIEmotionView
extension QDUIHelper {
    static func customEmotionViewAppearance() {
//        QMUIEmotionView.appearance().emotionSize = CGSize(width: 24, height: 24)
//        QMUIEmotionView.appearance().minimumEmotionHorizontalSpacing = 14
//        QMUIEmotionView.appearance().sendButtonBackgroundColor = QDThemeManager.shared.currentTheme!.themeTintColor
    }
}

// MARK: - UITabBarItem
extension QDUIHelper {
    
    static func tabBarItem(title: String?, image: UIImage?, selectedImage: UIImage?, tag: Int) -> UITabBarItem {
        let tabBarItem = UITabBarItem(title: title, image: image, tag: tag)
        tabBarItem.selectedImage = selectedImage
        return tabBarItem
    }
}

// MARK: - Button
extension QDUIHelper {
    static func generateDarkFilledButton() -> QMUIButton {
        let themeTintColor = QDThemeManager.shared.currentTheme.themeTintColor
        let button = QMUIButton(size: CGSize(width: 200, height: 40))
        button.adjustsButtonWhenHighlighted = true
        button.titleLabel?.font = UIFontBoldMake(14)
        button.setTitleColor(UIColorWhite, for: .normal)
        button.backgroundColor = themeTintColor
        button.highlightedBackgroundColor = themeTintColor.qmui_transition(to: UIColorBlack, progress: 0.15)// 高亮时的背景色
        button.layer.cornerRadius = 4
        return button
    }
    
    static func generateLightBorderedButton() -> QMUIButton {
        let themeTintColor = QDThemeManager.shared.currentTheme.themeTintColor
        let button = QMUIButton(size: CGSize(width: 200, height: 40))
        button.titleLabel?.font = UIFontBoldMake(14)
        button.setTitleColor(themeTintColor, for: .normal)
        button.backgroundColor = themeTintColor.qmui_transition(to: UIColorWhite, progress: 0.9)
        button.highlightedBackgroundColor = themeTintColor.qmui_transition(to: UIColorWhite, progress: 0.75) // 高亮时的背景色
        button.layer.borderColor = button.backgroundColor?.qmui_transition(to: themeTintColor, progress: 0.5).cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 4
        button.highlightedBorderColor = button.backgroundColor?.qmui_transition(to: themeTintColor, progress: 0.9) // 高亮时的边框颜色
        return button
    }
}

// MARK: - Emotion
extension QDUIHelper {
    
    static let QMUIEmotionString = "01-[微笑];02-[开心];03-[生气];04-[委屈];05-[亲亲];06-[坏笑];07-[鄙视];08-[啊]"
    
    static func qmuiEmotions() -> [QMUIEmotion] {
        var emotions = [QMUIEmotion]()
        let emotionStringArray = QMUIEmotionString.components(separatedBy: ";")
        emotionStringArray.forEach { (emotionString) in
            let emotionItems = emotionString.components(separatedBy: "-")
            let identifier = String("emotion_\(String(describing: emotionItems.first))")
            let emotion = QMUIEmotion(identifier: identifier, displayName: emotionItems.last!)
            emotions.append(emotion)
        }
        asyncLoadImages(emotions)
        return emotions
    }
    
    private static func asyncLoadImages(_ emotions: [QMUIEmotion]) {
        DispatchQueue.global().async {
            DispatchQueue.main.async {
                emotions.forEach { (emotion) in
//                    emotion.image = UIImageMake(emotion.identifier)?.qmui_imblen
                }
            }
        }
    }
    
    /// 用于主题更新后，更新表情 icon 的颜色
    static func updateEmotionImages() {
        asyncLoadImages(qmuiEmotions())
    }
}

// MARK: - SavePhoto
extension QDUIHelper {
    static func showAlertWhenSavedPhotoFailureByPermissionDenied() {
        
    }
}

// MARK: - Calculate
extension QDUIHelper {
    static func humanReadableFileSize(_ size: UInt64) {
        
    }
}

// MARK: - Theme
extension QDUIHelper {
    static func navigationBarBackgroundImage(_ color: UIColor?) -> UIImage? {
        let size = CGSize(width: 4, height: 88) // iPhone X，navigationBar 背景图 88，所以直接用 88 的图，其他手机会取这张图在 y 轴上的 0-64 部分的图片
        var resultImage: UIImage?
        let themeColor = color != nil ? color! : UIColorClear
        
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        let gradColors = [themeColor.cgColor, color?.qmui_colorWithAlphaAddedToWhite(0.86).cgColor]
        guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradColors as CFArray, locations: nil) else { return nil }
        context.drawLinearGradient(gradient, start: CGPoint.zero, end: CGPoint(x: 0, y: size.height), options: .drawsBeforeStartLocation)
        resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        resultImage = resultImage?.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1))
        return resultImage
    }
}


