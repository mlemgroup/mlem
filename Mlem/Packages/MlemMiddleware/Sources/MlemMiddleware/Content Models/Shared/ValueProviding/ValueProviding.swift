//
//  Untitled.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-02-25.
//

/// Protocol for when you may have a realized value and may have an ExpectedValue (e.g., ReportEditorView)
public protocol ValueProviding<T> {
    associatedtype T
    
    var value: T? { get }
}

/// Protocol for when you have a realized value that you may need to treat interchangeably with a ValueProviding.
public protocol RealizedValueProviding<T>: ValueProviding {
    var realizedValue: T { get }
}
