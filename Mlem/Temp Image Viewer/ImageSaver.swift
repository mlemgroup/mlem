//
//  ImageSaver.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-11-15.
//  Adapted from https://www.hackingwithswift.com/books/ios-swiftui/how-to-save-images-to-the-users-photo-library
//

import Foundation
import UIKit

class ImageSaver: NSObject {
    func writeToPhotoAlbum(imageData: Data) {
        if let image = UIImage(data: imageData) {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
        }
    }

    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        print("Save finished!")
    }
}
