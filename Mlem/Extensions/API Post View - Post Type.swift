//
//  API Post View - Post Type.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-14.
//

import Foundation

extension APIPostView {
    var postType: PostType {
        // url types: either image or link
        #warning("TODO: is it safe to always use thumbnailURL here?")
        if let postURL = post.thumbnailUrl {
            return postURL.isImage ? .image(postURL) : .link(postURL)
        }
        
        // otherwise text, but post.body needs to be present, even if it's an empty string
        if let postBody = post.body {
            return .text(postBody)
        }
        
        return .titleOnly
    }
}
