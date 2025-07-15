//
//  LemmyPost+ActorIdentifiable.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19.
//

import Foundation

extension LemmyPost {
    var linkUrl: URL? { LemmyURL(string: url?.absoluteString ?? "")?.url }
    // var thumbnailImageUrl: URL? { LemmyURL(string: thumbnail_url)?.url }
    var thumbnailImageUrl: URL? { thumbnailUrl }
    
    var embed: PostEmbed? {
        if embedTitle != nil || embedDescription != nil || embedVideoUrl != nil {
            return .init(
                title: embedTitle,
                description: embedDescription,
                videoUrl: embedVideoUrl
            )
        }
        return nil
    }
}
