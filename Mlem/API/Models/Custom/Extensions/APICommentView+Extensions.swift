//
//  APICommentView+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19.
//

import Foundation

extension APICommentView: Identifiable {
    // defer to our contained comment for identity
    var id: Int { comment.id }
}
