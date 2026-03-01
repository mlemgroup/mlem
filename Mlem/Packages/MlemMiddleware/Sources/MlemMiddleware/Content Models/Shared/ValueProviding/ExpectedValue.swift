//
//  ExpectedValue.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-01-07.
//

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

func dummyExpectedValue<T>(_ value: T?) -> ExpectedValue<T> {
    .init(
        value: value,
        provideValue: { assertionFailure("Dummy function! This should not be called") })
}
