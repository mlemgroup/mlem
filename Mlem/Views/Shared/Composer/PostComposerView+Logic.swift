//
//  PostComposerView+Logic.swift
//  Mlem
//
//  Created by Sjmarf on 24/09/2023.
//

import Foundation
import PhotosUI
import SwiftUI

extension PostComposerView {
    var hasPostContent: Bool {
        !postTitle.isEmpty || !attachmentModel.url.isEmpty || !postBody.isEmpty || attachmentModel.imageModel != nil
    }
    
    var isReadyToPost: Bool {
        switch attachmentModel.imageModel?.state {
        case nil, .uploaded:
            return postTitle.trimmed.isNotEmpty && titleSlurMatch == nil && bodySlurMatch == nil
        default:
            return false
        }
    }
    
    var isValidURL: Bool {
        guard attachmentModel.url.lowercased().hasPrefix("http://") ||
            attachmentModel.url.lowercased().hasPrefix("https://") else {
            return false // URL protocol is missing
        }

        guard URL(string: attachmentModel.url) != nil else {
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
            
            guard attachmentModel.url.lowercased().isEmpty || isValidURL else {
                errorDialogMessage = "You seem to have entered an invalid URL, please check it again."
                isShowingErrorDialog = true
                return
            }
            
            isSubmitting = true
            
            if let post = editModel.editPost {
                await post.edit(name: postTitle, url: attachmentModel.url, body: postBody, nsfw: isNSFW)
            } else {
                let response = try await apiClient.createPost(
                    communityId: editModel.community.communityId,
                    name: postTitle.trimmed,
                    nsfw: isNSFW,
                    body: postBody.trimmed,
                    url: attachmentModel.url.trimmed
                )
                
                hapticManager.play(haptic: .success, priority: .high)
                
                if let postTracker = editModel.postTracker {
                    Task {
                        await postTracker.prependItem(PostModel(from: response.postView))
                    }
                }
            }
            
            dismiss()
            
        } catch {
            isSubmitting = false
            errorHandler.handle(error)
        }
    }
}
