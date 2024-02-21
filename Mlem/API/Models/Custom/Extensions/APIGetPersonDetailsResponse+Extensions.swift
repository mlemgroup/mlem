//
//  ApiGetPersonDetailsResponse+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19.
//

import Foundation

extension ApiGetPersonDetailsResponse: ActorIdentifiable, Identifiable {
    var actorId: URL { personView.person.actorId }
    var id: Int { personView.person.id }
}
