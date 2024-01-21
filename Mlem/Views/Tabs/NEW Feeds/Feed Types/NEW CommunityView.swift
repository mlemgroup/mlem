//
//  NEW CommunityView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-01-19.
//

import Dependencies
import Foundation
import SwiftUI

/// View for post feeds aggregating multiple communities (all, local, subscribed, saved)
struct NewCommunityFeedView: View {
    @Dependency(\.errorHandler) var errorHandler
    
    @StateObject var postTracker: StandardPostTracker
    
    // TODO: sorting
    @State var postSortType: PostSortType = .hot
    
    init(feedType: NewFeedType) {
        // need to grab some stuff from app storage to initialize post tracker with
        @AppStorage("internetSpeed") var internetSpeed: InternetSpeed = .fast
        @AppStorage("upvoteOnSave") var upvoteOnSave = false
        @AppStorage("showReadPosts") var showReadPosts = true
        @AppStorage("defaultPostSorting") var defaultPostSorting: PostSortType = .hot
        
        self._postSortType = .init(wrappedValue: defaultPostSorting)
        self._postTracker = .init(wrappedValue: .init(
            internetSpeed: internetSpeed,
            sortType: defaultPostSorting,
            showReadPosts: showReadPosts,
            feedType: feedType
        ))
    }
    
    var body: some View {
        content
            .onAppear {
                Task { await postTracker.loadMoreItems() }
            }
            .refreshable {
                await Task {
                    do {
                        _ = try await postTracker.refresh(clearBeforeRefresh: false)
                    } catch {
                        errorHandler.handle(error)
                    }
                }.value
            }
            .background {
                VStack(spacing: 0) {
                    Color.systemBackground
                    Color.secondarySystemBackground
                }
            }
            .fancyTabScrollCompatible()
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Community!")
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarColor(visibility: .automatic)
    }
    
    @ViewBuilder
    var content: some View {
        ScrollView {
            NewPostFeedView(postSortType: $postSortType, showCommunity: true)
                .environmentObject(postTracker)
                .background(Color.secondarySystemBackground)
        }
    }
}
