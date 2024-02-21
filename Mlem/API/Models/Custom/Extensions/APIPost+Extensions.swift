//
//  ApiPost+ActorIdentifiable.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19.
//

import Foundation

extension ApiPost: ActorIdentifiable, Identifiable {
    var actorId: URL { apId }
}

extension ApiPost {
    var linkUrl: URL? { LemmyURL(string: url)?.url }
    // var thumbnailImageUrl: URL? { LemmyURL(string: thumbnail_url)?.url }
    var thumbnailImageUrl: URL? { thumbnailUrl }
}
