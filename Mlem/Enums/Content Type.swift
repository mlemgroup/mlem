//
//  Content Type.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-08-26.
//

import Foundation

enum ContentType: Int, Codable {
    case post, comment, community, user, message, mention, reply, instance
}
