//
//  PrivateMessageRepository+Dependency.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-09-23.
//

import Dependencies
import Foundation

extension PrivateMessageRepository: DependencyKey {
    static let liveValue = PrivateMessageRepository()
}

extension DependencyValues {
    var privateMessageRepository: PrivateMessageRepository {
        get { self[PrivateMessageRepository.self] }
        set { self[PrivateMessageRepository.self] = newValue }
    }
}
