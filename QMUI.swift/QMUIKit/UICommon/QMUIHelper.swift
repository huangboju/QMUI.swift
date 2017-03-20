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

class QMUIHelper: NSObject {
    
    static let shared = QMUIHelper()
    
    private override init() {}
    
    weak var helperDelegate: QMUIHelperDelegate?

    // MARK: - UIApplication
    static func renderStatusBarStyleDark() {
        UIApplication.shared.statusBarStyle = .default
    }

    static func renderStatusBarStyleLight() {
        UIApplication.shared.statusBarStyle = .lightContent
    }

    static func dimmedApplicationWindow() {
        let window = UIApplication.shared.keyWindow
        window?.tintAdjustmentMode = .dimmed
        window?.tintColorDidChange()
    }

    static func resetDimmedApplicationWindow() {
        let window = UIApplication.shared.keyWindow
        window?.tintAdjustmentMode = .normal
        window?.tintColorDidChange()
    }
}

let QMUIResourcesMainBundleName = "QMUIResources.bundle"

// MARK: - QMUI专属
extension QMUIHelper {
    static var resourcesBundle: Bundle? {
        return QMUIHelper.resourcesBundle(with: QMUIResourcesMainBundleName)
    }

    static func image(with name: String) -> UIImage? {
        let bundle = QMUIHelper.resourcesBundle
        return QMUIHelper.image(in: bundle, with: name)
    }
    
