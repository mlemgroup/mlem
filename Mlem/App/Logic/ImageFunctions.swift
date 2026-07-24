//
//  ImageFunctions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-08-25.
//

import Foundation
import ImageIO
import MlemMiddleware
import Nuke
import Photos
import SwiftUI
import UniformTypeIdentifiers

func saveMedia(url: URL) async {
    do {
        let (data, _) = try await ImagePipeline.shared.data(url: url)
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
func createImageFromView(
    _ view: some View,
    environment: EnvironmentValues,
    dimensions: CGSize? = nil
) -> UIImage? {
    let renderer = ImageRenderer(content: view.environment(\.self, environment))
    renderer.scale = 3 // boost resolution to look better on larger devices
    if let dimensions {
        renderer.proposedSize = .init(dimensions)
    } else {
        // assume screen width
        renderer.proposedSize.width = UIScreen.main.bounds.width
    }
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
        let (data, _) = try await ImagePipeline.shared.data(url: url)
        let fileName = try getFileName(url: url, data: data)
        return try data.writeToTempFile(fileName: fileName)
    } catch {
        handleError(error)
        return nil
    }
}

private func getFileName(url: URL, data: Data) throws(FileDownloadError) -> String {
    let url = url.unwrapProxy()

    if !url.pathExtension.isEmpty {
        return url.pathExtension
    }

    // Infer file type from the image data
    if let source = CGImageSourceCreateWithData(data as CFData, nil),
       let typeIdentifier = CGImageSourceGetType(source),
       let ext = UTType(typeIdentifier as String)?.preferredFilenameExtension {
        return "\(String(localized: "image")).\(ext)"
    }

    throw .couldNotDetermineFileType
}

enum FileDownloadError: Error {
    case couldNotDetermineFileType
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
