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
    var swipeActions: SwipeConfiguration = .init()
    
    init(
        community: CommunityModel,
        showTypeLabel: Bool = false,
        swipeActions: SwipeConfiguration? = nil
    ) {
        self.community = community
        self.showTypeLabel = showTypeLabel
        self.swipeActions = swipeActions ?? .init(trailingActions: [subscribeSwipeAction])
    }
    
    var subscribeSwipeAction: SwipeAction {
        let (emptySymbolName, fullSymbolName) = community.subscribed
        ? (Icons.unsubscribePerson, Icons.unsubscribePersonFill)
        : (Icons.subscribePerson, Icons.subscribePersonFill)
        return SwipeAction(
            symbol: .init(emptyName: emptySymbolName, fillName: fullSymbolName),
            color: community.subscribed ? .red : .green,
            action: {
                Task {
                    await subscribe()
                }
            }
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
                    Image(systemName: community.subscribed ? Icons.subscribed : Icons.personFill)
                }
                .foregroundStyle(community.subscribed ? .green : .secondary)
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
            Button(role: community.subscribed ? .destructive : nil) {
                Task(priority: .userInitiated) { await subscribe() }
            } label: {
                Label(
                    community.subscribed ? "Unsubscribe" : "Subscribe",
                    systemImage: community.subscribed ? Icons.unsubscribe : Icons.subscribe)
            }
        }
        .addSwipeyActions(swipeActions)
    }
}
