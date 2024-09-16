//
//  ImageFunctions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-08-25.
//

import Foundation
import Nuke
import SwiftUI

func saveImage(url: URL) async {
    do {
        let (data, _) = try await ImagePipeline.shared.data(for: .init(url: url))
        let imageSaver = ImageSaver()
        try await imageSaver.writeToPhotoAlbum(imageData: data)
        ToastModel.main.add(.success("Image Saved"))
    } catch {
        ToastModel.main.add(.basic(
            "Failed to Save Image",
            subtitle: "You may need to allow Mlem to access your Photo Library in System Settings.",
            color: Palette.main.negative,
            duration: 5
        ))
    }
}

func fullSizeUrl(url: URL?) -> URL? {
    if let url, var components = URLComponents(url: url, resolvingAgainstBaseURL: true) {
        components.queryItems = components.queryItems?.filter { $0.name != "thumbnail" }
        return components.url
    }
    return nil
}

/// Downloads the image at the given URL to the file system, returning the path to the downloaded image
func downloadImageToFileSystem(url: URL, fileName: String) async -> URL? {
    do {
        let (data, _) = try await ImagePipeline.shared.data(for: .init(url: url))
        var fileType = url.pathExtension
        
        // image proxies that use url query param don't have pathExtension so we extract it from the embedded url
        if fileType.isEmpty,
           let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
           let queryItems = components.queryItems,
           let baseUrlString = queryItems.first(where: { $0.name == "url" })?.value,
           let baseUrl = URL(string: baseUrlString) {
            fileType = baseUrl.pathExtension
        }
        
        if fileType.isEmpty {
            assertionFailure("Empty fileType!")
            return nil
        }
        
        let fileUrl = FileManager.default.temporaryDirectory.appending(path: "\(fileName).\(fileType)")
        if FileManager.default.fileExists(atPath: fileUrl.absoluteString) {
            try FileManager.default.removeItem(at: fileUrl)
        }
        try data.write(to: fileUrl)
        return fileUrl
    } catch {
        handleError(error)
        return nil
    }
}
