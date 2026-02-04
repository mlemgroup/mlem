//
//  ExpectedValue.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-01-07.
//

/// Represents a value that a model can have, but might not currently be fetched if the model was instantiated
/// with a low-tier snapshot.
public struct ExpectedValue<T>: ValueProviding {
    public var value_: T?
    
    /// Provides the value, or nil if the value is not present
    public var value: T? {
        get {
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
        provideValue: { assertionFailure("This should be overridden") })
}

/// ValueProviding wrapper for values that are guaranteed to be present
public struct RealizedValue<T>: ValueProviding {
    private let value_: T
    public var value: T? { value_ }
    
    public init(_ value: T) {
        self.value_ = value
    }
}

/// Protocol for when you may have a realized value and may have an ExpectedValue (e.g., ReportEditorView)
public protocol ValueProviding<T> {
    associatedtype T
    
    var value: T? { get }
}
