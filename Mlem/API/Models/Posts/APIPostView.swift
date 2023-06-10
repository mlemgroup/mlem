//
//  APIPostView.swift
//  Mlem
//
//  Created by Nicholas Lawson on 09/06/2023.
//

import Foundation

struct APIPostView: Decodable {
    let community: APICommunity
    let creator: APIPerson
    let post: APIPost
    var myVote: ScoringOperation?
    var counts: APIPostAggregates
}

extension APIPostView: Identifiable {
    var id: Int { post.id }
}

extension APIPostView: Equatable {
    static func == (lhs: APIPostView, rhs: APIPostView) -> Bool {
        // defer to our child `post` value conformance
        lhs.post == rhs.post
    }
}
