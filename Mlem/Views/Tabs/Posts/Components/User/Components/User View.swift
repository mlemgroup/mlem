//
//  User View.swift
//  Mlem
//
//  Created by David Bureš on 02.04.2022.
//

import CachedAsyncImage
import SwiftUI

/// View for showing user profiles
/// Accepts the following parameters:
/// - **userID**: Non-optional ID of the user
/// - **account**: Authenticated account to make the requests
struct UserView: View {
    // appstorage
    @AppStorage("shouldShowUserHeaders") var shouldShowUserHeaders: Bool = true
    
    // environment
    @EnvironmentObject var appState: AppState
    
    // parameters
    @State var userID: Int
    @State var account: SavedAccount
    @State var userDetails: APIPersonView?

    // members
    @State private var errorAlert: ErrorAlert?
    @StateObject private var privateCommentReplyTracker: CommentReplyTracker = .init()
    @StateObject private var privatePostTracker: PostTracker = .init()
    @StateObject private var privateCommentTracker: CommentTracker = .init()
    
    @State private var selectionSection = 0
    @State var isDragging: Bool = false
    @FocusState var isReplyFieldFocused
    
    enum FeedType : String, CaseIterable, Identifiable {
        case Overview = "Overview"
        case Comments = "Comments"
        case Posts = "Posts"
        case Saved = "Saved"
        
        var id: String { return self.rawValue }
    }
    
    struct FeedItem : Identifiable {
        let id = UUID()
        let published: Date
        let comment: HierarchicalComment?
        let post: APIPostView?
    }
    
    var body: some View {
        contentView
            .alert(using: $errorAlert) { content in
                Alert(title: Text(content.title), message: Text(content.message))
            }
    }
    
    @ViewBuilder
    private var contentView: some View {
        if let userDetails {
            view(for: userDetails)
        } else {
            progressView
        }
    }
    
