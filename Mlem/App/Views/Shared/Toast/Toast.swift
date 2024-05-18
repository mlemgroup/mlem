//
//  Toast.swift
//  Mlem
//
//  Created by Sjmarf on 15/05/2024.
//

import MlemMiddleware
import SwiftUI

enum Toast: Hashable {
    case basic(
        title: String,
        subtitle: String? = nil,
        systemImage: String? = nil,
        color: Color,
        duration: Double = 1.5
    )
    
    case undoable(
        title: String,
        systemImage: String? = nil,
        callback: () -> Void,
        color: Color
    )
    
    case error(_ details: ErrorDetails)
    
    case profile(AnyProfileProviding)
    
    var duration: Double {
        switch self {
        case let .basic(_, _, _, _, duration):
            duration
        case .undoable:
            2.5
        case .profile:
            0.5
        case .error:
            1.0
        }
    }
    
    static func success(_ message: String? = nil) -> Self {
        .basic(
            title: message ?? "Success",
            subtitle: nil,
            systemImage: "checkmark.circle.fill",
            color: .green,
            duration: 1
        )
    }
    
    static func failure(_ message: String? = nil) -> Self {
        .basic(
            title: message ?? "Failed",
            subtitle: nil,
            systemImage: "xmark.circle.fill",
            color: .red,
            duration: 1
        )
    }
    
    static func profile(_ model: any ProfileProviding) -> Self {
        .profile(.init(wrappedValue: model))
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case let .basic(title, subtitle, systemImage, color, duration):
            hasher.combine("basic")
            hasher.combine(title)
            hasher.combine(subtitle)
            hasher.combine(systemImage)
            hasher.combine(color)
            hasher.combine(duration)
        case let .undoable(title: title, systemImage: systemImage, callback: _, color: color):
            hasher.combine("undoable")
            hasher.combine(title)
            hasher.combine(systemImage)
            hasher.combine(color)
        case let .error(details):
            hasher.combine("error")
            hasher.combine(details)
        case let .profile(profile):
            hasher.combine("profile")
            hasher.combine(profile)
        }
    }
    
    static func == (lhs: Toast, rhs: Toast) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

struct AnyProfileProviding: Hashable {
    let wrappedValue: any ProfileProviding
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(wrappedValue.actorId)
    }
    
    static func == (lhs: AnyProfileProviding, rhs: AnyProfileProviding) -> Bool {
        lhs.wrappedValue.actorId == rhs.wrappedValue.actorId
    }
}
