//
//  Community Search Result Tracker.swift
//  Mlem
//
//  Created by David Bureš on 16.05.2023.
//

import Foundation

class CommunitySearchResultsTracker: ObservableObject
{
    @Published var foundCommunities: [APICommunity] = .init()
    @Published var isLoading: Bool = false
}
