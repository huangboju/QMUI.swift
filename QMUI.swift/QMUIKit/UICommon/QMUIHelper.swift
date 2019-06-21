//
//  QMUIHelper.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/2/9.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

protocol QMUIHelperDelegate: class {
    func QMUIHelperPrint(_ log: String)
}

let QMUIResourcesMainBundleName = "QMUIResources.bundle"

// MARK: - QMUI专属
extension QMUIHelper {
    static var resourcesBundle: Bundle? {
        return QMUIHelper.resourcesBundle(QMUIResourcesMainBundleName)
    }

    static func image(name: String) -> UIImage? {
        let bundle = QMUIHelper.resourcesBundle
        return QMUIHelper.image(in: bundle, name: name)
    }

    static func resourcesBundle(_ bundleName: String) -> Bundle? {
        var bundle = Bundle(path: (Bundle.main.resourcePath ?? "") + "/\(bundleName)")
        if bundle == nil {
            // 动态framework的bundle资源是打包在framework里面的，所以无法通过mainBundle拿到资源，只能通过其他方法来获取bundle资源。

            let frameworkBundle = Bundle(for: self)
            if let bundleData = parse(bundleName) {
                bundle = Bundle(path: frameworkBundle.path(forResource: bundleData["name"], ofType: bundleData["type"])!)
            }
        }
        return bundle
    }

    static func image(in bundle: Bundle?, name: String?) -> UIImage? {
        if let bundle = bundle, let name = name {
            if UIImage.responds(to: #selector(UIImage.init(named:in:compatibleWith:))) {
                return UIImage(named: name, in: bundle, compatibleWith: nil)
            } else {
                if let imagePath = bundle.resourcePath?.appending("\(name).png") {
                    return UIImage(contentsOfFile: imagePath)
                }
            }
        }
        return nil
    }

    private static func parse(_ bundleName: String) -> [String: String]? {
        let bundleData = bundleName.components(separatedBy: ".")
        guard bundleData.count == 2 else {
            return nil
        }
        return [
            "name": bundleData[0],
            "type": bundleData[1],
        ]
    }
}

// MARK: - SystemVersion
extension QMUIHelper {
    
    static var numbericOSVersion: Int {
        let OSVersion = UIDevice.current.systemVersion
        let OSVersionArr = OSVersion.components(separatedBy: ".")
        var numbericOSVersion = 0
        var pos = 0
        while OSVersionArr.count > 0 && pos < 3 {
            numbericOSVersion += (Int(OSVersionArr[pos])! * Int(powf(10, (4 - Float(pos) * 2))))
            pos += 1
        }
        return numbericOSVersion
    }
    
    static func compareSystemVersion(_ currentVersion: String, to targetVersion: String) -> ComparisonResult {
        let currentVersionArr = currentVersion.components(separatedBy: ".")
        let targetVersionArr = targetVersion.components(separatedBy: ".")
        var pos = 0
        while currentVersionArr.count > pos || targetVersionArr.count > pos {
            let v1 = currentVersionArr.count > pos ? Int(currentVersionArr[pos])! : 0
            let v2 = targetVersionArr.count > pos ? Int(targetVersionArr[pos])! : 0
            if v1 < v2 {
                return .orderedAscending
            } else if v1 > v2 {
                return .orderedDescending
            }
            pos += 1
        }
        return .orderedSame
    }
    
    static func isCurrentSystemAtLeastVersion(_ targetVersion: String) -> Bool {
        let result = QMUIHelper.compareSystemVersion(UIDevice.current.systemVersion, to: targetVersion)
        return result == .orderedSame || result == .orderedDescending
    }
    
    static func isCurrentSystemLowerThanVersion(_ targetVersion: String) -> Bool {
        let result = QMUIHelper.compareSystemVersion(UIDevice.current.systemVersion, to: targetVersion)
        return result == .orderedAscending
    }
}

