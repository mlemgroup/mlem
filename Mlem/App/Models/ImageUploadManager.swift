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
    struct PendingUpload: Hashable, Equatable {
        let data: Data
        let type: UTType?
    }

    enum UploadState: Hashable {
        case idle
        case waiting(PendingUpload)
        case uploading(PendingUpload, progress: Double)
        case done(ImageUpload1)
        case previousUpload(URL)
        
        var isDone: Bool {
            switch self {
            case .done, .previousUpload: true
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

    var url: URL? {
        switch state {
        case let .done(image): image.url
        case let .previousUpload(url): url
        default: nil
        }
    }

    var progress: Double {
        switch state {
        case .idle, .waiting: 0
        case let .uploading(_, progress): progress
        case .done, .previousUpload: 1
        }
    }
    
    func choosePhoto(_ photo: PhotosPickerItem) async throws {
        do {
            guard let data = try await photo.loadTransferable(type: Data.self) else {
                throw ApiClientError.unsuccessful
            }
            self.state = .waiting(.init(data: data, type: photo.supportedContentTypes.first))
        } catch {
            Task { @MainActor in
                state = .idle
            }
            throw error
        }
    }
    
    func chooseFile(localUrl url: URL) async throws {
        do {
            guard url.startAccessingSecurityScopedResource() else {
                throw ApiClientError.insufficientPermissions
            }
            let data = try Data(contentsOf: url)
            url.stopAccessingSecurityScopedResource()
            let type = UTType(filenameExtension: url.pathExtension)
            self.state = .waiting(.init(data: data, type: type))
        } catch {
            url.stopAccessingSecurityScopedResource()
            Task { @MainActor in
                state = .idle
            }
            throw error
        }
    }
    
    func pasteFromClipboard() async {
        if UIPasteboard.general.hasImages, let content = UIPasteboard.general.image {
            if let data = content.pngData() {
                self.state = .waiting(.init(data: data, type: .png))
            }
        }
    }
    
    func upload(api: ApiClient) async throws {
        guard case let .waiting(pendingImage) = self.state else {
            throw ImageUploadManagerError.noPendingImage
        }
        
        do {
            let image = try await api.uploadImage(
                pendingImage.data,
                fileType: pendingImage.type
            ) { value in
                Task { @MainActor in
                    self.state = .uploading(pendingImage, progress: value)
                }
            }
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

    func setPreviousUpload(_ url: URL?) {
        if let url {
            self.state = .previousUpload(url)
        } else {
            self.state = .idle
        }
    }

    func matchesPreviousUpload(_ url: URL?) -> Bool {
        switch (self.state, url) {
        case let (.previousUpload(otherUrl), .some(url)): otherUrl == url
        case (.idle, nil): true
        default: false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(state)
    }

    var isWaiting: Bool {
        switch state {
        case .waiting: true
        default: false
        }
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

enum ImageUploadManagerError: Error {
    case noPendingImage
} 
