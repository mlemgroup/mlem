//
//  Opened Post.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import Dependencies
import SwiftUI

internal enum PossibleStyling {
    case bold, italics
}

struct ExpandedPost: View {
    
    @Dependency(\.commentRepository) var commentRepository
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.notifier) var notifier
    @Dependency(\.hapticManager) var hapticManager
    
    // appstorage
    @AppStorage("defaultCommentSorting") var defaultCommentSorting: CommentSortType = .top
    @AppStorage("shouldShowUserServerInComment") var shouldShowUserServerInComment: Bool = false
    @AppStorage("shouldShowUserAvatars") var shouldShowUserAvatars: Bool = false

    @EnvironmentObject var appState: AppState
    @EnvironmentObject var editorTracker: EditorTracker

    @StateObject var commentTracker: CommentTracker = .init()
    @EnvironmentObject var postTracker: PostTracker
    @State var post: APIPostView
    
    @State var isLoading: Bool = false

    @State private var sortSelection = 0
    @State private var commentSortingType: CommentSortType = .top
    
    var body: some View {
        contentView
            .environmentObject(commentTracker)
            .navigationBarTitle(post.community.name, displayMode: .inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) { toolbarMenu }
            }
            .task { await loadComments() }
            .refreshable { await refreshComments() }
            .onChange(of: commentSortingType) { newSortingType in
                withAnimation(.easeIn(duration: 0.4)) {
                    commentTracker.comments = sortComments(commentTracker.comments, by: newSortingType)
                }
            }
    }
    
    private var contentView: some View {
        ScrollView {
            VStack(spacing: 0) {
                postView
                    .id(post.hashValue)
                
                Divider()
                    .background(.black)

                if commentTracker.comments.isEmpty {
                    noCommentsView()
                } else {
                    commentsView
                }
            }
        }
        .listStyle(PlainListStyle())
        .fancyTabScrollCompatible()
    }
    
    // MARK: Subviews

    /**
     Displays the post itself, plus a little divider to keep it visually distinct from comments
     */
    private var postView: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: AppConstants.postAndCommentSpacing) {
                HStack {
                    CommunityLinkView(community: post.community)
                    
                    Spacer()
                    
                    EllipsisMenu(size: 24, menuFunctions: genMenuFunctions())
                }
                
                LargePost(
                    postView: post,
                    isExpanded: true
                )
                
                UserProfileLink(user: post.creator,
                                serverInstanceLocation: .bottom,
                                postContext: post.post)
            }
            .padding(.top, AppConstants.postAndCommentSpacing)
            .padding(.horizontal, AppConstants.postAndCommentSpacing)
            
            PostInteractionBar(postView: post,
                               menuFunctions: genMenuFunctions(),
                               voteOnPost: voteOnPost,
                               updatedSavePost: savePost,
                               deletePost: deletePost,
                               replyToPost: replyToPost)
        }
    }

    /**
     Displays a "no comments" message
     */
    @ViewBuilder
    private func noCommentsView() -> some View {
        if isLoading {
            LoadingView(whatIsLoading: .comments)
        } else {
            VStack(spacing: 2) {
                VStack(spacing: 5) {
                    Image(systemName: "binoculars")
                    Text("No comments to be found")
                }
                Text("Why not post the first one?")
                    .font(.caption)
            }
            .foregroundColor(.secondary)
            .padding()
        }
    }

    /**
     Displays the comments
     */
    private var commentsView: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            ForEach(commentTracker.commentsView, id: \.commentView.comment.hashValue) { comment in
                CommentItem(
                    hierarchicalComment: comment,
                    postContext: post,
                    showPostContext: false,
                    showCommentCreator: true
                )
            }
        }
    }
    
    private var toolbarMenu: some View {
        Menu {
            ForEach(CommentSortType.allCases, id: \.self) { type in
                Button {
                    commentSortingType = type
                } label: {
                    Label(type.description, systemImage: type.imageName)
                }
                .disabled(type == commentSortingType)
            }

        } label: {
            Label(commentSortingType.description, systemImage: commentSortingType.imageName)
        }
    }
}
