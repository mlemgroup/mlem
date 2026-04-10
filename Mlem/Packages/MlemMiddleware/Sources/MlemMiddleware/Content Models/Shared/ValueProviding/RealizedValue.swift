//
//  RealizedValue.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-02-25.
//

import Observation

@Observable
public class RealizedValue<T>: RealizedValueProviding {
    private var value_: T
    public var value: T? { value_ }
    public var realizedValue: T { value_ }
    
    public init(_ value: T) {
        self.value_ = value
    }
    
    public func set(_ newValue: T) {
        value_ = newValue
    }
}
