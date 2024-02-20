//
//  DistinguishCommentRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct DistinguishCommentRequest: APIPostRequest {
    typealias Body = APIDistinguishComment
    typealias Response = APICommentResponse

    let path = "/comment/distinguish"
    let body: Body?

    init(
      commentId: Int,
      distinguished: Bool
    ) {
        self.body = .init(
          commentId: commentId,
          distinguished: distinguished
      )
    }
}
