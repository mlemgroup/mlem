//
//  PrivateMessageRepository+Dependency.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-09-23.
//
import Dependencies
import Foundation

extension MessageRepository: DependencyKey {
    static let liveValue = MessageRepository()
}

extension DependencyValues {
    var messageRepository: MessageRepository {
        get { self[MessageRepository.self] }
        set { self[MessageRepository.self] = newValue }
    }
}
