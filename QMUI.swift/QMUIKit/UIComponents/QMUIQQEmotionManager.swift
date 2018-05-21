//
//  QMUIQQEmotionManager.swift
//  QMUI.swift
//
//  Created by 黄伯驹 on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

import UIKit

protocol QMUIQQEmotionInputViewProtocol: UITextInput {
    var text: String { get set }
    var selectedRange: Range<Int> { get }
}

/**
 *  提供一个QQ表情面板，能为绑定的`UITextField`或`UITextView`提供表情的相关功能，包括点击表情输入对应的表情名字、点击删除按钮删除表情。由于表情的插入、删除都会受当前输入框的光标所在位置的影响，所以请在适当的时机更新`selectedRangeForBoundTextInput`的值，具体情况请查看属性的注释。
 *  @warning 由于QQ表情图片较多（文件大小约400K），因此表情图片被以bundle的形式存放在
 *  @warning 一个`QMUIQQEmotionManager`无法同时绑定`boundTextField`和`boundTextView`，在两者都绑定的情况下，优先使用`boundTextField`。
 *  @warning 由于`QMUIQQEmotionManager`里面多个地方会调用`boundTextView.text`，而`setText:`并不会触发`UITextViewDelegate`的`textViewDidChange:`或`UITextViewTextDidChangeNotification`，从而在刷新表情面板里的发送按钮的enabled状态时可能不及时，所以`QMUIQQEmotionManager`要求绑定的`QMUITextView`必须打开`shouldResponseToProgrammaticallyTextChanges`属性
 */
class QMUIQQEmotionManager {
    /// 要绑定的UITextField
    weak var boundTextField: UITextField?

    /// 要绑定的UITextView
    weak var boundTextView: UITextView?

    /**
     *  `selectedRangeForBoundTextInput`决定了表情将会被插入（删除）的位置，因此使用控件的时候需要及时更新它。
     *
     *  通常用到的更新时机包括：
     *  - 降下键盘显示QQ表情面板之前（调用resignFirstResponder、endEditing:之前）
     *  - <UITextViewDelegate>的`textViewDidChangeSelection:`回调里
     *  - 输入框里的文字发生变化时，例如点了发送按钮后输入框文字会被清空，此时要重置`selectedRangeForBoundTextInput`为0
     */
    var selectedRangeForBoundTextInput: Range<Int> = 0 ..< 0

    /**
     *  显示QQ表情的表情面板，已被设置了默认的`didSelectEmotionBlock`和`didSelectDeleteButtonBlock`，在`QMUIQQEmotionManager`初始化完后，即可将`emotionView`添加到界面上。
     */
    let emotionView: QMUIEmotionView = QMUIEmotionView()

    init() {
        emotionView.didSelectEmotionClosure = { [weak self] _, emotion in
            guard let strongSelf = self else {
                return
            }

            guard let notNilBoundInputView = strongSelf.boundInputView() else {
                return
            }

            var inputText = notNilBoundInputView.text
            // 用一个局部变量先保存selectedRangeForBoundTextInput的值，是为了避免在接下来这段代码执行的过程中，外部可能修改了self.selectedRangeForBoundTextInput的值，导致计算错误
            var selectedRange = strongSelf.selectedRangeForBoundTextInput
            if selectedRange.lowerBound <= inputText.length {
                // 在输入框文字的中间插入表情
                var mutableText = inputText
                mutableText.insert(contentsOf: emotion.displayName, at: mutableText.index(mutableText.startIndex, offsetBy: selectedRange.lowerBound))
                notNilBoundInputView.text = mutableText
                selectedRange = (mutableText.length + emotion.displayName.length) ..< (mutableText.length + emotion.displayName.length)
            } else {
                // 在输入框文字的结尾插入表情
                inputText = "\(inputText)\(emotion.displayName)"
                notNilBoundInputView.text = inputText
                selectedRange = inputText.length ..< inputText.length
            }

            strongSelf.selectedRangeForBoundTextInput = selectedRange
        }

        emotionView.didSelectDeleteButtonClosure = { [weak self] in
            self?.deleteEmotionDisplayNameAtCurrentSelectedRange(force: true)
        }
    }

