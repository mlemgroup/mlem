//
//  PostType+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-06-03.
//

import MlemMiddleware

extension PostType {
    var lineLimit: Int {
        switch self {
        case .text, .titleOnly: 4
        case .image, .link: 2
        }
    }
}
