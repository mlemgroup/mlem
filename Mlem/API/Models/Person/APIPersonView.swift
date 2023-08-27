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
}

extension APIPersonView: Hashable, Equatable, Identifiable {
    var id: Int { hashValue }
    
    static func == (lhs: APIPersonView, rhs: APIPersonView) -> Bool {
        lhs.hashValue == rhs.hashValue
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(person.id)
    }
}
