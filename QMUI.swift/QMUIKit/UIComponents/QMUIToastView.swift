//
//  QMUIToastView.swift
//  QMUI.swift
//
//  Created by 黄伯驹 on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

enum QMUIToastViewPosition {
    case top
    case center
    case bottom
}

/**
 * `QMUIToastView`是一个用来显示toast的控件，其主要结构包括：`backgroundView`、`contentView`，这两个view都是通过外部赋值获取，默认使用`QMUIToastBackgroundView`和`QMUIToastContentView`。
 *
 * 拓展性：`QMUIToastBackgroundView`和`QMUIToastContentView`是QMUI提供的默认的view，这两个view都可以通过appearance来修改样式，如果这两个view满足不了需求，那么也可以通过新建自定义的view来代替这两个view。另外，QMUI也提供了默认的toastAnimator来实现ToastView的显示和隐藏动画，如果需要重新定义一套动画，可以继承`QMUIToastAnimator`并且实现`QMUIToastViewAnimatorDelegate`中的协议就可以自定义自己的一套动画。
 *
 * 建议使用`QMUIToastView`的时候，再封装一层，具体可以参考`QMUITips`这个类。
 *
 * @see QMUIToastBackgroundView
 * @see QMUIToastContentView
 * @see QMUIToastAnimator
 * @see QMUITips
 */
class QMUIToastView: UIView {
    /**s
     * 承载Toast内容的UIView，可以自定义并赋值给contentView。如果contentView需要跟随ToastView的tintColor变化而变化，可以重写自定义view的`tintColorDidChange`来实现。默认使用`QMUIToastContentView`实现。
     */
    var contentView: UIView?

    /**
     * `contentView`下面的黑色背景UIView，默认使用`QMUIToastBackgroundView`实现，可以通过`QMUIToastBackgroundView`的 cornerRadius 和 styleColor 来修改圆角和背景色。
     */
    var backgroundView: UIView?
}
