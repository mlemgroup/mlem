//
//  PersistenceRepository+Dependency.swift
//  Mlem
//
//  Created by mormaer on 26/07/2023.
//
//

import Dependencies
import Foundation

extension PersistenceRepository: DependencyKey {
    static let liveValue = PersistenceRepository(keychainAccess: { Constants.main.keychain[$0] })
}

extension DependencyValues {
    var persistenceRepository: PersistenceRepository {
        get { self[PersistenceRepository.self] }
        set { self[PersistenceRepository.self] = newValue }
    }
}
