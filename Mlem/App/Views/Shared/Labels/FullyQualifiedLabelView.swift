//
//  FullyQualifiedLabelView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-19.
//

import Foundation
import MlemMiddleware
import SwiftUI

enum FullyQualifiedLabelStyle {
    case small
    case medium
    case large
    
    var avatarSize: CGFloat {
        switch self {
        case .small: AppConstants.smallAvatarSize
        case .medium: AppConstants.mediumAvatarSize
        case .large: AppConstants.largeAvatarSize
        }
    }
    
    var instanceLocation: InstanceLocation {
        switch self {
        case .small: .trailing
        case .medium: .trailing
        case .large: .bottom
        }
    }
}

/// View for rendering fully qualified labels (i.e., user or community names)
struct FullyQualifiedLabelView: View {
    // these aren't used now but they will be for flairs
    @Environment(\.postContext) var postContext: (any Post1Providing)?
    @Environment(\.communityContext) var communityContext: (any Community1Providing)?
  
    let entity: (any CommunityOrPersonStub & Profile2Providing)?
    let labelStyle: FullyQualifiedLabelStyle
    let showAvatar: Bool
    
    var body: some View {
        HStack {
            if showAvatar {
                AvatarView(url: entity?.avatar, type: .person)
                    .frame(width: labelStyle.avatarSize, height: labelStyle.avatarSize)
            }
            
            FullyQualifiedNameView(name: entity?.name, instance: entity?.host, instanceLocation: labelStyle.instanceLocation)
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
