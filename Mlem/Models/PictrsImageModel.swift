//
//  PictrsImageModel.swift
//  Mlem
//
//  Created by Sjmarf on 29/09/2023.
//

import SwiftUI

struct PictrsImageModel {
    enum UploadState {
        case uploading(progress: Double)
        case uploaded(file: PictrsFile?)
        case failed(Error?)
    }
    var image: Image?
    var state: UploadState = .uploading(progress: 0)
}
