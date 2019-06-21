//
//  String+QMUI.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/4/13.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

extension String {
    /// 判断是否包含某个子字符串
    func qmui_includesString(string: String) -> Bool {
        guard string.length > 0 else {
            return false
        }

        return contains(string)
    }

    /// 去掉头尾的空白字符
    var qmui_trim: String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// 去掉整段文字内的所有空白字符（包括换行符）
    func qmui_trimAllWhiteSpace() -> String {
        return replacingOccurrences(of: "\\s", with: "", options: .regularExpression)
    }

    /// 将文字中的换行符替换为空格
    func qmui_trimLineBreakCharacter() -> String {
        return replacingOccurrences(of: "[\r\n]", with: " ", options: .regularExpression)
    }

    /// 把该字符串转换为对应的 md5
    var qmui_md5: String {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        let messageData = data(using:.utf8)!
        var digestData = Data(count: length)
        
        _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
            messageData.withUnsafeBytes { messageBytes -> UInt8 in
                if let messageBytesBaseAddress = messageBytes.baseAddress, let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                    let messageLength = CC_LONG(messageData.count)
                    CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
                }
                return 0
            }
        }
        return digestData.map { String(format: "%02hhx", $0) }.joined()
    }

    /// 把某个十进制数字转换成十六进制的数字的字符串，例如“10”->“A”
    static func qmui_hexString(with int: Int) -> String {
        var hexString = ""
        var integer = int
        var remainder = 0
        for _ in 0 ..< 9 {
            remainder = integer % 16
            integer = integer / 16
            let letter = hexLetterString(with: remainder)
            hexString = letter + hexString
            if integer == 0 {
                break
            }
        }
        return hexString
    }

    /// 把参数列表拼接成一个字符串并返回，相当于用另一种语法来代替 [NSString stringWithFormat:]
    static func qmui_stringByConcat(_ argvs: Any...) -> String {
        var result = ""
        for argv in argvs {
            result += String(describing: argv)
        }

        return result
    }

    /**
     * 将秒数转换为同时包含分钟和秒数的格式的字符串，例如 100->"01:40"
     */
    static func qmui_timeStringWithMinsAndSecs(from seconds: Double) -> String {
        let min = floor(seconds / 60)
        let sec = floor(seconds - min * 60)

        return String(format: "%02ld:%02ld", min, sec)
    }

    /**
     * 用正则表达式匹配的方式去除字符串里一些特殊字符，避免UI上的展示问题
     * @link http://www.croton.su/en/uniblock/Diacriticals.html
     */
    func qmui_removeMagicalChar() -> String {
        if length == 0 {
            return self
        }

        if let regex = try? NSRegularExpression(pattern: "[\u{0300}-\u{036F}]", options: .caseInsensitive) {
            let modifiedString = regex.stringByReplacingMatches(in: self, options: NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, length), withTemplate: "")

            return modifiedString
        } else {
            return self
        }
    }

    /**
     *  按照中文 2 个字符、英文 1 个字符的方式来计算文本长度
     */
    var qmui_lengthWhenCountingNonASCIICharacterAsTwo: Int {
        func isChinese(_ char: Character) -> Bool {
            return "\u{4E00}" <= char && char <= "\u{9FA5}"
        }

        var characterLength = 0
        for char in self {
            if isChinese(char) {
                characterLength += 2
            } else {
                characterLength += 1
            }
        }

        return characterLength
    }

    private func transformIndexToDefaultModeWithIndex(_ index: Int) -> Int {
        var stringLength = 0
        for (index, i) in enumerated() {
            if i.unicodeScalars.first?.isASCII ?? false {
                stringLength += 1
            } else {
                stringLength += 2
            }

            if stringLength > index {
                return index
            }
        }
        return 0
    }

    private func transformRangeToDefaultModeWithRange(_ range: Range<String.Index>) -> Range<String.Index> {
        var stringLength = 0
        var resultRange: Range<String.Index> = startIndex ..< startIndex
        for (index, i) in enumerated() {
            if i.unicodeScalars.first?.isASCII ?? false {
                stringLength += 1
            } else {
                stringLength += 2
            }

            if stringLength >= self.index(after: range.lowerBound).utf16Offset(in: self) {
                let currentIndex = self.index(startIndex, offsetBy: index)

                if resultRange.lowerBound == startIndex {
                    resultRange = currentIndex ..< resultRange.upperBound
                }

                if !resultRange.isEmpty && stringLength >= resultRange.upperBound.utf16Offset(in: self) {
                    let upperBound = stringLength == resultRange.upperBound.utf16Offset(in: self) ?
                        self.index(after: currentIndex) : currentIndex
                    resultRange = resultRange.lowerBound ..< upperBound
                    return resultRange
                }
            }
        }

        return resultRange
    }

    /**
     *  将字符串从指定的 index 开始裁剪到结尾，裁剪时会避免将 emoji 等 "character sequences" 拆散（一个 emoji 表情占用1-4个长度的字符）。
     *
     *  例如对于字符串“😊😞”，它的长度为4，若调用 [string qmui_substringAvoidBreakingUpCharacterSequencesFromIndex:1]，将返回“😊😞”。
     *  若调用系统的 [string substringFromIndex:1]，将返回“?😞”。（?表示乱码，因为第一个 emoji 表情被从中间裁开了）。
     *
     *  @param index 要从哪个 index 开始裁剪文字
     *  @param lessValue 要按小的长度取，还是按大的长度取
     *  @param countingNonASCIICharacterAsTwo 是否按照 英文 1 个字符长度、中文 2 个字符长度的方式来裁剪
     *  @return 裁剪完的字符
     */
    func qmui_substringAvoidBreakingUpCharacterSequencesFromIndex(index: Int, lessValue: Bool, countingNonASCIICharacterAsTwoindex: Bool) -> String {
        let index = countingNonASCIICharacterAsTwoindex ? transformIndexToDefaultModeWithIndex(index) : index

        let range = rangeOfComposedCharacterSequence(at: self.index(startIndex, offsetBy: index))

        return String(describing: [(lessValue ? range.upperBound : range.lowerBound)...])
    }

    /**
     *  相当于 `qmui_substringAvoidBreakingUpCharacterSequencesFromIndex: lessValue:YES` countingNonASCIICharacterAsTwo:NO
     *  @see qmui_substringAvoidBreakingUpCharacterSequencesFromIndex:lessValue:countingNonASCIICharacterAsTwo:
     */
    func qmui_substringAvoidBreakingUpCharacterSequencesFromIndex(index: Int) -> String {
        return qmui_substringAvoidBreakingUpCharacterSequencesFromIndex(index: index, lessValue: true, countingNonASCIICharacterAsTwoindex: false)
    }

    /**
     *  将字符串从开头裁剪到指定的 index，裁剪时会避免将 emoji 等 "character sequences" 拆散（一个 emoji 表情占用1-4个长度的字符）。
     *
     *  例如对于字符串“😊😞”，它的长度为4，若调用 [string qmui_substringAvoidBreakingUpCharacterSequencesToIndex:1]，将返回“😊”。
     *  若调用系统的 [string substringToIndex:1]，将返回“?”。（?表示乱码，因为第一个 emoji 表情被从中间裁开了）。
     *
     *  @param index 要裁剪到哪个 index
     *  @return 裁剪完的字符
     *  @param countingNonASCIICharacterAsTwo 是否按照 英文 1 个字符长度、中文 2 个字符长度的方式来裁剪
     */
    func qmui_substringAvoidBreakingUpCharacterSequencesToIndex(index: Int, lessValue: Bool, countingNonASCIICharacterAsTwo: Bool) -> String {
        let index = countingNonASCIICharacterAsTwo ? transformIndexToDefaultModeWithIndex(index) : index

        let range = rangeOfComposedCharacterSequence(at: self.index(startIndex, offsetBy: index))

        return String(describing: [...(lessValue ? range.lowerBound : range.upperBound)])
    }

    /**
     *  相当于 `qmui_substringAvoidBreakingUpCharacterSequencesToIndex:lessValue:YES` countingNonASCIICharacterAsTwo:NO
     *  @see qmui_substringAvoidBreakingUpCharacterSequencesToIndex:lessValue:countingNonASCIICharacterAsTwo:
     */
    func qmui_substringAvoidBreakingUpCharacterSequencesToIndex(index: Int) -> String {
        return qmui_substringAvoidBreakingUpCharacterSequencesToIndex(index: index, lessValue: true, countingNonASCIICharacterAsTwo: false)
    }

    /**
     *  将字符串里指定 range 的子字符串裁剪出来，会避免将 emoji 等 "character sequences" 拆散（一个 emoji 表情占用1-4个长度的字符）。
     *
     *  例如对于字符串“😊😞”，它的长度为4，在 lessValue 模式下，裁剪 (0, 1) 得到的是空字符串，裁剪 (0, 2) 得到的是“😊”。
     *  在非 lessValue 模式下，裁剪 (0, 1) 或 (0, 2)，得到的都是“😊”。
     *
     *  @param range 要裁剪的文字位置
     *  @param lessValue 裁剪时若遇到“character sequences”，是向下取整还是向上取整。
     *  @param countingNonASCIICharacterAsTwo 是否按照 英文 1 个字符长度、中文 2 个字符长度的方式来裁剪
     *  @return 裁剪完的字符
     */
    func qmui_substringAvoidBreakingUpCharacterSequencesWithRange(range: Range<String.Index>, lessValue: Bool, countingNonASCIICharacterAsTwo: Bool) -> String {

        let range = countingNonASCIICharacterAsTwo ? transformRangeToDefaultModeWithRange(range) : range

        let characterSequencesRange = lessValue ? downRoundRangeOfComposedCharacterSequencesForRange(range) :
            rangeOfComposedCharacterSequences(for: range)

        return String(describing: [characterSequencesRange])
    }

    /**
     *  相当于 `qmui_substringAvoidBreakingUpCharacterSequencesWithRange:lessValue:YES` countingNonASCIICharacterAsTwo:NO
     *  @see qmui_substringAvoidBreakingUpCharacterSequencesWithRange:lessValue:countingNonASCIICharacterAsTwo:
     */
    func qmui_substringAvoidBreakingUpCharacterSequencesWithRange(range: Range<String.Index>) -> String {
        return qmui_substringAvoidBreakingUpCharacterSequencesWithRange(range: range, lessValue: true, countingNonASCIICharacterAsTwo: false)
    }

    /**
     *  移除指定位置的字符，可兼容emoji表情的情况（一个emoji表情占1-4个length）
     *  @param index 要删除的位置
     */
    func qmui_stringByRemoveCharacter(at index: Int) -> String {
        guard let stringIndex = self.index(startIndex, offsetBy: index, limitedBy: endIndex) else {
            return self
        }
        let rangeForMove = rangeOfComposedCharacterSequence(at: stringIndex)
        let resultString = replacingCharacters(in: rangeForMove, with: "")
        return resultString
    }

    /**
     *  移除最后一个字符，可兼容emoji表情的情况（一个emoji表情占1-4个length）
     *  @see `qmui_stringByRemoveCharacterAtIndex:`
     */
    func qmui_stringByRemoveLastCharacter() -> String {
        return qmui_stringByRemoveCharacter(at: length - 1)
    }

    private func downRoundRangeOfComposedCharacterSequencesForRange(_ range: Range<String.Index>) -> Range<String.Index> {
        if range.isEmpty {
            return range
        }

        let resultRange = rangeOfComposedCharacterSequences(for: range)
        if resultRange.upperBound > range.upperBound {
            return downRoundRangeOfComposedCharacterSequencesForRange(range.lowerBound ..< index(before: range.upperBound))
        }

        return resultRange
    }

    private static func hexLetterString(with int: Int) -> String {
        assert(int < 16, "要转换的数必须是16进制里的个位数，也即小于16，但你传给我是\(int)")

        var letter = ""
        switch int {
        case 10:
            letter = "A"
        case 11:
            letter = "B"
        case 12:
            letter = "C"
        case 13:
            letter = "D"
        case 14:
            letter = "E"
        case 15:
            letter = "F"
        default:
            letter = "\(int)"
        }
        return letter
    }

    var encoding: String {
        //        let unreservedChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~"
        //        let unreservedCharset = CharacterSet(charactersIn: unreservedChars)
        //        return addingPercentEncoding(withAllowedCharacters: unreservedCharset) ?? self
        return addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? self
    }

    init(seconds: Double) {
        let min = floor(seconds / 60)
        let sec = floor(seconds - min * 60)
        self.init(format: "%02ld:%02ld", min, sec)
    }

    var decoding: String {
        return removingPercentEncoding ?? self
    }

    func index(from: Int) -> Index {
        return index(startIndex, offsetBy: from)
    }

    // https://stackoverflow.com/questions/45562662/how-can-i-use-string-slicing-subscripts-in-swift-4
    func substring(from: Int) -> String {
        return String(describing: [from...])
    }

    func substring(to: Int) -> String {
        return String(describing: [..<index(from: to)])
    }

    func substring(with nsrange: NSRange) -> String {
        guard let range = Range(nsrange, in: self) else { return "" }
        return String(self[range])
    }

    var length: Int {
        return count
    }

    subscript(i: Int) -> String {
        return self[i ..< i + 1]
    }

    subscript(r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}
