//
//  PostComposerView.swift
//  Mlem
//
//  Created by Weston Hanners on 6/29/23.
//

import Dependencies
import SwiftUI

struct PostComposerView: View {
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.hapticManager) var hapticManager
    
    @Environment(\.dismiss) var dismiss
    
    let postTracker: PostTrackerNew
    let editModel: PostEditorModel
    
    @State var postTitle: String
    @State var postURL: String
    @State var postBody: String
    @State var isNSFW: Bool
    
    init(editModel: PostEditorModel) {
        self.postTracker = editModel.postTracker
        self.editModel = editModel
        
        self._postTitle = State(initialValue: editModel.editPost?.post.name ?? "")
        self._postURL = State(initialValue: editModel.editPost?.post.url?.description ?? "")
        self._postBody = State(initialValue: editModel.editPost?.post.body ?? "")
        self._isNSFW = State(initialValue: editModel.editPost?.post.nsfw ?? false)
    }

    var body: some View {
        PostDetailEditorView(
            community: editModel.community,
            postTitle: $postTitle,
            postURL: $postURL,
            postBody: $postBody,
            isNSFW: $isNSFW
        ) {
            if let post = editModel.editPost {
                let editedPost = await postTracker.edit(post: post, name: postTitle, url: postURL, body: postBody, nsfw: isNSFW)
                
                if let responseCallback = editModel.responseCallback {
                    responseCallback(editedPost)
                }
                
            } else {
                let response = try await apiClient.createPost(
                    communityId: editModel.community.id,
                    name: postTitle.trimmed,
                    nsfw: isNSFW,
                    body: postBody.trimmed,
                    url: postURL.trimmed
                )
                
                hapticManager.play(haptic: .success, priority: .high)
                
                await MainActor.run {
                    withAnimation {
                        postTracker.prepend(PostModel(from: response.postView))
                    }
                }
            }
            
            dismiss()
        }
    }
}

struct PostComposerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PostComposerView(
                editModel: PostEditorModel(
                    community: .mock(id: 1, name: "mlem")
                )
            )
        }
    }
}
