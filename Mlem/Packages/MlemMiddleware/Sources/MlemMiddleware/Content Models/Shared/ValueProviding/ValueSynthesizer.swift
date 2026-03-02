//
//  ValueSynthesizer.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-02-25.
//

import Foundation

public enum ValueMergeType {
    /// Indicates value should be true when any merged value is true
    case disjunctive
    
    /// Indicates value should be true only when all merged values are true
    case conjunctive
}

public protocol MergeableValue: Equatable {
    /// Merges self with other using the given merge type.
    /// - Returns: result of the merged value
    func merge(with other: Self, using mergeType: ValueMergeType) -> Self
}

// Allows optionals to be used as MergeableValue
extension Optional: MergeableValue where Wrapped: MergeableValue & Equatable {
    /// If both self and other are present, returns the result of merging them; otherwise returns whichever value is present,
    /// and nil if both are nil.
    public func merge(with other: Optional<Wrapped>, using mergeType: ValueMergeType) -> Optional<Wrapped> {
        if let other {
            return self?.merge(with: other, using: mergeType)
        }
        return self
    }
}

/// Provides methods for tracking sibling `ValueSynthesizer`s. When `synthesize()` is called, all sibling values
/// are accumulated into a single result according to the specified `mergeType`
@Observable
public class ValueSynthesizer<T: MergeableValue> {
    internal let uid: NSUUID = .init()
    internal let mergeType: ValueMergeType
    
    // using NSMapTable to store weak references
    internal var siblings: NSMapTable<NSUUID, ValueSynthesizer> = .weakToWeakObjects()
    
    public var value_: T
    
    public init(value: T, mergeType: ValueMergeType) {
        self.value_ = value
        self.mergeType = mergeType
    }
    
    internal func synthesize() -> T {
        siblings.dictionaryRepresentation().values.reduce(value_) { result, sibling in
            result.merge(with: sibling.value_, using: mergeType)
        }
    }
    
    public func addSibling(_ sibling: ValueSynthesizer) {
        siblings.setObject(sibling, forKey: sibling.uid)
    }
    
    public func removeSibling(_ sibling: ValueSynthesizer) {
        siblings.removeObject(forKey: sibling.uid)
    }
}
