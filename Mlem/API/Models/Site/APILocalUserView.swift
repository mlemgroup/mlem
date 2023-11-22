//
//  APILocalUserView.swift
//  Mlem
//
//  Created by Sjmarf on 22/11/2023.
//

import Foundation

// lemmy_api_common::site::LocalUserView
struct APILocalUserView: Decodable {
    let counts: APIPersonAggregates
    let localUser: APILocalUser
    let person: APIPerson
}
