//
//  InstanceStubProviding.swift
//  Mlem
//
//  Created by Sjmarf on 12/02/2024.
//

import Foundation

protocol InstanceStubProviding: ActorIdentifiable {
    var stub: NewInstanceStub { get }
    
    var url: URL { get }
}

extension InstanceStubProviding {
    var url: URL { stub.url }
    var actorId: URL { stub.actorId }
}
