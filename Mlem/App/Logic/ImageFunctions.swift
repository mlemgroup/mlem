//
//  ImageFunctions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-08-25.
//

import Foundation
import MlemMiddleware
import Nuke
import Photos
import Rest
import SwiftUI

func saveMedia(url: URL) async {
    do {
        let (data, _) = try await ImagePipeline.shared.data(for: .init(urlRequest: mlemUrlRequest(url: url)))
        let imageSaver = ImageSaver()
        if url.pathExtension.isMovieExtension {
            try await imageSaver.writeVideoToPhotoAlbum(url: url)
            ToastModel.main.add(.success("Video Saved"))
        } else {
            try await imageSaver.writeImageToPhotoAlbum(imageData: data)
            ToastModel.main.add(.success("Image Saved"))
        }
    } catch {
        handleError(error, silent: true)
        ToastModel.main.add(.basic(
            "Failed to save media",
            subtitle: "You may need to allow Mlem to access your Photo Library in System Settings.",
            color: .themedNegative,
            duration: 5
        ))
    }
}

@MainActor
func createImageFromView(_ view: some View, dimensions: CGSize) -> UIImage? {
    print("DEBUG using dimensions \(dimensions)")
    let renderer = ImageRenderer(content: view)
    renderer.scale = 3 // boost resolution to look better on larger devices
    renderer.proposedSize.width = dimensions.width
    // renderer.proposedSize.height = dimensions.height
    return renderer.uiImage
}

func shareImage(url: URL, navigation: NavigationLayer) async {
    if let fileUrl = await downloadImageToFileSystem(url: url) {
        navigation.model?.shareInfo = .init(url: fileUrl)
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
func downloadImageToFileSystem(url: URL) async -> URL? {
    do {
        let (data, _) = try await ImagePipeline.shared.data(for: .init(urlRequest: mlemUrlRequest(url: url)))
        var fileName: String
        
        // image proxies that use url query param don't have pathExtension so we extract it from the embedded url
        if url.pathExtension.isEmpty,
           let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
           let queryItems = components.queryItems,
           let baseUrlString = queryItems.first(where: { $0.name == "url" })?.value,
           let baseUrl = URL(string: baseUrlString) {
            fileName = baseUrl.lastPathComponent
        } else {
            fileName = url.lastPathComponent
        }
        
        if fileName.isEmpty {
            assertionFailure("Empty fileName!")
            return nil
        }
        
        return try data.writeToTempFile(fileName: fileName)
    } catch {
        handleError(error)
        return nil
    }
}

func downloadTextToFileSystem(fileName: String, text: String) async -> URL? {
    do {
        let fileUrl = FileManager.default.temporaryDirectory.appending(path: fileName)
        if FileManager.default.fileExists(atPath: fileUrl.absoluteString) {
            try FileManager.default.removeItem(at: fileUrl)
        }
        try text.write(to: fileUrl, atomically: true, encoding: String.Encoding.utf8)
        return fileUrl
    } catch {
        handleError(error)
        return nil
    }
}
