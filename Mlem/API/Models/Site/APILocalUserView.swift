//
//  APILocalUserView.swift
//  Mlem
//
//  Created by Sjmarf on 22/11/2023.
//

import Foundation

// lemmy_api_common::site::LocalUserView
struct APILocalUserView: Decodable {
    var localUser: APILocalUser
    var person: APIPerson
    let counts: APIPersonAggregates
}
