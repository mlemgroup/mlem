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
    @Environment(Palette.self) var palette
    @Environment(AppState.self) var appState
    @Environment(\.postContext) var postContext: (any Post1Providing)?
    @Environment(\.commentContext) var commentContext: (any Comment1Providing)?
    @Environment(\.communityContext) var communityContext: (any Community1Providing)?
    @Environment(\.feedContext) var feedContext: FeedContext?

    @Setting(\.showSubscribedStatus) var showSubscribedStatus
    
    let entity: (any CommunityOrPersonStub & Profile1Providing)?
    let labelStyle: FullyQualifiedLabelStyle
    var showAvatar: Bool = true
    var showInstance: Bool = true
    let blurred: Bool
    
    var showSubscriptionIndicator: Bool {
        guard showSubscribedStatus,
              let userSession = appState.firstSession as? UserSession,
              let communityId = postContext?.communityId,
              let feedContextShowsIndicator = feedContext?.showSubscriptionIndicator else {
            return false
        }
        
        let subscribedToCommunity: Bool = userSession.subscriptions.communityIds.contains(communityId)
        
        return subscribedToCommunity && feedContextShowsIndicator
    }
    
    @ScaledMetric(relativeTo: .body) var subscriptionIndicatorSize: CGFloat = 8.0
    
    var fallback: FixedImageView.Fallback {
        if entity is any CommunityStubProviding {
            return .community
        }
        if entity is any PersonStubProviding || entity is UserAccount {
            return .person
        }
        return .image
    }
    
    var body: some View {
        HStack(spacing: 7) {
            if showAvatar {
                CircleCroppedImageView(
                    url: entity?.avatar?.withIconSize(labelStyle.avatarResolution),
                    frame: labelStyle.avatarSize,
                    fallback: fallback,
                    showProgress: false,
                    blurred: blurred
                )
            }
            
            HStack(spacing: 4) {
                if showSubscriptionIndicator {
                    Image(systemName: Icons.present)
                        .font(.system(size: subscriptionIndicatorSize))
                        .foregroundStyle(palette.secondary)
                        .padding(.bottom, 2)
                }
                
                FullyQualifiedNameView(
                    name: entity?.name,
                    instance: entity?.host,
                    instanceLocation: showInstance ? labelStyle.instanceLocation : .disabled,
                    prependedText: flairs.textView
                )
            }
            .imageScale(.small)
            .offset(y: 1)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
    }
    
    var flairs: [PersonFlair] {
        guard let person = entity as? any Person else { return [] }
        return person.flairs(
            interactableContext: interactableContext,
            communityContext: communityContext
        )
    }
    
    var interactableContext: (any Interactable2Providing)? {
        guard let person = entity as? any Person else { return nil }
        if let commentContext2 = commentContext as? any Comment2Providing, commentContext2.creator.actorId == person.actorId {
            return commentContext2
        }
        if let postContext2 = postContext as? any Post2Providing, postContext2.creator.actorId == person.actorId {
            return postContext2
        }
        return nil
    }
    
    var accessibilityLabel: String {
        guard let entity, let fullName = entity.fullName else { return String(localized: "Loading...") }
        let flairs = flairs
        if !flairs.isEmpty {
            return "\(fullName), " + flairs.map { String(localized: $0.label) }.joined(separator: ", ")
        }
        return fullName
    }
}
