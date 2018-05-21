//
//  QMUIEmotionInputManager.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/5/4.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

/**
 *  提供一个常见的通用表情面板，能为绑定的`UITextField`或`UITextView`提供表情的相关功能，包括点击表情输入对应的表情名字、点击删除按钮删除表情。
 *  使用方式：
 *  1. 使用 init 方法初始化。
 *  2. 通过 `boundTextField` 或 `boundTextView` 关联一个输入框，建议这些输入框使用 `QMUITextField` 或 `QMUITextView`，原因看下面的 warning。
 *  3. 将所有表情通过 `self.emotionView.emotions` 设置进去，注意这个数组里的所有 `QMUIEmotion` 的 `displayName` 都应该使用左右标识符包裹起来（例如中括号“[]”），并且所有表情的左右标识符都应该保持一致。
 *  4. 将 `self.emotionView` add 到界面上即可。
 *
 *  @warning 一个`QMUIEmotionInputManager`无法同时绑定`boundTextField`和`boundTextView`，在两者都绑定的情况下，优先使用`boundTextField`。
 *  @warning 由于`QMUIEmotionInputManager`里面多个地方会调用`boundTextView.text`，而`setText:`并不会触发`UITextViewDelegate`的`textViewDidChange:`或`UITextViewTextDidChangeNotification`，以及 `UITextField` 的 `UIControlEventEditingChanged` 事件，从而在刷新表情面板里的发送按钮的enabled状态时可能不及时，所以推荐使用 `QMUITextView` 代替 `UITextView`、用 `QMUITextField` 代替 `UITextField`，并确保它们的`shouldResponseToProgrammaticallyTextChanges`属性是 `YES`（默认即为 `YES`）。
 *  @warning 由于表情的插入、删除都会受当前输入框的光标所在位置的影响，所以请在适当的时机更新`selectedRangeForBoundTextInput`的值，具体情况请查看该属性的注释。
 */
class QMUIEmotionInputManager: NSObject {

    /// 要绑定的 UITextField
    weak var boundTextField: UITextField?
    
    /// 要绑定的 UITextView
    weak var boundTextView: UITextView?
    
    /**
     *  `selectedRangeForBoundTextInput`决定了表情将会被插入（删除）的位置，因此使用控件的时候需要及时更新它。
     *
     *  通常用到的更新时机包括：
     *  - 降下键盘显示表情面板之前（调用resignFirstResponder、endEditing:之前）
     *  - <UITextViewDelegate>的`textViewDidChangeSelection:`回调里
     *  - 输入框里的文字发生变化时，例如点了发送按钮后输入框文字会被清空，此时要重置`selectedRangeForBoundTextInput`为0
     */
    var selectedRangeForBoundTextInput: NSRange = NSRange(location: 0, length: 0)
    
    /**
     *  表情面板，已被设置了默认的`didSelectEmotionBlock`和`didSelectDeleteButtonBlock`，在`QMUIEmotionInputManager`初始化完后，即可将`emotionView`添加到界面上。
     */
    private(set) var emotionView: QMUIEmotionView
    
    private var boundInputView: UITextInput? {
        if boundTextField != nil {
            return boundTextField
        } else if boundTextView != nil {
            return boundTextView
        }
        return nil
    }
    
