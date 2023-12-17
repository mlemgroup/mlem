//
//  LinkAttachmentModel.swift
//  Mlem
//
//  Created by Sjmarf on 17/12/2023.
//

import SwiftUI
import Dependencies
import PhotosUI

class LinkAttachmentModel: ObservableObject {
    @Dependency(\.pictrsRepository) private var pictrsRepository: PictrsRespository
    @Dependency(\.apiClient) private var apiClient: APIClient
    @Dependency(\.errorHandler) private var errorHandler: ErrorHandler
    
    var uploadTask: Task<(), any Error>?
    
    @Published var photosPickerItem: PhotosPickerItem?
    @Published var showingUploadConfirmation: Bool = false
    
    @Binding var url: String
    @Binding var imageModel: PictrsImageModel?
    @Binding var askedForPermissionToUploadImages: Bool
    @Binding var confirmImageUploads: Bool
    
    @Published var showingPhotosPicker: Bool = false
    @Published var showingFilePicker: Bool = false
    
    init(
        url: Binding<String>,
        imageModel: Binding<PictrsImageModel?>,
        askedForPermissionToUploadImages: Binding<Bool>,
        confirmImageUploads: Binding<Bool>
    ) {
        self._url = url
        self._imageModel = imageModel
        self._askedForPermissionToUploadImages = askedForPermissionToUploadImages
        self._confirmImageUploads = confirmImageUploads
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
        case .success(let url):
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
        case .failure(let error):
            imageModel = .init(state: .failed(String(describing: error)))
        }
    }
    
    func prepareToUpload(data: Data) {
        imageModel = .init()
        self.imageModel?.state = .readyToUpload(data: data)
        if let uiImage = UIImage(data: data) {
            self.imageModel?.image = Image(uiImage: uiImage)
        }
        if self.askedForPermissionToUploadImages == false || self.confirmImageUploads {
            self.showingUploadConfirmation = true
        } else {
            self.uploadImage()
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
                url = content.absoluteString
            }
        }
    }
    
    func uploadImage() {
        guard let imageModel = imageModel else { return }
        Task(priority: .userInitiated) {
            self.uploadTask = try await pictrsRepository.uploadImage(
                imageModel: imageModel,
                onUpdate: { newValue in
                    DispatchQueue.main.async {
                        self.imageModel = newValue
                        switch newValue.state {
                        case .uploaded(let file):
                            if let file = file {
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
        if let task = self.uploadTask {
            task.cancel()
        }
        switch self.imageModel?.state {
        case .uploaded(file: let file):
            if let file = file {
                self.photosPickerItem = nil
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
            self.imageModel = nil
        }
        if url == "" && self.imageModel != nil {
            self.imageModel = nil
        }
    }
}
