//
//  FeedsView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-01-07.
//

import Foundation
import SwiftUI

struct FeedsView: View {
    @Environment(AppState.self) var appState
    
    var body: some View {
        content
            .navigationTitle("Feeds")
    }
    
    var content: some View {
        MinimalPostFeedView(appState: appState)
    }
}

struct MinimalPostFeedView: View {
    @State var postTracker: StandardPostTracker?
    
    init(appState: AppState) {
        // need to grab some stuff from app storage to initialize with
        @AppStorage("internetSpeed") var internetSpeed: InternetSpeed = .fast
        @AppStorage("upvoteOnSave") var upvoteOnSave = false
        @AppStorage("showReadPosts") var showReadPosts = true
        @AppStorage("defaultPostSorting") var defaultPostSorting: ApiSortType = .hot
        
        if let apiSource = appState.apiSource {
            self._postTracker = .init(wrappedValue: .init(
                internetSpeed: internetSpeed,
                sortType: defaultPostSorting,
                showReadPosts: showReadPosts,
                feedType: .aggregateFeed(apiSource, type: .subscribed)
            )
            )
        } else {
            self._postTracker = .init(wrappedValue: nil)
        }
    }
    
    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Feeds")
                .fancyTabScrollCompatible()
                .task {
                    await postTracker?.loadMoreItems()
                }
        }
    }
    
    @ViewBuilder
    var content: some View {
        if let postTracker {
            ScrollView {
                LazyVStack {
                    ForEach(postTracker.items, id: \.uid) { post in
                        VStack {
                            Text(post.title)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                            Divider()
                        }
                    }
                }
                
                switch postTracker.loadingState {
                case .loading:
                    Text("Loading...")
                case .done:
                    Text("Done")
                case .idle:
                    Text("Idle")
                }
            }
        } else {
            Text("No post tracker!")
        }
    }
}
