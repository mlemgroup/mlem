//
//  Toast.swift
//  Mlem
//
//  Created by Sjmarf on 15/05/2024.
//

import MlemMiddleware
import SwiftUI

enum ToastType: Hashable {
    case basic(
        title: String,
        subtitle: String? = nil,
        systemImage: String? = nil,
        color: Color,
        duration: Double = 1.5
    )
    
    case undoable(
        title: String? = nil,
        systemImage: String? = nil,
        callback: () -> Void,
        color: Color = Palette.main.accent
    )
    
    case error(_ details: ErrorDetails)
    
    case account(Account)
    
    var duration: Double {
        switch self {
        case let .basic(_, _, _, _, duration):
            duration
        case .undoable:
            2.5
        case .account:
            1.0
        case .error:
            1.5
        }
    }
    
    var location: ToastLocation {
        switch self {
        case .undoable:
            .bottom
        default:
            .top
        }
    }
    
    var important: Bool {
        switch self {
        case .error:
            true
        default:
            false
        }
    }
    
    static func success(_ message: String? = nil) -> Self {
        .basic(
            title: message ?? "Success",
            subtitle: nil,
            systemImage: Icons.successCircleFill,
            color: Palette.main.success,
            duration: 1
        )
    }
    
    static func failure(_ message: String? = nil) -> Self {
        .basic(
            title: message ?? "Failed",
            subtitle: nil,
            systemImage: Icons.failureCircleFill,
            color: Palette.main.failure,
            duration: 1
        )
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
        case let .account(account):
            hasher.combine("account")
            hasher.combine(account)
        }
    }
    
    static func == (lhs: ToastType, rhs: ToastType) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
