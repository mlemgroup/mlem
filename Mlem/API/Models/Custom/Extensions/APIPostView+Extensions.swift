//
//  ApiPostView+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19.
//

import Foundation

extension ApiPostView: ActorIdentifiable, Identifiable {
    var actorId: URL { post.apId }
    var id: Int { post.id }
}
