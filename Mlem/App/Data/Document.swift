//
//  Document.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-09.
//

import Foundation

struct Document: Identifiable, Hashable {
    let title: String
    let body: String
    var id: Int {
        var hasher = Hasher()
        hasher.combine(body)
        return hasher.finalize()
    }
}