    override init() {
        emotionView = QMUIEmotionView()
        super.init()
        emotionView.didSelectEmotionClosure = {[weak self] (index, emotion) in
            guard let strongSelf = self, let _ = strongSelf.boundInputView else {
                return
            }
            var inputText: String = ""
            if strongSelf.boundTextField != nil {
                inputText = strongSelf.boundTextField!.text ?? ""
            } else if strongSelf.boundTextView != nil {
                inputText = strongSelf.boundTextView!.text
            }
            // 用一个局部变量先保存selectedRangeForBoundTextInput的值，是为了避免在接下来这段代码执行的过程中，外部可能修改了self.selectedRangeForBoundTextInput的值，导致计算错误
            var selectedRange = strongSelf.selectedRangeForBoundTextInput
            if selectedRange.location <= inputText.length {
                // 在输入框文字的中间插入表情
                let mutableText = NSMutableString(string: inputText)
                mutableText.insert(emotion.displayName, at: selectedRange.location)
                if strongSelf.boundTextField != nil {
                    strongSelf.boundTextField!.text = mutableText as String?
                } else if strongSelf.boundTextView != nil {
                    strongSelf.boundTextView!.text = mutableText as String?
                }
                // UITextView setText:会触发textViewDidChangeSelection:，而如果在这个delegate里更新self.selectedRangeForBoundTextInput，就会导致计算错误
                selectedRange = NSRange(location: selectedRange.location + emotion.displayName.length, length: 0)
            } else {
                // 在输入框文字的结尾插入表情
                inputText = inputText.appending(emotion.displayName)
                if strongSelf.boundTextField != nil {
                    strongSelf.boundTextField!.text = inputText
                } else if strongSelf.boundTextView != nil {
                    strongSelf.boundTextView!.text = inputText
                }
                selectedRange = NSRange(location: inputText.length, length: 0)
                // 始终都应该从 boundInputView.text 获取最终的文字，因为可能在 setText: 时受 maximumTextLength 的限制导致文字截断
            }
            strongSelf.selectedRangeForBoundTextInput = selectedRange
        }
        emotionView.didSelectDeleteButtonClosure = { [weak self] () in
            self?.deleteEmotionDisplayNameAtCurrentSelectedRange(forceDelete: true)
        }
    }
    
