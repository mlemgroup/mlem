//
//  LemmyPictrsUploadResponse.swift
//
//
//  Created by Sjmarf on 26/08/2024.
//

import Foundation

public struct LemmyPictrsUploadResponse: Codable {
    public let msg: String?
    public let files: [LemmyPictrsFile]?
}
