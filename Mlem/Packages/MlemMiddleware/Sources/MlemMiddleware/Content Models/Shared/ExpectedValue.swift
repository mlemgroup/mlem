//
//  ExpectedValue.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-01-07.
//

import os

import Foundation

/// Represents a value that a model can have, but might not currently be fetched if the model was instantiated
/// with a low-tier snapshot.
public struct ExpectedValue<T>: ValueProviding {
    public var value_: T?
    
    /// Provides the value, or nil if the value is not present
    public var value: T? {
        if let ret = value_ { return ret }
        Task {
            do {
                try await provideValue()
            } catch {
                print(error)
            }
        }
        return nil
    }
    
    /// Callback expected to update value_
    let provideValue: () async throws -> Void
    
    init(value: T?, provideValue: @escaping () async throws -> Void) {
        self.value_ = value
        self.provideValue = provideValue
    }
}

/// ValueProviding wrapper for values that are guaranteed to be present
public struct RealizedValue<T>: ValueProviding {
    private let value_: T
    public var value: T? { value_ }
    
    public init(_ value: T) {
        self.value_ = value
    }
}

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

/// Value that synthesizes multiple values from multiple sources
@Observable
public class SyntheticExpectedValue<T: NewMergeableValue>: ValueProviding {
    private let uid: NSUUID = .init()
    private let mergeType: ValueMergeType
    
    // using NSMapTable to store weak references
    private var siblings: NSMapTable<NSUUID, SyntheticExpectedValue> = .weakToWeakObjects()
    
    public var value_: T?
    public var value: T? {
        if value_ == nil {
            Task {
                do {
                    try await provideValue()
                } catch {
                    print(error)
                }
            }
        }
        return siblings.dictionaryRepresentation().values.reduce(value_) { result, sibling in
            if let result {
                if let siblingValue = sibling.value {
                    return result.merge(with: siblingValue, using: mergeType)
                }
                return result
            }
            return sibling.value
        }
    }
    
    /// Callback expected to update value_
    let provideValue: () async throws -> Void
    
    init(value: T?, provideValue: @escaping () async throws -> Void, mergeType: ValueMergeType) {
        self.value_ = value
        self.provideValue = provideValue
        self.mergeType = mergeType
    }
    
    public func addSibling(_ sibling: SyntheticExpectedValue) {
        siblings.setObject(sibling, forKey: sibling.uid)
    }
    
    public func removeSibling(_ sibling: SyntheticExpectedValue) {
        siblings.removeObject(forKey: sibling.uid)
    }
}

/// Protocol for when you may have a realized value and may have an ExpectedValue (e.g., ReportEditorView)
public protocol ValueProviding<T> {
    associatedtype T
    
    var value: T? { get }
}

// Dummy inits

func dummyExpectedValue<T>(_ value: T?) -> ExpectedValue<T> {
    .init(
        value: value,
        provideValue: { assertionFailure("Dummy function! This should not be called") })
}

func dummySyntheticExpectedValue<T>(_ value: T?) -> SyntheticExpectedValue<T> {
    .init(
        value: value,
        provideValue: { assertionFailure("Dummy function! This should not be called") },
        mergeType: .disjunctive)
}
