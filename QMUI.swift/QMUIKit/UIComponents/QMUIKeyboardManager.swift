//
//  QMUIKeyboardManager.swift
//  QMUI.swift
//
//  Created by 黄伯驹 on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//
import UIKit

extension UIView {
    fileprivate func qmui_findFirstResponder() -> UIView? {
        if isFirstResponder {
            return self
        }

        for subview in subviews {
            if let responder = subview.qmui_findFirstResponder() {
                return responder
            }
        }
        return nil
    }
}

/// 注意：由于某些Bug（例如 iOS 8 的 iPad 修改切换键盘类型，delegate 回调键盘高度值错误），QMUIKeyboardManager 不再支持 iPad 的浮动键盘了 - 更新于 2017.12.8 ///

/**
 *  `QMUIKeyboardManager` 提供了方便管理键盘事件的方案，使用的场景是需要跟随键盘的显示或者隐藏来更改界面的 UI，例如输入框跟随在键盘的顶部。
 *  由于键盘通知是整个 App 全局的，所以经常会遇到 A 的键盘监听回调里接收到 B 的键盘事件，这样的情况往往不是我们想要的，即使可以通过判断当前的 firstResponder 来区分，但还是不能完美的解决问题或者有时候解决起来非常麻烦。`QMUIKeyboardManager` 通过 `delegateEnabled` 和 `targetResponder` 等属性来方便地控制 firstResponder，从而可以实现某个键盘监听回调方法只响应某个 UIResponder 或者某几个 UIResponder 触发的键盘通知。
 *  使用方式：
 *  1. 使用 initWithDelegate: 方法初始化
 *  2. 通过 addTargetResponder: 的方式将要监听的输入框添加进来
 *  3. 在 delegate 方法里（一般用 keyboardWillChangeFrameWithUserInfo:）处理键盘位置变化时的布局
 *
 *  另外 QMUIKeyboardManager 同时集成在了 UITextField(QMUI) 和 UITextView(QMUI) 里，具体请查看对应文件。
 *  @see UITextField(QMUI)
 *  @see UITextView(QMUI)
 */
class QMUIKeyboardManager: NSObject {
    
    static var kCurrentResponder: UIResponder?
    
    // 1、系统键盘app启动第一次使用键盘的时候，会调用两轮键盘通知事件，之后就只会调用一次。而搜狗等第三方输入法的键盘，目前发现每次都会调用三次键盘通知事件。总之，键盘的通知事件是不确定的。
    
    // 2、搜狗键盘可以修改键盘的高度，在修改键盘高度之后，会调用键盘的keyboardWillChangeFrameNotification和keyboardWillShowNotification通知。
    
    // 3、如果从一个聚焦的输入框直接聚焦到另一个输入框，会调用前一个输入框的keyboardWillChangeFrameNotification，在调用后一个输入框的keyboardWillChangeFrameNotification，最后调用后一个输入框的keyboardWillShowNotification（如果此时是浮动键盘，那么后一个输入框的keyboardWillShowNotification不会被调用；）。
    
    // 4、iPad可以变成浮动键盘，固定->浮动：会调用keyboardWillChangeFrameNotification和keyboardWillHideNotification；浮动->固定：会调用keyboardWillChangeFrameNotification和keyboardWillShowNotification；浮动键盘在移动的时候只会调用keyboardWillChangeFrameNotification通知，并且endFrame为zero，fromFrame不为zero，而是移动前键盘的frame。浮动键盘在聚焦和失焦的时候只会调用keyboardWillChangeFrameNotification，不会调用show和hide的notification。
    
    // 5、iPad可以拆分为左右的小键盘，小键盘的通知具体基本跟浮动键盘一样。
    
    // 6、iPad可以外接键盘，外接键盘之后屏幕上就没有虚拟键盘了，但是当我们输入文字的时候，发现底部还是有一条灰色的候选词，条东西也是键盘，它也会触发跟虚拟键盘一样的通知事件。如果点击这条候选词右边的向下箭头，则可以完全隐藏虚拟键盘，这个时候如果失焦再聚焦发现还是没有这条候选词，也就是键盘完全不出来了，如果输入文字，候选词才会重新出来。总结来说就是这条候选词是可以关闭的，关闭之后只有当下次输入才会重新出现。（聚焦和失焦都只调用keyboardWillChangeFrameNotification和keyboardWillHideNotification通知，而且frame始终不变，都是在屏幕下面）
    
    // 7、iOS8 hide 之后高度变成0了，keyboardWillHideNotification还是正常的，所以建议不要使用键盘高度来做动画，而是用键盘的y值；在show和hide的时候endFrame会出现一些奇怪的中间值，最终值是对的；两个输入框切换聚焦，iOS8不会触发任何键盘通知；iOS8的浮动切换正常；
    
    // 8、iOS8在 固定->浮动 的过程中，后面的keyboardWillChangeFrameNotification和keyboardWillHideNotification里面的endFrame是正确的，而iOS10和iOS9是错的，iOS9的y值是键盘的MaxY，而iOS10的y值是隐藏状态下的y，也就是屏幕高度。所以iOS9和iOS10需要在keyboardDidChangeFrameNotification里面重新刷新一下。
    
    private var targetResponderValues: [NSValue] = []
    private var keyboardMoveUserInfo: QMUIKeyboardUserInfo?
    private var keyboardMoveBeginRect: CGRect = .zero
    
    fileprivate weak var currentResponder: UIResponder?
    fileprivate weak var currentResponderWhenResign: UIResponder?
    
    private var isDebug: Bool = false

