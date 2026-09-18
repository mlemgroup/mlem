//
//  LemmyUploadImageRequest.swift
//  Mlem
//
//  Created by Sjmarf on 2026-09-07.
//

import Rest
import UniformTypeIdentifiers

struct LemmyUploadImageRequest: UploadRequest {
    typealias Response = LemmyPictrsUploadResponse

    var form: MultipartFormData
    let path: String = "pictrs/image"

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
