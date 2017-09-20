//
//  AnyEquatable.swift
//  AnyEquatable
//
//  Created by Rock Yang on 2017/9/19.
//  Copyright © 2017年 Rock Yang. All rights reserved.
//

import Foundation


public struct AnyEquatable : Equatable {
    
    private let _box: _AnyEquatableBox
    
    public var base: Any {
        return _box._base
    }
    
    fileprivate init() {
        fatalError()
    }
    
    public static func ==(lhs: AnyEquatable, rhs: AnyEquatable) -> Bool {
        return lhs._box._isEqual(to: rhs._box) ?? false
    }
}

protocol _AnyEquatableBox {
    
    var _base: Any { get }
    
    func _unbox<T>() -> T?
    
    func _isEqual(to: _AnyEquatableBox) -> Bool?
}

class _AnyEquatableBoxBase<Base> : _AnyEquatableBox {
    
    var _base: Any { return _baseEquatable }
    
    var _baseEquatable: Base
    
    init(_ base: Base) {
        self._baseEquatable = base
    }
    
    func _unbox<T>() -> T? {
        return (self as _AnyEquatableBox as? _AnyEquatableBoxBase<T>)?._baseEquatable
    }
    
    func _isEqual(to other: _AnyEquatableBox) -> Bool? {
        return false
    }
}

class _EquatableBox<T: Equatable> : _AnyEquatableBoxBase<T> {
    
    override func _isEqual(to other: _AnyEquatableBox) -> Bool? {
        if let otherValue: T = other._unbox() {
            return _baseEquatable == otherValue
        } else {
            return nil
        }
    }
}

extension AnyEquatable {
    
    public init<T: Equatable>(_ base: T) {
        self._box = _EquatableBox(base)
    }
}

private class _EqutableOptionalBox<T: Equatable> : _AnyEquatableBoxBase<Optional<T>> {
    
    override func _isEqual(to other: _AnyEquatableBox) -> Bool? {
        if let otherValue: Optional<T> = other._unbox() {
            return _baseEquatable == otherValue
        } else {
            return nil
        }
    }
}

extension AnyEquatable {
    
    public init<T: Equatable>(_ base: Optional<T>) {
        self._box = _EqutableOptionalBox(base)
    }
}

private class _EquatableArrayBox<T: Equatable> : _AnyEquatableBoxBase<Array<T>> {
    
    override func _isEqual(to other: _AnyEquatableBox) -> Bool? {
        if let otherValue: Array<T> = other._unbox() {
            return _baseEquatable == otherValue
        } else {
            return nil
        }
    }
}

extension AnyEquatable {
    
    init<T: Equatable>(_ base: Array<T>) {
        self._box = _EquatableArrayBox(base)
    }
}

private class _EquatableDictionaryBox<E: Hashable, T: Equatable> : _AnyEquatableBoxBase<Dictionary<E, T>> {
    
    override func _isEqual(to other: _AnyEquatableBox) -> Bool? {
        if let otherValue: Dictionary<E, T> = other._unbox() {
            return _baseEquatable == otherValue
        } else {
            return nil
        }
    }
}

extension AnyEquatable {
    
    init<E, T: Equatable>(_ base: Dictionary<E, T>) {
        self._box = _EquatableDictionaryBox(base)
    }
}


private class _EqutableSetBox<E: Hashable> : _AnyEquatableBoxBase<Set<E>> {
    
    override func _isEqual(to other: _AnyEquatableBox) -> Bool? {
        if let otherValue: Set<E> = other._unbox() {
            return _baseEquatable == otherValue
        } else {
            return nil
        }
    }
}

extension AnyEquatable {
    
    init<E>(_ base: Set<E>) {
        self._box = _EqutableSetBox<E>(base)
    }
}

private class _AnyObjectBox<T: AnyObject> : _AnyEquatableBoxBase<T> {
    
    override func _isEqual(to other: _AnyEquatableBox) -> Bool? {
        if let otherValue: T = other._unbox() {
            return _baseEquatable === otherValue
        } else {
            return nil
        }
    }
}

extension AnyEquatable {
    
    init<T: AnyObject>(_ base: T) {
        self._box = _AnyObjectBox(base)
    }
    
    init<T: AnyObject & Equatable>(_ base: T) {
        self._box = _EqutableOptionalBox(base)
    }
}
