//
//  SavePostRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

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
            post_id: postId,
            save: save
        )
    }
}