// MARK: - DynamicType
extension QMUIHelper {
    /// 返回当前contentSize的level，这个值可以在设置里面的“字体大小”查看，辅助功能里面有个“更大字体”可以设置更大的字体，不过这里我们这个接口将更大字体都做了统一，都返回“字体大小”里面最大值。
    static var preferredContentSizeLevel: Int {
        var index = 0
        if UIApplication.instancesRespond(to: #selector(getter: UIApplication.preferredContentSizeCategory)) {
            let contentSizeCategory = UIApplication.shared.preferredContentSizeCategory

            switch contentSizeCategory {
            case UIContentSizeCategory.extraSmall:
                index = 0
            case UIContentSizeCategory.small:
                index = 1
            case UIContentSizeCategory.medium:
                index = 2
            case UIContentSizeCategory.large:
                index = 3
            case UIContentSizeCategory.extraLarge:
                index = 4
            case UIContentSizeCategory.extraExtraLarge:
                index = 5
            case UIContentSizeCategory.extraExtraExtraLarge:
                index = 6
            case UIContentSizeCategory.accessibilityMedium, UIContentSizeCategory.accessibilityLarge, UIContentSizeCategory.accessibilityExtraLarge, UIContentSizeCategory.accessibilityExtraExtraLarge, UIContentSizeCategory.accessibilityExtraExtraExtraLarge:
                index = 6
            default:
                index = 6
            }
        }

        return index
    }

    /// 设置当前cell的高度，heights是有七个数值的数组，对于不支持的iOS版本，则选择中间的值返回。
    static func heightForDynamicTypeCell(_ heights: [CGFloat]) -> CGFloat {
        let index = QMUIHelper.preferredContentSizeLevel
        return heights[index]
    }
}

// MARK: - Keyboard

extension QMUIHelper {
    
    @objc func handleKeyboardWillShow(_ notification: Notification) {
        _isKeyboardVisible = true
        lastKeyboardHeight = QMUIHelper.keyboardHeight(notification)
    }

    @objc func handleKeyboardWillHide(_ notification: Notification) {
        _isKeyboardVisible = false
    }

    /**
     * 判断当前App里的键盘是否升起，默认为NO
     */
    static var isKeyboardVisible: Bool {
        return shared._isKeyboardVisible
    }

    /**
     * 记录上一次键盘显示时的高度（基于整个 App 所在的 window 的坐标系），注意使用前用 `isKeyboardVisible` 判断键盘是否显示，因为即便是键盘被隐藏的情况下，调用 `lastKeyboardHeightInApplicationWindowWhenVisible` 也会得到高度值。
     */
    static var lastKeyboardHeightInApplicationWindowWhenVisible: CGFloat {
        return shared.lastKeyboardHeight
    }

    /**
     * 获取当前键盘frame相关
     * @warning 注意iOS8以下的系统在横屏时得到的rect，宽度和高度相反了，所以不建议直接通过这个方法获取高度，而是使用<code>keyboardHeightWithNotification:inView:</code>，因为在后者的实现里会将键盘的rect转换坐标系，转换过程就会处理横竖屏旋转问题。
     */
    static func keyboardRect(_ notification: Notification?) -> CGRect {
        guard let keyboardRect = (notification?.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return .zero }
        return keyboardRect
    }

    /// 获取当前键盘的高度，注意高度可能为0（例如第三方键盘会发出两次notification，其中第一次的高度就为0
    static func keyboardHeight(_ notification: Notification?) -> CGFloat {
        return QMUIHelper.keyboardHeight(notification, in: nil)
    }

    /**
     * 获取当前键盘在屏幕上的可见高度，注意外接键盘（iPad那种）时，[QMUIHelper keyboardRectWithNotification]得到的键盘rect里有一部分是超出屏幕，不可见的，如果直接拿rect的高度来计算就会与意图相悖。
     * @param notification 接收到的键盘事件的UINotification对象
     * @param view 要得到的键盘高度是相对于哪个View的键盘高度，若为nil，则等同于调用QMUIHelper.keyboardHeight(with: notification)
     * @warning 如果view.window为空（当前View尚不可见），则会使用App默认的UIWindow来做坐标转换，可能会导致一些计算错误
     * @return 键盘在view里的可视高度
     */
    static func keyboardHeight(_ notification: Notification?, in view: UIView?) -> CGFloat {
        let rect = keyboardRect(notification)
        guard let view = view else {
            return rect.height
        }
        let keyboardRectInView = view.convert(rect, from: view.window)
        let keyboardVisibleRectInView = view.bounds.intersection(keyboardRectInView)
        let resultHeight = keyboardVisibleRectInView.isNull ? 0 : keyboardVisibleRectInView.height
        return resultHeight
    }

    /// 获取键盘显示/隐藏的动画时长，注意返回值可能为0
    static func keyboardAnimationDuration(_ notification: Notification?) -> TimeInterval {
        guard let animationDuration = notification?.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return 0 }
        return animationDuration
    }

    /// 获取键盘显示/隐藏的动画时间函数
    static func keyboardAnimationCurve(_ notification: Notification?) -> UIView.AnimationCurve {
        guard let curve = notification?.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int else { return .easeIn }
        return UIView.AnimationCurve(rawValue: curve)!
    }

    /// 获取键盘显示/隐藏的动画时间函数
    static func keyboardAnimationOptions(_ notification: Notification?) -> UIView.AnimationOptions {
        let rawValue = UInt(QMUIHelper.keyboardAnimationCurve(notification).rawValue)
        return UIView.AnimationOptions(rawValue: rawValue)
    }
}

