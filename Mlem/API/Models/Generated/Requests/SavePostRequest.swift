//
//  SavePostRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct SavePostRequest: APIPutRequest {
    typealias Body = APISavePost
    typealias Response = APIPostResponse

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
