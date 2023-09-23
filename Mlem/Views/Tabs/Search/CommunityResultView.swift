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
    
    var subscribeSwipeAction: SwipeAction {
        let (emptySymbolName, fullSymbolName) = community.subscribed
            ? ("person.crop.circle.badge.xmark", "person.crop.circle.badge.xmark.fill")
            : ("person.crop.circle.badge.plus", "person.crop.circle.badge.plus.fill")
        return SwipeAction(
            symbol: .init(emptyName: emptySymbolName, fillName: fullSymbolName),
            color: community.subscribed ? .red : .green,
            action: subscribe
        )
    }
    
    func subscribe() async {
        var community = community
        await community.toggleSubscribe {
            contentTracker.update(with: AnyContentModel($0))
        }
    }
    
    var caption: String {
        if let host = community.community.actorId.host {
            if showTypeLabel {
                return "Community ∙ @\(host)"
            } else {
                return "@\(host)"
            }
        }
        return "Unknown instance"
    }
    
    var body: some View {
        NavigationLink(value: NavigationRoute.apiCommunity(community.community)) {
            HStack(spacing: 10) {
                AvatarView(community: community.community, avatarSize: 48)
                VStack(alignment: .leading, spacing: 4) {
                    if community.community.nsfw {
                        Text("\(community.community.name) - NSFW")
                            .foregroundStyle(.red)
                    } else {
                        Text(community.community.name)
                    }
                    Text(caption)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer()
                HStack(spacing: 5) {
                    Text(abbreviateNumber(community.subscriberCount))
                        .monospacedDigit()
                    Image(systemName: community.subscribed ? "checkmark.circle" : "person.fill")
                }
                .foregroundStyle(community.subscribed ? .green : .secondary)
                Image(systemName: "chevron.right")
                    .imageScale(.small)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.vertical, 8)
        .background(.background)
        .addSwipeyActions(trailing: [subscribeSwipeAction])
        .draggable(community.community.actorId) {
            HStack {
                AvatarView(community: community.community, avatarSize: 24)
                Text(community.community.name)
            }
            .padding(8)
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .contextMenu {
            Button(
                community.subscribed ? "Unsubscribe" : "Subscribe",
                systemImage: community.subscribed ? AppConstants.unsubscribeSymbolName : AppConstants.subscribeSymbolName,
                role: community.subscribed ? .destructive : nil
            ) {
                Task(priority: .userInitiated) { await subscribe() }
            }
        }
    }
}
