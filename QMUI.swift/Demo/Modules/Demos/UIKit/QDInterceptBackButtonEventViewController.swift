//
//  QDInterceptBackButtonEventViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/4/23.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

class QDInterceptBackButtonEventViewController: QDCommonViewController, QMUITextViewDelegate, UINavigationControllerBackButtonHandlerProtocol {

    private var textView: QMUITextView!
    
    private var textCountLabel: UILabel!
    
    init() {
        super.init(nibName: nil, bundle: nil)
        automaticallyAdjustsScrollViewInsets = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func initSubviews() {
        super.initSubviews()
        
        textView = QMUITextView()
        textView.placeholder = "请输入个人简介..."
        textView.font = UIFontMake(15)
        textView.layer.borderWidth = PixelOne
        textView.layer.borderColor = UIColorSeparator.cgColor
        textView.layer.cornerRadius = 4
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 6, bottom: 8, right: 6)
        textView.delegate = self
        view.addSubview(textView)
        
        textCountLabel = UILabel()
        textCountLabel.font = UIFontMake(14)
        textCountLabel.numberOfLines = 0
        textCountLabel.textColor = UIColorGrayDarken
        textCountLabel.text = "请在下方输入内容，并点击返回按钮或者手势返回："
        textCountLabel.sizeToFit()
        view.addSubview(textCountLabel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textView.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let inset: CGFloat = 12
        let contentWidht = view.bounds.width - 2 * inset
        let labelSize = textCountLabel.sizeThatFits(CGSize(width: contentWidht, height: CGFloat.greatestFiniteMagnitude))
        textCountLabel.frame = CGRect(x: inset, y: qmui_navigationBarMaxYInViewCoordinator + 20, width: contentWidht, height: labelSize.height)
        textView.frame = CGRect(x: inset, y: textCountLabel.frame.maxY + 10, width: view.bounds.width - 2 * inset, height: 100)
    }
    
    private var localText: String {
        get {
            return UserDefaults.standard.string(forKey: "LocalText") ?? ""
        }
        set {
            let userDefaults = UserDefaults.standard
            userDefaults.set(newValue, forKey: "LocalText")
            userDefaults.synchronize()
        }
    }
    
    // MARK: UINavigationControllerBackButtonHandlerProtocol
    func shouldHoldBackButtonEvent() -> Bool {
        return true
    }
    
    func canPopViewController() -> Bool {
        // 这里不要做一些费时的操作，否则可能会卡顿
        if !textView.text.isEmpty {
            textView.resignFirstResponder()
            let alertController = QMUIAlertController(title: "是否返回？", message: "返回后输入框的数据将不会自动保存", preferredStyle: .alert)
            let backActioin = QMUIAlertAction(title: "返回", style: .cancel) { (_) in
                self.navigationController?.popViewController(animated: true)
            }
            let continueAction = QMUIAlertAction(title: "继续编辑", style: .default) { (_) in
                self.textView.becomeFirstResponder()
            }
            alertController.add(action: backActioin)
            alertController.add(action: continueAction)
            alertController.show(true)
            return false
        } else {
            return true
        }
    }
    
}
