//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-05.
//

import Foundation

public extension ImageUpload1Snapshot {
    init(from response: PieFedImageUploadResponse) {
        self.init(
            url: response.url,
            alias: nil,
            deleteToken: nil
        )
    }
}