// MARK: - AudioSession
extension QMUIHelper {
    /**
     *  听筒和扬声器的切换
     *
     *  @param speaker   是否转为扬声器，NO则听筒
     *  @param temporary 决定使用kAudioSessionProperty_OverrideAudioRoute还是kAudioSessionProperty_OverrideCategoryDefaultToSpeaker，两者的区别请查看本组的博客文章:http://km.oa.com/group/gyui/articles/show/235957
     */
    static func redirectAudioRoute(_ speaker: Bool, temporary: Bool) {
        let audioSession = AVAudioSession.sharedInstance()
        if audioSession.category != AVAudioSession.Category.playAndRecord {
            return
        }
        if temporary {
            try? audioSession.overrideOutputAudioPort(speaker ? .speaker : .none)
        } else {
//            try? audioSession.setCategory(speaker ? .ambient : [])
        }
    }

    /**
     *  设置category
     *
     *  @param category 使用iOS7的category，iOS6的会自动适配
     */
    static func setAudioSession(_ category: AVAudioSession.Category) {
        let categories: [AVAudioSession.Category] = [
            .ambient,
            .soloAmbient,
            .playback,
            .record,
            .playAndRecord,
            .audioProcessing,
        ]

        // 如果不属于系统category，返回
        guard categories.contains(category) else {
            return
        }

        try? AVAudioSession.sharedInstance().setCategory(category)
    }

    private static func categoryForLowVersion(_ category: AVAudioSession.Category) -> Int {
        if category == .ambient {
            return kAudioSessionCategory_AmbientSound
        }
        if category == .soloAmbient {
            return kAudioSessionCategory_SoloAmbientSound
        }
        if category == .playback {
            return kAudioSessionCategory_MediaPlayback
        }
        if category == .record {
            return kAudioSessionCategory_RecordAudio
        }
        if category == .playAndRecord {
            return kAudioSessionCategory_PlayAndRecord
        }
        if category == .audioProcessing {
            return kAudioSessionCategory_AudioProcessing
        }
        return kAudioSessionCategory_AmbientSound
    }
}

// MARK: - UIGraphic
extension QMUIHelper {
    /// 获取一像素的大小
    static var pixelOne: CGFloat {
        return 1 / UIScreen.main.scale
    }

    /// 判断size是否超出范围
    static func inspectContext(size: CGSize) {
        if size.width < 0 || size.height < 0 {
            assert(false, "QMUI CGPostError, \(#file):\(#line) \(#function), 非法的size：\(size)\n\(Thread.callStackSymbols)")
        }
    }

    /// context是否合法
    static func inspectContextIfInvalidatedInDebugMode(context: CGContext?) {
        // crash了就找zhoon或者molice
        assert(context != nil, "QMUI CGPostError, \(#file):\(#line) \(#function), 非法的context：\(String(describing: context))\n\(Thread.callStackSymbols)")
    }

    static func inspectContextIfInvalidatedInReleaseMode(context: CGContext?) -> Bool {
        return context != nil
    }
}

// MARK: - Device
extension QMUIHelper {
    static var isIPad: Bool {
        // [[[UIDevice currentDevice] model] isEqualToString:@"iPad"] 无法判断模拟器，改为以下方式
        return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad
    }

    static var isIPadPro: Bool {
        return QMUIHelper.isIPad && (DEVICE_WIDTH == 1024 && DEVICE_HEIGHT == 1366)
    }

    static var isIPod: Bool {
        return UIDevice.current.model.contains("iPod touch")
    }

    static var isIPhone: Bool {
        return UIDevice.current.model.contains("iPhone")
    }

    static var isSimulator: Bool {
        #if TARGET_OS_SIMULATOR
            return true
        #else
            return false
        #endif
    }

    static var is58InchScreen: Bool {
        return CGSize(width: DEVICE_WIDTH, height: DEVICE_HEIGHT) == screenSizeFor58Inch
    }

    static var is55InchScreen: Bool {
        return CGSize(width: DEVICE_WIDTH, height: DEVICE_HEIGHT) == screenSizeFor55Inch
    }

    static var is47InchScreen: Bool {
        return CGSize(width: DEVICE_WIDTH, height: DEVICE_HEIGHT) == screenSizeFor47Inch
    }

