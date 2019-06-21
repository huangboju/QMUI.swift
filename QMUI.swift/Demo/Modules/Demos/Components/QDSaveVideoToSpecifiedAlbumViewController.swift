//
//  QDSaveVideoToSpecifiedAlbumViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/5/15.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit
import MobileCoreServices
import Photos

class QDSaveVideoToSpecifiedAlbumViewController: QDCommonViewController {

    private var videoPath: String?
    private var takeVideoButton: QMUIButton!
    private var pickerController: UIImagePickerController?
    private var actionSheet: QMUIAlertController?
    private var albumsArray: [QMUIAssetsGroup]
    
    init() {
        albumsArray = [QMUIAssetsGroup]()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setNavigationItems(_ isInEditMode: Bool, animated: Bool) {
        super.setNavigationItems(isInEditMode, animated: animated)
        title = "保存视频到指定相册"
    }
    
    override func initSubviews() {
        super.initSubviews()
    
        takeVideoButton = QDUIHelper.generateLightBorderedButton()
        takeVideoButton.setTitle("拍摄视频", for: .normal)
        takeVideoButton.addTarget(self, action: #selector(handleTakeVideoButtonClick(_:)), for: .touchUpInside)
        view.addSubview(takeVideoButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        takeVideoButton.frame = takeVideoButton.frame.setXY(view.bounds.width.center(takeVideoButton.frame.width), view.bounds.height.center(takeVideoButton.frame.height))
    }

    @objc private func handleTakeVideoButtonClick(_ sender: Any?) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            if pickerController == nil {
                pickerController = UIImagePickerController()
                pickerController?.sourceType = .camera
                pickerController?.mediaTypes = [kUTTypeMovie as String]
                pickerController?.delegate = self
            }
            
            present(pickerController!, animated: true) {
                UIApplication.shared.isStatusBarHidden = true
            }
        } else {
            QMUITips.showError(text: "检测不到该设备中有可使用的摄像头", in: view, hideAfterDelay: 2)
        }
    }
    
    private func saveVideoToAlbum(with info: [String : Any]) {
        if actionSheet == nil {
            actionSheet = QMUIAlertController(title: "保存到指定相册", message: nil, preferredStyle: .sheet)
            // 显示空相册，不显示智能相册
            QMUIAssetsManager.shared.enumerateAllAlbums(withAlbumContentType: .all, showEmptyAlbum: true, showSmartAlbumIfSupported: false) { (resultAssetsGroup) in
                if let resultAssetsGroup = resultAssetsGroup {
                    self.albumsArray.append(resultAssetsGroup)
                    let action = QMUIAlertAction(title: resultAssetsGroup.name, style: .default, handler: { (action) in
                        if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(self.videoPath!) {
                            QMUISaveVideoAtPathToSavedPhotosAlbumWithAlbumAssetsGroup(videoPath: self.videoPath!, albumAssetsGroup: resultAssetsGroup, completionBlock: { (asset, error) in
                                if asset != nil {
                                    QMUITips.showSucceed(text: "已保存到相册-\(String(describing: resultAssetsGroup.name!))", in: (self.navigationController?.view)!, hideAfterDelay: 2)
                                }
                            })
                        } else {
                            QMUITips.showError(text: "保存失败，视频格式不符合当前设备要求", in: self.view, hideAfterDelay: 2)
                        }
                    })
                    self.actionSheet?.add(action: action)
                } else {
                    // group 为 nil，即遍历相册完毕
                    let cancelAction = QMUIAlertAction(title: "取消", style: .cancel, handler: nil)
                    self.actionSheet?.add(action: cancelAction)
                }
            }
        }
        
        let videoURL = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.mediaURL)] as! URL
        self.videoPath = videoURL.path
        actionSheet?.show(true)
    }
}

extension QDSaveVideoToSpecifiedAlbumViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        picker.dismiss(animated: true) {
            if QMUIAssetsManager.authorizationStatus == .notDetermined {
                QMUIAssetsManager.requestAuthorization { (status) in
                    // requestAuthorization:(void(^)(QMUIAssetAuthorizationStatus status))handler 不在主线程执行，因此涉及 UI 相关的操作需要手工放置到主流程执行。
                    DispatchQueue.main.async {
                        if status == .authorized {
                            self.saveVideoToAlbum(with: info)
                        } else {
                            QDUIHelper.showAlertWhenSavedPhotoFailureByPermissionDenied()
                        }
                    }
                }
            } else if QMUIAssetsManager.authorizationStatus == .notAuthorized {
                QDUIHelper.showAlertWhenSavedPhotoFailureByPermissionDenied()
            } else {
                self.saveVideoToAlbum(with: info)
            }
            UIApplication.shared.isStatusBarHidden = false
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {
            UIApplication.shared.isStatusBarHidden = false
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
