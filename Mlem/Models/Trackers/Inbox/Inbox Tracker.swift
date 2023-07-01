//
//  Inbox Tracker.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-30.
//

import Foundation

protocol InboxTracker {
    func loadNextPage(account: SavedAccount) async throws
}
