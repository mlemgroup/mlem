//
//  UserFeedView.swift
//  Mlem
//
//  Created by Sjmarf on 25/08/2023.
//

import SwiftUI

struct UserFeedView: View {
    var userID: Int
    @StateObject var privatePostTracker: PostTracker
    @StateObject var privateCommentTracker: CommentTracker
    
    @Binding var selectedTab: UserViewTab
    
    struct FeedItem: Identifiable {
        let id = UUID()
        let published: Date
        let comment: HierarchicalComment?
        let post: PostModel?
    }
    
    var body: some View {
        let feed = generateFeed()
            .sorted(by: {
                $0.published > $1.published
            })
        
        if feed.isEmpty {
            emptyFeed
        } else {
            if selectedTab == .posts {
                VStack(spacing: 0) {
                    content(feed)
                }
            } else {
                LazyVStack(spacing: 0) {
                    content(feed)
                }
            }
        }
    }
    
    func content(_ feed: [FeedItem]) -> some View {
        ForEach(feed) { feedItem in
            if let post = feedItem.post {
                postEntry(for: post)
            }
            if let comment = feedItem.comment {
                commentEntry(for: comment)
            }
        }
    }
    
    func generateFeed() -> [FeedItem] {
        let feed: [FeedItem]
        switch selectedTab {
        case .overview:
            feed = generateMixedFeed(savedItems: false)
        case .saved:
            feed = generateMixedFeed(savedItems: true)
        case .comments:
            feed = generateCommentFeed()
        case .posts:
            feed = generatePostFeed()
        }
        
        return feed
    }
    
    private func postEntry(for post: PostModel) -> some View {
        NavigationLink(.postLinkWithContext(.init(post: post, postTracker: privatePostTracker))) {
            VStack(spacing: 0) {
                FeedPost(
                    post: post,
                    showPostCreator: false,
                    showCommunity: true
                )
                
                Divider()
            }
        }
        .buttonStyle(.plain)
    }
    
    private func commentEntry(for comment: HierarchicalComment) -> some View {
        VStack(spacing: 0) {
            CommentItem(
                hierarchicalComment: comment,
                postContext: nil,
                indentBehaviour: .never,
                showPostContext: true,
                showCommentCreator: false
            )
            
            Divider()
        }
    }
    
    @ViewBuilder
    private var emptyFeed: some View {
        HStack {
            Spacer()
            Text("Nothing to see here, get out there and make some stuff!")
                .padding()
                .font(.headline)
                .opacity(0.5)
            Spacer()
        }
        .background()
    }
    
    private func generateCommentFeed(savedItems: Bool = false) -> [FeedItem] {
        privateCommentTracker.comments
            // Matched saved state
            .filter {
                if savedItems {
                    return $0.commentView.saved
                } else {
                    // If we unfavorited something while
                    // here we don't want it showing up in our feed
                    return $0.commentView.creator.id == userID
                }
            }
        
            // Create Feed Items
            .map {
                FeedItem(published: $0.commentView.comment.published, comment: $0, post: nil)
            }
    }
    
    private func generatePostFeed(savedItems: Bool = false) -> [FeedItem] {
        privatePostTracker.items
            // Matched saved state
            .filter {
                if savedItems {
                    return $0.saved
                } else {
                    // If we unfavorited something while
                    // here we don't want it showing up in our feed
                    return $0.creator.id == userID
                }
            }
        
            // Create Feed Items
            .map {
                FeedItem(published: $0.post.published, comment: nil, post: $0)
            }
    }
    
    private func generateMixedFeed(savedItems: Bool) -> [FeedItem] {
        var result: [FeedItem] = []
        
        result.append(contentsOf: generatePostFeed(savedItems: savedItems))
        result.append(contentsOf: generateCommentFeed(savedItems: savedItems))
        
        return result
    }
}
