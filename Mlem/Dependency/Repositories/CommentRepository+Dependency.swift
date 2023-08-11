// 
//  CommentRepository+Dependency.swift
//  Mlem
//
//  Created by mormaer on 14/07/2023.
//  
//

import Dependencies

extension CommentRepository: DependencyKey {
  static let liveValue = CommentRepository()
}

extension DependencyValues {
  var commentRepository: CommentRepository {
    get { self[CommentRepository.self] }
    set { self[CommentRepository.self] = newValue }
  }
}
