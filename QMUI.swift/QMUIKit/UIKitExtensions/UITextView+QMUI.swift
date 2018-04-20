//
//  UITextView+QMUI.swift
//  QMUI.swift
//
//  Created by xnxin on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

extension UITextView {

    /**
     *  convert UITextRange to NSRangefor example, [self qmui_convertNSRangeFromUITextRange:self.markedTextRange]
     */
    func qmui_convertNSRange(from textRange: UITextRange) -> NSRange {
        let location = offset(from: beginningOfDocument, to: textRange.start)
        let length = offset(from: textRange.start, to: textRange.end)
        return NSMakeRange(location, length)
    }

    /**
     *  设置 text 会让 selectedTextRange 跳到最后一个字符，导致在中间修改文字后光标会跳到末尾，所以设置前要保存一下，设置后恢复过来
     */
    func qmui_setTextKeepingSelectedRange(_ text: String) {
        let selectedTextRange = self.selectedTextRange
        self.text = text
        self.selectedTextRange = selectedTextRange
    }

    /**
     *  设置 attributedText 会让 selectedTextRange 跳到最后一个字符，导致在中间修改文字后光标会跳到末尾，所以设置前要保存一下，设置后恢复过来
     */
    func qmui_setAttributedTextKeepingSelectedRange(_ attributedText: NSAttributedString) {
        let selectedTextRange = self.selectedTextRange
        self.attributedText = attributedText
        self.selectedTextRange = selectedTextRange
    }

    /**
     *  UITextView.scrollRangeToVisible() 并不会考虑 textContainerInset.bottom，所以使用这个方法来代替
     */
    func qmui_scrollCaretVisibleAnimated(_ animated: Bool) {
        if bounds.isEmpty {
            return
        }

        let caret = caretRect(for: selectedTextRange!.end)
        // scrollEnabled 为 NO 时可能产生不合法的 rect 值 https://github.com/QMUI/QMUI_iOS/issues/205
        if caret.minX.isInfinite || caret.minY.isInfinite {
            return
        }

        var contentOffsetY = contentOffset.y

        if caret.minY == contentOffset.y + textContainerInset.top {
            // 命中这个条件说明已经不用调整了，直接 return，避免继续走下面的判断，会重复调整，导致光标跳动
            return
        }

        if caret.minY < contentOffset.y + textContainerInset.top {
            // 光标在可视区域上方，往下滚动
            contentOffsetY = caret.minY - textContainerInset.top - contentInset.top
        } else if caret.maxY > contentOffset.y + bounds.height - textContainerInset.bottom - contentInset.bottom {
            // 光标在可视区域下方，往上滚动
            contentOffsetY = caret.maxY - bounds.height + textContainerInset.bottom + contentInset.bottom
        } else {
            // 光标在可视区域内，不用调整
            return
        }

        setContentOffset(CGPoint(x: contentOffset.x, y: contentOffsetY), animated: animated)
    }
}
