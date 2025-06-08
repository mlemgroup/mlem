//
//  File.swift
//  Haptics
//
//  Created by Sjmarf on 2025-05-28.
//

import Foundation

public enum HapticError: Error, CustomStringConvertible {
    case failedToStartEngine(Error)
    case failedToStartPlayer(Error)
    case failedToMakePlayer(Error)
    case noPlayer(Haptic)
    
    public var description: String {
        switch self {
        case let .failedToStartEngine(error):
            "HapticManager engine failed to start. Underlying error: \(String(describing: error))"
        case let .failedToStartPlayer(error):
            "HapticManager player failed to start. Underlying error: \(String(describing: error))"
        case let .failedToMakePlayer(error):
            "HapticManager failed to make player. Underlying error: \(String(describing: error))"
        case let .noPlayer(haptic):
            "No player available for \(haptic.rawValue)"
        }
    }
}
