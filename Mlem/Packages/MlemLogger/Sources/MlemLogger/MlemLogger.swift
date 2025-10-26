//
//  MlemLogger.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-10-24.
//

import os

public extension Logger {
    static func mlemLogger(file: String = #file) -> Logger {
        let splitFile = file.split(separator: "/")
        return Logger(subsystem: String(splitFile.first ?? "Unknown"), category: String(splitFile.last ?? "Unknown"))
    }
    
    /// Singleton logger to be used ONLY where access to a relevant specific logger is not available. Use of
    /// this logger is discouraged except where absolutely necessary. Ensure any messages sent to this logger
    /// contain enough contextual information to determine their source.
    static let universal: Logger = Logger(subsystem: "Universal", category: "Logger")
    
    #if DEBUG
    /// Singleton logger for temporary development logs.
    /// - Warning: by design, release builds will fail if any messages to this logger are present
    static let dev: Logger = Logger(subsystem: "Dev", category: "Logger")
    #endif
}
