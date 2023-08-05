//
//  PostRepository+Dependency.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-31.
//

import Foundation
import Dependencies

extension PostRepository: DependencyKey {
  static let liveValue = PostRepository()
}

extension DependencyValues {
  var postRepository: PostRepository {
    get { self[PostRepository.self] }
    set { self[PostRepository.self] = newValue }
  }
}
