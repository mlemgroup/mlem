//
//  Toast.swift
//  Mlem
//
//  Created by Sjmarf on 15/05/2024.
//

import MlemMiddleware
import SwiftUI

enum Toast: Hashable {
    case basic(title: String, subtitle: String? = nil, systemImage: String, color: Color)
    case profile(AnyProfileProviding)
    
    static func success(_ message: String? = nil) -> Self {
        .basic(title: message ?? "Success", subtitle: nil, systemImage: Icons.successCircle, color: .green)
    }
    
    static func failure(_ message: String? = nil) -> Self {
        .basic(title: message ?? "Failed", subtitle: nil, systemImage: Icons.failureCircle, color: .red)
    }
    
    static func profile(_ model: any ProfileProviding & ActorIdentifiable) -> Self {
        .profile(.init(wrappedValue: model))
    }
}

struct AnyProfileProviding: Hashable {
    let wrappedValue: any ProfileProviding & ActorIdentifiable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(wrappedValue.actorId)
    }
    
    static func == (lhs: AnyProfileProviding, rhs: AnyProfileProviding) -> Bool {
        lhs.wrappedValue.actorId == rhs.wrappedValue.actorId
    }
}
