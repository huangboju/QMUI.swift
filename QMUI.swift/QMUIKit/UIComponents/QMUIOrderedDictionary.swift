//
//  QMUIOrderedDictionary.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/2/9.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

// 使用： let od = QMUIOrderedDictionary(dictionaryLiteral: ("3", "q"), ("2", "w"))
struct QMUIOrderedDictionary<K: Hashable, V> {
    var allKeys = [K]()
    private var dict = [K: V]()

    var count: Int {
        return allKeys.count
    }

    subscript(key: K) -> V? {
        get {
            return dict[key]
        }
        set(newValue) {
            if newValue == nil {
                dict.removeValue(forKey: key)
                allKeys = allKeys.filter { $0 != key }
            } else {
                let oldValue = dict.updateValue(newValue!, forKey: key)
                if oldValue == nil {
                    allKeys.append(key)
                }
            }
        }
    }
}

extension QMUIOrderedDictionary: Sequence {
    func makeIterator() -> AnyIterator<Value> {
        var counter = 0
        return AnyIterator {
            guard counter < self.allKeys.count else {
                return nil
            }
            let next = self.dict[self.allKeys[counter]]
            counter += 1
            return next
        }
    }
}

extension QMUIOrderedDictionary: CustomStringConvertible {
    var description: String {
        let isString = type(of: allKeys[0]) == String.self
        var result = "["
        for key in allKeys {
            result += isString ? "\"\(key)\"" : "\(key)"
            result += ": \(self[key]!), "
        }
        result = String(result.dropLast(2))
        result += "]"
        return result
    }
}

extension QMUIOrderedDictionary: ExpressibleByDictionaryLiteral {
    init(dictionaryLiteral elements: (K, V)...) {
        self.init()
        for (key, value) in elements {
            self[key] = value
        }
    }
    
    
}
