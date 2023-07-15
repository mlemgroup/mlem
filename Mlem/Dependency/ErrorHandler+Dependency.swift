// 
//  ErrorHandler+Dependency.swift
//  Mlem
//
//  Created by mormaer on 15/07/2023.
//  
//

import Dependencies

extension ErrorHandler: DependencyKey {
  static let liveValue = ErrorHandler()
}

extension DependencyValues {
  var errorHandler: ErrorHandler {
    get { self[ErrorHandler.self] }
    set { self[ErrorHandler.self] = newValue }
  }
}
