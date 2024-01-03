//
//  CommunityResultView.swift
//  Mlem
//
//  Created by Sjmarf on 18/09/2023.
//

import SwiftUI
import Dependencies

struct CommunityResultView: View {
    @Dependency(\.apiClient) private var apiClient
    @Dependency(\.hapticManager) var hapticManager
    
    @EnvironmentObject var contentTracker: ContentTracker<AnyContentModel>
    
    let community: CommunityModel
    let showTypeLabel: Bool
    var swipeActions: SwipeConfiguration?

    @State private var isPresentingConfirmDestructive: Bool = false
    @State private var confirmationMenuFunction: StandardMenuFunction?
    
    func confirmDestructive(destructiveFunction: StandardMenuFunction) {
        confirmationMenuFunction = destructiveFunction
        isPresentingConfirmDestructive = true
    }
    
    var title: String {
        if community.blocked ?? false {
            return "\(community.name) ∙ Blocked"
        } else if community.nsfw {
            return "\(community.name) ∙ NSFW"
        } else {
            return community.name
        }
    }
    
    var caption: String {
        if let host = community.communityUrl.host {
            if showTypeLabel {
                return "Community ∙ @\(host)"
            } else {
                return "@\(host)"
            }
        }
        return "Unknown instance"
    }
    
    var body: some View {
        NavigationLink(value: AppRoute.community(community)) {
            HStack(spacing: 10) {
                if community.blocked ?? false {
                    Image(systemName: Icons.hide)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .padding(9)
                } else {
                    AvatarView(community: community, avatarSize: 48, iconResolution: .fixed(128))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .lineLimit(1)
                        .foregroundStyle(community.nsfw ? .red : .primary)
                    Text(caption)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer()
                if let subscriberCount = community.subscriberCount {
                    HStack(spacing: 5) {
                        Text(abbreviateNumber(subscriberCount))
                            .monospacedDigit()
                        Image(systemName: (community.subscribed ?? false) ? Icons.subscribed : Icons.personFill)
                    }
                    .foregroundStyle((community.subscribed ?? false) ? .green : .secondary)
                }
                Image(systemName: Icons.forward)
                    .imageScale(.small)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal)
            .contentShape(Rectangle())
        }
        .opacity((community.blocked ?? false) ? 0.5 : 1)
        .buttonStyle(.plain)
        .padding(.vertical, 8)
        .background(.background)
        .draggable(community.communityUrl) {
            HStack {
                AvatarView(community: community, avatarSize: 24)
                Text(community.name)
            }
            .padding(8)
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .destructiveConfirmation(
            isPresentingConfirmDestructive: $isPresentingConfirmDestructive,
            confirmationMenuFunction: confirmationMenuFunction
        )
        .addSwipeyActions(swipeActions ?? community.swipeActions({
            contentTracker.update(with: AnyContentModel($0))
        }, confirmDestructive: confirmDestructive))
        .contextMenu {
            ForEach(community.menuFunctions {
                contentTracker.update(with: AnyContentModel($0))
            }) { item in
                MenuButton(menuFunction: item, confirmDestructive: confirmDestructive)
            }
        }
    }
}

#Preview {
    CommunityResultView(
        community: .init(from: .mock()),
        showTypeLabel: true
    )
}
