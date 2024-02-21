//
//  ApiCommentView+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19.
//

import Foundation

extension ApiCommentView: Identifiable {
    // defer to our contained comment for identity
    var id: Int { comment.id }
}
