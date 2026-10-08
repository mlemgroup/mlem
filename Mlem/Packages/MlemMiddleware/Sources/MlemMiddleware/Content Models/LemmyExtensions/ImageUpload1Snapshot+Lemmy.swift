//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-14.
//

import Foundation

extension ImageUpload1Snapshot {
    init(from file: LemmyPictrsFile, baseUrl: URL) {
        self.init(
            url: baseUrl.appending(path: "pictrs/image/\(file.file)"),
            deleteToken: .init(wrappedValue: LemmyV3ImageDeleteToken(
                alias: file.file,
                token: file.deleteToken
            ))
        )
    }

    init(from response: LemmyV4ImageUploadResponse) {
        self.init(
            url: response.imageUrl,
            deleteToken: .init(wrappedValue: LemmyV4ImageDeleteToken(filename: response.filename))
        )
    }
}
