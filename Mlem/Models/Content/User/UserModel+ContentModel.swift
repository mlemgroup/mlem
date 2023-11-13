//
//  UserModel+ContentModel.swift
//  Mlem
//
//  Created by Sjmarf on 07/10/2023.
//

import Foundation

extension UserModel: ContentModel {
    var uid: ContentModelIdentifier { .init(contentType: .user, contentId: userId) }
    var imageUrls: [URL] {
        if let url = avatar {
            return [url.withIconSize(128)]
        }
        return []
    }
    var searchResultScore: Int {
        if let commentCount, let postCount {
            let result = commentCount / 4 + postCount
            return Int(result)
        }
        return 0
    }
}
