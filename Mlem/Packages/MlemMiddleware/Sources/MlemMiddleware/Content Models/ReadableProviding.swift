//
//  ReadableProviding.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2024-12-04.
//

public protocol UnifiedReadableProviding {
    var read: ExpectedValue<Bool> { get }
}

// TODO: Full unified models remove
public protocol ReadableProviding {
    var read: Bool { get }
}
