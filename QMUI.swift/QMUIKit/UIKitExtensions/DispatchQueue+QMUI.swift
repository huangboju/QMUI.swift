//
//  DispatchQueue+QMUI.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/3/18.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

extension DispatchQueue {

    private static var _onceTracker = [String]()

    public class func once(token: String, block: () -> Void) {
        objc_sync_enter(self); defer { objc_sync_exit(self) }

        if _onceTracker.contains(token) {
            return
        }

        _onceTracker.append(token)
        block()
    }
}
