//
//  LemmyUploadImageRequest.swift
//  Mlem
//
//  Created by Sjmarf on 2026-09-07.
//

import Rest
import UniformTypeIdentifiers

struct LemmyV4UploadImageRequest: UploadRequest {
    typealias Response = LemmyV4ImageUploadResponse

    var form: MultipartFormData
    let path: String = "api/v4/image"

    init(data: Data, fileType: UTType?) {
        self.form = MultipartFormData()
        form.addFile(
            fieldName: "images[]",
            filenameWithoutExtension: "image",
            type: fileType,
            data: data
        )
    }
}
