//
//  LinkAttachmentModel.swift
//  Mlem
//
//  Created by Sjmarf on 17/12/2023.
//

import Dependencies
import PhotosUI
import SwiftUI

class LinkAttachmentModel: ObservableObject {
    @Dependency(\.pictrsRepository) private var pictrsRepository: PictrsRespository
    @Dependency(\.apiClient) private var apiClient: APIClient
    @Dependency(\.errorHandler) private var errorHandler: ErrorHandler
    
    var uploadTask: Task<Void, any Error>?
    
    @AppStorage("promptUser.permission.privacy.allowImageUploads") var askedForPermissionToUploadImages: Bool = false
    @AppStorage("confirmImageUploads") var confirmImageUploads: Bool = false
    
    @Published var url: String = ""
    @Published var imageModel: PictrsImageModel?
    
    init(url: String) {
        self.url = url
    }
    
    @Published var photosPickerItem: PhotosPickerItem?
    @Published var showingUploadConfirmation: Bool = false
    @Published var showingPhotosPicker: Bool = false
    @Published var showingFilePicker: Bool = false
    
    func attachImageAction() {
        showingPhotosPicker = true
    }
    
    func attachFileAction() {
        showingFilePicker = true
    }
    
    func pasteFromClipboardAction() {
        pasteFromClipboard()
    }
    
    func removeLinkAction() {
        url = ""
        deletePictrs()
    }
    
    func prepareToUpload(photo: PhotosPickerItem) async {
        do {
            if let data = try await photo.loadTransferable(type: Data.self) {
                DispatchQueue.main.async {
                    self.prepareToUpload(data: data)
                }
            } else {
                imageModel = .init(state: .failed("Invalid image format"))
            }
        } catch {
            imageModel = .init(state: .failed(String(describing: error)))
        }
    }
    
    func prepareToUpload(result: Result<URL, Error>) {
        switch result {
        case let .success(url):
            do {
                guard url.startAccessingSecurityScopedResource() else {
                    imageModel = .init(state: .failed("Invalid permissions"))
                    return
                }
                let data = try Data(contentsOf: url)
                url.stopAccessingSecurityScopedResource()
                prepareToUpload(data: data)
            } catch {
                url.stopAccessingSecurityScopedResource()
                imageModel = .init(state: .failed(String(describing: error)))
            }
        case let .failure(error):
            imageModel = .init(state: .failed(String(describing: error)))
        }
    }
    
    func prepareToUpload(data: Data) {
        imageModel = .init()
        imageModel?.state = .readyToUpload(data: data)
        if let uiImage = UIImage(data: data) {
            imageModel?.image = Image(uiImage: uiImage)
        }
        if askedForPermissionToUploadImages == false || confirmImageUploads {
            showingUploadConfirmation = true
        } else {
            uploadImage()
        }
    }
    
    func pasteFromClipboard() {
        Task {
            if UIPasteboard.general.hasImages, let content = UIPasteboard.general.image {
                if let data = content.pngData() {
                    DispatchQueue.main.async {
                        self.prepareToUpload(data: data)
                    }
                }
            } else if UIPasteboard.general.hasURLs, let content = UIPasteboard.general.url {
                DispatchQueue.main.async {
                    self.url = content.absoluteString
                }
            }
        }
    }
    
    func uploadImage() {
        guard let imageModel else { return }
        Task(priority: .userInitiated) {
            self.uploadTask = try await pictrsRepository.uploadImage(
                imageModel: imageModel,
                onUpdate: { newValue in
                    DispatchQueue.main.async {
                        self.imageModel = newValue
                        switch newValue.state {
                        case let .uploaded(file):
                            if let file {
                                do {
                                    var components = URLComponents()
                                    components.scheme = try self.apiClient.session.instanceUrl.scheme
                                    components.host = try self.apiClient.session.instanceUrl.host
                                    components.path = "/pictrs/image/\(file.file)"
                                    self.url = components.url?.absoluteString ?? ""
                                } catch {
                                    self.imageModel?.state = .failed(nil)
                                }
                            }
                        default:
                            self.url = ""
                        }
                    }
                }
            )
        }
    }
    
    func deletePictrs(compareUrl: String? = nil) {
        if let task = uploadTask {
            task.cancel()
        }
        photosPickerItem = nil
        switch imageModel?.state {
        case let .uploaded(file: file):
            if let file {
                Task {
                    do {
                        if let compareUrl {
                            var components = URLComponents()
                            components.scheme = try self.apiClient.session.instanceUrl.scheme
                            components.host = try self.apiClient.session.instanceUrl.host
                            components.path = "/pictrs/image/\(file.file)"
                            if let imageModelUrl = components.url?.absoluteString, compareUrl != imageModelUrl {
                                try await pictrsRepository.deleteImage(file: file)
                                print("Deleted from pictrs")
                                DispatchQueue.main.async {
                                    self.imageModel = nil
                                }
                            }
                        } else {
                            try await pictrsRepository.deleteImage(file: file)
                            print("Deleted from pictrs")
                            DispatchQueue.main.async {
                                self.imageModel = nil
                            }
                        }
                    } catch {
                        print("ERROR", error)
                        errorHandler.handle(error)
                    }
                }
            }
        default:
            imageModel = nil
        }
        if url == "", imageModel != nil {
            imageModel = nil
        }
    }
}
