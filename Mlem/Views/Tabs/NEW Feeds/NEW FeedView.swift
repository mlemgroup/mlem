//
//  NEW FeedView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-01-11.
//

import Dependencies
import Foundation
import SwiftUI

/// View for post feeds aggregating multiple communities (all, local, subscribed, saved)
struct AggregateFeedView: View {
    @StateObject var postTracker: StandardPostTracker
    
    // TODO: sorting
    
    init(feedType: NewFeedType) {
        // need to grab some stuff from app storage to initialize post tracker with
        @AppStorage("internetSpeed") var internetSpeed: InternetSpeed = .fast
        @AppStorage("upvoteOnSave") var upvoteOnSave = false
        
        // TODO: ERIC handle sort type
        
        self._postTracker = .init(wrappedValue: .init(
            internetSpeed: internetSpeed,
            sortType: .hot,
            unreadOnly: false,
            feedType: feedType
        ))
    }
    
    var body: some View {
        content
            .onAppear {
                Task {
                    await postTracker.loadMoreItems()
                }
            }
    }
    
    @ViewBuilder
    var content: some View {
        Text("I'm a general feed!")
        Text("The post tracker contains \(postTracker.items.count) items")
        Button("More") {
            Task {
                await postTracker.loadMoreItems()
            }
        }
    }
}
