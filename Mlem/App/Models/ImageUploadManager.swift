//
//  ImageUploadManager.swift
//  Mlem
//
//  Created by Sjmarf on 02/09/2024.
//

import MlemMiddleware
import PhotosUI
import SwiftUI

@Observable
class ImageUploadManager: Hashable {
    enum UploadState: Hashable {
        case idle, uploading(progress: Double), done(ImageUpload1)
        
        var isDone: Bool {
            switch self {
            case .done: true
            default: false
            }
        }
    }
    
    private(set) var state: UploadState = .idle
    
    init() {}
    
    var image: ImageUpload1? {
        switch state {
        case let .done(image):
            return image
        default:
            return nil
        }
    }
    
    var progress: Double {
        switch state {
        case .idle: 0
        case let .uploading(progress): progress
        case .done: 1
        }
    }
    
    func uploadPhoto(_ photo: PhotosPickerItem, api: ApiClient) async throws {
        do {
            guard let data = try await photo.loadTransferable(type: Data.self) else {
                throw ApiClientError.unsuccessful
            }
            guard let fileExtension = photo.supportedContentTypes.first?.preferredFilenameExtension else {
                throw ApiClientError.unsuccessful
            }
            try await upload(data: data, fileExtension: fileExtension, api: api)
        } catch {
            Task { @MainActor in
                state = .idle
            }
            throw error
        }
    }
    
    func uploadFile(localUrl url: URL, api: ApiClient) async throws {
        do {
            guard url.startAccessingSecurityScopedResource() else {
                throw ApiClientError.insufficientPermissions
            }
            let data = try Data(contentsOf: url)
            url.stopAccessingSecurityScopedResource()
            try await upload(data: data, fileExtension: url.pathExtension, api: api)
            
        } catch {
            url.stopAccessingSecurityScopedResource()
            Task { @MainActor in
                state = .idle
            }
            throw error
        }
    }
    
    func pasteFromClipboard(api: ApiClient) async throws {
        do {
            if UIPasteboard.general.hasImages, let content = UIPasteboard.general.image {
                if let data = content.pngData() {
                    try await upload(data: data, fileExtension: "png", api: api)
                }
            }
        } catch {
            Task { @MainActor in
                state = .idle
            }
            throw error
        }
    }
    
    func upload(data: Data, fileExtension: String, api: ApiClient) async throws {
        do {
            let image = try await api.uploadImage(data, fileExtension: fileExtension, onProgress: { value in
                Task { @MainActor in
                    self.state = .uploading(progress: value)
                }
            })
            Task { @MainActor in
                state = .done(image)
            }
        } catch {
            Task { @MainActor in
                state = .idle
            }
            throw error
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(state)
    }
    
    @MainActor
    func clear() {
        state = .idle
    }
    
    func delete() async throws {
        var imageToDelete: ImageUpload1?
        if let image {
            imageToDelete = image
        }
        await clear()
        try await imageToDelete?.delete()
    }
    
    static func == (lhs: ImageUploadManager, rhs: ImageUploadManager) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
