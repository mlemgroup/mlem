//
//  ExpectedValue.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-01-07.
//

/// Represents a value that a model can have, but might not currently be fetched if the model was instantiated
/// with a low-tier snapshot.
public class ExpectedValue<T> {
    /// Provides the value, or nil if the value is not present
    let getValue: () -> T?
    
    /// When called, updates the value provider (i.e., what getValue() reads from) to include this value.
    let provideValue: () async throws -> Void
    
    /// Provides the value currently stored in this ExpectedValue. If the value is not present,
    /// it is automatically fetched
    public var value: T? {
        get {
            if let ret = getValue() { return ret }
            Task {
                do {
                    try await provideValue()
                } catch {
                    print(error)
                }
            }
            return nil
        }
    }
    
    /// Provides the value currently stored in this ExpectedValue. DOES NOT automatically fetch
    /// if the value is not present. 
    public var value_: T? { getValue() }
    
    init(getValue: @escaping () -> T?, provideValue: @escaping () async throws -> Void) {
        self.getValue = getValue
        self.provideValue = provideValue
    }
}
