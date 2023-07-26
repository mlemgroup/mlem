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
    
    var body: some View {
        //        VStack(spacing: 0) {
        ////            ScrollView {
        //                //            Section {
        //                postView
        //                //            }
        //                
        //                //                Divider()
        //                //                    .background(.black)
        //                
        //                //            Section {
        //                if commentTracker.isLoading {
        //                    commentsLoadingView
        //                } else {
        //                    if commentTracker.comments.count == 0 {
        //                        noCommentsView
        //                    } else {
        //                        commentsView
        //                    }
        //                }
        //                //            }
        ////            }
        //        }
        Group {
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
        .listStyle(PlainListStyle())
        .fancyTabScrollCompatible()
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
//        LazyVStack(alignment: .leading, spacing: 0) {
        List(commentTracker.comments) { comment in
                // swiftlint:disable redundant_discardable_let
                let _ = print("drawing parent comment \(comment.id) at depth 0: \(comment.commentView.comment.content.prefix(30))")
                // swiftlint:enable redundant_discardable_let
                CommentItem(
                    hierarchicalComment: comment,
                    postContext: post,
                    depth: comment.depth,
                    showPostContext: false,
                    showCommentCreator: true,
                    replyToComment: replyToComment
                )
            }
//        }
        .environmentObject(commentTracker)
    }
}
