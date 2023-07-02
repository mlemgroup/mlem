//
//  PostComposerView.swift
//  Mlem
//
//  Created by Weston Hanners on 6/29/23.
//

import SwiftUI

struct PostComposerView: View {
    
    init(community: APICommunity) {
        self.community = community
    }
    
    var community: APICommunity
        
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var postTracker: PostTracker
    @EnvironmentObject var appState: AppState

    @State var postTitle: String = ""
    @State var postURL: String = ""
    @State var postBody: String = ""
    @State var isNSFW: Bool = false
    
    @State var isSubmitting: Bool = false
    @State var isBadURL: Bool = false

    private var isReadyToPost: Bool {
        // We need postTitle to be not empty
        // and at least an attached postBody or postURL.
        return postTitle.trimmed.isNotEmpty
        && (postBody.trimmed.isNotEmpty || postURL.trimmed.isNotEmpty)
    }
    
    private var isValidURL: Bool {
        guard postURL.lowercased().hasPrefix("http://") ||
                postURL.lowercased().hasPrefix("https://") else {
            return false // URL protocol is missing
        }

        guard URL(string: postURL) != nil else {
            return false // Not Parsable
        }
        
        return true
    }
    
    func submitPost() async {
        do {
            guard let account = appState.currentActiveAccount else {
                print("Cannot Submit, No Active Account")
                return
            }
            
            guard isValidURL else {
                isBadURL = true
                return
            }
            
            isSubmitting = true
            
            try await postPost(to: community,
                               postTitle: postTitle.trimmed,
                               postBody: postBody.trimmed,
                               postURL: postURL.trimmed,
                               postIsNSFW: isNSFW,
                               postTracker: postTracker,
                               account: account)
            
            print("Post Successful")
            
            dismiss()
            
        } catch {
            print("Something went wrong)")
            isSubmitting = false
        }
    }
    
    func uploadImage() {
        print("Uploading")
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 15) {
                    
                    // Community Row
                    HStack {
                        CommunityLabel(shouldShowCommunityIcons: true,
                                       community: community)
                        Spacer()
                        // NSFW Toggle
                        NSFWToggle(compact: false, isEnabled: isNSFW)
                    }
                    
                    // Title Row
                    HStack {
                        Text("Title")
                            .foregroundColor(.secondary)
                            .accessibilityHidden(true)
                        TextField("Your post title", text: $postTitle)
                        .accessibilityLabel("Title")
                    }
                    
                    // URL Row
                    HStack {
                        Text("URL")
                            .foregroundColor(.secondary)
                            .accessibilityHidden(true)
                        
                        TextField("Your post link", text: $postURL)
                            .keyboardType(.URL)
                            .autocorrectionDisabled()
                            .autocapitalization(.none)
                            .accessibilityLabel("URL")
                        
                        // Upload button, temporarily hidden
                        //                        Button(action: uploadImage) {
                        //                            Image(systemName: "paperclip")
                        //                                .font(.title3)
                        //                                .dynamicTypeSize(.medium)
                        //                        }
                        //                        .accessibilityLabel("Upload Image")
                    }
                    
                    // Post Text
                    TextField("What do you want to say?",
                              text: $postBody,
                              axis: .vertical)
                    .accessibilityLabel("Post Body")
                    Spacer()
                }
                .padding()
                
                // Loading Indicator
                if isSubmitting {
                    ZStack {
                        Color.gray.opacity(0.3)
                        ProgressView()
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Submitting Post")
                    .edgesIgnoringSafeArea(.all)
                    .allowsHitTesting(false)
                }
            }

            .navigationTitle("New Post")
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
                    }.disabled(isSubmitting || !isReadyToPost)
                }
            }
            .alert("Submit Failed", isPresented: $isBadURL) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("You seem to have entered an invalid URL, please check it again.")
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct PostComposerView_Previews: PreviewProvider {
    static let community = generateFakeCommunity(id: 1,
                                                 namePrefix: "mlem")
        
    static var previews: some View {
        NavigationStack {
            PostComposerView(community: community)
        }
    }
}
