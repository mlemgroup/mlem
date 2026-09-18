//
//  PieFedUploadImageRequest.swift
//  Mlem
//
//  Created by Sjmarf on 2026-09-07.
//

import Rest
import UniformTypeIdentifiers

struct PieFedUploadImageRequest: UploadRequest {
    typealias Response = PieFedImageUploadResponse

    var form: MultipartFormData
    let path: String = "api/alpha/upload/image"

    init(data: Data, fileType: UTType?) {
        self.form = MultipartFormData()
        form.addFile(
            fieldName: "file",
            filenameWithoutExtension: "image",
            type: fileType,
            data: data
        )
    }
}
