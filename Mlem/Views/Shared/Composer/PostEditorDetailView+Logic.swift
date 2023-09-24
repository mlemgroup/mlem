//
//  PostEditorDetailView+Logic.swift
//  Mlem
//
//  Created by Sjmarf on 24/09/2023.
//

import Foundation
import PhotosUI

extension PostDetailEditorView {
    var isReadyToPost: Bool {
        // This only requirement to post is a title
        postTitle.trimmed.isNotEmpty
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
    
    func uploadImage() {
//        Task {
//            if let data = try? await imageSelection?.loadTransferable(type: Data.self) {
//                do {
//                    let res = try await apiClient.uploadImage(data, callback: { print("Upload \($0)") })
//                    if let firstFile = res.files.first {
//                        var components = URLComponents()
//                        components.scheme = try apiClient.session.instanceUrl.scheme
//                        components.host = try apiClient.session.instanceUrl.host
//                        components.path = "pictrs/image/\(firstFile.file)"
//                        postURL = components.url?.absoluteString ?? ""
//                    }
//                } catch {
//                    errorHandler.handle(error)
//                }
//            }
//        }
    }
}
