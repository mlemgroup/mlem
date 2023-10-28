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

    var subscribeSwipeAction: SwipeAction {
        let (emptySymbolName, fullSymbolName) = (community.subscribed ?? false)
        ? (Icons.unsubscribePerson, Icons.unsubscribePersonFill)
        : (Icons.subscribePerson, Icons.subscribePersonFill)
        return SwipeAction(
            symbol: .init(emptyName: emptySymbolName, fillName: fullSymbolName),
            color: (community.subscribed ?? false) ? .red : .green,
            action: {
                Task {
                    await subscribe()
                }
            }
        )
    }
    
    func subscribe() async {
        var community = community
        try? await community.toggleSubscribe {
            contentTracker.update(with: AnyContentModel($0))
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
                AvatarView(community: community, avatarSize: 48)
                VStack(alignment: .leading, spacing: 4) {
                    if community.nsfw {
                        Text("\(community.name) - NSFW")
                            .foregroundStyle(.red)
                    } else {
                        Text(community.name)
                    }
                    Text(caption)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer()
                HStack(spacing: 5) {
                    Text(abbreviateNumber(community.subscriberCount ?? 0))
                        .monospacedDigit()
                    Image(systemName: (community.subscribed ?? false) ? Icons.subscribed : Icons.personFill)
                }
                .foregroundStyle((community.subscribed ?? false) ? .green : .secondary)
                Image(systemName: Icons.forward)
                    .imageScale(.small)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal)
            .contentShape(Rectangle())
        }
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
        .contextMenu {
            if let subscribed = community.subscribed {
                Button(role: subscribed ? .destructive : nil) {
                    Task(priority: .userInitiated) { await subscribe() }
                } label: {
                    Label(
                        subscribed ? "Unsubscribe" : "Subscribe",
                        systemImage: subscribed ? Icons.unsubscribe : Icons.subscribe)
                }
            }
        }
        .addSwipeyActions(swipeActions ?? .init(trailingActions: [subscribeSwipeAction]))
    }
}
