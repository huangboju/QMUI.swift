//
//  UIScrollView+QMUI.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/3/17.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

extension UIScrollView: SelfAware2 {
    private static let _onceToken = UUID().uuidString

    static func awake2() {
        let clazz = UIScrollView.self
        DispatchQueue.once(token: _onceToken) {
            ReplaceMethod(clazz, #selector(description), #selector(qmui_description))
        }
    }
}

extension UIScrollView {

    @objc func qmui_description() -> String {
        return qmui_description() + ", contentInset = \(contentInset)"
    }

    /// 判断UIScrollView是否已经处于顶部（当UIScrollView内容不够多不可滚动时，也认为是在顶部）
    var qmui_alreadyAtTop: Bool {
        if !qmui_canScroll {
            return true
        }

        if contentOffset.y == -qmui_contentInset.top {
            return true
        }

        return false
    }

    /// 判断UIScrollView是否已经处于底部（当UIScrollView内容不够多不可滚动时，也认为是在底部）
    var qmui_alreadyAtBottom: Bool {
        if !qmui_canScroll {
            return true
        }

        if contentOffset.y == contentSize.height + qmui_contentInset.bottom - bounds.height {
            return true
        }

        return false
    }
    
    /// UIScrollView 的真正 inset，在 iOS11 以后需要用到 adjustedContentInset 而在 iOS11 以前只需要用 contentInset
    var qmui_contentInset: UIEdgeInsets {
        if #available(iOS 11, *) {
            return adjustedContentInset
        } else {
            return contentInset
        }
    }

    /**
     * 判断当前的scrollView内容是否足够滚动
     * @warning 避免与<i>scrollEnabled</i>混淆
     */
    @objc var qmui_canScroll: Bool {
        // 没有高度就不用算了，肯定不可滚动，这里只是做个保护
        if bounds.size == .zero {
            return false
        }

        let canVerticalScroll = contentSize.height + qmui_contentInset.verticalValue > bounds.height
        let canHorizontalScoll = contentSize.width + qmui_contentInset.horizontalValue > bounds.width
        return canVerticalScroll || canHorizontalScoll
    }

    /**
     * 不管当前scrollView是否可滚动，直接将其滚动到最顶部
     * @param force 是否无视qmui_canScroll而强制滚动
     * @param animated 是否用动画表现
     */
    func qmui_scrollToTopForce(_ force: Bool, animated: Bool) {
        if force || (!force && qmui_canScroll) {
            setContentOffset(CGPoint(x: -qmui_contentInset.left, y: -qmui_contentInset.top), animated: animated)
        }
    }

    /**
     * 等同于qmui_scrollToTop(false, animated: animated)
     */
    func qmui_scrollToTopAnimated(_ animated: Bool) {
        qmui_scrollToTopForce(false, animated: animated)
    }

    /// 等同于qmui_scrollToTop(false)
    func qmui_scrollToTop() {
        qmui_scrollToTopAnimated(false)
    }

    /**
     * 如果当前的scrollView可滚动，则将其滚动到最底部
     * @param animated 是否用动画表现
     * @see [UIScrollView qmui_canScroll]
     */
    func qmui_scrollToBottomAnimated(_ animated: Bool) {
        if qmui_canScroll {
            setContentOffset(CGPoint(x: contentOffset.x, y: contentSize.height + qmui_contentInset.bottom - bounds.height), animated: animated)
        }
    }

    /// 等同于qmui_scrollToBottomAnimated(false)
    func qmui_scrollToBottom() {
        qmui_scrollToBottomAnimated(false)
    }

    // 立即停止滚动，用于那种手指已经离开屏幕但列表还在滚动的情况。
    func qmui_stopDeceleratingIfNeeded() {
        if isDecelerating {
            setContentOffset(contentOffset, animated: false)
        }
    }
}
