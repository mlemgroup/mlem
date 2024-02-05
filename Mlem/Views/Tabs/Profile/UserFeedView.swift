//
//  UserFeedView.swift
//  Mlem
//
//  Created by Sjmarf on 25/08/2023.
//

import Dependencies
import SwiftUI

struct UserFeedView: View {
    @Dependency(\.siteInformation) var siteInformation
    @EnvironmentObject var editorTracker: EditorTracker
    
    var user: UserModel
    
    // TODO: this private post tracker feels super ugly
    @ObservedObject var privatePostTracker: StandardPostTracker
    @ObservedObject var privateCommentTracker: CommentTracker
    @ObservedObject var communityTracker: ContentTracker<CommunityModel>
    
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
        siteInformation.myUserInfo?.localUserView.person.id == user.userId
    }
    
    var body: some View {
        LazyVStack(spacing: 0) {
            switch selectedTab {
            case .communities:
                Label(
                    "\(user.displayName) moderates ^[\(communityTracker.items.count) communities](inflect: true).",
                    systemImage: Icons.moderationFill
                )
                .foregroundStyle(.secondary)
                .font(.footnote)
                .padding(.vertical, 4)
                Divider()
                ForEach(communityTracker.items, id: \.uid) { community in
                    CommunityResultView(community, complications: .instanceOnly, trackerCallback: {
                        communityTracker.update(with: $0)
                    })

                    Divider()
                }
                .environmentObject(communityTracker)
            default:
                let feedItems = generateFeed()
                if feedItems.isEmpty {
                    emptyFeed
                } else {
                    ForEach(feedItems, id: \.uid) { feedItem in
                        if let post = feedItem.post {
                            postEntry(for: post)
                        }
                        if let comment = feedItem.comment {
                            commentEntry(for: comment)
                        }
                    }
                }
            }
        }
    }
    
    func generateFeed() -> [FeedItem] {
        let feed: [FeedItem]
        switch selectedTab {
        case .overview:
            feed = generateOverviewFeed()
        case .comments:
            feed = generateCommentFeed()
        case .posts:
            feed = generatePostFeed()
        default:
            feed = []
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
                    postTracker: privatePostTracker,
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
                commentTracker: privateCommentTracker,
                hierarchicalComment: comment,
                postContext: nil,
                indentBehaviour: .never,
                showPostContext: true,
                showCommentCreator: false,
                pageContext: .profile
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
                $0.commentView.creator.id == user.userId
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
    
    private func generatePostFeed() -> [FeedItem] {
        privatePostTracker.items
            .filter {
                $0.creator.userId == user.userId
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
    
    private func generateOverviewFeed() -> [FeedItem] {
        var result: [FeedItem] = []
        
        result.append(contentsOf: generatePostFeed())
        result.append(contentsOf: generateCommentFeed())
        
        return result
    }
}
