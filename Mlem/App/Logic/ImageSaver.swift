//
//  ImageSaver.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-11-15.
//  Adapted from https://www.hackingwithswift.com/books/ios-swiftui/how-to-save-images-to-the-users-photo-library
//

import Foundation
import Photos

class ImageSaver: NSObject {
    func writeVideoToPhotoAlbum(url: URL) async throws {
        guard let tempFile = await downloadImageToFileSystem(url: url) else {
            ToastModel.main.add(.error(.init(title: "Failed to save video")))
            return
        }
        
        try await PHPhotoLibrary.shared().performChanges {
            _ = PHAssetCreationRequest.creationRequestForAssetFromVideo(atFileURL: tempFile)
        }
    }
    
    func writeImageToPhotoAlbum(imageData: Data) async throws {
        try await PHPhotoLibrary.shared().performChanges {
            let creationRequest = PHAssetCreationRequest.forAsset()
            creationRequest.addResource(with: .photo, data: imageData, options: nil)
        }
    }
}
