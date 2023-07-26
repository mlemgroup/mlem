//
//  PostComposerView.swift
//  Mlem
//
//  Created by Weston Hanners on 6/29/23.
//

import Dependencies
import SwiftUI

struct PostComposerView: View {
    
    @Environment(\.dismiss) var dismiss
    
    let appState: AppState
    let postTracker: PostTracker
    let editModel: PostEditorModel
    
    @State var postTitle: String
    @State var postURL: String
    @State var postBody: String
    @State var isNSFW: Bool
    
    init(editModel: PostEditorModel) {
        self.appState = editModel.appState
        self.postTracker = editModel.postTracker
        self.editModel = editModel
        
        self._postTitle = State(initialValue: editModel.editPost?.name ?? "")
        self._postURL = State(initialValue: editModel.editPost?.url?.description ?? "")
        self._postBody = State(initialValue: editModel.editPost?.body ?? "")
        self._isNSFW = State(initialValue: editModel.editPost?.nsfw ?? false)
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
                try await editPost(postId: post.id,
                                   postTitle: postTitle,
                                   postBody: postBody,
                                   postURL: postURL,
                                   postIsNSFW: isNSFW,
                                   postTracker: postTracker,
                                   account: appState.currentActiveAccount)
                print("Edit successful")
            } else {
                try await postPost(to: editModel.community,
                                   postTitle: postTitle.trimmed,
                                   postBody: postBody.trimmed,
                                   postURL: postURL.trimmed,
                                   postIsNSFW: isNSFW,
                                   postTracker: postTracker,
                                   account: appState.currentActiveAccount)
                print("Post Successful")
            }
            
            dismiss()
        }
    }
}

struct PostComposerView_Previews: PreviewProvider {
    static let community = generateFakeCommunity(id: 1,
                                                 namePrefix: "mlem")
    
    static var previews: some View {
        PostComposerView(editModel: PostEditorModel(community: community,
                                                    appState: AppState(defaultAccount: generateFakeAccount(),
                                                                       selectedAccount: Binding.constant(generateFakeAccount()))))
    }
}
