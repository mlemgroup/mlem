//
//  APIPersonView.swift
//  Mlem
//
//  Created by Nicholas Lawson on 09/06/2023.
//

import Foundation

protocol APIPersonViewLike {
    var person: APIPerson { get }
    var counts: APIPersonAggregates { get }
}

// lemmy_db_views_actor::structs::PersonView
struct APIPersonView: APIPersonViewLike, Decodable {
    internal init(
        person: APIPerson = .mock,
        counts: APIPersonAggregates = .mock,
        isAdmin: Bool? = nil
    ) {
        self.person = person
        self.counts = counts
        self.isAdmin = isAdmin
    }
    
    let person: APIPerson
    let counts: APIPersonAggregates
    let isAdmin: Bool? // TODO: 0.18 deprecation make this field non-optional
}

extension APIPersonView: Mockable {
    static var mock: APIPersonView { .init() }
}

extension APIPersonView: ActorIdentifiable, Identifiable {
    var id: Int { person.id }
    var actorId: URL { person.actorId }
}
