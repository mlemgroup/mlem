//
//  APIGetPersonDetailsResponse+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19.
//

import Foundation

extension APIGetPersonDetailsResponse: ActorIdentifiable, Identifiable {
    var actorId: URL { person_view.person.actorId }
    var id: Int { person_view.person.id }
}
