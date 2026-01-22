//
//  Bool+Extensions.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-05-05.
//

extension Bool: MergeableValue {
    public func merge(with other: Bool, using mergeType: StateManagerMergeType) -> Bool {
        switch mergeType {
        case .disjunctive: self || other
        case .conjunctive: self && other
        }
    }
    
    public func or(_ other: Bool) -> Bool {
        self || other
    }
}
