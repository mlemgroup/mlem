// 
//  HapticManager+Dependency.swift
//  Mlem
//
//  Created by mormaer on 18/07/2023.
//  
//

import Dependencies

extension HapticManager: DependencyKey {
  static let liveValue = HapticManager()
}

extension DependencyValues {
  var hapticManager: HapticManager {
    get { self[HapticManager.self] }
    set { self[HapticManager.self] = newValue }
  }
}
