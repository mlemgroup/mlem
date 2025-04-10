//
//  FullyQualifiedLabelView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-19.
//

import Foundation
import MlemMiddleware
import SwiftUI

enum FullyQualifiedLabelStyle: CaseIterable {
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
    typealias Entity = CommunityOrPerson & Profile1Providing
    
    @Environment(AppState.self) var appState
    @Environment(\.postContext) var postContext: (any Post1Providing)?
    @Environment(\.commentContext) var commentContext: (any Comment1Providing)?
    @Environment(\.communityContext) var communityContext: (any Community1Providing)?
    @Environment(\.feedContext) var feedContext: FeedContext?

    @Setting(\.post_showSubscribedStatus) var showSubscribedStatus
    @Setting(\.person_showAvatar) var showPersonAvatar
    @Setting(\.community_showAvatar) var showCommunityAvatar
    
    let entity: (any Entity)?
    let avatarFallback: MediaView.Fallback
    let labelStyle: FullyQualifiedLabelStyle
    var showAvatar: Bool?
    var showInstance: Bool = true
    var blurred: Bool = false
    
    var shouldShowAvatar: Bool {
        if let showAvatar { return showAvatar }
        
        if entity is any CommunityStubProviding {
            return showCommunityAvatar
        } else {
            return showPersonAvatar
        }
    }
    
    var showSubscriptionIndicator: Bool {
        guard showSubscribedStatus,
              entity is any CommunityStubProviding,
              let userSession = appState.firstSession as? UserSession,
              let communityId = postContext?.communityId,
              let feedContextShowsIndicator = feedContext?.showSubscriptionIndicator else {
            return false
        }
        
        let subscribedToCommunity: Bool = userSession.subscriptions.communityIds.contains(communityId)
        
        return subscribedToCommunity && feedContextShowsIndicator
    }
    
    @ScaledMetric(relativeTo: .body) var subscriptionIndicatorSize: CGFloat = 8.0
    
    var body: some View {
        HStack(spacing: 7) {
            if shouldShowAvatar {
                CircleCroppedImageView(
                    url: entity?.avatar?.withIconSize(labelStyle.avatarResolution),
                    frame: labelStyle.avatarSize,
                    fallback: avatarFallback,
                    showProgress: false,
                    blurred: blurred
                )
            }
            
            HStack(spacing: 4) {
                if showSubscriptionIndicator {
                    Image(systemName: Icons.present)
                        .font(.system(size: subscriptionIndicatorSize))
                        .foregroundStyle(.themedSecondary)
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
        guard let entity else { return String(localized: "Loading...") }
        let flairs = flairs
        if !flairs.isEmpty {
            return "\(entity.fullName), " + flairs.map { String(localized: $0.label) }.joined(separator: ", ")
        }
        return entity.fullName
    }
}

extension FullyQualifiedLabelView {
    init(
        _ entity: (any Person)?,
        labelStyle: FullyQualifiedLabelStyle,
        showAvatar: Bool? = nil,
        showInstance: Bool = true,
        blurred: Bool = false
    ) {
        self.init(
            entity: entity,
            avatarFallback: .personAvatar,
            labelStyle: labelStyle,
            showAvatar: showAvatar,
            showInstance: showInstance,
            blurred: blurred
        )
    }
    
    init(
        _ entity: (any Community)?,
        labelStyle: FullyQualifiedLabelStyle,
        showAvatar: Bool? = nil,
        showInstance: Bool = true,
        blurred: Bool = false
    ) {
        self.init(
            entity: entity,
            avatarFallback: .communityAvatar,
            labelStyle: labelStyle,
            showAvatar: showAvatar,
            showInstance: showInstance,
            blurred: blurred
        )
    }
    
    init(
        _ entity: UserAccount?,
        labelStyle: FullyQualifiedLabelStyle,
        showAvatar: Bool? = nil,
        showInstance: Bool = true,
        blurred: Bool = false
    ) {
        self.init(
            entity: entity,
            avatarFallback: .personAvatar,
            labelStyle: labelStyle,
            showAvatar: showAvatar,
            showInstance: showInstance,
            blurred: blurred
        )
    }
}

#if DEBUG
    #Preview("Sizes", traits: .sampleEnvironment, .sizeThatFitsLayout) {
        VStack(alignment: .leading) {
            ForEach(FullyQualifiedLabelStyle.allCases, id: \.self) { style in
                FullyQualifiedLabelView(Person1.mock(.generic), labelStyle: style)
            }
        }
        .padding()
    }
#endif
