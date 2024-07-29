//
//  Toast.swift
//  Mlem
//
//  Created by Sjmarf on 15/05/2024.
//

import MlemMiddleware
import SwiftUI

enum ToastType: Hashable {
    // Don't initialize this directly - use one of the static methods instead
    case basic(
        title: String,
        subtitle: String?,
        systemImage: String?,
        color: Color,
        duration: Double
    )
    
    static func basic(
        _ title: LocalizedStringResource,
        subtitle: String? = nil,
        systemImage: String? = nil,
        color: Color,
        duration: Double = 1.5
    ) -> ToastType {
        .basic(
            title: String(localized: title),
            subtitle: subtitle,
            systemImage: systemImage,
            color: color,
            duration: duration
        )
    }
    
    @_disfavoredOverload
    static func basic(
        _ title: String,
        subtitle: String? = nil,
        systemImage: String? = nil,
        color: Color,
        duration: Double = 1.5
    ) -> ToastType {
        .basic(
            title: title,
            subtitle: subtitle,
            systemImage: systemImage,
            color: color,
            duration: duration
        )
    }
    
    // Don't initialize this directly - use one of the static methods instead
    case undoable(
        title: String?,
        systemImage: String?,
        successSystemImage: String?,
        callback: () -> Void,
        color: Color
    )

    static func undoable(
        _ title: LocalizedStringResource? = nil,
        systemImage: String? = nil,
        successSystemImage: String? = nil,
        callback: @escaping () -> Void,
        color: Color = Palette.main.accent
    ) -> ToastType {
        let string: String?
        if let title {
            string = .init(localized: title)
        } else {
            string = nil
        }

        return .undoable(
            title: string,
            systemImage: systemImage,
            successSystemImage: successSystemImage,
            callback: callback,
            color: color
        )
    }
    
    @_disfavoredOverload
    static func undoable(
        _ title: String? = nil,
        systemImage: String? = nil,
        successSystemImage: String? = nil,
        callback: @escaping () -> Void,
        color: Color = Palette.main.accent
    ) -> ToastType {
        .undoable(
            title: title,
            systemImage: systemImage,
            successSystemImage: successSystemImage,
            callback: callback,
            color: color
        )
    }
    
    case loading(title: String)
    
    static func loading(_ title: LocalizedStringResource = "Loading...") -> ToastType {
        .loading(title: String(localized: title))
    }
    
    @_disfavoredOverload
    static func loading(_ title: String) -> ToastType {
        .loading(title: title)
    }
    
    case error(_ details: ErrorDetails)
    
    case account(any Account)
    
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
        case .loading:
            10
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
    
    static func success(_ message: LocalizedStringResource? = nil) -> Self {
        if let message {
            return success(String(localized: message))
        } else {
            return success(nil as String?)
        }
    }
    
    @_disfavoredOverload
    static func success(_ message: String? = nil) -> Self {
        .basic(
            title: message ?? "Success",
            subtitle: nil,
            systemImage: Icons.successCircleFill,
            color: Palette.main.positive,
            duration: 1
        )
    }
    
    static func failure(_ message: LocalizedStringResource? = nil) -> Self {
        if let message {
            return failure(String(localized: message))
        } else {
            return failure(nil as String?)
        }
    }
    
    @_disfavoredOverload
    static func failure(_ message: String? = nil) -> Self {
        .basic(
            title: message ?? "Failed",
            subtitle: nil,
            systemImage: Icons.failureCircleFill,
            color: Palette.main.negative,
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
        case let .undoable(
            title: title,
            systemImage: systemImage,
            successSystemImage: successSystemImage,
            callback: _,
            color: color
        ):
            hasher.combine("undoable")
            hasher.combine(title)
            hasher.combine(systemImage)
            hasher.combine(successSystemImage)
            hasher.combine(color)
        case let .error(details):
            hasher.combine("error")
            hasher.combine(details)
        case let .account(account):
            hasher.combine("account")
            hasher.combine(account)
        case .loading:
            hasher.combine("loading")
        }
    }
    
    static func == (lhs: ToastType, rhs: ToastType) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
