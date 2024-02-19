//
//  APIPost+ActorIdentifiable.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19.
//

import Foundation

extension APIPost: ActorIdentifiable, Identifiable {
    var actorId: URL { ap_id }
}

extension APIPost {
    var linkUrl: URL? { LemmyURL(string: url)?.url }
    // var thumbnailImageUrl: URL? { LemmyURL(string: thumbnail_url)?.url }
    var thumbnailImageUrl: URL? { thumbnail_url }
}
