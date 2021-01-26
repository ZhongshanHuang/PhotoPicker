//
//  PoSentinel.swift
//  HZSPhotoPicker
//
//  Created by 黄中山 on 2020/7/5.
//  Copyright © 2020 黄中山. All rights reserved.
//

import Foundation

class PoSentinel {

    // MARK: - Properties
    private var _value: Int = 0

    private func _valuePtr() -> UnsafeMutablePointer<Int> {
        withUnsafeMutablePointer(to: &_value) { (ptr) -> UnsafeMutablePointer<Int> in
            return ptr
        }
    }

    // MARK: - Initializers
    init(value: Int = 0) {
        self._value = value
    }

    // MARK: - Public
    var value: Int {
        return _swift_stdlib_atomicLoadInt(object: _valuePtr())
    }

    @discardableResult
    func increase() -> Int {
        return _swift_stdlib_atomicFetchAddInt(object: _valuePtr(), operand: 1)
    }
}
