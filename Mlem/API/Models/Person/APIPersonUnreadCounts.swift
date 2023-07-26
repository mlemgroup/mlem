//
//  APIPersonUnreadCounts.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-26.
//

import Foundation

struct APIPersonUnreadCounts: Decodable {
    let replies: Int
    let mentions: Int
    let privateMessages: Int
}
