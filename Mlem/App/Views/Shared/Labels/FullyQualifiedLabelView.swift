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
        case .small: Constants.main.smallAvatarSize
        case .medium: Constants.main.mediumAvatarSize
        case .large: Constants.main.largeAvatarSize
        }
    }
    
    var avatarResolution: Int {
        switch self {
        case .small: 32
        case .medium: 64
        case .large: 96
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
  
    let entity: (any CommunityOrPersonStub & Profile1Providing)?
    let labelStyle: FullyQualifiedLabelStyle
    let showAvatar: Bool
    
    var fallback: FixedImageView.Fallback {
        if entity is any CommunityStubProviding {
            return .community
        }
        if entity is any PersonStubProviding {
            return .person
        }
        return .image
    }
    
    var body: some View {
        HStack {
            if showAvatar {
                CircleCroppedImageView(
                    url: entity?.avatar?.withIconSize(labelStyle.avatarResolution),
                    fallback: fallback,
                    showProgress: false
                )
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
