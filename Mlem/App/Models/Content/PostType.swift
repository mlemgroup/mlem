//
//  PostType.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-14.
//

import Foundation

enum PostType: Equatable {
    case text(String)
    case image(URL)
    case link(URL?)
    case titleOnly
}
