//
//  InstanceModel+ContentModel.swift
//  Mlem
//
//  Created by Sjmarf on 22/01/2024.
//

import Foundation

extension InstanceModel: ContentModel {
    var uid: ContentModelIdentifier { .init(contentType: .instance, contentId: name.hash) }
    var imageUrls: [URL] {
        if let url = avatar {
            return [url.withIconSize(128)]
        }
        return []
    }
    var searchResultScore: Int { self.userCount ?? 0 }
}
