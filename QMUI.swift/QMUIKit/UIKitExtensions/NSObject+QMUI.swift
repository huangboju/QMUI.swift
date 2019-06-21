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

        if !type(of: self).isSubclass(of: superclass) {
//            print("\(#function), \(NSStringFromClass(superclass)) 并非 \(NSStringFromClass(type(of: self))) 的父类")
            return false
        }

        if !superclass.instancesRespond(to: selector) {
//            print("\(#function), 父类 \(NSStringFromClass(superclass)) 自己本来就无法响应 \(NSStringFromSelector(selector)) 方法")
            return false
        }

        let superclassMethod = class_getInstanceMethod(superclass, selector)
        let instanceMethod = class_getInstanceMethod(type(of: self), selector)
        if instanceMethod == nil || instanceMethod == superclassMethod {
            return false
        }
        return true
    }

    /**
     对 super 发送消息

     @param aSelector 要发送的消息
     @return 消息执行后的结果
     @link http://stackoverflow.com/questions/14635024/using-objc-msgsendsuper-to-invoke-a-class-method
     */
    //    func qmui_performSelectorToSuperclass(aSelector: Selector) -> Any {
    //        var mySuper = objc_super()
    //        mySuper.receiver = self
    //        mySuper.super_class = class_getSuperclass(object_getClass(self))
    //        return
    //    }

    /**
     对 super 发送消息

     @param aSelector 要发送的消息
     @param object 作为参数传过去
     @return 消息执行后的结果
     @link http://stackoverflow.com/questions/14635024/using-objc-msgsendsuper-to-invoke-a-class-method
     */
    //    func qmui_performSelectorToSuperclass(aSelector: Selector, with object: Any) -> Any {
    //
    //    }
    
    /**
     遍历当前实例的所有方法，父类的方法不包含在内
     */
    func qmui_enumrateInstanceMethods(using handle: ((_ selector: Selector?) -> Void)?) {
        NSObject.qmui_enumrateInstanceMethods(of: type(of: self),using: handle)
    }
    
    /**
     遍历指定的某个类的实例方法，该类的父类方法不包含在内
     *  @param aClass   要遍历的某个类
     *  @param block    遍历时使用的 block，参数为某一个方法
     */
    static func qmui_enumrateInstanceMethods(of aClass: AnyClass, using handle: ((_ selector: Selector?) -> Void)?) {
        var count:UInt32 = 0
        let methods = class_copyMethodList(NSObject.self , &count)
        for i in 0..<Int(count){
            if let method = methods?[i] {
                let sel = method_getName(method)
                handle?(sel)
                let name = String(cString: sel_getName(sel))
                print(name)
            } else {
                handle?(nil)
            }
        }
    }
    
    
    /**
     遍历某个 protocol 里的所有方法

     @param protocol 要遍历的 protocol，例如 \@protocol(xxx)
     @param block 遍历过程中调用的 block
     */
    static func qmui_enumerateProtocolMethods(ptc: Protocol, using handle: ((_ selector: Selector?) -> Void)?) {
        var methodCount: UInt32 = 0
        let methods = protocol_copyMethodDescriptionList(ptc, false, true, &methodCount)
        for i in 0 ..< methodCount {
            handle?(methods?[Int(i)].name)
        }
    }
}
