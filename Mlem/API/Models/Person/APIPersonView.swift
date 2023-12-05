//
//  APIPersonView.swift
//  Mlem
//
//  Created by Nicholas Lawson on 09/06/2023.
//

import Foundation

// lemmy_db_views_actor::structs::PersonView
struct APIPersonView: Decodable {
    let person: APIPerson
    let counts: APIPersonAggregates
    let isAdmin: Bool? // TODO: 0.18 deprecation make this field non-optional
}