    init(with delegate: QMUIKeyboardManagerDelegate) {
        self.delegate = delegate
        delegateEnabled = true
        super.init()
        addKeyboardNotification()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    /**
     *  获取当前的 delegate
     */
    private(set) weak var delegate: QMUIKeyboardManagerDelegate?

    /**
     *  是否允许触发delegate的回调，某些场景可能要主动停止对键盘事件的响应。
     *  默认为 YES。
     */
    var delegateEnabled: Bool = true

    /**
     *  添加触发键盘事件的 UIResponder，一般是 UITextView 或者 UITextField ，不添加 targetResponder 的话，则默认接受任何 UIResponder 产生的键盘通知。
     *  添加成功将会返回 true，否则返回 false。
     */
    @discardableResult
    func add(targetResponder: UIResponder) -> Bool {

        if !targetResponder.isKind(of: UIResponder.self) {
            return false
        }
        targetResponderValues.append(packageTargetResponder(targetResponder))
        return true
    }

    /**
     *  获取当前所有的 target UIResponder，若不存在则返回 nil
     */
    func allTargetResponders() -> [UIResponder] {
        var targetResponders = [UIResponder]()
        for value in targetResponderValues {
            if let responder = unPackageTargetResponder(value) {
                targetResponders.append(responder)
            }
        }
        return targetResponders
    }
    
    /**
     *  移除 targetResponder 跟 keyboardManager 的关系，如果成功会返回 YES
     */
    func remove(targetResponder: UIResponder) -> Bool {
        if targetResponderValues.contains(packageTargetResponder(targetResponder)) {
            targetResponderValues.remove(object: packageTargetResponder(targetResponder))
            return true
        }
        return false
    }

    private func packageTargetResponder(_ targetResponder: UIResponder) -> NSValue {
        return NSValue(nonretainedObject: targetResponder)
    }

    private func unPackageTargetResponder(_ value: NSValue) -> UIResponder? {
        if let responder = value.nonretainedObjectValue as? UIResponder {
            return responder
        }

        return nil
    }

    // MARK: - Notification
    private func addKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidChangeFrame(_:)), name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        if isDebug {
            print("keyboardWillShowNotification - \(self)")
        }
        
        if !shouldReceiveShowNotification() {
            return
        }

        let userInfo = newUserInfoWithNotification(notification)
        userInfo.targetResponder = QMUIKeyboardManager.kCurrentResponder

        if delegateEnabled {
            delegate?.keyBoardWillShow?(userInfo)
        }

