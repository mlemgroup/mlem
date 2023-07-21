// 
//  APIClient+Dependency.swift
//  Mlem
//
//  Created by mormaer on 14/07/2023.
//  
//

import Dependencies

extension APIClient: DependencyKey {
  static let liveValue = APIClient()
}

extension DependencyValues {
  var apiClient: APIClient {
    get { self[APIClient.self] }
    set { self[APIClient.self] = newValue }
  }
}
