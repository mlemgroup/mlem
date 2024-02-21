//
//  ContentStub.swift
//  Mlem
//
//  Created by Sjmarf on 16/02/2024.
//

import Foundation

protocol ContentStub: ActorIdentifiable {
    var source: any ApiSource { get }
}

extension ContentStub {
    var host: String? { actorId.host() }
}