        // 额外处理iPad浮动键盘
//        if IS_IPAD {
//            keyboardMoveUserInfo = userInfo
//            keyboardDidChangeFrame(keyboardView: type(of: self).keyboardView())
//        }
    }

    @objc private func keyboardDidShow(_ notification: Notification) {
        
        if isDebug {
            print("keyboardDidShowNotification - \(self)")
        }

        let userInfo = newUserInfoWithNotification(notification)
        userInfo.targetResponder = currentResponder

        let firstResponder = UIApplication.shared.keyWindow?.qmui_findFirstResponder()
        let shouldReceiveDidShowNotification = targetResponderValues.count <= 0 || firstResponder == QMUIKeyboardManager.kCurrentResponder

        if shouldReceiveDidShowNotification {
            if delegateEnabled {
                delegate?.keyBoardDidShow?(nil)
            }
            
            // 额外处理iPad浮动键盘
//            if IS_IPAD {
//                keyboardMoveUserInfo = userInfo
//                keyboardDidChangeFrame(keyboardView: type(of: self).keyboardView())
//            }
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        
        if isDebug {
            print("keyboardWillHideNotification - \(self)")
        }

        if !shouldReceiveHideNotification() {
            return
        }

        let userInfo = newUserInfoWithNotification(notification)
        userInfo.targetResponder = QMUIKeyboardManager.kCurrentResponder

        if delegateEnabled {
            delegate?.keyboardWillHide?(userInfo)
        }
        
        // 额外处理iPad浮动键盘
//        if IS_IPAD {
//            keyboardMoveUserInfo = userInfo
//            keyboardDidChangeFrame(keyboardView: type(of: self).keyboardView())
//        }
    }

    @objc private func keyboardDidHide(_ notification: Notification) {
        
        if isDebug {
            print("keyboardDidHideNotification - \(self)")
        }

        let userInfo = newUserInfoWithNotification(notification)
        userInfo.targetResponder = QMUIKeyboardManager.kCurrentResponder

        if shouldReceiveHideNotification() {
            if delegateEnabled {
                delegate?.keyboardDidHide?(userInfo)
            }
        }

        if QMUIKeyboardManager.kCurrentResponder != nil && QMUIKeyboardManager.kCurrentResponder!.isFirstResponder && !IS_IPAD {
            QMUIKeyboardManager.kCurrentResponder = nil
        }

        // 额外处理iPad浮动键盘
//        if IS_IPAD {
//            if targetResponderValues.count <= 0 || kCurrentResponder != nil {
//                keyboardMoveUserInfo = userInfo
//                keyboardDidChangeFrame(keyboardView: type(of: self).keyboardView())
//            }
//        }
    }

    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        
        if isDebug {
            print("keyboardWillChangeFrameNotification - \(self)")
        }

        let userInfo = newUserInfoWithNotification(notification)
        if shouldReceiveShowNotification() {
            userInfo.targetResponder = currentResponder
        } else if shouldReceiveHideNotification() {
            userInfo.targetResponder = currentResponder
        } else {
            return
        }

        if delegateEnabled {
            delegate?.keyboardWillChangeFrame?(with: userInfo)
        }
        
        // 额外处理iPad浮动键盘
//        if IS_IPAD {
//            keyboardMoveUserInfo = userInfo
//            addFrameObserverIfNeeded()
//        }
    }

    @objc private func keyboardDidChangeFrame(_ notification: Notification) {
        
        if isDebug {
            print("keyboardDidChangeFrameNotification - \(self)")
        }

        let userInfo = newUserInfoWithNotification(notification)
        if shouldReceiveShowNotification() {
            userInfo.targetResponder = QMUIKeyboardManager.kCurrentResponder
        } else if shouldReceiveHideNotification() {
            userInfo.targetResponder = QMUIKeyboardManager.kCurrentResponder
        } else {
            return
        }

        if delegateEnabled {
            delegate?.keyboardDidChangeFrame?(with: userInfo)
        }

        // 额外处理iPad浮动键盘
//        if IS_IPAD {
//            keyboardMoveUserInfo = userInfo
//            keyboardDidChangeFrame(keyboardView: type(of: self).keyboardView())
//        }
    }

    private func newUserInfoWithNotification(_ notification: Notification) -> QMUIKeyboardUserInfo {
        let userInfo = QMUIKeyboardUserInfo()
        userInfo.keyboardManager = self
        userInfo.notification = notification
        return userInfo
    }

    private func shouldReceiveShowNotification() -> Bool {
        
        // 这里有BUG，如果点击了webview导致键盘下降，这个时候运行shouldReceiveHideNotification就会判断错误
        QMUIKeyboardManager.kCurrentResponder = currentResponderWhenResign ??  UIApplication.shared.keyWindow?.qmui_findFirstResponder()
        currentResponderWhenResign = nil

        if targetResponderValues.count <= 0 {
            return true
        } else {
            return QMUIKeyboardManager.kCurrentResponder != nil && targetResponderValues.contains(packageTargetResponder(QMUIKeyboardManager.kCurrentResponder!))
        }
    }

    private func shouldReceiveHideNotification() -> Bool {
        if targetResponderValues.count <= 0 {
            return true
        } else {
            if let currentResponder = QMUIKeyboardManager.kCurrentResponder {
                return targetResponderValues.contains(packageTargetResponder(currentResponder))
            }

            return false
        }
    }

    // MARK: - iPad浮动键盘
    private func addFrameObserverIfNeeded() {
        guard let keyboardView = type(of: self).keyboardView else {
            return
        }

        if let _ = QMUIKeyboardViewFrameObserver.observerForView(keyboardView: keyboardView) {
            return
        }

        let observer = QMUIKeyboardViewFrameObserver()
        observer.keyboardViewChangeFrameClosure = { [weak self] keyboardView in
            self?.keyboardDidChangedFrame(keyboardView: keyboardView)
        }
        observer.addToKeyboardView(aKeyboardView: keyboardView)
        // 手动调用第一次
        keyboardDidChangedFrame(keyboardView: keyboardView)
    }

    private func keyboardDidChangedFrame(keyboardView: UIView?) {
        if keyboardView != type(of: self).keyboardView {
            return
        }

        // 也需要判断targetResponder
        if !shouldReceiveShowNotification() && !shouldReceiveHideNotification() {
            return
        }

        if delegateEnabled {
            
            let keyboardWindow = keyboardView?.window
            if keyboardMoveBeginRect.size.width == 0 && keyboardMoveBeginRect.size.height == 0 {
                // 第一次需要初始化
                keyboardMoveBeginRect = CGRect(x: 0, y: keyboardWindow?.bounds.size.height ?? 0, width: keyboardWindow?.bounds.size.width ?? 0, height: 0)
            }
            
            var endFrame = CGRect.zero
            if keyboardWindow != nil {
                endFrame = keyboardWindow!.convert(keyboardView?.frame ?? .zero, to: nil)
            } else {
                endFrame = keyboardView?.frame ?? .zero
            }
            
            // 自己构造一个QMUIKeyboardUserInfo，一些属性使用之前最后一个keyboardUserInfo的值
            let aKeyboardMoveUserInfo = QMUIKeyboardUserInfo()
            aKeyboardMoveUserInfo.keyboardManager = self
            aKeyboardMoveUserInfo.targetResponder = keyboardMoveUserInfo?.targetResponder
            aKeyboardMoveUserInfo.animationDuration = keyboardMoveUserInfo?.animationDuration ?? 0.25
            aKeyboardMoveUserInfo.animationCurve = keyboardMoveUserInfo?.animationCurve ?? UIView.AnimationCurve.easeIn
            aKeyboardMoveUserInfo.animationOptions = keyboardMoveUserInfo?.animationOptions ?? []
            aKeyboardMoveUserInfo.beginFrame = keyboardMoveBeginRect
            aKeyboardMoveUserInfo.endFrame = endFrame
            
            if isDebug {
                print("keyboardDidMoveNotification - \(self)")
            }
            
            delegate?.keyboardWillChangeFrame?(with: aKeyboardMoveUserInfo)
            keyboardMoveBeginRect = endFrame
            
            if let notNilCurrentResponder = QMUIKeyboardManager.kCurrentResponder {
                let mainWindow = UIApplication.shared.keyWindow ?? UIApplication.shared.windows.first!
                let keyboardRect = keyboardMoveUserInfo?.endFrame ?? .zero
                let distanceFromBottom = QMUIKeyboardManager.distanceFromMinYToBottom(in: mainWindow, keyboardRect: keyboardRect)
                if distanceFromBottom < keyboardRect.size.height {
                    if !notNilCurrentResponder.isFirstResponder {
                        // will hide
                        QMUIKeyboardManager.kCurrentResponder = nil
                    }
                } else if distanceFromBottom > keyboardRect.size.height {
                    if !notNilCurrentResponder.isFirstResponder {
                        // 浮动
                        QMUIKeyboardManager.kCurrentResponder = nil
                    }
                }
            }
        }
    }

    // MARK: - 工具方法

    /**
     *  把键盘的rect转为相对于view的rect。一般用来把键盘的rect转化为相对于当前 self.view 的 rect，然后获取 y 值来布局对应的 view（这里一般不要获取键盘的高度，因为对于iPad的键盘，浮动状态下键盘的高度往往不是我们想要的）。
     *  @param rect 键盘的rect，一般拿 keyboardUserInfo.endFrame
     *  @param view 一个特定的view或者window，如果传入nil则相对有当前的 mainWindow
     */
    static func convert(keyboardRect: CGRect, to view: UIView?) -> CGRect {
        var keyboardRect = keyboardRect
        if keyboardRect == CGRect.null || keyboardRect == CGRect.infinite {
            return keyboardRect
        }

        let mainWindow = UIApplication.shared.keyWindow ?? UIApplication.shared.windows.first
        guard let notNilMainWindow = mainWindow else {
            if let notNilView = view {
                return notNilView.convert(keyboardRect, from: nil)
            } else {
                return keyboardRect
            }
        }

        keyboardRect = notNilMainWindow.convert(keyboardRect, from: nil)
        guard let notNilView = view else {
            return notNilMainWindow.convert(keyboardRect, to: nil)
        }

        if notNilView == notNilMainWindow {
            return keyboardRect
        }

        let toWindow = notNilView.isKind(of: UIWindow.self) ? notNilView : notNilView.window
        guard let notNilToWindow = toWindow else {
            return notNilMainWindow.convert(keyboardRect, to: notNilView)
        }

        if notNilMainWindow == notNilToWindow {
            return notNilMainWindow.convert(keyboardRect, to: notNilView)
        }

        keyboardRect = notNilMainWindow.convert(keyboardRect, to: notNilMainWindow)
        keyboardRect = notNilToWindow.convert(keyboardRect, from: notNilMainWindow)
        keyboardRect = notNilView.convert(keyboardRect, from: notNilToWindow)

        return keyboardRect
    }

    /**
     *  获取键盘到顶部到相对于view底部的距离，这个值在某些情况下会等于endFrame.size.height或者visiableKeyboardHeight，不过在iPad浮动键盘的时候就包括了底部的空隙。所以建议使用这个方法。
     */
    static func distanceFromMinYToBottom(in view: UIView, keyboardRect: CGRect) -> CGFloat {
        let rect = convert(keyboardRect: keyboardRect, to: view)
        let distance = view.bounds.height - rect.minY
        return distance
    }

    /**
     *  根据键盘的动画参数自己构建一个动画，调用者只需要设置view的位置即可
     */
    static func animate(with animated: Bool, keyboardUserInfo: QMUIKeyboardUserInfo, animations: @escaping (() -> Void), completion: ((Bool) -> Void)?) {
        if animated {
            UIView.animate(withDuration: keyboardUserInfo.animationDuration, delay: 0, options: [.beginFromCurrentState, keyboardUserInfo.animationOptions], animations: animations, completion: completion)
        } else {
            animations()
            completion?(true)
        }
    }

    /**
     *  这个方法特殊处理 iPad Pro 外接键盘的情况。使用外接键盘在完全不显示键盘的时候，不会调用willShow的通知，所以导致一些通过willShow回调来显示targetResponder的场景（例如微信朋友圈的评论输入框）无法把targetResponder正常的显示出来。通过这个方法，你只需要关心你的show和hide的状态就好了，不需要关心是否 iPad Pro 的情况。
     *  @param showBlock 键盘显示回调的block，不能把showBlock理解为系统的show通知，而是你有输入框聚焦了并且期望键盘显示出来。
     *  @param hideBlock 键盘隐藏回调的block，不能把hideBlock理解为系统的hide通知，而是键盘即将消失在界面上并且你期望跟随键盘变化的UI回到默认状态。
     */
    static func handleKeyboardNotification(with userInfo: QMUIKeyboardUserInfo, showClosure: ((_ keyboardUserInfo: QMUIKeyboardUserInfo) -> Void)?, hideClosure: ((_ keyboardUserInfo: QMUIKeyboardUserInfo) -> Void)?) {
        // 专门处理 iPad Pro 在键盘完全不显示的情况（不会调用willShow，所以通过是否focus来判断）
        if QMUIKeyboardManager.visiableKeyboardHeight <= 0 && !userInfo.isTargetResponderFocused {
            hideClosure?(userInfo)
        } else {
            showClosure?(userInfo)
        }
    }

    /**
     *  键盘面板的私有view，可能为nil
     */
    static var keyboardView: UIView? {
        for window in UIApplication.shared.windows {
            if let view = getKeyboardView(from: window) {
                return view
            }
        }

        return nil
    }

    /**
     *  键盘面板所在的私有window，可能为nil
     */
    static var keyboardWindow: UIWindow? {
        for window in UIApplication.shared.windows {
            if let _ = getKeyboardView(from: window) {
                return window
            }
        }

        var kbWindows = [UIWindow]()
        for window in UIApplication.shared.windows {
            let windowName = String(describing: type(of: window))
            if IOS_VERSION < 9 {
                // UITextEffectsWindow
                if windowName.length == 19 && windowName.hasPrefix("UI") && windowName.hasSuffix("TextEffectsWindow") {
                    kbWindows.append(window)
                }
            } else {
                // UIRemoteKeyboardWindow
                if windowName.length == 22 && windowName.hasPrefix("UI") && windowName.hasSuffix("RemoteKeyboardWindow") {
                    kbWindows.append(window)
                }
            }
        }

        if kbWindows.count == 1 {
            return kbWindows.first
        }
        return nil
    }

    /**
     *  是否有键盘在显示
     */
    static var isKeyboardVisible: Bool {
        guard let keyboardView = self.keyboardView,
            let keyboardWindow = keyboardView.window else {
            return false
        }

        let rect = keyboardWindow.bounds.intersection(keyboardView.frame)
        if rect == CGRect.null || rect == CGRect.infinite {
            return false
        }

        return rect.size.width > 0 && rect.size.height > 0
    }

    /**
     *  当期那键盘相对于屏幕的frame
     */
    static var currentKeyboardFrame: CGRect {
        guard let keyboardView = self.keyboardView else {
            return CGRect.null
        }

        if let keyboardWindow = keyboardView.window {
            return keyboardWindow.convert(keyboardView.frame, to: nil)
        } else {
            return keyboardView.frame
        }
    }

    /**
     *  当前键盘高度键盘的可见高度
     */
    static var visiableKeyboardHeight: CGFloat {
        guard let keyboardView = keyboardView,
            let keyboardWindow = keyboardView.window else {
            return 0
        }

        let visiableRect = keyboardWindow.bounds.intersection(keyboardView.frame)
        if visiableRect == CGRect.null {
            return 0
        }

        return visiableRect.size.height
    }

    private class func getKeyboardView(from window: UIWindow?) -> UIView? {
        guard let window = window else { return nil }
    
        let windowName = String(describing: type(of: window))
        if IOS_VERSION < 9 {
            if windowName != "UITextEffectsWindow" {
                return nil
            }
        } else {
            if windowName != "UIRemoteKeyboardWindow" {
                return nil
            }
        }

        for view in window.subviews {
            let viewName = String(describing: type(of: view))
            if viewName != "UIInputSetContainerView" {
                continue
            }
            
            for subview in view.subviews {
                let subviewName = String(describing: type(of: subview))
                if subviewName != "UIInputSetHostView" {
                    continue
                }
                return subview
            }
        }

        return nil
    }
}

