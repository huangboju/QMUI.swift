//
//  QDSaveImageToSpecifiedAlbumViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/5/15.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

private let TestImageSize = CGSize(width: 160, height: 160)

class QDSaveImageToSpecifiedAlbumViewController: QDCommonViewController {

    private var changeImageButton: QMUIButton!
    private var saveButton: QMUIButton!
    private var alertController: QMUIAlertController?
    private var testImageView: UIImageView!
    private let textArray: [String] = ["A", "B","C","D","E","F","G"]
    private var albumsArray: [QMUIAssetsGroup]
    
    init() {
        albumsArray = [QMUIAssetsGroup]()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func initSubviews() {
        super.initSubviews()
        
        testImageView = UIImageView()
        testImageView.image = randomImage
        view.addSubview(testImageView)
        
        // 普通按钮
        changeImageButton = QDUIHelper.generateLightBorderedButton()
        changeImageButton.setTitle("更换随机图片", for: .normal)
        changeImageButton.addTarget(self, action: #selector(handleGeneratedButtonClick(_:)), for: .touchUpInside)
        view.addSubview(changeImageButton)
        
        // 边框按钮
        saveButton = QDUIHelper.generateDarkFilledButton()
        saveButton.setTitle("保存图片到指定相册", for: .normal)
        saveButton.addTarget(self, action: #selector(handleSaveButtonClick(_:)), for: .touchUpInside)
        view.addSubview(saveButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let contentMinY = qmui_navigationBarMaxYInViewCoordinator
        testImageView.frame = CGRect(x: view.bounds.width.center(TestImageSize.width), y: contentMinY + 60, width: TestImageSize.width, height: TestImageSize.height)
        changeImageButton.frame = changeImageButton.frame.setXY(view.bounds.width.center(changeImageButton.frame.width), testImageView.frame.maxY + 50)
        saveButton.frame = changeImageButton.frame.setY(changeImageButton.frame.maxY + 30)
    }
    
    @objc private func handleGeneratedButtonClick(_ sender: Any?) {
        testImageView.image = randomImage
    }
    
    @objc private func handleSaveButtonClick(_ sender: Any?) {
        if QMUIAssetsManager.authorizationStatus == .notDetermined {
            QMUIAssetsManager.requestAuthorization { (status) in
                // requestAuthorization:(void(^)(QMUIAssetAuthorizationStatus status))handler 不在主线程执行，因此涉及 UI 相关的操作需要手工放置到主流程执行。
                DispatchQueue.main.async {
                    if status == .authorized {
                        self.saveImageToAlbum()
                    } else {
                        QDUIHelper.showAlertWhenSavedPhotoFailureByPermissionDenied()
                    }
                }
            }
        } else if QMUIAssetsManager.authorizationStatus == .notAuthorized {
            QDUIHelper.showAlertWhenSavedPhotoFailureByPermissionDenied()
        } else {
            saveImageToAlbum()
        }
    }
    
    private func saveImageToAlbum() {
        if alertController == nil {
            alertController = QMUIAlertController(title: "保存到指定相册", message: nil, preferredStyle: .sheet)
            // 显示空相册，不显示智能相册
            QMUIAssetsManager.shared.enumerateAllAlbums(
                withAlbumContentType: .all,
                showEmptyAlbum: true,
                showSmartAlbumIfSupported: false) { (resultAssetsGroup) in
                    if let resultAssetsGroup = resultAssetsGroup {
                        self.albumsArray.append(resultAssetsGroup)
                        let action = QMUIAlertAction(title: resultAssetsGroup.name, style: .default, handler: { (action) in
                            QMUIImageWriteToSavedPhotosAlbumWithAlbumAssetsGroup(image: self.testImageView.image!, albumAssetsGroup: resultAssetsGroup, completionBlock: { (asset, error) in
                                if asset != nil {
                                    QMUITips.showSucceed(text: "已保存到相册-\(String(describing: resultAssetsGroup.name!))", in: (self.navigationController?.view)!, hideAfterDelay: 2)
                                }
                            })
                        })
                        self.alertController?.add(action: action)
                    } else {
                        let cancelAction = QMUIAlertAction(title: "取消", style: .cancel, handler: nil)
                        self.alertController?.add(action: cancelAction)
                    }
            }
        }
        alertController?.show(true)
    }
    
    private var randomText: String {
        let index = Int(arc4random()) % textArray.count
        let text = textArray[index]
        return text
    }
    
    private var randomImage: UIImage? {
        guard let tmpImage = image(from: randomText, textColor: UIColorWhite), let resultBackgroundImage = UIImage.qmui_image(shape: .oval, size: CGSize(width: TestImageSize.width, height: TestImageSize.height), tintColor: QDCommonUI.randomThemeColor()) else {
            return nil
        }
        let resultImage = resultBackgroundImage.qmui_image(imageAbove: tmpImage, at: CGPoint(x: resultBackgroundImage.size.width.center(tmpImage.size.width), y: resultBackgroundImage.size.height.center(tmpImage.size.height)))
        return resultImage
    }
    
    private func image(from text: String, textColor: UIColor) -> UIImage? {
        let font = UIFontMake(95)
        let fontAttributes = [NSAttributedString.Key.font : font, NSAttributedString.Key.foregroundColor: textColor]
        let size = text.size(withAttributes:fontAttributes)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        text.draw(at: CGPoint(x: 0, y: 0),withAttributes: fontAttributes)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
