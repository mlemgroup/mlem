//
//  Post1Providing+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-04-29.
//

import Foundation
import MlemMiddleware

extension Post1Providing {
    var postType: PostType {
        // post with URL: either image or link
        if let linkUrl {
            // if image, return image link, otherwise return thumbnail
            return linkUrl.isImage ? .image(linkUrl) : .link(thumbnailUrl)
        }

        // otherwise text, but post.body needs to be present, even if it's an empty string
        if let postBody = content {
            return .text(postBody)
        }

        return .titleOnly
    }
    
    var menuActions: ActionGroup {
        ActionGroup(children: [
            ActionGroup(
                children: [upvoteAction, downvoteAction]
            ),
            saveAction
        ])
    }
}
