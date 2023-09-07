//
//  CommunityLabelView.swift
//  Mlem
//
//  Created by Sjmarf on 27/08/2023.
//
import SwiftUI

struct CommunityLabelView: View {
    // settings
    @AppStorage("shouldShowCommunityIcons") var shouldShowCommunityIcons: Bool = true

    // parameters
    let community: APICommunity
    let serverInstanceLocation: ServerInstanceLocation
    let overrideShowAvatar: Bool? // if present, shows or hides the avatar according to value; otherwise uses system setting
    
    var avatarSize: CGFloat { serverInstanceLocation == .bottom
        ? AppConstants.largeAvatarSize
        : AppConstants.smallAvatarSize
    }

    var showAvatar: Bool {
        if let overrideShowAvatar {
            return overrideShowAvatar
        } else {
            return shouldShowCommunityIcons
        }
    }

    init(
        community: APICommunity,
        serverInstanceLocation: ServerInstanceLocation,
        overrideShowAvatar: Bool? = nil
    ) {
        self.community = community
        self.serverInstanceLocation = serverInstanceLocation
        self.overrideShowAvatar = overrideShowAvatar
    }

    var body: some View {
        Group {
            HStack(alignment: .bottom, spacing: AppConstants.largeAvatarSpacing) {
                if showAvatar {
                    AvatarView(community: community, avatarSize: avatarSize)
                        .accessibilityHidden(true)
                }

                switch serverInstanceLocation {
                case .disabled:
                    communityName
                case .trailing:
                    HStack(spacing: 0) {
                        communityName
                        communityInstance
                    }
                    .foregroundColor(.secondary)
                case .bottom:
                    VStack(alignment: .leading) {
                        communityName
                        communityInstance
                    }
                }
            }
            .accessibilityElement(children: .combine)
        }
    }

    @ViewBuilder
    private var communityName: some View {
        Text(community.name)
            .dynamicTypeSize(.small ... .accessibility1)
            .font(.footnote)
            .bold()
            .foregroundColor(.secondary)
    }

    @ViewBuilder
    private var communityInstance: some View {
        if let host = community.actorId.host() {
            Text("@\(host)")
                .dynamicTypeSize(.small ... .accessibility2)
                .lineLimit(1)
                .foregroundColor(Color(uiColor: .tertiaryLabel))
                .font(.caption)
                .allowsHitTesting(false)
        } else {
            EmptyView()
        }
    }

}
