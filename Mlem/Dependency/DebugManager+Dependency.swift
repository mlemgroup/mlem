//
//  DebugManager+Dependency.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-11-18.
//

import Dependencies
import Foundation

extension DebugManager: DependencyKey {
    static let liveValue = DebugManager()
}

extension DependencyValues {
    var debugManager: DebugManager {
        get { self[DebugManager.self] }
        set { self[DebugManager.self] = newValue }
    }
}
