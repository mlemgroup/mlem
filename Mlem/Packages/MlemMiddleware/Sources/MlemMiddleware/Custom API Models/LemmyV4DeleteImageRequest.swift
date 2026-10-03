//
//  LemmyV4DeleteImageRequest.swift
//  Mlem
//
//  Created by Sjmarf on 2026-10-03.
//

import Rest

struct LemmyV4DeleteImageRequest: DeleteRequest {
    typealias Response = LemmySuccessResponse

    let path: String
    let body: LemmyDeleteImageParams?

    init(filename: String) {
        self.path = "api/v4/account/media"
        self.body = .init(filename: filename)
    }
}
