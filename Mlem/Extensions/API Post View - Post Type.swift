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
        if let postURL = post.url {
            return postURL.isImage ? .image : .link
        }
        
        // otherwise text, but post.body needs to be present, even if it's an empty string
        if post.body != nil {
            return .text
        }
        
        print ("Unknown post type encountered! postView: \(self)")
        return .error
    }
}
