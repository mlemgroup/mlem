//
//  MaybePresent.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2026-11-05.
//

public enum MaybePresent<Value> {
    case some(Value)
    case none
    case notProvided
    
    public init(_ value: Value?) {
        if let value {
            self = .some(value)
        } else {
            self = .none
        }
    }
    
    public var value: Value? {
        switch self {
        case let .some(value): value
        case .none, .notProvided: nil
        }
    }
    
    public var isProvided: Bool {
        switch self {
        case .some, .none: true
        case .notProvided: false
        }
    }
}

extension MaybePresent: Equatable where Value: Equatable {}
extension MaybePresent: Hashable where Value: Hashable {}
extension MaybePresent: Sendable where Value: Sendable {}
