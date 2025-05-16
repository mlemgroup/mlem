//
//  Toast.swift
//  Mlem
//
//  Created by Sjmarf on 15/05/2024.
//

import Icons
import MlemMiddleware
import SwiftUI
import Theming

enum ToastType: Hashable {
    // Don't initialize this directly - use one of the static methods instead
    case basic(
        title: String,
        subtitle: String?,
        icon: Icon?,
        color: ThemedColor,
        duration: Double
    )
    
    static func basic(
        _ title: LocalizedStringResource,
        subtitle: LocalizedStringResource? = nil,
        icon: Icon? = nil,
        color: ThemedColor? = nil,
        duration: Double = 1.5
    ) -> ToastType {
        let subtitleString: String?
        if let subtitle {
            subtitleString = String(localized: subtitle)
        } else {
            subtitleString = nil
        }
        return .basic(
            title: String(localized: title),
            subtitle: subtitleString,
            icon: icon,
            color: color ?? .themedAccent,
            duration: duration
        )
    }
    
    @_disfavoredOverload
    static func basic(
        _ title: String,
        subtitle: String? = nil,
        icon: Icon? = nil,
        color: ThemedColor? = nil,
        duration: Double = 1.5
    ) -> ToastType {
        .basic(
            title: title,
            subtitle: subtitle,
            icon: icon,
            color: color ?? .themedAccent,
            duration: duration
        )
    }
    
    // Don't initialize this directly - use one of the static methods instead
    case undoable(
        title: String?,
        icon: Icon?,
        successIcon: Icon?,
        callback: () -> Void,
        color: ThemedColor
    )

    static func undoable(
        _ title: LocalizedStringResource? = nil,
        icon: Icon? = nil,
        successIcon: Icon? = nil,
        callback: @escaping () -> Void,
        color: ThemedColor = .themedAccent
    ) -> ToastType {
        let string: String?
        if let title {
            string = .init(localized: title)
        } else {
            string = nil
        }

        return .undoable(
            title: string,
            icon: icon,
            successIcon: successIcon,
            callback: callback,
            color: color
        )
    }
    
    @_disfavoredOverload
    static func undoable(
        _ title: String? = nil,
        icon: Icon? = nil,
        successIcon: Icon? = nil,
        callback: @escaping () -> Void,
        color: ThemedColor = .themedAccent
    ) -> ToastType {
        .undoable(
            title: title,
            icon: icon,
            successIcon: successIcon,
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
    
    static var urlCopyError: ToastType {
        basic(
            "No URL Copied",
            subtitle: "Copy a URL to the clipboard, then try again.",
            icon: nil,
            color: .themedAccent,
            duration: 2
        )
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
            icon: .general.success,
            color: .themedPositive,
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
            icon: .general.failure,
            color: .themedNegative,
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
            icon: icon,
            successIcon: successIcon,
            callback: _,
            color: color
        ):
            hasher.combine("undoable")
            hasher.combine(title)
            hasher.combine(icon)
            hasher.combine(successIcon)
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
