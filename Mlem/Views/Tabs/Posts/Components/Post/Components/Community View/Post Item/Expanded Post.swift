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
    
    // appstorage
    @AppStorage("defaultCommentSorting") var defaultCommentSorting: CommentSortType = .top
    @AppStorage("shouldShowUserServerInComment") var shouldShowUserServerInComment: Bool = false
    @AppStorage("shouldShowUserAvatars") var shouldShowUserAvatars: Bool = false

    @EnvironmentObject var appState: AppState

    @StateObject var commentTracker: CommentTracker = .init()
    @StateObject var commentReplyTracker: CommentReplyTracker = .init()

    @EnvironmentObject var postTracker: PostTracker

    @State var post: APIPostView
    
    @State var responseItem: ConcreteRespondable?

    @State private var sortSelection = 0

    @State private var commentSortingType: CommentSortType = .top

    @State private var isInTheMiddleOfStyling: Bool = false

    @State private var viewID: UUID = UUID()
    
    @State var isDragging: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                postView
                
                Divider()
                    .background(.black)

                if commentTracker.isLoading {
                    commentsLoadingView
                } else {
                    if commentTracker.comments.count == 0 {
                        noCommentsView
                    } else {
                        commentsView
                    }
                }
            }
        }
        .scrollDisabled(isDragging)
        .sheet(item: $responseItem) { responseItem in
            ResponseComposerView(concreteRespondable: responseItem)
        }
        .environmentObject(commentTracker)
        .environmentObject(commentReplyTracker)
        .navigationBarTitle(post.community.name, displayMode: .inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
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
        .refreshable {
            Task(priority: .userInitiated) {
                commentTracker.comments = .init()
                await loadComments()
            }
        }
        .onChange(of: commentSortingType) { newSortingType in
            withAnimation(.easeIn(duration: 0.4)) {
                commentTracker.comments = sortComments(commentTracker.comments, by: newSortingType)
            }
        }
    }
    // subviews

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
                
                UserProfileLink(user: post.creator, serverInstanceLocation: .bottom)
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
     Displays a loading indicator for the comments
     */
    private var commentsLoadingView: some View {
        ProgressView("Loading comments…")
            .padding(.top, AppConstants.postAndCommentSpacing)
            .task(priority: .userInitiated) {
                if post.counts.comments != 0 {
                    await loadComments()
                } else {
                    commentTracker.isLoading = false
                }
            }
            .onAppear {
                commentSortingType = defaultCommentSorting
            }
    }

    /**
     Displays a "no comments" message
     */
    private var noCommentsView: some View {
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

    /**
     Displays the comments
     */
    private var commentsView: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            ForEach(commentTracker.comments) { comment in
                CommentItem(
                    hierarchicalComment: comment,
                    postContext: post,
                    depth: 0,
                    showPostContext: false,
                    showCommentCreator: true,
                    isDragging: $isDragging,
                    replyToComment: replyToComment
                )
            }
        }
        .environmentObject(commentTracker)
    }
}
