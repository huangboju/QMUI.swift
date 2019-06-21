//
//  QMUIVisualEffectView.swift
//  QMUI.swift
//
//  Created by 黄伯驹 on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

enum QMUIVisualEffectViewStyle {
    case extraLight
    case light
    case dark

    var effStyle: UIBlurEffect.Style {
        let effStyle: UIBlurEffect.Style
        switch self {
        case .extraLight:
            effStyle = .extraLight
        case .light:
            effStyle = .light
        case .dark:
            effStyle = .dark
        }
        return effStyle
    }
}

class QMUIVisualEffectView: UIView {
    public private(set) var style: QMUIVisualEffectViewStyle = .light

    private var effectView: UIVisualEffectView?

    convenience init(style: QMUIVisualEffectViewStyle) {
        self.init()
        self.style = style
    }

    private func initEffectViewUI() {
        effectView = UIVisualEffectView(effect: UIBlurEffect(style: style.effStyle))
        effectView?.clipsToBounds = true
        addSubview(effectView!)
    }

    override var backgroundColor: UIColor? {
        set {
            effectView?.backgroundColor = newValue
        }
        get {
            return effectView?.backgroundColor
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        effectView?.frame = bounds.size.rect
    }
}
