//
//  Post Types.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-14.
//

import Foundation

enum PostType: Equatable, Hashable, Identifiable {
    var id: Int { self.hashValue }
    
    case text(String)
    case image(URL)
    case link(URL?)
    case titleOnly
}