    static var is40InchScreen: Bool {
        return CGSize(width: DEVICE_WIDTH, height: DEVICE_HEIGHT) == screenSizeFor40Inch
    }

    static var is35InchScreen: Bool {
        return CGSize(width: DEVICE_WIDTH, height: DEVICE_HEIGHT) == screenSizeFor35Inch
    }

    static var screenSizeFor58Inch: CGSize {
        return CGSize(width: 375, height: 812)
    }

    static var screenSizeFor55Inch: CGSize {
        return CGSize(width: 414, height: 736)
    }

    static var screenSizeFor47Inch: CGSize {
        return CGSize(width: 375, height: 667)
    }

    static var screenSizeFor40Inch: CGSize {
        return CGSize(width: 320, height: 568)
    }

    static var screenSizeFor35Inch: CGSize {
        return CGSize(width: 320, height: 480)
    }

    static var safeAreaInsetsForIPhoneX: UIEdgeInsets {
        if !is58InchScreen {
            return UIEdgeInsets.zero
        }

        let orientation = UIApplication.shared.statusBarOrientation

        switch orientation {
        case .portrait:
            return UIEdgeInsets(top: 44, left: 0, bottom: 34, right: 0)

        case .portraitUpsideDown:
            return UIEdgeInsets(top: 34, left: 0, bottom: 44, right: 0)

        case .landscapeLeft, .landscapeRight:
            return UIEdgeInsets(top: 0, left: 44, bottom: 21, right: 44)

        case .unknown:
            return UIEdgeInsets(top: 44, left: 0, bottom: 34, right: 0)
        @unknown default:
            fatalError()
        }
    }

    private static var _isHighPerformanceDevice = -1
    /// 判断当前设备是否高性能设备，只会判断一次，以后都直接读取结果，所以没有性能问题
    static var isHighPerformanceDevice: Bool {
        if _isHighPerformanceDevice < 0 {
            _isHighPerformanceDevice = PreferredVarForUniversalDevices(1, 1, 1, 0, 0)
        }
        return _isHighPerformanceDevice > 0
    }
}

// MARK: - Orientation
extension QMUIHelper {
    
    @objc private func handleDeviceOrientation(_ notification: NSNotification) {
        // 如果是由 setValue:forKey: 方式修改方向而走到这个 notification 的话，理论上是不需要重置为 Unknown 的，但因为在 UIViewController (QMUI) 那边会再次记录旋转前的值，所以这里就算重置也无所谓
        QMUIHelper.shared.orientationBeforeChangingByHelper = .unknown
    }
    
    /**
     *  旋转当前设备的方向到指定方向，一般用于 [UIViewController supportedInterfaceOrientations] 发生变化时主动触发界面方向的刷新
     *  @return 是否真正旋转了方向，YES 表示参数的方向和目前设备方向不一致，NO 表示一致也即不会旋转
     *  @see [QMUIConfiguration automaticallyRotateDeviceOrientation]
     */
    @discardableResult
    static func rotateToDeviceOrientation(_ orientation: UIDeviceOrientation) -> Bool {
        if UIDevice.current.orientation == orientation {
            UIViewController.attemptRotationToDeviceOrientation()
            return false
        }
        UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
        return true
    }
    
    /// 根据指定的旋转方向计算出对应的旋转角度
    static func angleForTransformWithInterface(_ orientation: UIInterfaceOrientation) -> CGFloat {
        var angle: CGFloat = 0
        switch orientation {
        case .portraitUpsideDown:
            angle = .pi
        case .landscapeLeft:
            angle = .pi / -2
        case .landscapeRight:
            angle = .pi / 2
        default:
            angle = 0.0
        }
        return angle
    }

    /// 根据当前设备的旋转方向计算出对应的CGAffineTransform
    static var transformForCurrentInterfaceOrientation: CGAffineTransform {
        return QMUIHelper.transformWithInterface(UIApplication.shared.statusBarOrientation)
    }

    /// 根据指定的旋转方向计算出对应的CGAffineTransform
    static func transformWithInterface(_ orientation: UIInterfaceOrientation) -> CGAffineTransform {

        let angle = QMUIHelper.angleForTransformWithInterface(orientation)
        return CGAffineTransform(rotationAngle: angle)
    }
}

// MARK: - ViewController
extension QMUIHelper {
    /**
     * 获取当前应用里最顶层的可见viewController
     * @warning 注意返回值可能为nil，要做好保护
     */
    static var visibleViewController: UIViewController? {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let rootViewController = appDelegate.window?.rootViewController {
            let visibleViewController = rootViewController.qmui_visibleViewControllerIfExist
            return visibleViewController
        }
        return nil
    }
}

