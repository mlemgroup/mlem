//
//  SyntheticExpectedValue.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-02-26.
//

import Observation

@Observable
public class SyntheticExpectedValue<T: MergeableValue>: ValueSynthesizer<T?>, ValueProviding {
    /// Callback expected to update value_
    let provideValue: () async throws -> Void
    
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
        return synthesize()
    }
    
    init(value: T?, provideValue: @escaping () async throws -> Void, mergeType: ValueMergeType) {
        self.provideValue = provideValue
        super.init(value: value, mergeType: mergeType)
    }
}

func dummySyntheticExpectedValue<T>(_ value: T?) -> SyntheticExpectedValue<T> {
    .init(
        value: value,
        provideValue: { assertionFailure("Dummy function! This should not be called") },
        mergeType: .disjunctive)
}
