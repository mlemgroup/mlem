//
//  ApiModTransferCommunity.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

// ModTransferCommunity.ts
struct ApiModTransferCommunity: Decodable {
    let id: Int
    let modPersonId: Int
    let otherPersonId: Int
    let communityId: Int
    let when_: String
}
