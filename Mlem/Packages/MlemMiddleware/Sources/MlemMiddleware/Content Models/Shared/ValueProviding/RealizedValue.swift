//
//  RealizedValue.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-02-25.
//

public struct RealizedValue<T>: RealizedValueProviding {
    private let value_: T
    public var value: T? { value_ }
    public var realizedValue: T { value_ }
    
    public init(_ value: T) {
        self.value_ = value
    }
}
