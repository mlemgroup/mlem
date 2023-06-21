//
//  API Post View - Post Type.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-14.
//

import Foundation

extension APIPostView {
    var postType: PostType {
        // image post--return image link
        if let postUrl = post.url, postUrl.isImage {
            return .image(postUrl)
        }
        
        // web post--return thumbnail link
        else if let thumbnailUrl = post.thumbnailUrl {
            return .link(thumbnailUrl)
        }
        
        // otherwise text, but post.body needs to be present, even if it's an empty string
        if let postBody = post.body {
            return .text(postBody)
        }
        
        return .titleOnly
    }
}
