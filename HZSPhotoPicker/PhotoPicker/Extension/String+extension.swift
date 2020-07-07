//
//  String+extension.swift
//  KitDemo
//
//  Created by 黄中山 on 2018/7/8.
//  Copyright © 2018年 黄中山. All rights reserved.
//

import UIKit

extension String {
    
    func appendingNameScale(_ scale: Int) -> String {
        if scale - 1 == 0 || self.isEmpty || self.hasSuffix("/") {
            return self
        } else {
            return self + "@\(scale)x"
        }
    }
    
    func pathScale() -> CGFloat {
        if self.isEmpty || hasSuffix("/") { return 1 }
        let name = (self as NSString).deletingPathExtension
        var scale: CGFloat = 1
        name.enumerateRegexMatches(regex: "@[0-9]+\\.?[0-9]*x$", options: [.anchorsMatchLines]) { (match, matchRange, stop) in
            if let match = match {
                let x = Int((match as NSString).substring(with: NSRange(location: 1, length: match.count - 2)))!
                scale = CGFloat(x)
            }
        }
        return scale
    }
    
    func enumerateRegexMatches(regex: String, options: NSRegularExpression.Options, usingClosure closure: (_ match: String?, _ matchRange: NSRange, _ stop: UnsafeMutablePointer<ObjCBool>) -> Void) {
        if regex.isEmpty { return }
        let pattern = try? NSRegularExpression(pattern: regex, options: options)
        if pattern == nil { return }
        pattern!.enumerateMatches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) { (result, flags, stop) in
            closure((self as NSString).substring(with: result!.range), result!.range, stop)
        }
    }
    
    
}

// MARK: - String isEmpty
extension Optional where Wrapped == String {
    
    var isEmpty: Bool {
        switch self {
        case .some(let value):
            return value.isEmpty
        case .none:
            return true
        }
    }
}
