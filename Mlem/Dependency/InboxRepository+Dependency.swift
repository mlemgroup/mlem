//
//  InboxRepository+Dependency.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-09-23.
//
import Dependencies
import Foundation

extension InboxRepository: DependencyKey {
    static let liveValue = InboxRepository()
}

extension DependencyValues {
    var inboxRepository: InboxRepository {
        get { self[InboxRepository.self] }
        set { self[InboxRepository.self] = newValue }
    }
}
