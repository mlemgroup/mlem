//
//  ImageUploadHistoryManager.swift
//  Mlem
//
//  Created by Sjmarf on 07/09/2024.
//

import MlemMiddleware
import SwiftUI

@Observable
class ImageUploadHistoryManager {
    private(set) var uploads: [ImageUpload1] = []
    
    func add(_ upload: ImageUpload1) {
        uploads.append(upload)
    }
    
    func deleteAll() {
        for upload in uploads {
            Task { try await upload.delete() }
        }
    }
    
    @discardableResult
    func deleteWhereNotPresent(in text: String) -> [ImageUpload1] {
        uploads.filter { upload in
            if !text.contains(upload.url.absoluteString) {
                Task { try await upload.delete() }
                return true
            }
            return false
        }
    }
}
