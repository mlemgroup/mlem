//
//  APICommentView.swift
//  Mlem
//
//  Created by Nicholas Lawson on 09/06/2023.
//

import Foundation

struct APICommentView: Decodable {
    let comment: APIComment
    let counts: APICommentAggregates
    var myVote: ScoringOperation?
    let creator: APIPerson
}

extension APICommentView: Identifiable {
    // defer to our contained comment for identity
    var id: Int { comment.id }
}

extension APICommentView: Equatable {
    static func == (lhs: APICommentView, rhs: APICommentView) -> Bool {
        // defer to our child comment for equality
        lhs.comment.id == rhs.comment.id
    }
}
