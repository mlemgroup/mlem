//
//  CommunityModel+ContentModel.swift
//  Mlem
//
//  Created by Sjmarf on 22/10/2023.
//

import Foundation

extension CommunityModel: ContentModel {
    var uid: ContentModelIdentifier { .init(contentType: .community, contentId: communityId) }
    var imageUrls: [URL] {
        if let url = avatar {
            return [url.withIcon64Parameters]
        }
        return []
    }
    var searchResultScore: Int { self.subscriberCount ?? 0 }
}