    private func boundInputView() -> QMUIQQEmotionInputViewProtocol? {
        if let notNilBoundTextField = boundTextField as? QMUIQQEmotionInputViewProtocol {
            return notNilBoundTextField
        } else if let notNilBoundTextView = boundTextView as? QMUIQQEmotionInputViewProtocol {
            return notNilBoundTextView
        }

        return nil
    }

    /**
     *  将当前光标所在位置的表情删除，在调用前请注意更新`selectedRangeForBoundTextInput`
     *  @param forceDelete 当没有删除掉表情的情况下（可能光标前面并不是一个表情字符），要不要强制删掉光标前的字符。YES表示强制删掉，NO表示不删，交给系统键盘处理
     *  @return 表示是否成功删除了文字（如果并不是删除表情，而是删除普通字符，也是返回YES）
     */
    @discardableResult
    func deleteEmotionDisplayNameAtCurrentSelectedRange(force: Bool) -> Bool {
        guard let notNilBoundInputView = self.boundInputView() else {
            return false
        }

        let selectedRange = selectedRangeForBoundTextInput
        var text = notNilBoundInputView.text

        // 没有文字或者光标位置前面没文字
        if text.length <= 0 || selectedRange.upperBound == 0 {
            return false
        }

        var hasDeleteEmotionDisplayNameSuccess = false
        let emotionDisplayNameMinimumLength = 3 // QQ表情里的最短displayName的长度
        let lengthForStringBeforeSelectedRange = selectedRange.lowerBound
        let lastCharacterBeforeSelectedRange = text[selectedRange.lowerBound - 1 ..< selectedRange.lowerBound]
        if lastCharacterBeforeSelectedRange == "]" && lengthForStringBeforeSelectedRange >= emotionDisplayNameMinimumLength {
            let beginIndex = lengthForStringBeforeSelectedRange - (emotionDisplayNameMinimumLength - 1) // 从"]"之前的第n个字符开始查找
            let endIndex = max(0, lengthForStringBeforeSelectedRange - 5) // 直到"]"之前的第n个字符结束查找，这里写5只是简单的限定，这个数字只要比所有QQ表情的displayName长度长就行了
            for i in (endIndex ... beginIndex).reversed() {
                let checkingCharacter = text[i ..< i + 1]
                if checkingCharacter == "]" {
                    // 查找过程中还没遇到"["就已经遇到"]"了，说明是非法的表情字符串，所以直接终止
                    break
                }
                if checkingCharacter == "[" {
                    let deletingDisplayNameRange: Range<Int> = i ..< lengthForStringBeforeSelectedRange - i
                    notNilBoundInputView.text = text.replace(deletingDisplayNameRange, with: "")
                    selectedRangeForBoundTextInput = deletingDisplayNameRange.lowerBound ..< deletingDisplayNameRange.lowerBound
                    hasDeleteEmotionDisplayNameSuccess = true
                    break
                }
            }
        }

        if hasDeleteEmotionDisplayNameSuccess {
            return true
        }

        if force {
            if selectedRange.upperBound <= text.length {
                if selectedRange.count > 0 {
                    // 如果选中区域是一段文字，则删掉这段文字
                    notNilBoundInputView.text = text.replace(selectedRange, with: "")
                    selectedRangeForBoundTextInput = selectedRange.lowerBound ..< selectedRange.lowerBound
                } else if selectedRange.lowerBound > 0 {
                    // 如果并没有选中一段文字，则删掉光标前一个字符
                    let textAfterDelete = text.qmui_stringByRemoveCharacter(at: selectedRange.lowerBound - 1)
                    notNilBoundInputView.text = textAfterDelete
                    let startIndex = selectedRange.lowerBound - (text.length - textAfterDelete.length)
                    selectedRangeForBoundTextInput = startIndex ..< startIndex
                }
            } else {
                // 选中区域超过文字长度了，非法数据，则直接删掉最后一个字符
                notNilBoundInputView.text = text.qmui_stringByRemoveLastCharacter()
                selectedRangeForBoundTextInput = notNilBoundInputView.text.length ..< notNilBoundInputView.text.length
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
    func shouldTakeOverControlDeleteKeyWithChangeText(in range: Range<Int>, replacementText: String) -> Bool {
        let isDeleteKeyPressed = replacementText.length == 0 && (boundInputView()?.text.length ?? 0) - 1 == range.lowerBound
        let hasMarkedText = boundInputView()?.markedTextRange != nil
        return isDeleteKeyPressed && !hasMarkedText
    }

    static let QQEmotionString = "0-[微笑];1-[撇嘴];2-[色];3-[发呆];4-[得意];5-[流泪];6-[害羞];7-[闭嘴];8-[睡];9-[大哭];10-[尴尬];11-[发怒];12-[调皮];13-[呲牙];14-[惊讶];15-[难过];16-[酷];17-[冷汗];18-[抓狂];19-[吐];20-[偷笑];21-[可爱];22-[白眼];23-[傲慢];24-[饥饿];25-[困];26-[惊恐];27-[流汗];28-[憨笑];29-[大兵];30-[奋斗];31-[咒骂];32-[疑问];33-[嘘];34-[晕];35-[折磨];36-[衰];37-[骷髅];38-[敲打];39-[再见];40-[擦汗];41-[抠鼻];42-[鼓掌];43-[糗大了];44-[坏笑];45-[左哼哼];46-[右哼哼];47-[哈欠];48-[鄙视];49-[委屈];50-[快哭了];51-[阴险];52-[亲亲];53-[吓];54-[可怜];55-[菜刀];56-[西瓜];57-[啤酒];58-[篮球];59-[乒乓];60-[咖啡];61-[饭];62-[猪头];63-[玫瑰];64-[凋谢];65-[示爱];66-[爱心];67-[心碎];68-[蛋糕];69-[闪电];70-[炸弹];71-[刀];72-[足球];73-[瓢虫];74-[便便];75-[月亮];76-[太阳];77-[礼物];78-[拥抱];79-[强];80-[弱];81-[握手];82-[胜利];83-[抱拳];84-[勾引];85-[拳头];86-[差劲];87-[爱你];88-[NO];89-[OK];90-[爱情];91-[飞吻];92-[跳跳];93-[发抖];94-[怄火];95-[转圈];96-[磕头];97-[回头];98-[跳绳];99-[挥手];100-[激动];101-[街舞];102-[献吻];103-[左太极];104-[右太极];105-[嘿哈];106-[捂脸];107-[奸笑];108-[机智];109-[皱眉];110-[耶];111-[红包];112-[鸡]"

    static var QQEmotionArray = [QMUIEmotion]()

    /**
     *  QQ表情的数组，会做缓存，图片只会加载一次
     */
    static func emotionsForQQ() -> [QMUIEmotion] {
        if QQEmotionArray.count > 0 {
            return QQEmotionArray
        }

        var emotions = [QMUIEmotion]()
        let emotionStringArray = QQEmotionString.split(separator: ";").map { String($0) }
        for emotionString in emotionStringArray {
            let emotionItem = emotionString.split(separator: "-").map { String($0) }
            let identifier = "smiley_\(emotionItem.first!)"
            let emotion = QMUIEmotion(identifier: identifier, displayName: emotionItem.last!)
            emotions.append(emotion)
        }

        QQEmotionArray = emotions
        asyncLoadImages(emotions)
        return QQEmotionArray
    }

    // 子线程预加载
    static func asyncLoadImages(_ emotions: [QMUIEmotion]) {
        DispatchQueue.global().async {
            emotions.forEach { e in
                _ = e.image
            }
        }
    }
}

extension String {
    mutating func replace(_ range: Range<Int>, with str: String) -> String {
        let startIndex = index(self.startIndex, offsetBy: range.lowerBound, limitedBy: self.endIndex) ?? self.startIndex
        let endIndex = index(self.startIndex, offsetBy: range.upperBound, limitedBy: self.endIndex) ?? self.startIndex
        replaceSubrange(startIndex ..< endIndex, with: str)
        return self
    }
}
