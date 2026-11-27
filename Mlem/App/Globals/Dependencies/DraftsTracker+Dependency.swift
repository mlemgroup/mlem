//
//  DraftsTracker+Dependency.swift
//  Mlem
//
//  Created by Eric Andrews on 2026-11-25.
//

import Dependencies

extension DraftsTracker: DependencyKey {
    static let liveValue: DraftsTracker = .init()
}

extension DependencyValues {
    var draftsTracker: DraftsTracker {
        get { self[DraftsTracker.self] }
        set { self[DraftsTracker.self] = newValue }
    }
}
