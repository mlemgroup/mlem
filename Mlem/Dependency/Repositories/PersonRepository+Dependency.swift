//
//  PersonRepository+Dependency.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-26.
//

import Foundation
import Dependencies

extension PersonRepository: DependencyKey {
  static let liveValue = PersonRepository()
}

extension DependencyValues {
  var personRepository: PersonRepository {
    get { self[PersonRepository.self] }
    set { self[PersonRepository.self] = newValue }
  }
}
