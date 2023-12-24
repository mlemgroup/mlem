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
    let community: CommunityModel
    let serverInstanceLocation: ServerInstanceLocation
    let overrideShowAvatar: Bool? // if present, shows or hides the avatar according to value; otherwise uses system setting
    let overrideShowSubscribed: Bool? // if present, shows or hides the subscribed status according to the value
    
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
    
    @available(*, deprecated, message: "Provide a CommunityModel rather than an APICommunity.")
    init(
        community: APICommunity,
        serverInstanceLocation: ServerInstanceLocation,
        overrideShowAvatar: Bool? = nil
    ) {
        self.init(
            community: CommunityModel(from: community),
            serverInstanceLocation: serverInstanceLocation,
            overrideShowAvatar: overrideShowAvatar
        )
    }

    init(
        community: CommunityModel,
        serverInstanceLocation: ServerInstanceLocation,
        overrideShowAvatar: Bool? = nil,
        overrideShowSubscribed: Bool? = nil
    ) {
        self.community = community
        self.serverInstanceLocation = serverInstanceLocation
        self.overrideShowAvatar = overrideShowAvatar
        self.overrideShowSubscribed = overrideShowSubscribed
    }

    var body: some View {
        Group {
            HStack(alignment: .bottom, spacing: AppConstants.largeAvatarSpacing) {
                if showAvatar {
                    AvatarView(community: community, avatarSize: avatarSize)
                        .accessibilityHidden(true)
                }
                
                communityLabel
            }
            .accessibilityElement(children: .combine)
        }
    }
    
    @ViewBuilder
    private var communityLabel: some View {
        HStack(spacing: 4) {
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
    }

    @ViewBuilder
    private var communityName: some View {
        HStack(spacing: 4) {
            Text(community.name)
                .dynamicTypeSize(.small ... .accessibility1)
                .font(.footnote)
                .bold()
                .foregroundColor(.secondary)
            
            if community.subscribed ?? false {
                Image(systemName: Icons.present)
                    .font(.system(size: 8.0))
                    .imageScale(.small)
                    .foregroundColor(.secondary)
            }
        }
    }

    @ViewBuilder
    private var communityInstance: some View {
        if let host = community.communityUrl.host() {
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
