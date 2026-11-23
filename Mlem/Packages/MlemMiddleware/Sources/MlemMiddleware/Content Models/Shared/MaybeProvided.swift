//
//  MaybeProvided.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2026-11-05.
//

public enum MaybeProvided<Value> {
    case some(Value)
    case none
    case notProvided
    
    public static func fromOptional(_ value: Value?) -> Self {
        if let value {
            return .some(value)
        } else {
            return .none
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

extension MaybeProvided: Equatable where Value: Equatable {}
extension MaybeProvided: Hashable where Value: Hashable {}
extension MaybeProvided: Sendable where Value: Sendable {}
