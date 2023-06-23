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
    @State var subscribedCommunities: [APICommunity]?

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
                                NavigationLink(value: favoritedCommunity.community)
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

                    Section
                    {
                        if subscribedCommunities != nil {
                            if !subscribedCommunities!.isEmpty
                            {
                                ForEach(subscribedCommunities!)
                                { subscribedCommunity in
                                    NavigationLink(value: subscribedCommunity)
                                    {
                                        Text("\(subscribedCommunity.name)\(Text("@\(subscribedCommunity.actorId.host!)").foregroundColor(.secondary).font(.caption))")
                                            .swipeActions(edge: .trailing, allowsFullSwipe: true)
                                        {
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
                                Text("You have no community subscriptions")
                            }
                            .listRowBackground(Color.clear)
                            .frame(maxWidth: .infinity)
                        }
                    } header: {
                        Text("Subscriptions")
                    }
                }
                else
                {
                    Section
                    {
                        ForEach(communitySearchResultsTracker.foundCommunities)
                        { foundCommunity in
                            NavigationLink(value: foundCommunity)
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
        .task {
            let request = ListCommunitiesRequest(account: account, sort: nil, page: nil, limit: nil, type: FeedType.subscribed);
            do {
                let response = try await APIClient().perform(request: request);
                subscribedCommunities = response.communities.map({
                    return $0.community;
                }).sorted(by: {
                    $0.name < $1.name
                });
            } catch {

            }
        }
    }

    internal func getFavoritedCommunitiesForAccount(account: SavedAccount, tracker: FavoriteCommunitiesTracker) -> [FavoriteCommunity]
    {
        return tracker.favoriteCommunities.filter { $0.forAccountID == account.id }
    }
}
