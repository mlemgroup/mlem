//
//  FullyQualifiedLabelView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-19.
//

import Foundation
import MlemMiddleware
import SwiftUI

/// View for rendering fully qualified labels (i.e., user or community names)
struct FullyQualifiedLabelView: View {
    // these aren't used now but they will be for flairs
    @Environment(\.postContext) var postContext: (any Post1Providing)?
    @Environment(\.communityContext) var communityContext: (any Community3Providing)?
    
    let avatar: URL?
    let showAvatar: Bool
    let name: String?
    let instance: String?
    let instanceLocation: InstanceLocation
    
    var spacing: CGFloat
    var avatarSize: CGFloat
    
    init(entity: (any CommunityOrPersonStub & ProfileProviding)?, showAvatar: Bool, instanceLocation: InstanceLocation) {
        if instanceLocation == .bottom {
            self.spacing = AppConstants.largeAvatarSize
            self.avatarSize = AppConstants.largeAvatarSize
        } else {
            self.spacing = 8
            self.avatarSize = AppConstants.smallAvatarSize
        }
        self.instanceLocation = instanceLocation
        self.showAvatar = showAvatar

        self.avatar = entity?.avatar
        
        self.name = entity?.name
        self.instance = entity?.host
    }
    
    var body: some View {
        HStack {
            if showAvatar {
                AvatarView(url: avatar, type: .person)
                    .frame(width: avatarSize, height: avatarSize)
            }
            
            FullyQualifiedNameView(name: name, instance: instance, instanceLocation: instanceLocation)
            // FullyQualifiedNameView(name: nil, instance: nil, instanceLocation: .bottom)
        }
    }
    
    // TODO: flairs, comment context
    // the basic idea here is:
    //
    // if entity is PersonStubProviding:
    //   ContentLoader { person.flairs(contexts) }
    //
    // to compute bannedFromCommunity:
    //
    // if commentContext, commentContext is Comment2Providing: commentContext.creatorBannedFromCommunity
    // else if postContext, postContext is Post2Providing: postContext.creatorBannedFromCommunity
    //
    // since in a comment, both commentContext and postContext will be present--need to make sure above logic is implemented such that
    // postContext is only checked if commentContext isn't present, regardless of commentContext upgrade level
}
