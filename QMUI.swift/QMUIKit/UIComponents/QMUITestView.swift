//
//  QMUITestView.swift
//  QMUI.swift
//
//  Created by 黄伯驹 on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

class QMUITestView: UIView {
    deinit {
        print("\((classForCoder, #function))")
    }

    override var frame: CGRect {
        willSet {
            if newValue != frame {
                print("frame发生变化, old is \(frame), new is \(newValue)")
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        print("\(#function), frame = \(frame)")
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        print("\(#function), superview is \(String(describing: superview))")
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()

        print("\(#function), superview is \(String(describing: window))")
    }

    override func addSubview(_ view: UIView) {
        super.addSubview(view)

        print("\(#function), subview is \(view), subviews.count before addSubview is \(subviews.count)")
    }

    override var isHidden: Bool {
        willSet {
            print("\(#function), hidden is \(newValue)")
        }
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view
    }
}

class QMUITestWindow: UIWindow {
    deinit {
        print("\((classForCoder, #function))")
    }

    override func addSubview(_ view: UIView) {
        super.addSubview(view)

        print("QMUITestWindow, subviews = \(subviews), view = \(view)")
    }

    override var frame: CGRect {
        willSet {
            if newValue != frame {
                print("QMUITestWindow, frame发生变化, old is \(frame), new is \(newValue)")
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        print("QMUITestWindow, layoutSubviews")
    }
}
