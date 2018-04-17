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

// 原项目这里hook了UIResponder的isFirstResponder，这里觉得没必要暂时不需要hook

fileprivate var kCurrentResponder: UIResponder?

class QMUIKeyboardManager {

    private var targetResponderValues = [NSValue]()
    private var keyboardMoveUserInfo: QMUIKeyboardUserInfo?
    private var keyboardMoveBeginRect: CGRect = .zero

    init(with delegate: QMUIKeyboardManagerDelegate) {
        self.delegate = delegate
        delegateEnabled = true
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
    private(set) var delegateEnabled = true

    /**
     *  添加触发键盘事件的 UIResponder，一般是 UITextView 或者 UITextField ，不添加 targetResponder 的话，则默认接受任何 UIResponder 产生的键盘通知。
     *  添加成功将会返回YES，否则返回NO。
     */
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
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(_:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidChangeFrame(_:)), name: NSNotification.Name.UIKeyboardDidChangeFrame, object: nil)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        print("keyboardWillShowNotification - \(self)")

        if shouldReceiveShowNotification() {
            return
        }

        let userInfo = newUserInfoWithNotification(notification)
        userInfo.targetResponder = kCurrentResponder

        delegate?.keyBoardWillShow!(userInfo)

        // 额外处理iPad浮动键盘
        if IS_IPAD {
            keyboardMoveUserInfo = userInfo
            keyboardDidChangeFrame(keyboardView: type(of: self).keyboardView())
        }
    }

    @objc private func keyboardDidShow(_ notification: Notification) {
        print("keyboardDidShowNotification - \(self)")

        let userInfo = newUserInfoWithNotification(notification)
        userInfo.targetResponder = kCurrentResponder

        let firstResponder = UIApplication.shared.keyWindow?.qmui_findFirstResponder()
        let shouldReceiveDidShowNotification = targetResponderValues.count <= 0 || firstResponder == kCurrentResponder

        if shouldReceiveDidShowNotification {
            delegate?.keyBoardDidShow?(nil)

            // 额外处理iPad浮动键盘
            if IS_IPAD {
                keyboardMoveUserInfo = userInfo
                keyboardDidChangeFrame(keyboardView: type(of: self).keyboardView())
            }
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        print("keyboardWillHideNotification - \(self)")

        if !shouldReceiveHideNotification() {
            return
        }

        let userInfo = newUserInfoWithNotification(notification)
        userInfo.targetResponder = kCurrentResponder

        delegate?.keyboardWillHide!(userInfo)

        // 额外处理iPad浮动键盘
        if IS_IPAD {
            keyboardMoveUserInfo = userInfo
            keyboardDidChangeFrame(keyboardView: type(of: self).keyboardView())
        }
    }

    @objc private func keyboardDidHide(_ notification: Notification) {
        print("keyboardDidHideNotification - \(self)")

        let userInfo = newUserInfoWithNotification(notification)
        userInfo.targetResponder = kCurrentResponder

        if shouldReceiveHideNotification() {
            delegate?.keyboardDidHide?(userInfo)
        }

        if kCurrentResponder?.isFirstResponder ?? false && !IS_IPAD {
            kCurrentResponder = nil
        }

        // 额外处理iPad浮动键盘
        if IS_IPAD {
            if targetResponderValues.count <= 0 || kCurrentResponder != nil {
                keyboardMoveUserInfo = userInfo
                keyboardDidChangeFrame(keyboardView: type(of: self).keyboardView())
            }
        }
    }

    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        print("keyboardWillChangeFrameNotification - \(self)")
        let userInfo = newUserInfoWithNotification(notification)
        if shouldReceiveShowNotification() {
            userInfo.targetResponder = kCurrentResponder
        } else if shouldReceiveHideNotification() {
            userInfo.targetResponder = kCurrentResponder
        } else {
            return
        }

        delegate?.keyboardWillChangeFrame?(with: userInfo)

        // 额外处理iPad浮动键盘
        if IS_IPAD {
            keyboardMoveUserInfo = userInfo
            addFrameObserverIfNeeded()
        }
    }

    @objc private func keyboardDidChangeFrame(_ notification: Notification) {
        print("keyboardDidChangeFrameNotification - \(self)")

        let userInfo = newUserInfoWithNotification(notification)
        if shouldReceiveShowNotification() {
            userInfo.targetResponder = kCurrentResponder
        } else if shouldReceiveHideNotification() {
            userInfo.targetResponder = kCurrentResponder
        } else {
            return
        }

        delegate?.keyboardDidChangeFrame?(with: userInfo)

        // 额外处理iPad浮动键盘
        if IS_IPAD {
            keyboardMoveUserInfo = userInfo
            keyboardDidChangeFrame(keyboardView: type(of: self).keyboardView())
        }
    }

    private func newUserInfoWithNotification(_ notification: Notification) -> QMUIKeyboardUserInfo {
        let userInfo = QMUIKeyboardUserInfo()
        userInfo.keyboardManager = self
        userInfo.notification = notification
        return userInfo
    }

    private func shouldReceiveShowNotification() -> Bool {
        kCurrentResponder = UIApplication.shared.keyWindow?.qmui_findFirstResponder()

        if targetResponderValues.count <= 0 {
            return true
        } else {
            if let currentResponder = kCurrentResponder {
                return targetResponderValues.contains(packageTargetResponder(currentResponder))
            }

            return false
        }
    }

    private func shouldReceiveHideNotification() -> Bool {
        if targetResponderValues.count <= 0 {
            return true
        } else {
            if let currentResponder = kCurrentResponder {
                return targetResponderValues.contains(packageTargetResponder(currentResponder))
            }

            return false
        }
    }

    // MARK: - iPad浮动键盘
    private func addFrameObserverIfNeeded() {
        guard let keyboardView = type(of: self).keyboardView() else {
            return
        }

        if let _ = QMUIKeyboardViewFrameObserver.observerForView(keyboardView: keyboardView) {
            return
        }

        let observer = QMUIKeyboardViewFrameObserver()
        observer.keyboardViewChangeFrameBlock = { [weak self] keyboardView in
            self?.keyboardDidChangeFrame(keyboardView: keyboardView)
        }
        observer.addToKeyboardView(aKeyboardView: keyboardView)
        // 手动调用第一次
        keyboardDidChangeFrame(keyboardView: keyboardView)
    }

    private func keyboardDidChangeFrame(keyboardView: UIView?) {
        if keyboardView != type(of: self).keyboardView() {
            return
        }

        // 也需要判断targetResponder
        if !shouldReceiveShowNotification() && !shouldReceiveHideNotification() {
            return
        }

        let keyboardWindow = keyboardView?.window
        if keyboardMoveBeginRect.size.width == 0 &&
            keyboardMoveBeginRect.size.height == 0 {
            // 第一次需要初始化
            keyboardMoveBeginRect = CGRect(x: 0, y: keyboardWindow?.bounds.size.height ?? 0, width: keyboardWindow?.bounds.size.width ?? 0, height: 0)
        }

        var endFrame = CGRect.zero
        if let notNilKeyboardWindow = keyboardWindow {
            endFrame = notNilKeyboardWindow.convert(keyboardView?.frame ?? .zero, to: nil)
        } else {
            endFrame = keyboardView?.frame ?? .zero
        }

        // 自己构造一个QMUIKeyboardUserInfo，一些属性使用之前最后一个keyboardUserInfo的值
        let aKeyboardMoveUserInfo = QMUIKeyboardUserInfo()
        aKeyboardMoveUserInfo.keyboardManager = self
        aKeyboardMoveUserInfo.targetResponder = keyboardMoveUserInfo?.targetResponder
        aKeyboardMoveUserInfo.animationDuration = keyboardMoveUserInfo?.animationDuration ?? 0
        aKeyboardMoveUserInfo.animationCurve = keyboardMoveUserInfo?.animationCurve ?? UIViewAnimationCurve.easeIn
        aKeyboardMoveUserInfo.animationOptions = keyboardMoveUserInfo?.animationOptions ?? []
        aKeyboardMoveUserInfo.beginFrame = keyboardMoveBeginRect
        aKeyboardMoveUserInfo.endFrame = endFrame

        print("keyboardDidMoveNotification - \(self)")

        delegate?.keyboardWillChangeFrame!(with: aKeyboardMoveUserInfo)
        keyboardMoveBeginRect = endFrame

        if let notNilCurrentResponder = kCurrentResponder {
            let mainWindow = UIApplication.shared.keyWindow ?? UIApplication.shared.windows.first!
            let keyboardRect = keyboardMoveUserInfo?.endFrame ?? .zero
            let distanceFromBottom = QMUIKeyboardManager.distanceFromMinYTo(bottomView: mainWindow, keyboardRect: keyboardRect)
            if distanceFromBottom < keyboardRect.size.height {
                if !notNilCurrentResponder.isFirstResponder {
                    // will hide
                    kCurrentResponder = nil
                }
            } else if distanceFromBottom > keyboardRect.size.height {
                if !notNilCurrentResponder.isFirstResponder {
                    // 浮动
                    kCurrentResponder = nil
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
    class func convert(keyboardRect: CGRect, to view: UIView?) -> CGRect {
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
    class func distanceFromMinYTo(bottomView: UIView, keyboardRect: CGRect) -> CGFloat {
        let rect = convert(keyboardRect: keyboardRect, to: bottomView)
        let distance = bottomView.bounds.height - rect.minY
        return distance
    }

    /**
     *  根据键盘的动画参数自己构建一个动画，调用者只需要设置view的位置即可
     */
    class func animate(with animated: Bool, keyboardUserInfo: QMUIKeyboardUserInfo, animations: @escaping (() -> Void), completion: ((Bool) -> Void)?) {
        if animated {
            UIView.animate(withDuration: keyboardUserInfo.animationDuration, delay: 0, options: [.beginFromCurrentState, keyboardUserInfo.animationOptions], animations: animations, completion: completion)
        } else {
            animations()
            if let notNilCompletion = completion {
                notNilCompletion(true)
            }
        }
    }

    /**
     *  这个方法特殊处理 iPad Pro 外接键盘的情况。使用外接键盘在完全不显示键盘的时候，不会调用willShow的通知，所以导致一些通过willShow回调来显示targetResponder的场景（例如微信朋友圈的评论输入框）无法把targetResponder正常的显示出来。通过这个方法，你只需要关心你的show和hide的状态就好了，不需要关心是否 iPad Pro 的情况。
     *  @param showBlock 键盘显示回调的block，不能把showBlock理解为系统的show通知，而是你有输入框聚焦了并且期望键盘显示出来。
     *  @param hideBlock 键盘隐藏回调的block，不能把hideBlock理解为系统的hide通知，而是键盘即将消失在界面上并且你期望跟随键盘变化的UI回到默认状态。
     */
    class func handleKeyboardNotification(with userInfo: QMUIKeyboardUserInfo, showBlock: ((_ keyboardUserInfo: QMUIKeyboardUserInfo) -> Void)?, hideBlock: ((_ keyboardUserInfo: QMUIKeyboardUserInfo) -> Void)?) {
        // 专门处理 iPad Pro 在键盘完全不显示的情况（不会调用willShow，所以通过是否focus来判断）
        if QMUIKeyboardManager.visiableKeyboardHeight() <= 0 && userInfo.isTargetResponderFocused {
            if let notNilHideBlock = hideBlock {
                notNilHideBlock(userInfo)
            }
        } else {
            if let notNilShowBlock = showBlock {
                notNilShowBlock(userInfo)
            }
        }
    }

    /**
     *  键盘面板的私有view，可能为nil
     */
    class func keyboardView() -> UIView? {
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
                if windowName == "UITextEffectsWindow" {
                    kbWindows.append(window)
                }
            } else {
                if windowName == "UIRemoteKeyboardWindow" {
                    kbWindows.append(window)
                }
            }
        }

        return kbWindows.first
    }

    /**
     *  是否有键盘在显示
     */
    static var isKeyboardVisible: Bool {
        guard let keyboardView = self.keyboardView(),
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
        guard let keyboardView = keyboardView() else {
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
    class func visiableKeyboardHeight() -> CGFloat {
        guard let keyboardView = keyboardView(),
            let keyboardWindow = keyboardView.window else {
            return 0
        }

        let visiableRect = keyboardWindow.bounds.intersection(keyboardView.frame)
        if visiableRect == CGRect.null {
            return 0
        }

        return visiableRect.size.height
    }

    private class func getKeyboardView(from window: UIWindow) -> UIView? {
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

        if IOS_VERSION < 8 {
            for view in window.subviews {
                let viewName = String(describing: type(of: view))
                if viewName != "UIPeripheralHostView" {
                    continue
                }
                return view
            }
        } else {
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
        }

        return nil
    }
}

class QMUIKeyboardViewFrameObserver: NSObject {

    private struct Keys {
        static var kAssociatedObjectKey_KeyboardViewFrameObserver = "kAssociatedObjectKey_KeyboardViewFrameObserver"
    }

    private weak var keyboardView: UIView!

    var keyboardViewChangeFrameBlock: ((_ keyboardView: UIView) -> Void)?

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
        objc_setAssociatedObject(keyboardView, &Keys.kAssociatedObjectKey_KeyboardViewFrameObserver, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
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

        if let notNilKeyboardViewChangeFrameBlock = keyboardViewChangeFrameBlock {
            notNilKeyboardViewChangeFrameBlock(keyboardView)
        }
    }

    private func addFrameObserver() {
        keyboardView.addObserver(self, forKeyPath: "frame", options: [], context: nil)
        keyboardView.addObserver(self, forKeyPath: "center", options: [], context: nil)
        keyboardView.addObserver(self, forKeyPath: "bounds", options: [], context: nil)
        keyboardView.addObserver(self, forKeyPath: "transform", options: [], context: nil)
    }

    private func removeFrameObserver() {
        keyboardView.removeObserver(self, forKeyPath: "frame")
        keyboardView.removeObserver(self, forKeyPath: "center")
        keyboardView.removeObserver(self, forKeyPath: "bounds")
        keyboardView.removeObserver(self, forKeyPath: "transform")
    }
}

extension UIViewAnimationCurve {
    fileprivate func toAnimationOptions() -> UIViewAnimationOptions {
        switch self {
        case .easeInOut:
            return UIViewAnimationOptions.curveEaseInOut
        case .easeIn:
            return UIViewAnimationOptions.curveEaseIn
        case .easeOut:
            return UIViewAnimationOptions.curveEaseOut
        case .linear:
            return UIViewAnimationOptions.curveLinear
        }
    }
}

class QMUIKeyboardUserInfo: NSObject {

    override init() {
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
            if let notNilAnimationDuration = originUserInfo[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval {
                animationDuration = notNilAnimationDuration
            }
            if let notNilAnimationCurve = originUserInfo[UIKeyboardAnimationCurveUserInfoKey] as? UIViewAnimationCurve {
                animationCurve = notNilAnimationCurve
                animationOptions = notNilAnimationCurve.toAnimationOptions()
            }

            if let notNilbeginFrame = originUserInfo[UIKeyboardFrameBeginUserInfoKey] as? CGRect {
                beginFrame = notNilbeginFrame
            }
            if let notNilEndFrame = originUserInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect {
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
            isTargetResponderFocused = targetResponder?.isFirstResponder ?? false
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
    fileprivate(set) var animationCurve: UIViewAnimationCurve = .easeInOut

    /**
     *  获取键盘动画的Options参数
     */
    fileprivate(set) var animationOptions: UIViewAnimationOptions = []

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