    /**
     *  将当前光标所在位置的表情删除，在调用前请注意更新`selectedRangeForBoundTextInput`
     *  @param forceDelete 当没有删除掉表情的情况下（可能光标前面并不是一个表情字符），要不要强制删掉光标前的字符。YES表示强制删掉，NO表示不删，交给系统键盘处理
     *  @return 表示是否成功删除了文字（如果并不是删除表情，而是删除普通字符，也是返回YES）
     */
    @discardableResult func deleteEmotionDisplayNameAtCurrentSelectedRange(forceDelete: Bool) -> Bool {
        guard boundInputView != nil else {
            return false
        }
        let selectedRange = selectedRangeForBoundTextInput
        var text: String = ""
        if boundTextField != nil {
            text = boundTextField!.text ?? ""
        } else if boundTextView != nil {
            text = boundTextView!.text
        }
        // 没有文字或者光标位置前面没文字
        if text.length == 0 || NSMaxRange(selectedRange) == 0 {
            return false
        }
        var hasDeleteEmotionDisplayNameSuccess = false
        let exampleEmotionDisplayName = emotionView.emotions.first?.displayName
        var emotionDisplayNameLeftSign: String? = nil
        var emotionDisplayNameRightSign: String? = nil
        if let displayName = exampleEmotionDisplayName {
            var index = displayName.index(displayName.startIndex, offsetBy: 0)
            emotionDisplayNameLeftSign = String(displayName[index])

            index = displayName.index(displayName.endIndex, offsetBy: -1)
            emotionDisplayNameRightSign = String(displayName[index])
        }
        let emotionDisplayNameMinimumLength = 3
        let lengthForStringBeforeSelectedRange = selectedRange.location
        let lastCharacterBeforeSelectedRange = text.substring(with: NSRange(location: selectedRange.location - 1, length: 1))
        if lastCharacterBeforeSelectedRange == emotionDisplayNameRightSign && lengthForStringBeforeSelectedRange >= emotionDisplayNameMinimumLength {
            let endIndex = lengthForStringBeforeSelectedRange - (emotionDisplayNameMinimumLength - 1) // 从"]"之前的第n个字符开始查找
            let beginIndex = max(0, lengthForStringBeforeSelectedRange - 5) // 直到"]"之前的第n个字符结束查找，这里写5只是简单的限定，这个数字只要比所有表情的displayName长度长就行了
            for i in (beginIndex...endIndex).reversed() {
                let checkingCharacter = text.substring(with: NSRange(location: i, length: 1))
                if checkingCharacter == emotionDisplayNameRightSign {
                    // 查找过程中还没遇到"["就已经遇到"]"了，说明是非法的表情字符串，所以直接终止
                    break
                }
                
                if checkingCharacter == emotionDisplayNameLeftSign {
                    let deletingDisplayNameRange = NSRange(location: i, length: lengthForStringBeforeSelectedRange - i)
                    if boundTextField != nil {
                        boundTextField!.text = (text as NSString).replacingCharacters(in: deletingDisplayNameRange, with: "")
                    } else if boundTextView != nil {
                        boundTextView!.text = (text as NSString).replacingCharacters(in: deletingDisplayNameRange, with: "")
                    }
                    selectedRangeForBoundTextInput = NSRange(location: deletingDisplayNameRange.location, length: 0)
                    hasDeleteEmotionDisplayNameSuccess = true
                    break
                }
            }
        }
        
        if hasDeleteEmotionDisplayNameSuccess {
            return true
        }
        
        if forceDelete {
            if NSMaxRange(selectedRange) <= text.length {
                if selectedRange.length > 0 {
                    // 如果选中区域是一段文字，则删掉这段文字
                    if boundTextField != nil {
                        boundTextField!.text = (text as NSString).replacingCharacters(in: selectedRange, with: "")
                    } else if boundTextView != nil {
                        boundTextView!.text = (text as NSString).replacingCharacters(in: selectedRange, with: "")
                    }
                    selectedRangeForBoundTextInput = NSRange(location: selectedRange.location, length: 0)
                } else if selectedRange.location > 0 {
                    // 如果并没有选中一段文字，则删掉光标前一个字符
                    let textAfterDelete = (text as String).qmui_stringByRemoveCharacter(at: selectedRange.location - 1)
                    if boundTextField != nil {
                        boundTextField!.text = textAfterDelete
                    } else if boundTextView != nil {
                        boundTextView!.text = textAfterDelete
                    }
                    selectedRangeForBoundTextInput = NSRange(location: selectedRange.location - (text.length - textAfterDelete.length), length: 0)
                }
            } else {
                // 选中区域超过文字长度了，非法数据，则直接删掉最后一个字符
                let tmpText = text.qmui_stringByRemoveLastCharacter()
                if boundTextField != nil {
                    boundTextField!.text = tmpText
                } else if boundTextView != nil {
                    boundTextView!.text = tmpText
                }
                selectedRangeForBoundTextInput = NSRange(location: tmpText.length, length: 0)
            }
            return true
        }
        return false
    }
    
    /**
     *  在 `UITextViewDelegate` 的 `textView:shouldChangeTextInRange:replacementText:` 或者 `QMUITextFieldDelegate` 的 `textField:shouldChangeTextInRange:replacementText:` 方法里调用，根据返回值来决定是否应该调用 `deleteEmotionDisplayNameAtCurrentSelectedRangeForce:`
     
     @param range 要发生变化的文字所在的range
     @param text  要被替换为的文字
     
     @return 是否会接管键盘的删除按钮事件，`YES` 表示接管，可调用 `deleteEmotionDisplayNameAtCurrentSelectedRangeForce:` 方法，`NO` 表示不可接管，应该使用系统自身的删除事件响应。
     */
    func shouldTakeOverControlDeleteKeyWithChangeText(in range: NSRange, replacementText text: String) -> Bool  {
        var length = 0
        if boundTextField != nil {
            length = boundTextField!.text?.length ?? 0
        } else if boundTextView != nil {
            length = boundTextView!.text.length
        }
        let isDeleteKeyPressed = text.length == 0 && length - 1 == range.location
        let hasMarkedText = boundInputView?.markedTextRange != nil
        return isDeleteKeyPressed && hasMarkedText
    }
}