class QMUIKeyboardViewFrameObserver: NSObject {

    private struct Keys {
        static var kAssociatedObjectKey_KeyboardViewFrameObserver = "kAssociatedObjectKey_KeyboardViewFrameObserver"
    }

    private weak var keyboardView: UIView!

    var keyboardViewChangeFrameClosure: ((_ keyboardView: UIView) -> Void)?

    override init() {
    }

    class func observerForView(keyboardView: UIView?) -> QMUIKeyboardViewFrameObserver? {
        guard let notNilKeyboardView = keyboardView else {
            return nil
        }

        return (objc_getAssociatedObject(notNilKeyboardView, &Keys.kAssociatedObjectKey_KeyboardViewFrameObserver) as? QMUIKeyboardViewFrameObserver)
    }

    deinit {
        removeFrameObserver()
    }

    func addToKeyboardView(aKeyboardView: UIView) {
        if aKeyboardView == keyboardView {
            return
        }

        removeFrameObserver()
        objc_setAssociatedObject(keyboardView!, &Keys.kAssociatedObjectKey_KeyboardViewFrameObserver, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        keyboardView = aKeyboardView
        addFrameObserver()
        objc_setAssociatedObject(aKeyboardView, &Keys.kAssociatedObjectKey_KeyboardViewFrameObserver, self, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    override func observeValue(forKeyPath keyPath: String?, of _: Any?, change: [NSKeyValueChangeKey: Any]?, context _: UnsafeMutableRawPointer?) {
        guard keyPath == "frame" &&
            keyPath == "center" &&
            keyPath == "bounds" &&
            keyPath == "transform" else {
            return
        }

        if let notificationIsPriorKey = change?[NSKeyValueChangeKey.notificationIsPriorKey] as? Bool, notificationIsPriorKey {
            return
        }

        if let changeKindKey = change?[NSKeyValueChangeKey.kindKey] as? NSKeyValueChange, changeKindKey != NSKeyValueChange.setting {
            return
        }

        if let notNilKeyboardViewChangeFrameBlock = keyboardViewChangeFrameClosure {
            notNilKeyboardViewChangeFrameBlock(keyboardView)
        }
    }

    private func addFrameObserver() {
        [
            "frame",
            "center",
            "bounds",
            "transform"
            ].forEach { keyboardView.addObserver(self, forKeyPath: $0, options: [], context: nil) }
    }

    private func removeFrameObserver() {
        [
        "frame",
         "center",
         "bounds",
         "transform"
        ].forEach { keyboardView.removeObserver(self, forKeyPath: $0) }
    }
}

extension UIView.AnimationCurve {
    fileprivate func toAnimationOptions() -> UIView.AnimationOptions {
        switch self {
        case .easeInOut:
            return UIView.AnimationOptions.curveEaseInOut
        case .easeIn:
            return UIView.AnimationOptions.curveEaseIn
        case .easeOut:
            return UIView.AnimationOptions.curveEaseOut
        case .linear:
            return UIView.AnimationOptions.curveLinear
        @unknown default:
            fatalError()
        }
    }
}

class QMUIKeyboardUserInfo: NSObject {

    override init() {
        super.init()
    }

    fileprivate var isTargetResponderFocused: Bool = false
    /**
     *  所在的KeyboardManager
     */
    fileprivate(set) weak var keyboardManager: QMUIKeyboardManager?

    /**
     *  当前键盘的notification
     */
    fileprivate(set) var notification: Notification? {
        didSet {
            if let notNilAnimationDuration = originUserInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval {
                animationDuration = notNilAnimationDuration
            }
            if let notNilAnimationCurve = originUserInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UIView.AnimationCurve {
                animationCurve = notNilAnimationCurve
                animationOptions = notNilAnimationCurve.toAnimationOptions()
            }

            if let notNilbeginFrame = originUserInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect {
                beginFrame = notNilbeginFrame
            }
            if let notNilEndFrame = originUserInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                endFrame = notNilEndFrame
            }
        }
    }

    /**
     *  notification自带的userInfo
     */
    var originUserInfo: [AnyHashable: Any] {
        return notification?.userInfo ?? [:]
    }

    /**
     *  触发键盘事件的UIResponder，注意这里的 `targetResponder` 不一定是通过 `addTargetResponder:` 添加的 UIResponder，而是当前触发键盘事件的 UIResponder。
     */
    fileprivate(set) var targetResponder: UIResponder? {
        didSet {
            isTargetResponderFocused = targetResponder?.keyboardManager_isFirstResponder ?? false
        }
    }

    /**
     *  获取键盘实际宽度
     */
    var width: CGFloat {
        let keyboardRect = QMUIKeyboardManager.convert(keyboardRect: endFrame, to: nil)
        return keyboardRect.size.width
    }

    /**
     *  获取键盘的实际高度
     */
    var height: CGFloat {
        let keyboardRect = QMUIKeyboardManager.convert(keyboardRect: endFrame, to: nil)
        return keyboardRect.size.height
    }

    /**
     *  获取键盘beginFrame
     */
    fileprivate(set) var beginFrame: CGRect = .zero

    /**
     *  获取键盘endFrame
     */
    fileprivate(set) var endFrame: CGRect = .zero

    /**
     *  获取键盘出现动画的duration，对于第三方键盘，这个值有可能为0
     */
    fileprivate(set) var animationDuration: TimeInterval = 0.0

    /**
     *  获取键盘动画的Curve参数
     */
    fileprivate(set) var animationCurve: UIView.AnimationCurve = .easeInOut

    /**
     *  获取键盘动画的Options参数
     */
    fileprivate(set) var animationOptions: UIView.AnimationOptions = []

    /**
     *  获取当前键盘在view上的可见高度，也就是键盘和view重叠的高度。如果view=nil，则直接返回键盘的实际高度。
     */
    func height(in view: UIView?) -> CGFloat {
        guard let notNilView = view else {
            return height
        }

        let keyboardRect = QMUIKeyboardManager.convert(keyboardRect: endFrame, to: notNilView)
        let visiableRect = notNilView.bounds.intersection(keyboardRect)
        if visiableRect == CGRect.null {
            return 0
        }
        return visiableRect.size.height
    }
}

@objc protocol QMUIKeyboardManagerDelegate: NSObjectProtocol {
    /**
     *  键盘即将显示
     */
    @objc optional func keyBoardWillShow(_ userInfo: QMUIKeyboardUserInfo?)

    /**
     *  键盘即将隐藏
     */
    @objc optional func keyboardWillHide(_ userInfo: QMUIKeyboardUserInfo?)

    /**
     *  键盘已经显示
     */
    @objc optional func keyBoardDidShow(_ userInfo: QMUIKeyboardUserInfo?)

    /**
     *  键盘已经隐藏
     */
    @objc optional func keyboardDidHide(_ userInfo: QMUIKeyboardUserInfo?)

    /**
     *  键盘frame即将发生变化。
     *  这个delegate除了对应系统的willChangeFrame通知外，在iPad下还增加了监听键盘frame变化的KVO来处理浮动键盘，所以调用次数会比系统默认多。需要让界面或者某个view跟随键盘运动，建议在这个通知delegate里面实现，因为willShow和willHide在手机上是准确的，但是在iPad的浮动键盘下是不准确的。另外，如果不需要跟随浮动键盘运动，那么在逻辑代码里面可以通过判断键盘的位置来过滤这种浮动的情况。
     */
    @objc optional func keyboardWillChangeFrame(with userInfo: QMUIKeyboardUserInfo?)

    /**
     *  键盘frame已经发生变化。
     */
    @objc optional func keyboardDidChangeFrame(with userInfo: QMUIKeyboardUserInfo?)
}

extension UIResponder: SelfAware4 {
    
    private static let _onceToken = UUID().uuidString
    
    static func awake4() {
        DispatchQueue.once(token: _onceToken) {
            let clazz = UIResponder.self
            ReplaceMethod(clazz, #selector(becomeFirstResponder), #selector(keyboardManager_becomeFirstResponder))
            ReplaceMethod(clazz, #selector(resignFirstResponder), #selector(keyboardManager_resignFirstResponder))
        }
    }
    
    @objc func keyboardManager_becomeFirstResponder() -> Bool {
        keyboardManager_isFirstResponder = true
        return keyboardManager_becomeFirstResponder()
    }
    
    @objc func keyboardManager_resignFirstResponder() -> Bool {
        keyboardManager_isFirstResponder = false
        return keyboardManager_resignFirstResponder()
    }
    
    fileprivate struct Keys {
        static var isFirstResponder = "isFirstResponder"
    }
    
    var keyboardManager_isFirstResponder: Bool {
        get {
            return (objc_getAssociatedObject(self, &Keys.isFirstResponder) as? Bool) ?? false
        }
        set {
            objc_setAssociatedObject(self, &Keys.isFirstResponder, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

/// 键盘相关Closure，搭配QMUIKeyboardManager一起使用
extension UITextField: QMUIKeyboardManagerDelegate {
    
    fileprivate struct Keys {
        static var keyboardWillShowNotificationClosure = "keyboardWillShowNotificationClosure"
        static var keyboardDidShowNotificationClosure = "keyboardDidShowNotificationClosure"
        static var keyboardWillHideNotificationClosure = "keyboardWillHideNotificationClosure"
        static var keyboardDidHideNotificationClosure = "keyboardDidHideNotificationClosure"
        static var keyboardWillChangeFrameNotificationnClosure = "keyboardWillHideNotificationClosure"
        static var keyboardDidChangeFrameNotificationClosure = "keyboardDidHideNotificationClosure"
        static var keyboardManager = "keyboardManager"
    }
    
    typealias KeyboardNotificationClosureType = (QMUIKeyboardUserInfo?) -> Void
    
    var qmui_keyboardWillShowNotificationClosure: KeyboardNotificationClosureType? {
        get {
            return objc_getAssociatedObject(self, &Keys.keyboardWillShowNotificationClosure) as? KeyboardNotificationClosureType
        }
        set {
            objc_setAssociatedObject(self, &Keys.keyboardWillShowNotificationClosure, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            if newValue != nil {
                initKeyboardManagerIfNeeded()
            }
        }
    }
    
    var qmui_keyboardDidShowNotificationClosure: KeyboardNotificationClosureType? {
        get {
            return objc_getAssociatedObject(self, &Keys.keyboardDidShowNotificationClosure) as? KeyboardNotificationClosureType
        }
        set {
            objc_setAssociatedObject(self, &Keys.keyboardDidShowNotificationClosure, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            if newValue != nil {
                initKeyboardManagerIfNeeded()
            }
        }
    }
    
    var qmui_keyboardWillHideNotificationClosure: KeyboardNotificationClosureType? {
        get {
            return objc_getAssociatedObject(self, &Keys.keyboardWillHideNotificationClosure) as? KeyboardNotificationClosureType
        }
        set {
            objc_setAssociatedObject(self, &Keys.keyboardWillHideNotificationClosure, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            if newValue != nil {
                initKeyboardManagerIfNeeded()
            }
        }
    }
    
    var qmui_keyboardDidHideNotificationClosure: KeyboardNotificationClosureType? {
        get {
            return objc_getAssociatedObject(self, &Keys.keyboardDidHideNotificationClosure) as? KeyboardNotificationClosureType
        }
        set {
            objc_setAssociatedObject(self, &Keys.keyboardDidHideNotificationClosure, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            if newValue != nil {
                initKeyboardManagerIfNeeded()
            }
        }
    }
    
    var qmui_keyboardWillChangeFrameNotificationnClosure: KeyboardNotificationClosureType? {
        get {
            return objc_getAssociatedObject(self, &Keys.keyboardWillChangeFrameNotificationnClosure) as? KeyboardNotificationClosureType
        }
        set {
            objc_setAssociatedObject(self, &Keys.keyboardWillChangeFrameNotificationnClosure, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            if newValue != nil {
                initKeyboardManagerIfNeeded()
            }
        }
    }
    
    var qmui_keyboardDidChangeFrameNotificationClosure: KeyboardNotificationClosureType? {
        get {
            return objc_getAssociatedObject(self, &Keys.keyboardDidChangeFrameNotificationClosure) as? KeyboardNotificationClosureType
        }
        set {
            objc_setAssociatedObject(self, &Keys.keyboardDidChangeFrameNotificationClosure, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            if newValue != nil {
                initKeyboardManagerIfNeeded()
            }
        }
    }
    
    private func initKeyboardManagerIfNeeded() {
        if qmui_keyboardManager == nil {
            qmui_keyboardManager = QMUIKeyboardManager(with: self)
            qmui_keyboardManager?.add(targetResponder: self)
        }
    }
    
    var qmui_keyboardManager: QMUIKeyboardManager? {
        get {
            return objc_getAssociatedObject(self, &Keys.keyboardManager) as? QMUIKeyboardManager
        }
        set {
            objc_setAssociatedObject(self, &Keys.keyboardManager, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func keyBoardWillShow(_ userInfo: QMUIKeyboardUserInfo?) {
        qmui_keyboardWillShowNotificationClosure?(userInfo)
    }

    
    /**
     *  键盘即将隐藏
     */
    func keyboardWillHide(_ userInfo: QMUIKeyboardUserInfo?) {
        qmui_keyboardWillHideNotificationClosure?(userInfo)
    }
    
    /**
     *  键盘已经显示
     */
    func keyBoardDidShow(_ userInfo: QMUIKeyboardUserInfo?) {
        qmui_keyboardDidShowNotificationClosure?(userInfo)
    }
    
    /**
     *  键盘已经隐藏
     */
    func keyboardDidHide(_ userInfo: QMUIKeyboardUserInfo?) {
        qmui_keyboardDidHideNotificationClosure?(userInfo)
    }
    
    /**
     *  键盘frame即将发生变化。
     *  这个delegate除了对应系统的willChangeFrame通知外，在iPad下还增加了监听键盘frame变化的KVO来处理浮动键盘，所以调用次数会比系统默认多。需要让界面或者某个view跟随键盘运动，建议在这个通知delegate里面实现，因为willShow和willHide在手机上是准确的，但是在iPad的浮动键盘下是不准确的。另外，如果不需要跟随浮动键盘运动，那么在逻辑代码里面可以通过判断键盘的位置来过滤这种浮动的情况。
     */
    func keyboardWillChangeFrame(with userInfo: QMUIKeyboardUserInfo?) {
        qmui_keyboardWillChangeFrameNotificationnClosure?(userInfo)
    }
    
    /**
     *  键盘frame已经发生变化。
     */
    func keyboardDidChangeFrame(with userInfo: QMUIKeyboardUserInfo?) {
        qmui_keyboardDidChangeFrameNotificationClosure?(userInfo)
    }
}

/// 键盘相关Closure，搭配QMUIKeyboardManager一起使用
extension UITextView: QMUIKeyboardManagerDelegate {
    
    fileprivate struct Keys {
        static var keyboardWillShowNotificationClosure = "keyboardWillShowNotificationClosure"
        static var keyboardDidShowNotificationClosure = "keyboardDidShowNotificationClosure"
        static var keyboardWillHideNotificationClosure = "keyboardWillHideNotificationClosure"
        static var keyboardDidHideNotificationClosure = "keyboardDidHideNotificationClosure"
        static var keyboardWillChangeFrameNotificationnClosure = "keyboardWillHideNotificationClosure"
        static var keyboardDidChangeFrameNotificationClosure = "keyboardDidHideNotificationClosure"
        static var keyboardManager = "keyboardManager"
    }
    
    typealias KeyboardNotificationClosureType = (QMUIKeyboardUserInfo?) -> Void
    
    var qmui_keyboardWillShowNotificationClosure: KeyboardNotificationClosureType? {
        get {
            return objc_getAssociatedObject(self, &Keys.keyboardWillShowNotificationClosure) as? KeyboardNotificationClosureType
        }
        set {
            objc_setAssociatedObject(self, &Keys.keyboardWillShowNotificationClosure, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            if newValue != nil {
                initKeyboardManagerIfNeeded()
            }
        }
    }
    
    var qmui_keyboardDidShowNotificationClosure: KeyboardNotificationClosureType? {
        get {
            return objc_getAssociatedObject(self, &Keys.keyboardDidShowNotificationClosure) as? KeyboardNotificationClosureType
        }
        set {
            objc_setAssociatedObject(self, &Keys.keyboardDidShowNotificationClosure, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            if newValue != nil {
                initKeyboardManagerIfNeeded()
            }
        }
    }
    
    var qmui_keyboardWillHideNotificationClosure: KeyboardNotificationClosureType? {
        get {
            return objc_getAssociatedObject(self, &Keys.keyboardWillHideNotificationClosure) as? KeyboardNotificationClosureType
        }
        set {
            objc_setAssociatedObject(self, &Keys.keyboardWillHideNotificationClosure, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            if newValue != nil {
                initKeyboardManagerIfNeeded()
            }
        }
    }
    
    var qmui_keyboardDidHideNotificationClosure: KeyboardNotificationClosureType? {
        get {
            return objc_getAssociatedObject(self, &Keys.keyboardDidHideNotificationClosure) as? KeyboardNotificationClosureType
        }
        set {
            objc_setAssociatedObject(self, &Keys.keyboardDidHideNotificationClosure, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            if newValue != nil {
                initKeyboardManagerIfNeeded()
            }
        }
    }
    
    var qmui_keyboardWillChangeFrameNotificationnClosure: KeyboardNotificationClosureType? {
        get {
            return objc_getAssociatedObject(self, &Keys.keyboardWillChangeFrameNotificationnClosure) as? KeyboardNotificationClosureType
        }
        set {
            objc_setAssociatedObject(self, &Keys.keyboardWillChangeFrameNotificationnClosure, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            if newValue != nil {
                initKeyboardManagerIfNeeded()
            }
        }
    }
    
    var qmui_keyboardDidChangeFrameNotificationClosure: KeyboardNotificationClosureType? {
        get {
            return objc_getAssociatedObject(self, &Keys.keyboardDidChangeFrameNotificationClosure) as? KeyboardNotificationClosureType
        }
        set {
            objc_setAssociatedObject(self, &Keys.keyboardDidChangeFrameNotificationClosure, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            if newValue != nil {
                initKeyboardManagerIfNeeded()
            }
        }
    }
    
    private func initKeyboardManagerIfNeeded() {
        if qmui_keyboardManager == nil {
            qmui_keyboardManager = QMUIKeyboardManager(with: self)
            qmui_keyboardManager?.add(targetResponder: self)
        }
    }
    
    var qmui_keyboardManager: QMUIKeyboardManager? {
        get {
            return objc_getAssociatedObject(self, &Keys.keyboardManager) as? QMUIKeyboardManager
        }
        set {
            objc_setAssociatedObject(self, &Keys.keyboardManager, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func keyBoardWillShow(_ userInfo: QMUIKeyboardUserInfo?) {
        qmui_keyboardWillShowNotificationClosure?(userInfo)
    }
    
    
    /**
     *  键盘即将隐藏
     */
    func keyboardWillHide(_ userInfo: QMUIKeyboardUserInfo?) {
        qmui_keyboardWillHideNotificationClosure?(userInfo)
    }
    
    /**
     *  键盘已经显示
     */
    func keyBoardDidShow(_ userInfo: QMUIKeyboardUserInfo?) {
        qmui_keyboardDidShowNotificationClosure?(userInfo)
    }
    
    /**
     *  键盘已经隐藏
     */
    func keyboardDidHide(_ userInfo: QMUIKeyboardUserInfo?) {
        qmui_keyboardDidHideNotificationClosure?(userInfo)
    }
    
    /**
     *  键盘frame即将发生变化。
     *  这个delegate除了对应系统的willChangeFrame通知外，在iPad下还增加了监听键盘frame变化的KVO来处理浮动键盘，所以调用次数会比系统默认多。需要让界面或者某个view跟随键盘运动，建议在这个通知delegate里面实现，因为willShow和willHide在手机上是准确的，但是在iPad的浮动键盘下是不准确的。另外，如果不需要跟随浮动键盘运动，那么在逻辑代码里面可以通过判断键盘的位置来过滤这种浮动的情况。
     */
    func keyboardWillChangeFrame(with userInfo: QMUIKeyboardUserInfo?) {
        qmui_keyboardWillChangeFrameNotificationnClosure?(userInfo)
    }
    
    /**
     *  键盘frame已经发生变化。
     */
    func keyboardDidChangeFrame(with userInfo: QMUIKeyboardUserInfo?) {
        qmui_keyboardDidChangeFrameNotificationClosure?(userInfo)
    }
}
