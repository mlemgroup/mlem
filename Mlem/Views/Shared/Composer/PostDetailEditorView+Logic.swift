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
    
    func loadImage() {
        guard let selection = imageSelection else { return }
        self.imageModel = .init()
        Task {
            do {
                let data = try await selection.loadTransferable(type: Data.self)
                DispatchQueue.main.async {
                    if let data = data {
                        self.imageModel?.state = .readyToUpload(data: data)
                        if let uiImage = UIImage(data: data) {
                            imageModel?.image = Image(uiImage: uiImage)
                        }
                        if askedForPermissionToUploadImages == false || confirmImageUploads {
                            showingUploadConfirmation = true
                        } else {
                            uploadImage()
                        }
                    } else {
                        self.imageModel?.state = .failed("Invalid format")
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.imageModel?.state = .failed(String(describing: error))
                }
            }
        }
    }
    
    func uploadImage() {
        guard let imageModel = imageModel else { return }
        Task(priority: .userInitiated) {
            self.uploadTask = try await pictrsRepository.uploadImage(
                imageModel: imageModel,
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
        imageSelection = nil
        imageModel = nil
        postURL = ""
    }
}
