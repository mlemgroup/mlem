// 
//  CommunityRepository+Dependency.swift
//  Mlem
//
//  Created by mormaer on 27/07/2023.
//  
//

import Dependencies

extension CommunityRepository: DependencyKey {
  static let liveValue = CommunityRepository()
}

extension DependencyValues {
  var communityRepository: CommunityRepository {
    get { self[CommunityRepository.self] }
    set { self[CommunityRepository.self] = newValue }
  }
}