// MARK: - UIApplication
extension QMUIHelper {
    /**
     *  更改状态栏内容颜色为深色
     *
     *  @warning 需在项目的 Info.plist 文件内设置字段 “View controller-based status bar appearance” 的值为 NO 才能生效，如果不设置，或者值为 YES，则请通过系统的 - UIViewController preferredStatusBarStyle 方法来修改
     */
    static func renderStatusBarStyleDark() {
        UIApplication.shared.statusBarStyle = .default
    }

    /**
     *  更改状态栏内容颜色为浅色
     *
     *  @warning 需在项目的 Info.plist 文件内设置字段 “View controller-based status bar appearance” 的值为 NO 才能生效，如果不设置，或者值为 YES，则请通过系统的 - UIViewController preferredStatusBarStyle 方法来修改
     */
    static func renderStatusBarStyleLight() {
        UIApplication.shared.statusBarStyle = .lightContent
    }

    /**
     * 把App的主要window置灰，用于浮层弹出时，请注意要在适当时机调用`resetDimmedApplicationWindow`恢复到正常状态
     */
    static func dimmedApplicationWindow() {
        let window = UIApplication.shared.delegate?.window
        window??.tintAdjustmentMode = .dimmed
        window??.tintColorDidChange()
    }

    /**
     * 恢复对App的主要window的置灰操作，与`dimmedApplicationWindow`成对调用
     */
    static func resetDimmedApplicationWindow() {
        let window = UIApplication.shared.delegate?.window
        window??.tintAdjustmentMode = .normal
        window??.tintColorDidChange()
    }
}

let QMUISpringAnimationKey = "QMUISpringAnimationKey"
// MARK: - Animation
extension QMUIHelper {
    static func actionSpringAnimation(for view: UIView) {
        let duration = 0.6
        let springAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        springAnimation.values = [0.85, 1.15, 0.9, 1.0]
        springAnimation.keyTimes = [
            (0.0 / duration),
            (0.15 / duration),
            (0.3 / duration),
            (0.45 / duration),
        ].map { NSNumber(value: $0) }
        springAnimation.duration = duration
        view.layer.add(springAnimation, forKey: QMUISpringAnimationKey)
    }
}

class QMUIHelper: NSObject {

    static let shared = QMUIHelper()

    private override init() {}

    weak var helperDelegate: QMUIHelperDelegate?

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension QMUIHelper: SelfAware {
    private static let _onceToken = UUID().uuidString
    
    private struct kAssociatedObjectKey {
        static var lastKeyboardHeight = "lastKeyboardHeight"
        static var isKeyboardVisible = "isKeyboardVisible"
        static var orientationBeforeChangingByHelper = "orientationBeforeChangingByHelper"
    }
    
    static func awake() {
        DispatchQueue.once(token: _onceToken) {
            // 先设置默认值，不然可能变量的指针地址错误
            shared._isKeyboardVisible = false
            shared.lastKeyboardHeight = 0
            shared.orientationBeforeChangingByHelper = .unknown
            NotificationCenter.default.addObserver(shared, selector: #selector(handleKeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(shared, selector: #selector(handleKeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
            NotificationCenter.default.addObserver(shared, selector: #selector(handleDeviceOrientation(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)
        }
    }
    
    private var _isKeyboardVisible: Bool {
        set {
            objc_setAssociatedObject(self, &kAssociatedObjectKey.isKeyboardVisible, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &kAssociatedObjectKey.isKeyboardVisible) as? Bool ?? false
        }
    }
    
    /**
     *  记录手动旋转方向前的设备方向，当值不为 UIDeviceOrientationUnknown 时表示设备方向有经过了手动调整。默认值为 UIDeviceOrientationUnknown。
     *  @see [QMUIHelper rotateToDeviceOrientation]
     */
    var orientationBeforeChangingByHelper: UIDeviceOrientation {
        set {
            objc_setAssociatedObject(self, &kAssociatedObjectKey.orientationBeforeChangingByHelper, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &kAssociatedObjectKey.orientationBeforeChangingByHelper) as? UIDeviceOrientation ?? .unknown
        }
    }
    
    private var lastKeyboardHeight: CGFloat {
        set {
            objc_setAssociatedObject(self, &kAssociatedObjectKey.lastKeyboardHeight, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &kAssociatedObjectKey.lastKeyboardHeight) as? CGFloat ?? 0
        }
    }
}
