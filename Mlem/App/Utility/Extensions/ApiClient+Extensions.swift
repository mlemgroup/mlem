//
//  ApiClient+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 02/06/2024.
//

import Foundation
import MlemMiddleware
import PhotosUI
import SwiftUI

extension ApiClient {
    var isActive: Bool {
        if token == nil {
            return AppState.main.guestSession.api === self
        }
        return AppState.main.activeSessions.contains(where: { $0.api === self })
    }
    
    var canInteract: Bool { isActive && token != nil }
    
    // Theoretically this could go in MlemMiddleware using a cross import overlay but SPM doesn't support that yet
    func uploadImage(
        _ photo: PhotosPickerItem,
        onProgress progressCallback: @escaping (_ progress: Double) -> Void = { _ in }
    ) async throws -> ImageUpload1 {
        guard let data = try await photo.loadTransferable(type: Data.self) else {
            throw ApiClientError.unsuccessful
        }
        return try await uploadImage(data, onProgress: progressCallback)
    }
    
    func uploadImage(
        localUrl url: URL,
        onProgress progressCallback: @escaping (_ progress: Double) -> Void = { _ in }
    ) async throws -> ImageUpload1 {
        do {
            guard url.startAccessingSecurityScopedResource() else {
                throw ApiClientError.insufficientPermissions
            }
            let data = try Data(contentsOf: url)
            url.stopAccessingSecurityScopedResource()
            return try await uploadImage(data, onProgress: progressCallback)
        } catch {
            url.stopAccessingSecurityScopedResource()
            throw error
        }
    }
}
