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
    }
    
    var state: UploadState = .idle
    
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
            try await upload(data: data, api: api)
        } catch {
            state = .idle
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
            try await upload(data: data, api: api)
            
        } catch {
            url.stopAccessingSecurityScopedResource()
            state = .idle
            throw error
        }
    }
    
    func pasteFromClipboard(api: ApiClient) async throws {
        do {
            if UIPasteboard.general.hasImages, let content = UIPasteboard.general.image {
                if let data = content.pngData() {
                    try await upload(data: data, api: api)
                }
            }
        } catch {
            state = .idle
            throw error
        }
    }
    
    private func upload(data: Data, api: ApiClient) async throws {
        let image = try await api.uploadImage(data, onProgress: { self.state = .uploading(progress: $0) })
        state = .done(image)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(state)
    }
    
    static func == (lhs: ImageUploadManager, rhs: ImageUploadManager) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
