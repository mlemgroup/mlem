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
    var hasPostContent: Bool {
        !postTitle.isEmpty || !postURL.isEmpty || !postBody.isEmpty || imageModel != nil
    }
    
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
    
    func uploadImage(imageSelection: PhotosPickerItem) {
        self.imageModel = .init()
        Task {
            self.uploadTask = try await pictrsRepository.uploadImage(
                imageModel: .init(),
                imageSelection: imageSelection,
                onUpdate: { newValue in
                    self.imageModel = newValue
                    switch newValue.state {
                    case .uploaded(let file):
                        if let file = file {
                            do {
                                var components = URLComponents()
                                components.scheme = try apiClient.session.instanceUrl.scheme
                                components.host = try apiClient.session.instanceUrl.host
                                components.path = "/pictrs/image/\(file.file)"
                                postURL = components.url?.absoluteString ?? ""
                            } catch {
                                self.imageModel?.state = .failed(nil)
                            }
                        } else {
                            
                        }
                    default:
                        postURL = ""
                    }
                }
            )
        }
    }
    
    func cancelUpload() {
        if let task = self.uploadTask {
            task.cancel()
        }
        switch imageModel?.state {
        case .uploaded(file: let file):
            if let file = file {
                Task {
                    do {
                        try await pictrsRepository.deleteImage(file: file)
                    } catch {
                        errorHandler.handle(error)
                    }
                    print("Deleted from pictrs")
                }
            }
        default:
            break
        }
    }
}
