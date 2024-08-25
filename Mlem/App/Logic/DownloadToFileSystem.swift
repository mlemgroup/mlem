//
//  DownloadToFileSystem.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-08-25.
//

import Foundation
import Nuke

/// Downloads the image at the given URL to the file system, returning the path to the downloaded image
func downloadImageToFileSystem(url: URL, fileName: String) async -> URL? {
    do {
        let (data, _) = try await ImagePipeline.shared.data(for: .init(url: url))
        let fileType = url.pathExtension
        let quicklook = FileManager.default.temporaryDirectory.appending(path: "\(fileName).\(fileType)")
        if FileManager.default.fileExists(atPath: quicklook.absoluteString) {
            try FileManager.default.removeItem(at: quicklook)
        }
        try data.write(to: quicklook)
        return quicklook
    } catch {
        handleError(error)
        return nil
    }
}
