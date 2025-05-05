//
//  SyntheticStateManager.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-05-04.
//

import Foundation

public enum StateManagerMergeType {
    /// Indicates displayedValue should be true when any merged value is true
    case disjunctive
    
    /// Indicates displayedValue should be true only when all merged values are true
    case conjunctive
}

public protocol MergeableValue: Equatable {
    /// Merges self with other using the given merge type.
    /// - Returns: result of the merged value
    func merge(with other: Self, using mergeType: StateManagerMergeType) -> Self
}

public class SyntheticStateManager<Value: MergeableValue>: StateManager<Value> {
    private let uid: UUID = .init()
    private let mergeType: StateManagerMergeType
    
    // TODO: use NSMapTable to store weak references
    private var siblings: [UUID: SyntheticStateManager] = .init()
    
    override public var displayedValue: Value {
        siblings.values.reduce(wrappedValue, { result, sibling in
            result.merge(with: sibling.wrappedValue, using: mergeType)
        })
    }
    
    init(
        wrappedValue: Value,
        mergeType: StateManagerMergeType,
        onSet: @escaping (Value, _ type: StateManagerUpdateType, _ semaphore: UInt?) -> Void = { _, _, _ in },
        onVerify: @escaping (Value, _ semaphore: UInt?) -> Void = { _, _ in }
    ) {
        self.mergeType = mergeType
        
        super.init(wrappedValue: wrappedValue, onSet: onSet, onVerify: onVerify)
    }
    
    public func addSibling(_ sibling: SyntheticStateManager) {
        siblings[sibling.uid] = sibling
    }
    
    public func removeSibling(_ sibling: SyntheticStateManager) {
        siblings.removeValue(forKey: sibling.uid)
    }
}
