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
            deleteToken: .init(wrappedValue: LemmyImageDeleteToken(
                alias: file.file,
                token: file.deleteToken
            ))
        )
    }
}
