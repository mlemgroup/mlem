//
//  Bool+Extensions.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-05-05.
//

extension Bool {
    public func or(_ other: Bool) -> Bool {
        self || other
    }
}

extension Bool: MergeableValue {
    public func merge(with other: Bool, using mergeType: ValueMergeType) -> Bool {
        switch mergeType {
        case .disjunctive: self || other
        case .conjunctive: self && other
        }
    }
}
