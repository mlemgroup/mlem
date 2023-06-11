//
//  APICommunityAggregates.swift
//  Mlem
//
//  Created by Nicholas Lawson on 09/06/2023.
//

import Foundation

struct APICommunityAggregates: Decodable {
    let comments: Int
    let communityId: Int
    let id: Int
    let posts: Int
    let subscribers: Int
    let usersActiveDay: Int
    let usersActiveHalfYear: Int
    let usersActiveMonth: Int
    let usersActiveWeek: Int
}
