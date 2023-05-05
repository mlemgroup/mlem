//
//  Saved Community Tracker.swift
//  Mlem
//
//  Created by David Bureš on 05.05.2023.
//

import Foundation

class SavedCommunityTracker: ObservableObject
{
    @Published var savedCommunities: [SavedCommunity] = .init()
}
