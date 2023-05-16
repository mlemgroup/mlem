//
//  Community Search View.swift
//  Mlem
//
//  Created by David Bureš on 16.05.2023.
//

import SwiftUI

struct CommunitySearchResultsView: View
{
    @EnvironmentObject var communitySearchResultsTracker: CommunitySearchResultsTracker
    
    @State var searchResults: [Community]?
    
    var instanceAddress: URL
    
    var account: SavedAccount
    
    @State private var isShowingDarkBackground: Bool = false
    
    var body: some View
    {
        VStack(alignment: .leading, spacing: 10)
        {
            List(communitySearchResultsTracker.foundCommunities)
            { foundCommunity in
                NavigationLink(destination: CommunityView(instanceAddress: instanceAddress, account: account, community: foundCommunity))
                {
                    HStack(alignment: .center, spacing: 10)
                    {
                        Text(foundCommunity.name)
                    }
                }
            }
            .frame(height: 300)
        }
    }
}
