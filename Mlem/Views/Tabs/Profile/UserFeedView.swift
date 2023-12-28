//
//  UserFeedView.swift
//  Mlem
//
//  Created by Sjmarf on 25/08/2023.
//

import SwiftUI
import Dependencies

struct UserFeedView: View {
    @Dependency(\.siteInformation) var siteInformation
    @EnvironmentObject var editorTracker: EditorTracker
    
    var userID: Int
    @ObservedObject var privatePostTracker: PostTracker
    @ObservedObject var privateCommentTracker: CommentTracker
    
    @Binding var selectedTab: UserViewTab
    
    struct FeedItem: Identifiable, Hashable {
        static func == (lhs: UserFeedView.FeedItem, rhs: UserFeedView.FeedItem) -> Bool {
            lhs.hashValue == rhs.hashValue
        }
        
        var id: Int { hashValue }
        var uid: ContentModelIdentifier
        let published: Date
        let comment: HierarchicalComment?
        let post: PostModel?
        let hashValue: Int
    }
    
    var isOwnProfile: Bool {
        return siteInformation.myUserInfo?.localUserView.person.id == userID
    }
    
    var body: some View {
        let feedItems = generateFeed()
        Group {
            if feedItems.isEmpty {
                emptyFeed
            } else {
                LazyVStack(spacing: 0) {
                    content(feedItems)
                }
            }
        }
    }
    
    func content(_ feed: [FeedItem]) -> some View {
        ForEach(feed, id: \.uid) { feedItem in
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
        
        return feed.sorted(by: {
            $0.published > $1.published
        })
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
        .buttonStyle(EmptyButtonStyle())
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
    
    var emptyFeedText: String {
        if isOwnProfile {
            return "Nothing to see here, get out there and make some stuff!"
        } else {
            return "Nothing to see here."
        }
    }
    
    @ViewBuilder
    private var emptyFeed: some View {
        Text(emptyFeedText)
            .padding()
            .font(.headline)
            .opacity(0.5)
            .multilineTextAlignment(.center)
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
                FeedItem(
                    uid: ContentModelIdentifier(contentType: .comment, contentId: $0.commentView.comment.id),
                    published: $0.commentView.comment.published,
                    comment: $0,
                    post: nil,
                    hashValue: $0.hashValue
                )
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
                    return $0.creator.userId == userID
                }
            }
        
            // Create Feed Items
            .map {
                FeedItem(
                    uid: ContentModelIdentifier(contentType: .post, contentId: $0.postId),
                    published: $0.post.published,
                    comment: nil,
                    post: $0,
                    hashValue: $0.hashValue
                )
            }
    }
    
    private func generateMixedFeed(savedItems: Bool) -> [FeedItem] {
        var result: [FeedItem] = []
        
        result.append(contentsOf: generatePostFeed(savedItems: savedItems))
        result.append(contentsOf: generateCommentFeed(savedItems: savedItems))
        
        return result
    }
}
