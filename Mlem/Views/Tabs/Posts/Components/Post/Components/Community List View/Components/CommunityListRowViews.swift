//
//  CommunityListRowViews.swift
//  Mlem
//
//  Created by Jake Shirley on 6/19/23.
//

import SwiftUI

struct HeaderView: View {
    let title: String

    var body: some View {
        HStack {
            Text(title)
            Spacer()
        }
    }
}

struct FavoriteStarButtonStyle: ButtonStyle {
    let isFavorited: Bool

    func makeBody(configuration: Configuration) -> some View {
        Image(systemName: isFavorited ? "star.fill" : "star")
            .foregroundColor(.blue)
            .opacity(isFavorited ? 1.0 : 0.2)
            .accessibilityRepresentation { configuration.label }
    }
}

struct CommuntiyFeedRowView: View {
    let community: APICommunity
    let subscribed: Bool
    let communitySubscriptionChanged: (APICommunity, Bool) -> Void

    @EnvironmentObject var appState: AppState
    @EnvironmentObject var favoritesTracker: FavoriteCommunitiesTracker

    var body: some View {
        NavigationLink(value: CommunityLinkWithContext(community: community, feedType: .subscribed)) {
            HStack {
                // NavigationLink with invisible array
                HStack(alignment: .bottom, spacing: 0) {
                    Text(community.name)
                    if let website = community.actorId.host(percentEncoded: false) {
                        Text("@\(website)").font(.footnote).foregroundColor(.gray).opacity(0.5)
                    }
                }
                Spacer()
                Button("Favorite Community") {
                    // Nice little haptics
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)

                    toggleFavorite()

                }.buttonStyle(FavoriteStarButtonStyle(isFavorited: isFavorited()))
                    .accessibilityHidden(true)
            }
        }.swipeActions {
            if subscribed {
                Button("Unsubscribe") {
                    Task(priority: .userInitiated) {
                        await subscribe(communityId: community.id, shouldSubscribe: false)
                    }
                }.tint(.red) // Destructive role seems to remove from list so just make it red
            } else {
                Button("Subscribe") {
                    Task(priority: .userInitiated) {
                        await subscribe(communityId: community.id, shouldSubscribe: true)
                    }
                }.tint(.blue)
            }
        }
        .accessibilityAction(named: "Toggle favorite") {
            toggleFavorite()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(communityLabel)
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
            unfavoriteCommunity(community: community, favoritedCommunitiesTracker: favoritesTracker)
            UIAccessibility.post(notification: .announcement, argument: "Un-favorited \(community.name)")
        } else {
            favoriteCommunity(account: appState.currentActiveAccount, community: community, favoritedCommunitiesTracker: favoritesTracker)
            UIAccessibility.post(notification: .announcement, argument: "Favorited \(community.name)")
        }
    }

    internal func isFavorited() -> Bool {
        return getFavoritedCommunities(
            account: appState.currentActiveAccount,
            favoritedCommunitiesTracker: favoritesTracker
        ).contains(community)
    }

    private func subscribe(communityId: Int, shouldSubscribe: Bool) async {
        // Refresh the list locally immedietly and undo it if we error
        communitySubscriptionChanged(community, shouldSubscribe)

        do {
            let request = FollowCommunityRequest(
                account: appState.currentActiveAccount,
                communityId: communityId,
                follow: shouldSubscribe
            )

            _ = try await APIClient().perform(request: request)
        } catch {
            // TODO: If we fail here and want to notify the user we should pass a message
            // into the contextual error below
            appState.contextualError = .init(underlyingError: error)
            communitySubscriptionChanged(community, !shouldSubscribe)
        }
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
                    Text("\(feedType.rawValue) Communities")
                    Text(description).font(.caption).foregroundColor(.gray)
                }
            }
            .padding(.bottom, 1)
            .accessibilityElement(children: .combine)
        }
    }
}
