//
//  PostComposerView.swift
//  Mlem
//
//  Created by Weston Hanners on 6/29/23.
//

import Dependencies
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

    var body: some View {
        PostDetailEditorView(
            community: community,
            postTitle: $postTitle,
            postURL: $postURL,
            postBody: $postBody,
            isNSFW: $isNSFW
        ) {
            try await postPost(to: community,
                               postTitle: postTitle.trimmed,
                               postBody: postBody.trimmed,
                               postURL: postURL.trimmed,
                               postIsNSFW: isNSFW,
                               postTracker: postTracker,
                               account: appState.currentActiveAccount)
            
            print("Post Successful")
            
            dismiss()
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
