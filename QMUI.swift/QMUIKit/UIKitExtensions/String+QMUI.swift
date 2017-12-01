//
//  String+QMUI.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/4/13.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

public extension String {
    public var qmui_md5: String {
        let messageData = data(using:.utf8)!
        var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        _ = digestData.withUnsafeMutableBytes { digestBytes in
            messageData.withUnsafeBytes {
                CC_MD5($0, CC_LONG(messageData.count), digestBytes)
            }
        }
        return digestData.map { String(format: "%02hhx", $0) }.joined()
    }

    public static func qmui_hexString(with int: Int) -> String {
        var hexString = ""
        var integer = int
        var remainder = 0
        for _ in 0 ..< 9 {
            remainder = integer % 16
            integer = integer / 16
            let letter = hexLetterString(with:remainder)
            hexString = letter + hexString
            if integer == 0 {
                break
            }
        }
        return hexString
    }
    
    public var qmui_trim: String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public static func hexLetterString(with int: Int) -> String {
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

    func substring(with range: NSRange) -> String {
        let start = index(startIndex, offsetBy: range.location)
        let end = index(endIndex, offsetBy: range.location + range.length - count)
        return String(describing: [start..<end])
    }

    var length: Int {
        return count
    }

    subscript(i: Int) -> String {
        return self[Range(i ..< i + 1)]
    }
    
    subscript(r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[Range(start ..< end)])
    }
}
