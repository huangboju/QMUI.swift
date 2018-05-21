//
//  QDObjectMethodsListViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/4/25.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

class QDObjectMethodsListViewController: QDCommonViewController {
    
    private var selectorNames: [String] = []
    private var textView: UITextView!

    init(aClass: AnyClass) {
        super.init(nibName: nil, bundle: nil)
        automaticallyAdjustsScrollViewInsets = false
        
        NSObject.qmui_enumrateInstanceMethods(of: aClass) { (selector) in
            if let selector = selector {
                self.selectorNames.append("- \(NSStringFromSelector(selector))")
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func initSubviews() {
        super.initSubviews()
        
        textView = UITextView()
        textView.textContainerInset = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
        textView.isEditable = false
        textView.attributedText = attributedStringForTextView()
        view.addSubview(textView)
    }
    
    private func attributedStringForTextView() -> NSAttributedString {
        let attributes: [NSAttributedStringKey: Any] = [NSAttributedStringKey.font : CodeFontMake(14), NSAttributedStringKey.foregroundColor: UIColorGray1, NSAttributedStringKey.paragraphStyle: NSMutableParagraphStyle(lineHeight: 24)]
        let attributedString = NSAttributedString(string: selectorNames.joined(separator: "\n"), attributes: attributes)
        return attributedString
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        textView.frame = view.bounds.insetEdges(UIEdgeInsets(top: qmui_navigationBarMaxYInViewCoordinator, left: 0, bottom: 0, right: 0))
    }
}
