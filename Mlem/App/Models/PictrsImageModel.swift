//
//  PictrsImageModel.swift
//  Mlem
//
//  Created by Sjmarf on 29/09/2023.
//

import PhotosUI
import SwiftUI

struct ImageUploadResponse: Codable {
    public let msg: String?
    public let files: [PictrsFile]?
}

struct PictrsFile: Codable, Equatable {
    public let file: String
    public let deleteToken: String
}

struct PictrsImageModel {
    enum UploadState {
        case waiting
        case readyToUpload(data: Data)
        case uploading(progress: Double)
        case uploaded(file: PictrsFile?)
        case failed(String?)
    }

    var image: Image?
    var state: UploadState = .waiting
}
