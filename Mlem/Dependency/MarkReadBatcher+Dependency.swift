//
//  MarkReadBatcher+Dependency.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-09.
//

import Dependencies
import Foundation

extension MarkReadBatcher: DependencyKey {
    static let liveValue = MarkReadBatcher()
}

extension DependencyValues {
    var markReadBatcher: MarkReadBatcher {
        get { self[MarkReadBatcher.self] }
        set { self[MarkReadBatcher.self] = newValue }
    }
}
