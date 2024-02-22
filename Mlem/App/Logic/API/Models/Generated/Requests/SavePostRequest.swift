//
//  SavePostRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct SavePostRequest: ApiPutRequest {
    typealias Body = ApiSavePost
    typealias Response = ApiPostResponse

    let path = "/post/save"
    let body: Body?

    init(
        postId: Int,
        save: Bool
    ) {
        self.body = .init(
            postId: postId,
            save: save
        )
    }
}
