//
//  ApiPersonView+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19.
//

import Foundation

extension ApiPersonView: ActorIdentifiable, Identifiable {
    var id: Int { person.id }
    var actorId: URL { person.actorId }
}
