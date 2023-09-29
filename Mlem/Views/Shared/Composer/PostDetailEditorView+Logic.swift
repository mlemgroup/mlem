//
//  PostEditorDetailView+Logic.swift
//  Mlem
//
//  Created by Sjmarf on 24/09/2023.
//

import Foundation
import SwiftUI
import PhotosUI

extension PostDetailEditorView {
    var isReadyToPost: Bool {
        switch imageModel?.state {
        case nil, .uploaded:
            return postTitle.trimmed.isNotEmpty
        default:
            return false
        }
    }
    
    var isValidURL: Bool {
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
            
            try await onSubmit()
            
        } catch {
            isSubmitting = false
            errorHandler.handle(error)
        }
    }
}
