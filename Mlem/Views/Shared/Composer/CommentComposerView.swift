//
//  CommentComposerView.swift
//  Mlem
//
//  Created by Weston Hanners on 7/2/23.
//

import SwiftUI

struct CommentComposerView: View {
    
    init(replyTo post: APIPostView) {
        self.post = post
    }
    
    var post: APIPostView
            
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var commentTracker: CommentTracker
    @EnvironmentObject var appState: AppState

    @State var postTitle: String = ""
    @State var postURL: String = ""
    @State var replybody: String = ""
    @State var isNSFW: Bool = false
    
    @State var isSubmitting: Bool = false
    @State var isBadURL: Bool = false

    private var isReadyToReply: Bool {
        return replybody.trimmed.isNotEmpty
    }

    func submitPost() async {
        do {
            isSubmitting = true
            
            try await postComment(
                to: post,
                commentContents: replybody,
                commentTracker: commentTracker,
                account: appState.currentActiveAccount,
                appState: appState)
                
                print("Reply Successful")
            
            dismiss()
            
        } catch {
            appState.contextualError = .init(underlyingError: error)
            isSubmitting = false
        }
    }
    
    func uploadImage() {
        print("Uploading")
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ZStack {
                    VStack(spacing: 15) {
                        
                        // Post Text
                        TextField("What do you want to say?",
                                  text: $replybody,
                                  axis: .vertical)
                        .accessibilityLabel("Reply Body")
                        .padding()
                        
                        Spacer()
                        
                        // Comment Context
                        FeedPost(postView: post,
                                 showPostCreator: true,
                                 showCommunity: true,
                                 showInteractionBar: false,
                                 enableSwipeActions: false,
                                 isDragging: Binding.constant(false),
                                 replyToPost: nil)
                    }
                    
                    // Loading Indicator
                    if isSubmitting {
                        ZStack {
                            Color.gray.opacity(0.3)
                            ProgressView()
                        }
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("Submitting Reply")
                        .edgesIgnoringSafeArea(.all)
                        .allowsHitTesting(false)
                    }
                }
                
                .navigationTitle("New Comment")
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
                                await submitPost()
                            }
                        } label: {
                            Image(systemName: "paperplane")
                        }.disabled(isSubmitting || !isReadyToReply)
                    }
                }
                .alert("Submit Failed", isPresented: $isBadURL) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text("You seem to have entered an invalid URL, please check it again.")
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
