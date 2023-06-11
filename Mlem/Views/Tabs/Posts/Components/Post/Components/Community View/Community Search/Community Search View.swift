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

    var account: SavedAccount
    var community: APICommunity?

    @Binding var feedType: FeedType
    @Binding var isShowingSearch: Bool

    @State private var isShowingDarkBackground: Bool = false

    var body: some View
    {
        VStack(alignment: .leading, spacing: 10)
        {
            List
            {
                if community == nil
                {
                    if communitySearchResultsTracker.foundCommunities.isEmpty
                    {
                        Section
                        {
                            Button
                            {
                                feedType = .subscribed
                                withAnimation(Animation.interactiveSpring(response: 0.5, dampingFraction: 1, blendDuration: 0.5))
                                {
                                    isShowingSearch.toggle()
                                }
                            } label: {
                                Label("Subscribed", systemImage: "house")
                            }
                            .disabled(feedType == .subscribed)
                            
                            Button
                            {
                                feedType = .all
                                withAnimation(Animation.interactiveSpring(response: 0.5, dampingFraction: 1, blendDuration: 0.5))
                                {
                                    isShowingSearch.toggle()
                                }
                            } label: {
                                Label("All Posts", systemImage: "rectangle.stack.fill")
                            }
                            .disabled(feedType == .all)
                            
                        } header: {
                            Text("Feeds")
                        }
                    }
                }
                if communitySearchResultsTracker.foundCommunities.isEmpty
                {
                    Section
                    {
                        if !getFavoritedCommunitiesForAccount(account: account, tracker: favoritedCommunitiesTracker).isEmpty
                        {
                            ForEach(getFavoritedCommunitiesForAccount(account: account, tracker: favoritedCommunitiesTracker))
                            { favoritedCommunity in
                                NavigationLink(destination: CommunityView(account: account, community: favoritedCommunity.community, feedType: .all))
                                {
                                    Text("\(favoritedCommunity.community.name)\(Text("@\(favoritedCommunity.community.actorId.host ?? "ERROR")").foregroundColor(.secondary).font(.caption))")
                                        .swipeActions(edge: .trailing, allowsFullSwipe: true)
                                    {
                                        Button(role: .destructive)
                                        {
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
                            VStack(alignment: .center, spacing: 10)
                            {
                                Image(systemName: "star.slash")
                                Text("You have no communities favorited")
                            }
                            .listRowBackground(Color.clear)
                            .frame(maxWidth: .infinity)
                        }
                    } header: {
                        Text("Favorites")
                    }
                }
                else
                {
                    Section
                    {
                        ForEach(communitySearchResultsTracker.foundCommunities)
                        { foundCommunity in
                            NavigationLink(destination: CommunityView(account: account, community: foundCommunity, feedType: .all))
                            {
                                Text("\(foundCommunity.name)\(Text("@\(foundCommunity.actorId.host ?? "ERROR")").foregroundColor(.secondary).font(.caption))")
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true)
                                {
                                    if favoritedCommunitiesTracker.favoriteCommunities.contains(where: { $0.community.id == foundCommunity.id })
                                    { /// This is when a community is already favorited
                                        Button(role: .destructive)
                                        {
                                            unfavoriteCommunity(account: account, community: foundCommunity, favoritedCommunitiesTracker: favoritedCommunitiesTracker)
                                        } label: {
                                            Label("Unfavorite", systemImage: "star.slash")
                                        }
                                    }
                                    else
                                    {
                                        Button
                                        {
                                            favoriteCommunity(account: account, community: foundCommunity, favoritedCommunitiesTracker: favoritedCommunitiesTracker)
                                        } label: {
                                            Label("Favorite", systemImage: "star")
                                        }
                                        .tint(.yellow)
                                    }
                                }
                            }
                        }
                    } header: {
                        Text("Search Results")
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
