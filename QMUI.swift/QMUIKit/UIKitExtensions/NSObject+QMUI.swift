//
//  NSObject+QMUI.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/2/9.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

extension NSObject {

    /**
     判断当前类是否有重写某个父类的指定方法

     @param selector 要判断的方法
     @param superclass 要比较的父类，必须是当前类的某个 superclass
     @return YES 表示子类有重写了父类方法，NO 表示没有重写（异常情况也返回 NO，例如当前类与指定的类并非父子关系、父类本身也无法响应指定的方法）
     */
    func qmui_hasOverrideMethod(selector: Selector, of superclass: AnyClass) -> Bool {
        return NSObject.qmui_hasOverrideMethod(selector: selector, for: type(of: self), of: superclass)
    }

    /**
     判断指定的类是否有重写某个父类的指定方法

     @param selector 要判断的方法
     @param superclass 要比较的父类，必须是当前类的某个 superclass
     @return YES 表示子类有重写了父类方法，NO 表示没有重写（异常情况也返回 NO，例如当前类与指定的类并非父子关系、父类本身也无法响应指定的方法）
     */
    static func qmui_hasOverrideMethod(selector: Selector,
                                       for aClass: AnyClass,
                                       of superclass: AnyClass) -> Bool {
        if !aClass.isSubclass(of: superclass) {
            return false
        }
        if !superclass.instancesRespond(to: selector) {
            return false
        }

        let superclassMethod = class_getInstanceMethod(superclass, selector)
        let instanceMethod = class_getInstanceMethod(aClass, selector)
        if instanceMethod == nil || instanceMethod == superclassMethod {
            return false
        }
        return true
    }

    /**
     遍历当前实例的所有方法，父类的方法不包含在内
     */
    func qmui_enumrateInstanceMethodsUsingBlock(_ block: ((_ selector: Selector?) -> Void)?) {
        NSObject.qmui_enumrateInstanceMethods(of: type(of: self), using: block)
    }

    /**
     遍历指定的某个类的实例方法，该类的父类方法不包含在内
     *  @param aClass   要遍历的某个类
     *  @param block    遍历时使用的 block，参数为某一个方法
     */
    static func qmui_enumrateInstanceMethods(of _: AnyClass,
                                             using block: ((_ selector: Selector?) -> Void)?) {
        var count: UInt32 = 0
        let methods = class_copyMethodList(NSObject.self, &count)
        for i in 0 ..< Int(count) {
            if let method = methods?[i] {
                let sel = method_getName(method)
                block?(sel)
                let name = String(cString: sel_getName(sel))
                print(name)
            } else {
                block?(nil)
            }
        }
    }

    /**
     遍历某个 protocol 里的所有方法

     @param protocol 要遍历的 protocol，例如 \@protocol(xxx)
     @param block 遍历过程中调用的 block
     */
    static func qmui_enumerateProtocolMethods(ptc: Protocol,
                                              using block: ((_ selector: Selector?) -> Void)?) {
        var methodCount: UInt32 = 0
        let methods = protocol_copyMethodDescriptionList(ptc, false, true, &methodCount)
        for i in 0 ..< methodCount {
            block?(methods?[Int(i)].name)
        }
    }
}
