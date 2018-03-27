//
//  SelfAware.swift
//  QMUI.swift
//
//  Created by 黄伯驹 on 2017/9/30.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

protocol SelfAware: class {
    static func awake()
}

protocol SelfAware2: class {
    static func awake2()
}

protocol SelfAware3: class {
    static func awake3()
}

class NothingToSeeHere {

    static func harmlessFunction() {
        let typeCount = Int(objc_getClassList(nil, 0))
        let types = UnsafeMutablePointer<AnyClass?>.allocate(capacity: typeCount)
        let autoreleasingTypes = AutoreleasingUnsafeMutablePointer<AnyClass>(types)
        objc_getClassList(autoreleasingTypes, Int32(typeCount))
        for index in 0 ..< typeCount {
            (types[index] as? SelfAware.Type)?.awake()
            (types[index] as? SelfAware2.Type)?.awake2()
            (types[index] as? SelfAware3.Type)?.awake3()
        }
        
        types.deallocate(capacity: typeCount)
    }
}

extension UIApplication {

    private static let runOnce: Void = {
        NothingToSeeHere.harmlessFunction()
    }()

    open override var next: UIResponder? {
        // Called before applicationDidFinishLaunching
        UIApplication.runOnce
        return super.next
    }
}
