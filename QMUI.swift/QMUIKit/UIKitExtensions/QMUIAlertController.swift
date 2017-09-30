//
//  QMUIAlertController.swift
//  QMUI.swift
//
//  Created by xnxin on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

enum QMUIAlertControllerStyle: Int {
    case sheet = 0
    case alert
}

enum QMUIAlertActionStyle: Int {
    case `default` = 0
    case cancel
    case destructive
};

class QMUIAlertController: UIViewController {

    public init(title: String?, message: String? = nil, preferredStyle: QMUIAlertControllerStyle) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    public func addAction(_ action: QMUIAlertAction) {
    
    }

    public func showWithAnimated(_ animated: Bool = true) {
    
    }
}

class QMUIAlertAction {
    init(title: String?, style: QMUIAlertActionStyle, handler: ((QMUIAlertAction) -> Void)? = nil) {
        
    }
}
