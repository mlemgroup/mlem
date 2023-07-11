//
//  ReportComposerView.swift
//  Mlem
//
//  Created by Jake Shirley on 7/1/23.
//

import SwiftUI

struct ReportComposerView: View {
    
    var reportedPost: APIPostView?
    var reportedComment: APICommentView?
    
    // environment
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    @State private var reportReason: String = ""
    @State private var isSubmitting: Bool = false
    
    func submitPostReport(for post: APIPostView) async {
        do {
            isSubmitting = true
            
            _ = try await reportPost(
                postId: post.post.id,
                account: appState.currentActiveAccount,
                reason: reportReason,
                appState: appState
            )
            
            dismiss()
            
        } catch {
            appState.contextualError = .init(underlyingError: error)
            isSubmitting = false
        }
    }
    
    func submitCommentReport(for comment: APICommentView) async {
        do {
            isSubmitting = true
            
            _ = try await reportComment(
                commentId: comment.comment.id,
                account: appState.currentActiveAccount,
                reason: reportReason,
                appState: appState
            )
            
            dismiss()
            
        } catch {
            appState.contextualError = .init(underlyingError: error)
            isSubmitting = false
        }
    }
    
    private var isReadyToPost: Bool {
        return !reportReason.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ZStack {
                    VStack {
                        if let post = reportedPost {
                            FeedPost(
                                postView: post,
                                showPostCreator: true,
                                showCommunity: true,
                                showInteractionBar: false,
                                enableSwipeActions: false,
                                isDragging: .constant(false),
                                replyToPost: nil
                            )
                        } else if let comment = reportedComment {
                            CommentItem(
                                hierarchicalComment: HierarchicalComment(comment: comment, children: []),
                                postContext: nil,
                                depth: 0,
                                showPostContext: false,
                                showCommentCreator: true,
                                isDragging: .constant(false),
                                showInteractionBar: false,
                                enableSwipeActions: false,
                                replyToComment: nil
                            )
                        }
                        
                        TextField("Reason for report",
                                  text: $reportReason,
                                  axis: .vertical)
                        .accessibilityLabel("Report Reason")
                        .padding()
                        
                        Spacer().layoutPriority(1)
                    }
                    
                    // Loading Indicator
                    if isSubmitting {
                        ZStack {
                            Color.gray.opacity(0.3)
                            ProgressView()
                        }
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("Submitting Report")
                        .edgesIgnoringSafeArea(.all)
                        .allowsHitTesting(false)
                    }
                }
                
                .navigationTitle("Report Content")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel", role: .destructive) {
                            dismiss()
                        }
                        .tint(.red)
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        // Submit Button
                        Button {
                            Task(priority: .userInitiated) {
                                if let report = reportedPost {
                                    await submitPostReport(for: report)
                                } else if let report = reportedComment {
                                    await submitCommentReport(for: report)
                                }
                            }
                        } label: {
                            Image(systemName: "paperplane")
                        }.disabled(isSubmitting || !isReadyToPost)
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}
