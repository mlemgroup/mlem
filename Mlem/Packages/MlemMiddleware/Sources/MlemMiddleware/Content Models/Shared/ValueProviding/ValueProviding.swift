//
//  Untitled.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-02-25.
//

/// Represents any member of the value providing family
public protocol ValueProviding<T> {
    associatedtype T
    
    var value: T? { get }
}

/// Represents a value that is guaranteed to be realized, but may need to be treated interchangeably with
/// other `ValueProviding`s
public protocol RealizedValueProviding<T>: ValueProviding {
    var realizedValue: T { get }
    
    // NOTE: while value_ is currently always T (not T?), so could theoretically be directly exposed as `T { get set }`,
    // it is intentionally obscured behind this setter for extensibility
    func set(_ newValue: T)
}
