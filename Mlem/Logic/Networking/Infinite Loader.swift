//
//  Infinite loader.swift
//  Mlem
//
//  Created by David Bureš on 18.06.2022.
//

import Foundation
import SwiftUI

func loadInfiniteFeed(connectionHandler: LemmyConnectionHandler, tracker: PostData_Decoded, communityName: String? = nil)
{
    if communityName == nil
    {
        print("Jumped into GLOBAL scope")
        tracker.latestLoadedPageGlobal += 1

        print("Page counter value: \(tracker.latestLoadedPageGlobal)")

        connectionHandler.sendCommand(maintainOpenConnection: false, command: """
        {"op": "GetPosts", "data": {"type_": "All", "sort":"Hot", "page": \(tracker.latestLoadedPageGlobal)}}
        """)
    }
    else
    {
        print("Jumped into COMMUNITY scope, with this community selected: \(communityName!)")
        tracker.latestLoadedPageCommunity += 1

        print("Page counter value: \(tracker.latestLoadedPageCommunity)")

        connectionHandler.sendCommand(maintainOpenConnection: false, command: """
        {"op": "GetPosts", "data": {"type_": "Community", "sort": "Hot", "page": \(tracker.latestLoadedPageCommunity), "community_name": "\(communityName!)"}}
        """) // TODO: For now, I have to put in the community name because the ID just straight-up doesn't work. Do something about it.
    }
}
