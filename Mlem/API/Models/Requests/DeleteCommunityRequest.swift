//
//  DeleteCommunityRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct DeleteCommunityRequest: APIPostRequest {
    typealias Body = APIDeleteCommunity
    typealias Response = APICommunityResponse

    let path = "/community/delete"
    let body: Body?

    init(
        communityId: Int,
        deleted: Bool
    ) {
        self.body = .init(
            community_id: communityId,
            deleted: deleted
        )
    }
}
