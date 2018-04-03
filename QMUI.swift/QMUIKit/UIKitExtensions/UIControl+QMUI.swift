//
//  UIControl+QMUI.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/4/12.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

extension UIControl: SelfAware2 {
    private static let _onceToken = UUID().uuidString

    static func awake2() {
        DispatchQueue.once(token: _onceToken) {
            let clazz = UIControl.self
            
            let selectors = [
                #selector(UIControl.touchesBegan(_:with:)),
                #selector(UIControl.touchesMoved(_:with:)),
                #selector(UIControl.touchesEnded(_:with:)),
                #selector(UIControl.touchesCancelled(_:with:)),
                #selector(UIControl.point(inside:with:)),
                #selector(setter: isHighlighted),
            ]
            
            let qmui_selectors = [
                #selector(UIControl.qmui_touchesBegan(_:with:)),
                #selector(UIControl.qmui_touchesMoved(_:with:)),
                #selector(UIControl.qmui_touchesEnded(_:with:)),
                #selector(UIControl.qmui_touchesCancelled(_:with:)),
                #selector(UIControl.qmui_point(inside:with:)),
                #selector(UIControl.qmui_setHighlighted(_:)),
                ]

            for index in 0..<selectors.count {
                ReplaceMethod(clazz, selectors[index], qmui_selectors[index])
            }
        }
    }
}

extension UIControl {

    private struct AssociatedKeys {
        static var qmui_outsideEdge = "qmui_outsideEdge"
        static var canSetHighlighted = "canSetHighlighted"
        static var touchEndCount = "touchEndCount"
        static var automaticallyAdjustTouchHighlightedInScrollView = "automaticallyAdjustTouchHighlightedInScrollView"
        static var qmui_highlightedClosure = "qmui_highlightedClosure"
    }
    
    /**
     *  是否接管 UIControl 的 touch 事件。
     *
     *  UIControl 在 UIScrollView 上会有300毫秒的延迟，默认情况下快速点击某个 UIControl，将不会看到 setHighlighted 的效果。如果通过将 UIScrollView.delaysContentTouches 置为 NO 来取消这个延迟，则系统无法判断 touch 时是要点击还是要滚动。
     *
     *  此时可以将 UIControl.qmui_automaticallyAdjustTouchHighlightedInScrollView 属性置为 YES，会使用自己的一套计算方式去判断触发 setHighlighted 的时机，从而保证既不影响 UIScrollView 的滚动，又能让 UIControl 在被快速点击时也能立马看到 setHighlighted 的效果。
     *
     *  @warning 使用了这个属性则不需要设置 UIScrollView.delaysContentTouches。
     */
    var qmui_automaticallyAdjustTouchHighlightedInScrollView: Bool {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.automaticallyAdjustTouchHighlightedInScrollView,
                                     newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.automaticallyAdjustTouchHighlightedInScrollView) as? Bool ?? false
        }
    }

    /// 响应区域需要改变的大小，负值表示往外扩大，正值表示往内缩小
    var qmui_outsideEdge: UIEdgeInsets {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.qmui_outsideEdge, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys.qmui_outsideEdge) as? UIEdgeInsets) ?? .zero
        }
    }
    
    typealias HighlightedClosureType = (_ highlighted: Bool) -> ()
    
    var qmui_highlightedClosure: HighlightedClosureType? {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.qmui_highlightedClosure, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys.qmui_highlightedClosure) as? HighlightedClosureType) ?? nil
        }
    }

    private var canSetHighlighted: Bool {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.canSetHighlighted, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys.canSetHighlighted) as? Bool) ?? false
        }
    }

    private var touchEndCount: Int {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.touchEndCount, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys.touchEndCount) as? Int) ?? 0
        }
    }

    @objc func qmui_touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchEndCount = 0
        if qmui_automaticallyAdjustTouchHighlightedInScrollView {
            canSetHighlighted = true
            qmui_touchesBegan(touches, with: event)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if self.canSetHighlighted {
                    self.isHighlighted = true
                }
            }
        } else {
            qmui_touchesBegan(touches, with: event)
        }
    }

    @objc func qmui_touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if qmui_automaticallyAdjustTouchHighlightedInScrollView {
            canSetHighlighted = false
        }
        qmui_touchesMoved(touches, with: event)
    }

    @objc func qmui_touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if qmui_automaticallyAdjustTouchHighlightedInScrollView {
            canSetHighlighted = false
            if isTouchInside {
                isHighlighted = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                    // 如果延迟时间太长，会导致快速点击两次，事件会触发两次
                    // 对于 3D Touch 的机器，如果点击按钮的时候在按钮上停留事件稍微长一点点，那么 touchesEnded 会被调用两次
                    // 把 super touchEnded 放到延迟里调用会导致长按无法触发点击，先这么改，再想想怎么办。// [self qmui_touchesEnded:touches withEvent:event];
                    self.sendActionsForAllTouchEventsIfCan()
                    if self.isHighlighted {
                        self.isHighlighted = false
                    }
                }
            } else {
                isHighlighted = false
            }
        } else {
            qmui_touchesEnded(touches, with: event)
        }
    }

    @objc func qmui_touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if qmui_automaticallyAdjustTouchHighlightedInScrollView {
            canSetHighlighted = false
            qmui_touchesCancelled(touches, with: event)
            if isHighlighted {
                isHighlighted = false
            }
        } else {
            qmui_touchesCancelled(touches, with: event)
        }
    }

    @objc func qmui_point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if event?.type != .touches {
            return qmui_point(inside: point, with: event)
        }
        let boundsInsetOutsideEdge = CGRect(x: bounds.minX + qmui_outsideEdge.left, y: bounds.minY + qmui_outsideEdge.top, width: bounds.width - qmui_outsideEdge.horizontalValue, height: bounds.height - qmui_outsideEdge.verticalValue)
        return boundsInsetOutsideEdge.contains(point)
    }
    
    @objc func qmui_setHighlighted(_ highlighted: Bool) {
        qmui_setHighlighted(highlighted)
        if let qmui_highlightedClosure = qmui_highlightedClosure {
            qmui_highlightedClosure(highlighted)
        }
    }

    // 这段代码需要以一个独立的方法存在，因为一旦有坑，外面可以直接通过runtime调用这个方法
    // 但，不要开放到.h文件里，理论上外面不应该用到它
    private func sendActionsForAllTouchEventsIfCan() {
        touchEndCount += 1
        if touchEndCount == 1 {
            sendActions(for: .allEvents)
        }
    }
}
