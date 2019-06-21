//
//  QMUIToastBackgroundView.swift
//  QMUI.swift
//
//  Created by 黄伯驹 on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

class QMUIToastBackgroundView: UIView {

    /**
     * 是否需要磨砂，默认NO。仅支持iOS8及以上版本。可以通过修改`styleColor`来控制磨砂的效果。
     */
    var showldBlurBackgroundView: Bool = false {
        didSet {
            if showldBlurBackgroundView {
                let effect = UIBlurEffect(style: .light)
                let effectView = UIVisualEffectView(effect: effect)
                effectView.layer.cornerRadius = cornerRadius
                effectView.layer.masksToBounds = true
                addSubview(effectView)
                self.effectView = effectView
            } else {
                if let notNilEffectView = effectView {
                    notNilEffectView.removeFromSuperview()
                    effectView = nil
                }
            }
        }
    }

    /**
     * 如果不设置磨砂，则styleColor直接作为`QMUIToastBackgroundView`的backgroundColor；如果需要磨砂，则会新增加一个`UIVisualEffectView`放在`QMUIToastBackgroundView`上面
     */
    var styleColor: UIColor = UIColor(r: 0, g: 0, b: 0, a: 0.8) {
        didSet {
            backgroundColor = styleColor
        }
    }

    /**
     * 设置圆角。
     */
    var cornerRadius: CGFloat = 10 {
        didSet {
            self.layer.cornerRadius = cornerRadius
            if let notNilEffectView = self.effectView {
                notNilEffectView.layer.cornerRadius = cornerRadius
            }
        }
    }

    private var effectView: UIView?

    override init(frame: CGRect) {
        super.init(frame: frame)

        layer.allowsGroupOpacity = false
        backgroundColor = styleColor
        layer.cornerRadius = cornerRadius
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        layer.allowsGroupOpacity = false
        backgroundColor = styleColor
        layer.cornerRadius = cornerRadius
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if let notNilEffectView = effectView {
            notNilEffectView.removeFromSuperview()
            effectView = nil
        }
    }
}
