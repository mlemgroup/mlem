//
//  SavedAccountTracker+Dependency.swift
//  Mlem
//
//  Created by mormaer on 26/08/2023.
//
//

import Dependencies
import Foundation

extension SavedAccountTracker: DependencyKey {
    static let liveValue = SavedAccountTracker()
}

extension DependencyValues {
    var accountsTracker: SavedAccountTracker {
        get { self[SavedAccountTracker.self] }
        set { self[SavedAccountTracker.self] = newValue }
    }
}
