//
//  Notifier+Dependency.swift
//  Mlem
//
//  Created by mormaer on 23/07/2023.
//
//

import Dependencies

extension Notifier: DependencyKey {
    static let liveValue = Notifier(display: { await NotificationDisplayer.display($0) })
}

extension DependencyValues {
    var notifier: Notifier {
        get { self[Notifier.self] }
        set { self[Notifier.self] = newValue }
    }
}