    static func resourcesBundle(with bundleName: String) -> Bundle? {
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

    static func image(in bundle: Bundle?, with name: String?) -> UIImage? {
        if let bundle = bundle, let name = name {
            // TODO:
            /*
             if ([UIImage respondsToSelector:@selector(imageNamed:inBundle:compatibleWithTraitCollection:)]) {
             return [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil]
             } else {
             NSString *imagePath = [[bundle resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", name]]
             return [UIImage imageWithContentsOfFile:imagePath]
             }
             */
            let imagePath = (bundle.resourcePath ?? "") + "\(name).png"
            return UIImage(contentsOfFile: imagePath)
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
            "type": bundleData[1]
        ]
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
    static let _onceToken = UUID().uuidString
    
    private struct kAssociatedObjectKey {
        static var LastKeyboardHeight = "LastKeyboardHeight"
        static var isKeyboardVisible = "isKeyboardVisible"
    }

    override class func initialize() {
        DispatchQueue.once(token: _onceToken) {
            NotificationCenter.default.addObserver(shared, selector: #selector(handleKeyboardWillShow), name: .UIKeyboardWillShow, object: nil)
            NotificationCenter.default.addObserver(shared, selector: #selector(handleKeyboardWillHide), name: .UIKeyboardWillHide, object: nil)
        }
    }

    func handleKeyboardWillShow(notification: Notification) {
        self._isKeyboardVisible = true
        self.lastKeyboardHeight = QMUIHelper.keyboardHeight(with: notification)
    }

    func handleKeyboardWillHide(notification: Notification) {
        self._isKeyboardVisible = false
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
     * 判断当前App里的键盘是否升起，默认为NO
     */
    public static var isKeyboardVisible: Bool {
        return shared._isKeyboardVisible
    }
    
    private var lastKeyboardHeight: CGFloat {
        set {
            objc_setAssociatedObject(self, &kAssociatedObjectKey.LastKeyboardHeight, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &kAssociatedObjectKey.LastKeyboardHeight) as? CGFloat ?? 0
        }
    }

    /**
     * 记录上一次键盘显示时的高度（基于整个 App 所在的 window 的坐标系），注意使用前用 `isKeyboardVisible` 判断键盘是否显示，因为即便是键盘被隐藏的情况下，调用 `lastKeyboardHeightInApplicationWindowWhenVisible` 也会得到高度值。
     */
    public static var lastKeyboardHeightInApplicationWindowWhenVisible: CGFloat {
        return shared.lastKeyboardHeight
    }

    /**
     * 获取当前键盘frame相关
     * @warning 注意iOS8以下的系统在横屏时得到的rect，宽度和高度相反了，所以不建议直接通过这个方法获取高度，而是使用<code>keyboardHeightWithNotification:inView:</code>，因为在后者的实现里会将键盘的rect转换坐标系，转换过程就会处理横竖屏旋转问题。
     */
    public static func keyboardRect(with notification: Notification) -> CGRect {
        guard let keyboardRect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return .zero }
        return keyboardRect
    }
    
    /// 获取当前键盘的高度，注意高度可能为0（例如第三方键盘会发出两次notification，其中第一次的高度就为0
    public static func keyboardHeight(with notification: Notification) -> CGFloat {
        return QMUIHelper.keyboardHeight(with: notification, in: nil)
    }

    /**
     * 获取当前键盘在屏幕上的可见高度，注意外接键盘（iPad那种）时，[QMUIHelper keyboardRectWithNotification]得到的键盘rect里有一部分是超出屏幕，不可见的，如果直接拿rect的高度来计算就会与意图相悖。
     * @param notification 接收到的键盘事件的UINotification对象
     * @param view 要得到的键盘高度是相对于哪个View的键盘高度，若为nil，则等同于调用QMUIHelper.keyboardHeight(with: notification)
     * @warning 如果view.window为空（当前View尚不可见），则会使用App默认的UIWindow来做坐标转换，可能会导致一些计算错误
     * @return 键盘在view里的可视高度
     */
    public static func keyboardHeight(with notification: Notification, in view: UIView?) -> CGFloat {
        let rect = keyboardRect(with: notification)
        guard let view = view else {
            return rect.height
        }
        let keyboardRectInView = view.convert(rect, from: view.window)
        let keyboardVisibleRectInView = view.bounds.intersection(keyboardRectInView)
        let resultHeight = keyboardVisibleRectInView.isNull ? 0 : keyboardVisibleRectInView.height
        return resultHeight
    }

    /// 获取键盘显示/隐藏的动画时长，注意返回值可能为0
    public static func keyboardAnimationDuration(with notification: Notification) -> TimeInterval {
        guard let animationDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double else { return 0 }
        return animationDuration
    }

    /// 获取键盘显示/隐藏的动画时间函数
    public static func keyboardAnimationCurve(with notification: Notification) -> UIViewAnimationCurve {
        guard let curve = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? Int else { return .easeIn }
        return UIViewAnimationCurve(rawValue: curve)!
    }

    /// 获取键盘显示/隐藏的动画时间函数
    public static func keyboardAnimationOptions(with notification: Notification) -> UIViewAnimationOptions {
        let rawValue = UInt(QMUIHelper.keyboardAnimationCurve(with: notification).rawValue)
        return UIViewAnimationOptions(rawValue: rawValue)
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
    static func redirectAudioRoute(with speaker: Bool, temporary: Bool) {
        let audioSession = AVAudioSession.sharedInstance()
        if audioSession.category != AVAudioSessionCategoryPlayAndRecord {
            return
        }
        if temporary {
            try? audioSession.overrideOutputAudioPort(speaker ? .speaker : .none)
        } else {
            try? audioSession.setCategory(audioSession.category, with: speaker ? .defaultToSpeaker : [])
        }
    }

    /**
     *  设置category
     *
     *  @param category 使用iOS7的category，iOS6的会自动适配
     */
    static func setAudioSession(category: String) {
        let categories = [
            AVAudioSessionCategoryAmbient,
            AVAudioSessionCategorySoloAmbient,
            AVAudioSessionCategoryPlayback,
            AVAudioSessionCategoryRecord,
            AVAudioSessionCategoryPlayAndRecord,
            AVAudioSessionCategoryAudioProcessing
        ]

        // 如果不属于系统category，返回
        guard categories.contains(category) else {
            return
        }

        try? AVAudioSession.sharedInstance().setCategory(category)
    }
    
    static func categoryForLowVersion(with category: String) -> Int {
        if category == AVAudioSessionCategoryAmbient {
            return kAudioSessionCategory_AmbientSound
        }
        if category == AVAudioSessionCategorySoloAmbient {
            return kAudioSessionCategory_SoloAmbientSound
        }
        if category == AVAudioSessionCategoryPlayback {
            return kAudioSessionCategory_MediaPlayback
        }
        if category == AVAudioSessionCategoryRecord {
            return kAudioSessionCategory_RecordAudio
        }
        if category == AVAudioSessionCategoryPlayAndRecord {
            return kAudioSessionCategory_PlayAndRecord
        }
        if category == AVAudioSessionCategoryAudioProcessing {
            return kAudioSessionCategory_AudioProcessing
        }
        return kAudioSessionCategory_AmbientSound
    }
}


// MARK: - UIGraphic
extension QMUIHelper {
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
//    static func inspectContextIfInvalidatedInDebugMode(context: CGContext) {
//    
//    }
//
//    static func inspectContextIfInvalidatedInReleaseMode(context: CGContext) -> Bool {
//    
//    }
}
