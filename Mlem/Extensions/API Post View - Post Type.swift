//
//  API Post View - Post Type.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-14.
//

import Foundation

extension APIPostView {
    var postType: PostType {
        // post with URL: either image or link
        if let postUrl = post.url {
            // if image, return image link, otherwise return thumbnail
            return postUrl.isImage ? .image(postUrl) : .link(post.thumbnailUrl)
        }

        // otherwise text, but post.body needs to be present, even if it's an empty string
        if let postBody = post.body {
            return .text(postBody)
        }

        return .titleOnly
    }
}
