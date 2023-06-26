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
            .accessibilityRepresentation{ configuration.label }
    }
}

struct CommuntiyFeedRowView: View {
    let account: SavedAccount
    let community: APICommunity
    let subscribed: Bool
    let communitySubscriptionChanged: (APICommunity, Bool) -> Void
    
    @EnvironmentObject var favoritesTracker: FavoriteCommunitiesTracker
    
    var body: some View {
        HStack {
            // NavigationLink with invisible array
            HStack(alignment: .bottom, spacing: 0) {
                Text(community.name)
                if let website = community.actorId.host(percentEncoded: false) {
                    Text("@\(website)").font(.footnote).foregroundColor(.gray).opacity(0.5)
                }
            }.background(
                NavigationLink(value: CommunityLinkWithContext(community: community, feedType: .subscribed)) {}.opacity(0).buttonStyle(.plain)
            )
            .accessibilityLabel("Community \(community.name)")
            .accessibilityAddTraits(.isLink)
            
            Spacer()
            
            Button("Favorite Community", action: {
                // Nice little haptics
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                
                if isFavorited() {
                    unfavoriteCommunity(account: account, community: community, favoritedCommunitiesTracker: favoritesTracker)
                }
                else {
                    favoriteCommunity(account: account, community: community, favoritedCommunitiesTracker: favoritesTracker)
                }
            }).buttonStyle(FavoriteStarButtonStyle(isFavorited: isFavorited()))
            
        }.swipeActions {
            if subscribed {
                Button("Unsubscribe") {
                    Task(priority: .userInitiated) {
                        await subscribe(communityId: community.id, shouldSubscribe: false)
                    }
                }.tint(.red) // Destructive role seems to remove from list so just make it red
            }
            else {
                Button("Subscribe") {
                    Task(priority: .userInitiated) {
                        await subscribe(communityId: community.id, shouldSubscribe: true)
                    }
                }.tint(.blue)
            }            
        }
    }
    
    internal func isFavorited() -> Bool {
        return getFavoritedCommunities(account: account, favoritedCommunitiesTracker: favoritesTracker).contains(community)
    }
    
    private func subscribe(communityId: Int, shouldSubscribe: Bool) async {
        // Refresh the list locally immedietly and undo it if we error
        communitySubscriptionChanged(community, shouldSubscribe)
        
        do {
            let request = FollowCommunityRequest(
                account: account,
                communityId: communityId,
                follow: shouldSubscribe
            )
            
            _ = try await APIClient().perform(request: request)
        } catch {
            // TODO: If we fail here and want to notify the user we'd ideally
            print(error)
            communitySubscriptionChanged(community, !shouldSubscribe)
        }
    }
}

struct HomepageFeedRowView: View {
    let account: SavedAccount
    let feedType: FeedType
    let iconName: String
    let iconColor: Color
    let description: String
    
    var body: some View {
        // NavigationLink with invisible array
        HStack {
            Image(systemName: iconName).resizable()
                .frame(width: 36, height: 36).foregroundColor(iconColor)
            VStack(alignment: .leading) {
                Text("\(feedType.rawValue) Communities")
                Text(description).font(.caption).foregroundColor(.gray)
            }
        }.background(
            NavigationLink(value: CommunityLinkWithContext(community: nil, feedType: feedType)) {}.opacity(0)
        ).padding(.bottom, 1)
    }
}
