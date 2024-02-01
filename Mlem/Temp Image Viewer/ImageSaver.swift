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
    let logger = MlemLogger()

    func writeToPhotoAlbum(imageData: Data) {
        PHPhotoLibrary.shared().performChanges({
            let creationRequest = PHAssetCreationRequest.forAsset()
            creationRequest.addResource(with: .photo, data: imageData, options: nil)
        }, completionHandler: { success, error in
            if success {
                self.logger.log(level: .debug, message: "Save finished!")
            } else {
                self.logger.log(level: .error, message: "Error saving photo: \(String(describing: error?.localizedDescription))")
            }
        })
    }
}
