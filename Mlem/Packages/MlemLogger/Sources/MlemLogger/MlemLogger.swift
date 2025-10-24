//
//  MlemLogger.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-10-24.
//

import os

public extension Logger {
    static func mlemLogger(subsystem: String, file: String = #fileID) -> Logger {
        Logger(subsystem: subsystem, category: file)
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
