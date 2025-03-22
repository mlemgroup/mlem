//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-02-25.
//  

import Foundation
import Nuke

extension Post2: ImagePrefetchProviding {
    public func imageRequests(configuration config: PrefetchingConfiguration) async -> [ImageRequest] {
        var ret: [ImageRequest] = await post1.imageRequests(configuration: config)
        
        // preload user and community avatars--fetching both because we don't know which we'll need, but these are super tiny
        // so it's probably not an API crime, right?
        if let avatarSize = config.avatarSize {
            if let communityAvatarLink = community.avatar {
                ret.append(ImageRequest(urlRequest: mlemUrlRequest(url: communityAvatarLink.withIconSize(avatarSize))))
            }
            
            if let userAvatarLink = creator.avatar {
                ret.append(ImageRequest(urlRequest: mlemUrlRequest(url: userAvatarLink.withIconSize(avatarSize))))
            }
        }
        
        return ret
    }
}
