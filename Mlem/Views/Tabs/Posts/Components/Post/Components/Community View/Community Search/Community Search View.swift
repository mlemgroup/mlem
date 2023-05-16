//
//  Community Search View.swift
//  Mlem
//
//  Created by David Bureš on 16.05.2023.
//

import SwiftUI

struct CommunitySearchResultsView: View
{
    @EnvironmentObject var favoritedCommunitiesTracker: FavoriteCommunitiesTracker
    @EnvironmentObject var communitySearchResultsTracker: CommunitySearchResultsTracker

    @State var searchResults: [Community]?

    var instanceAddress: URL

    var account: SavedAccount

    @State private var isShowingDarkBackground: Bool = false

    var body: some View
    {
        VStack(alignment: .leading, spacing: 10)
        {
            if communitySearchResultsTracker.foundCommunities.isEmpty
            {
                if !getFavoritedCommunitiesForAccount(account: account, tracker: favoritedCommunitiesTracker).isEmpty
                {
                    List(getFavoritedCommunitiesForAccount(account: account, tracker: favoritedCommunitiesTracker))
                    { favoritedCommunity in
                        NavigationLink(destination: CommunityView(instanceAddress: instanceAddress, account: account, community: favoritedCommunity.community))
                        {
                            Text(favoritedCommunity.community.name)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        unfavoriteCommunity(account: account, community: favoritedCommunity.community, favoritedCommunitiesTracker: favoritedCommunitiesTracker)
                                    } label: {
                                        Label("Unfavorite", systemImage: "star.slash")
                                    }

                                }
                        }
                    }
                }
                else
                {
                    VStack(alignment: .center, spacing: 10) {
                        Image(systemName: "star.slash")
                        Text("You have no communities favorites")
                    }
                }
            }
            else
            {
                List(communitySearchResultsTracker.foundCommunities)
                { foundCommunity in
                    NavigationLink(destination: CommunityView(instanceAddress: instanceAddress, account: account, community: foundCommunity))
                    {
                        Text(foundCommunity.name)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                if favoritedCommunitiesTracker.favoriteCommunities.contains(where: { $0.community.id == foundCommunity.id })
                                { /// This is when a community is already favorited
                                    Button(role: .destructive) {
                                        unfavoriteCommunity(account: account, community: foundCommunity, favoritedCommunitiesTracker: favoritedCommunitiesTracker)
                                    } label: {
                                        Label("Unfavorite", systemImage: "star.slash")
                                    }
                                }
                                else
                                {
                                    Button {
                                        favoriteCommunity(account: account, community: foundCommunity, favoritedCommunitiesTracker: favoritedCommunitiesTracker)
                                    } label: {
                                        Label("Favorite", systemImage: "star")
                                    }
                                    .tint(.yellow)
                                }
                            }
                    }
                }
            }
        }
        .frame(height: 300)
    }

    internal func getFavoritedCommunitiesForAccount(account: SavedAccount, tracker: FavoriteCommunitiesTracker) -> [FavoriteCommunity]
    {
        return tracker.favoriteCommunities.filter { $0.forAccountID == account.id }
    }
}
