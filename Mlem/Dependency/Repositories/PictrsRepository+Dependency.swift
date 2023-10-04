//
//  PictrsRepository+Dependency.swift
//  Mlem
//
//  Created by Sjmarf on 29/09/2023.
//

import Dependencies
import Foundation

extension PictrsRespository: DependencyKey {
    static let liveValue = PictrsRespository()
}

extension DependencyValues {
    var pictrsRepository: PictrsRespository {
        get { self[PictrsRespository.self] }
        set { self[PictrsRespository.self] = newValue }
    }
}
