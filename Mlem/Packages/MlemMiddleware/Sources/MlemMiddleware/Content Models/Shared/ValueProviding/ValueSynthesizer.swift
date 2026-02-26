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

public protocol NewMergeableValue: Equatable {
    /// Merges self with other using the given merge type.
    /// - Returns: result of the merged value
    func merge(with other: Self, using mergeType: ValueMergeType) -> Self
}

// extends Optional to be NewMergeableValue if wrapped value is NewMergeableValue
extension Optional: NewMergeableValue where Wrapped: NewMergeableValue & Equatable {
    public func merge(with other: Optional<Wrapped>, using mergeType: ValueMergeType) -> Optional<Wrapped> {
        return self.map { value in
            return other.map { otherValue in
                return value.merge(with: otherValue, using: mergeType)
            } ?? value
        } ?? other
    }
}

@Observable
public class ValueSynthesizer<T: NewMergeableValue> {
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