    private func view(for userDetails: APIPersonView) -> some View {
        ScrollView {
            CommunitySidebarHeader(
                title: userDetails.person.displayName ?? userDetails.person.name,
                subtitle: "@\(userDetails.person.name)@\(userDetails.person.actorId.host()!)",
                avatarSubtext: "Joined \(userDetails.person.published.getRelativeTime(date: Date.now))",
                bannerURL: shouldShowUserHeaders ? userDetails.person.banner : nil,
                avatarUrl: userDetails.person.avatar,
                label1: "\(userDetails.counts.commentCount) Comments",
                label2: "\(userDetails.counts.postCount) Posts")
            
            if let bio = userDetails.person.bio {
                MarkdownView(text: bio).padding()
            }
            
            Picker(selection: $selectionSection, label: Text("Profile Section")) {
                Text(FeedType.Overview.rawValue).tag(0)
                Text(FeedType.Comments.rawValue).tag(1)
                Text(FeedType.Posts.rawValue).tag(2)
                
                // Only show saved posts if we are
                // browsing our own profile
                if isShowingOwnProfile() {
                    Text(FeedType.Saved.rawValue).tag(3)
                }
                
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            switch selectionSection {
            case 0:
                mixedFeed
            case 1:
                commentsFeed
            case 2:
                postsFeed
            case 3:
                savedFeed
            default:
                Text("Coming soon!")
            }
        }
        .environmentObject(privateCommentReplyTracker)
        .environmentObject(privatePostTracker)
        .environmentObject(privateCommentTracker)
        .navigationTitle(userDetails.person.displayName ?? userDetails.person.name)
        .navigationBarTitleDisplayMode(.inline)
        .headerProminence(.standard)
        .refreshable {
            await tryLoadUser()
        }
    }
    
    private func isShowingOwnProfile() -> Bool {
        return userID == account.id
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
    
    @ViewBuilder
    private var commentsFeed: some View {
        LazyVStack {
            if generateCommentFeed(savedItems: false).isEmpty {
                emptyFeed
            }
            else {
                ForEach(generateCommentFeed(savedItems: false))
                { feedItem in
                    commentEntry(for: feedItem.comment!)
                    Spacer().frame(height: 8)
                }
            }
        }.background(Color.secondarySystemBackground)
    }
    
    @ViewBuilder
    private var postsFeed: some View {
        LazyVStack {
            if generatePostFeed(savedItems: false).isEmpty {
                emptyFeed
            }
            else {
                ForEach(generatePostFeed(savedItems: false))
                { feedItem in
                    postEntry(for: feedItem.post!)
                    Spacer().frame(height: 8)
                }
            }
        }
        .background(Color.secondarySystemBackground)
    }
    
    @ViewBuilder
    private var mixedFeed: some View {
        LazyVStack {
            if generateMixedFeed(savedItems: false).isEmpty {
                emptyFeed
            }
            else {
                ForEach(generateMixedFeed(savedItems: false))
                { feedItem in
                    if let comment = feedItem.comment {
                        commentEntry(for: comment)
                    }
                    else if let post = feedItem.post {
                        postEntry(for: post)
                    }
                    Spacer().frame(height: 8)
                }
            }
        }.background(Color.secondarySystemBackground)
    }
    
    @ViewBuilder
    private var savedFeed: some View {
        LazyVStack {
            if generateMixedFeed(savedItems: true).isEmpty {
                emptyFeed
            }
            else {
                ForEach(generateMixedFeed(savedItems: true))
                { feedItem in
                    if let comment = feedItem.comment {
                        commentEntry(for: comment)
                    }
                    else if let post = feedItem.post {
                        postEntry(for: post)
                    }
                    Spacer().frame(height: 8)
                }
            }
        }.background(Color.secondarySystemBackground)
    }
    
    private func generateCommentFeed(savedItems: Bool) -> [FeedItem] {
        return privateCommentTracker.comments
            // Matched saved state
            .filter({
                if savedItems {
                    return $0.commentView.saved
                } else {
                    // If we un-favorited something while
                    // here we don't want it showing up in our feed
                    return $0.commentView.creator.id == userID
                }
            })
        
            // Create Feed Items
            .map({
                return FeedItem(published: $0.commentView.comment.published, comment: $0, post: nil)
            })
        
            // Newest first
            .sorted(by: {
            $0.published > $1.published
        })
    }
    
    private func generatePostFeed(savedItems: Bool) -> [FeedItem] {
        return privatePostTracker.posts
            // Matched saved state
            .filter({
                if savedItems {
                    return $0.saved
                } else {
                    // If we un-favorited something while
                    // here we don't want it showing up in our feed
                    return $0.creator.id == userID
                }
            })
        
            // Create Feed Items
            .map({
                return FeedItem(published: $0.post.published, comment: nil, post: $0)
            })
        
            // Newest first
            .sorted(by: {
            $0.published > $1.published
        })
    }
    
    private func generateMixedFeed(savedItems: Bool) -> [FeedItem] {
        var result: [FeedItem] = []
        
        result.append(contentsOf: generatePostFeed(savedItems: savedItems))
        result.append(contentsOf: generateCommentFeed(savedItems: savedItems))
        
        // Sort by authored date, newest first
        result = result.sorted(by: {
            $0.published > $1.published
        })
        
        return result;
    }
    
    @MainActor
    private var progressView: some View {
        ProgressView {
            if isShowingOwnProfile() {
                Text("Loading your profile…")
            }
            else {
                Text("Loading user profile…")
            }
        }
        .task(priority: .userInitiated) {
            await tryLoadUser()
        }
    }
    
    private func tryLoadUser() async {
        do {
            let authoredContent = try await loadUser(savedItems: false)
            var savedContentData: GetPersonDetailsResponse? = nil
            if isShowingOwnProfile() {
                savedContentData = try await loadUser(savedItems: true)
            }
            
            privateCommentTracker.add(authoredContent.comments
                .sorted(by: { $0.comment.published > $1.comment.published})
                .map({HierarchicalComment(comment: $0, children: [])}))
            
            privatePostTracker.add(authoredContent.posts)
            
            if let savedContent = savedContentData {
                privateCommentTracker.add(savedContent.comments
                    .sorted(by: { $0.comment.published > $1.comment.published})
                    .map({HierarchicalComment(comment: $0, children: [])}))
                
                privatePostTracker.add(savedContent.posts)
            }
            
            userDetails = authoredContent.personView
        } catch {
            handle(error)
        }
    }
    
    private func loadUser(savedItems: Bool) async throws -> GetPersonDetailsResponse {
        let request = try GetPersonDetailsRequest(
            accessToken: account.accessToken,
            instanceURL: account.instanceLink,
            limit: 20, // TODO: Stream pages
            savedOnly: savedItems,
            personId: userID
        )
        
        return try await APIClient().perform(request: request)
    }
    
    private func handle(_ error: Error) {
        switch error {
        case APIClientError.response(let message, _):
            errorAlert = .init(
                title: "Error",
                message: message.error
            )
        case is APIClientError:
            errorAlert = .init(
                title: "Couldn't load user info",
                message: "There was an error while loading user information.\nTry again later."
            )
        default:
            errorAlert = .unexpected
        }
    }
    
    /*
     User post
     */
    private func postEntry(for post: APIPostView) -> some View {
        NavigationLink {
            ExpandedPost(account: account , post: post, feedType: .constant(.subscribed))
        } label: {
            FeedPost(postView: post, account: account, isDragging: $isDragging)
        }
        .buttonStyle(.plain)
    }
    
    /*
     User comment
     */
    private func commentEntry(for comment: HierarchicalComment) -> some View {
        VStack {
            HStack {
                CommentItem(account: account, hierarchicalComment: comment, postContext: nil, depth: 0, showPostContext: true, isDragging: $isDragging)
                    .padding(.vertical)
                Spacer()
            }
        }.background(Color.systemBackground)
    }
}


// TODO: darknavi - Move these to a common area for reuse
struct UserViewPreview : PreviewProvider {
    static let previewAccount = SavedAccount(id: 0, instanceLink: URL(string: "lemmy.com")!, accessToken: "abcdefg", username: "Test Account")
    
    // Only Admin and Bot work right now
    // Because the rest require post/comment context
    enum PreviewUserType:  String, CaseIterable {
        case Normal = "normal"
        case Mod = "mod"
        case OP = "op"
        case Bot = "bot"
        case Admin = "admin"
        case Dev = "developer"
    }
    
    static func generatePreviewUser(name: String, displayName: String, userType: PreviewUserType) -> APIPerson {
        return APIPerson(id: name.hashValue, name: name, displayName: displayName, avatar: URL(string: "https://lemmy.ml/pictrs/image/df86c06d-341c-4e79-9c80-d7c7eb64967a.jpeg?format=webp"), banned: false, published: Date.now.advanced(by: -10000), updated: nil, actorId: URL(string: "https://google.com")!, bio: "Just here for the good vibes!", local: false, banner: URL(string: "https://i.imgur.com/wcayaCB.jpeg"), deleted: false, sharedInboxUrl: nil, matrixUserId: nil, admin: userType == .Admin, botAccount: userType == .Bot, banExpires: nil, instanceId: 123)
    }
    
    static func generatePreviewComment(creator: APIPerson, isMod: Bool) -> APIComment {
        return APIComment(id: 0, creatorId: creator.id, postId: 0, content: "", removed: false, deleted: false, published: Date.now, updated: nil, apId: "foo.bar", local: false, path: "foo", distinguished: isMod, languageId: 0)
    }
    
    static func generateFakeCommunity(id: Int, namePrefix: String) -> APICommunity {
        return APICommunity(id: id, name: "\(namePrefix) Fake Community \(id)", title: "\(namePrefix) Fake Community \(id) Title", description: "This is a fake community (#\(id))", published: Date.now, updated: nil, removed: false, deleted: false, nsfw: false, actorId: URL(string: "https://lemmy.google.com/c/\(id)")!, local: false, icon: nil, banner: nil, hidden: false, postingRestrictedToMods: false, instanceId: 0)
    }
    
    static func generatePreviewPost(creator: APIPerson) -> APIPostView {
        let community = generateFakeCommunity(id: 123, namePrefix: "Test")
        let post = APIPost(id: 123, name: "Test Post Title", url: nil, body: "This is a test post body", creatorId: creator.id, communityId: 123, deleted: false, embedDescription: "Embeedded Description", embedTitle: "Embedded Title", embedVideoUrl: nil, featuredCommunity: false, featuredLocal: false, languageId: 0, apId: "my.app.id", local: false, locked: false, nsfw: false, published: Date.now, removed: false, thumbnailUrl: nil, updated: nil)
        
        let postVotes = APIPostAggregates(id: 123, postId: post.id, comments: 0, score: 10, upvotes: 15, downvotes: 5, published: Date.now, newestCommentTime: Date.now, newestCommentTimeNecro: Date.now, featuredCommunity: false, featuredLocal: false)
        
        return APIPostView(post: post, creator: creator, community: community, creatorBannedFromCommunity: false, counts: postVotes, subscribed: .notSubscribed, saved: false, read: false, creatorBlocked: false, unreadComments: 0)
    }
    
    static func generateUserProfileLink(name: String, userType: PreviewUserType) -> UserProfileLink {
        let previewUser = generatePreviewUser(name: name, displayName: name, userType: userType);
        
        var postContext: APIPostView? = nil
        var commentContext: APIComment? = nil
        
        if userType == .Mod {
            commentContext = generatePreviewComment(creator: previewUser, isMod:  true)
        }
        
        if userType == .OP {
            commentContext = generatePreviewComment(creator: previewUser, isMod:  false)
            postContext = generatePreviewPost(creator: previewUser)
        }
        
        return UserProfileLink(account: UserViewPreview.previewAccount, user: previewUser, showServerInstance: true)
    }
    
    static var previews: some View {
        UserView(userID: 123, account: previewAccount, userDetails: APIPersonView(person: generatePreviewUser(name: "actualUsername", displayName: "PreferredUsername", userType: .Normal), counts: APIPersonAggregates(id: 123, personId: 123, postCount: 123, postScore: 567, commentCount: 14, commentScore: 974)))
    }
}
