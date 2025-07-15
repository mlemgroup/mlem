//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-05.
//

import Foundation

public extension ImageUpload1Snapshot {
    init(from response: PieFedUploadResponse) {
        self.url = response.url
        self.alias = nil
        self.deleteToken = nil
    }
}
