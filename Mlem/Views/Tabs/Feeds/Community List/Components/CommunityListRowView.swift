//
//  CommunityListRowViews.swift
//  Mlem
//
//  Created by Jake Shirley on 6/19/23.
//

import Dependencies
import SwiftUI

struct CommuntiyFeedRowView: View {

    @Dependency(\.favoriteCommunitiesTracker) var favoriteCommunitiesTracker
    @Dependency(\.hapticManager) var hapticManager
    @Dependency(\.notifier) var notifier
    
    let community: APICommunity
    let subscribed: Bool
    let communitySubscriptionChanged: (APICommunity, Bool) -> Void
    
    var favoriteSwipeAction: SwipeAction {
        SwipeAction(symbol:
                .init(
                    emptyName: isFavorited() ? "star.slash" : "star",
                    fillName: isFavorited() ? "star.slash.fill" : "star.fill"
                ),
                color: .blue,
                action: toggleFavorite
        )
    }
        
    var unsubscribeSwipeAction: SwipeAction {
        if subscribed {
            SwipeAction(symbol:
                    .init(
                        emptyName: "person.crop.circle.badge.xmark", fillName: "person.crop.circle.fill.badge.xmark"),
                        color: .red,
                        action: { await subscribe(communityId: community.id, shouldSubscribe: false) }
            )
        } else {
            SwipeAction(symbol:
                    .init(
                        emptyName: "person.crop.circle.badge.plus", fillName: "person.crop.circle.fill.badge.plus"),
                        color: .green,
                        action: { await subscribe(communityId: community.id, shouldSubscribe: true) }
            )
        }
    }
    
    var body: some View {
        NavigationLink(value: CommunityLinkWithContext(community: community, feedType: .subscribed)) {
            HStack {
                content
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
                    .imageScale(.small)
                    .fontWeight(.semibold)
            }
            .padding(.vertical, 7)
            .padding(.horizontal, 15)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(Color(.secondarySystemGroupedBackground))
        .addSwipeyActions(leading: [favoriteSwipeAction], trailing: [unsubscribeSwipeAction])

        .accessibilityAction(named: "Toggle favorite") {
            toggleFavorite()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(communityLabel)
    }
    
    private var content: some View {
        HStack(spacing: 15) {
            Group {
                if let url = community.icon {
                    CachedImage(
                        url: url.withIcon64Parameters,
                        shouldExpand: false,
                        fixedSize: CGSize(width: 36, height: 36),
                        imageNotFound: defaultCommunityAvatar,
                        contentMode: .fill
                    )
                } else {
                    defaultCommunityAvatar()
                }
            }
            .clipShape(Circle())
            .overlay(Circle()
                .stroke(
                    Color(UIColor.secondarySystemBackground),
                    lineWidth: shouldClipAvatar(community: community) ? 1 : 0
                ))
            .frame(width: 36, height: 36)
            .accessibilityHidden(true)
            
            VStack(alignment: .leading, spacing: 0) {
                Text(community.name)
                    .foregroundStyle(.primary)
                
                if let instanceName = community.actorId.host(percentEncoded: false) {
                    Text("@\(instanceName)")
                        .font(.footnote)
                        .foregroundStyle(.tertiary)
                }
            }
        }
    }
    
    private func defaultCommunityAvatar() -> AnyView {
        AnyView(
            ZStack {
                VStack {
                    Spacer()
                    Image(systemName: "building.2.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 24)
                        .foregroundStyle(.white)
                }
                .scaledToFit()
                .mask(
                    Circle()
                        .frame(width: 30, height: 30)
                )
            }
            .frame(maxWidth: .infinity)
            .background(.gray)
        )
    }

    private var communityLabel: String {
        var label = community.name

        if let website = community.actorId.host(percentEncoded: false) {
            label += "@\(website)"
        }

        if isFavorited() {
            label += ", is a favorite"
        }

        return label
    }

    private func toggleFavorite() {
        if isFavorited() {
            favoriteCommunitiesTracker.unfavorite(community)
            UIAccessibility.post(notification: .announcement, argument: "Unfavorited \(community.name)")
            Task {
                await notifier.add(.success("Unfavorited \(community.name)"))
            }
        } else {
            favoriteCommunitiesTracker.favorite(community)
            UIAccessibility.post(notification: .announcement, argument: "Favorited \(community.name)")
            Task {
                await notifier.add(.success("Favorited \(community.name)"))
            }
        }
    }

    private func isFavorited() -> Bool {
        favoriteCommunitiesTracker.isFavorited(community)
    }

    private func subscribe(communityId: Int, shouldSubscribe: Bool) async {
        communitySubscriptionChanged(community, shouldSubscribe)
    }
}

struct HomepageFeedRowView: View {
    let feedType: FeedType
    let iconName: String
    let iconColor: Color
    let description: String

    var body: some View {
        NavigationLink(value: CommunityLinkWithContext(community: nil, feedType: feedType)) {
            HStack {
                Image(systemName: iconName).resizable()
                    .frame(width: 36, height: 36).foregroundColor(iconColor)
                VStack(alignment: .leading) {
                    Text("\(feedType.label) Communities")
                    Text(description).font(.caption).foregroundColor(.gray)
                }
            }
            .padding(.bottom, 1)
            .accessibilityElement(children: .combine)
        }
    }
}
