//
//  PostComposerView.swift
//  Mlem
//
//  Created by Weston Hanners on 6/29/23.
//

import SwiftUI

extension HorizontalAlignment {
    enum LabelStart: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context[HorizontalAlignment.leading]
        }
    }
    
    static let labelStart = HorizontalAlignment(LabelStart.self)
}

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
    @State var isShowingErrorDialog: Bool = false
    @State var errorDialogMessage: String = ""

    private var isReadyToPost: Bool {
        // This only requirement to post is a title
        return postTitle.trimmed.isNotEmpty
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
            guard postTitle.trimmed.isNotEmpty else {
                errorDialogMessage = "You need to enter a title for your post."
                isShowingErrorDialog = true
                return
            }
            
            guard postURL.lowercased().isEmpty || isValidURL else {
                errorDialogMessage = "You seem to have entered an invalid URL, please check it again."
                isShowingErrorDialog = true
                return
            }
            
            isSubmitting = true
            
            try await postPost(to: community,
                               postTitle: postTitle.trimmed,
                               postBody: postBody.trimmed,
                               postURL: postURL.trimmed,
                               postIsNSFW: isNSFW,
                               postTracker: postTracker,
                               account: appState.currentActiveAccount)
            
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
                        CommunityLabel(community: community,
                                       serverInstanceLocation: .bottom,
                                       overrideShowAvatar: true
                        )
                        Spacer()
                        // NSFW Toggle
                        NSFWToggle(compact: false, isEnabled: $isNSFW)
                    }
                    
                    VStack(alignment: .labelStart) {
                        // Title Row
                        HStack {
                            Text("Title")
                                .foregroundColor(.secondary)
                                .dynamicTypeSize(.small ... .accessibility2)
                                .accessibilityHidden(true)
                            TextField("Your post title", text: $postTitle)
                                .alignmentGuide(.labelStart) { $0[HorizontalAlignment.leading] }
                                .dynamicTypeSize(.small ... .accessibility2)
                                .accessibilityLabel("Title")
                        }
                        
                        // URL Row
                        HStack {
                            Text("URL")
                                .foregroundColor(.secondary)
                                .dynamicTypeSize(.small ... .accessibility2)
                                .accessibilityHidden(true)
                            
                            TextField("Your post link (Optional)", text: $postURL)
                                .alignmentGuide(.labelStart) { $0[HorizontalAlignment.leading] }
                                .dynamicTypeSize(.small ... .accessibility2)
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
                    }

                    // Post Text
                    TextField("What do you want to say? (Optional)",
                              text: $postBody,
                              axis: .vertical)
                    .dynamicTypeSize(.small ... .accessibility2)
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
            .alert("Submit Failed", isPresented: $isShowingErrorDialog) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorDialogMessage)
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
