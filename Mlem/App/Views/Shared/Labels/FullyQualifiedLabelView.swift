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
    typealias Entity = CommunityOrPerson & ProfileProviding
    
    @Environment(AppState.self) var appState
    @Environment(\.postContext) var postContext: Post?
    @Environment(\.commentContext) var commentContext: Comment?
    @Environment(\.communityContext) var communityContext: Community?
    @Environment(\.feedContext) var feedContext: FeedContext?

    @Setting(\.post_showSubscribedStatus) var showSubscribedStatus
    @Setting(\.person_showAvatar) var showPersonAvatar
    @Setting(\.community_showAvatar) var showCommunityAvatar
    
    let entity: (any Entity)?
    let avatarFallback: MediaView.Fallback
    let labelStyle: FullyQualifiedLabelStyle
    var showAvatar: Bool?
    var showInstance: Bool = true
    var showFlairs: Bool = true
    var blurred: Bool = false
    
    var shouldShowAvatar: Bool {
        if let showAvatar { return showAvatar }
        
        if entity is Community {
            return showCommunityAvatar
        } else {
            return showPersonAvatar
        }
    }
    
    var showSubscriptionIndicator: Bool {
        guard showSubscribedStatus,
              entity is Community,
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

            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 4) {
                    if showSubscriptionIndicator {
                        Image(icon: .general.circle)
                            .symbolVariant(.fill)
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
                    .symbolVariant(.fill)
                }
                .imageScale(.small)
                .offset(y: 1)
                if let note = (entity as? Person)?.note, feedContext != .person {
                    self.note(text: note)
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
    }

    func note(text: String) -> some View {
        Text(text)
            .font(.footnote)
            .foregroundStyle(.secondary)
}
    
    var flairs: [PersonFlair] {
        guard showFlairs, let person = entity as? Person else { return [] }
        return person.flairs(
            interactableContext: interactableContext,
            communityContext: communityContext
        )
    }
    
    var interactableContext: (any InteractableProviding)? {
        guard let person = entity as? Person else { return nil }
        if let commentContext,
           let creator = commentContext.creator.value,
           creator.actorId == person.actorId {
            return commentContext
        }
        if let postContext,
           let creator = postContext.creator.value,
           creator.actorId == person.actorId {
            return postContext
        }
        return nil
    }
    
    var accessibilityLabel: String {
        guard let entity else { return String(localized: "Loading...") }
        let flairs = flairs

        var result = entity.fullName
        
        if !flairs.isEmpty {
            result += flairs.map { String(localized: $0.label) }.joined(separator: ", ")
        }

        if let note = (entity as? Person)?.note {
            result += "\(String(localized: "Note")): \(note)"
        }

        return result
    }
}

extension FullyQualifiedLabelView {
    init(
        _ entity: Person?,
        labelStyle: FullyQualifiedLabelStyle,
        showAvatar: Bool? = nil,
        showInstance: Bool = true,
        showFlairs: Bool = true,
        blurred: Bool = false
    ) {
        self.init(
            entity: entity,
            avatarFallback: .personAvatar,
            labelStyle: labelStyle,
            showAvatar: showAvatar,
            showInstance: showInstance,
            showFlairs: showFlairs,
            blurred: blurred
        )
    }
    
    init(
        _ entity: Community?,
        labelStyle: FullyQualifiedLabelStyle,
        showAvatar: Bool? = nil,
        showInstance: Bool = true,
        showFlairs: Bool = true,
        blurred: Bool = false
    ) {
        self.init(
            entity: entity,
            avatarFallback: .communityAvatar,
            labelStyle: labelStyle,
            showAvatar: showAvatar,
            showInstance: showInstance,
            showFlairs: showFlairs,
            blurred: blurred
        )
    }
    
    init(
        _ entity: UserAccount?,
        labelStyle: FullyQualifiedLabelStyle,
        showAvatar: Bool? = nil,
        showInstance: Bool = true,
        showFlairs: Bool = true,
        blurred: Bool = false
    ) {
        self.init(
            entity: entity,
            avatarFallback: .personAvatar,
            labelStyle: labelStyle,
            showAvatar: showAvatar,
            showInstance: showInstance,
            showFlairs: showFlairs,
            blurred: blurred
        )
    }
}

// TODO: updated mocks
// #if DEBUG
//    #Preview("Sizes", traits: .sampleEnvironment, .sizeThatFitsLayout) {
//        VStack(alignment: .leading) {
//            ForEach(FullyQualifiedLabelStyle.allCases, id: \.self) { style in
//                FullyQualifiedLabelView(Person1.mock(.generic), labelStyle: style)
//            }
//        }
//        .padding()
//    }
// #endif
