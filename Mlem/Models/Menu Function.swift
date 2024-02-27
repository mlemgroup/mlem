//
//  Menu Functions.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-30.
//

import Foundation
import SwiftUI

enum MenuFunction: Identifiable {
    var id: String {
        switch self {
        case let .standard(standardMenuFunction):
            return standardMenuFunction.id
        case let .shareUrl(shareMenuFunction):
            return shareMenuFunction.id
        case let .shareImage(shareImageFunction):
            return shareImageFunction.id
        case let .navigation(navigationMenuFunction):
            return navigationMenuFunction.id
        case .childMenu:
            return UUID().uuidString
        }
    }
    
    case standard(StandardMenuFunction)
    case shareUrl(ShareMenuFunction)
    case shareImage(ShareImageFunction)
    case navigation(NavigationMenuFunction)
    /// - Parameter titleKey: User-facing title label for menu.
    /// - Parameter children: Menu items for this child menu.
    /// - Note: Destructive confirmation is not supported at this time.
    case childMenu(titleKey: String, children: [MenuFunction])
}

enum MenuFunctionRole {
    case destructive(prompt: String?)
}

// some convenience initializers because MenuFunction.standard(StandardMenuFunction...) is ugly
extension MenuFunction {
    static func standardMenuFunction(
        text: String,
        imageName: String,
        role: MenuFunctionRole? = nil,
        enabled: Bool = true,
        callback: @escaping () -> Void
    ) -> MenuFunction {
        MenuFunction.standard(StandardMenuFunction(
            text: text,
            imageName: imageName,
            role: role,
            enabled: enabled,
            callback: callback
        ))
    }
    
    // swiftlint:disable:next function_parameter_count
    static func toggleableMenuFunction(
        toggle: Bool,
        trueText: String,
        trueImageName: String,
        trueRole: MenuFunctionRole? = nil,
        falseText: String,
        falseImageName: String,
        falseRole: MenuFunctionRole? = nil,
        enabled: Bool = true,
        callback: @escaping () -> Void
    ) -> MenuFunction {
        if toggle {
            return standardMenuFunction(
                text: trueText,
                imageName: trueImageName,
                role: trueRole,
                enabled: enabled,
                callback: callback
            )
        } else {
            return standardMenuFunction(
                text: falseText,
                imageName: falseImageName,
                role: falseRole,
                enabled: enabled,
                callback: callback
            )
        }
    }
    
    static func navigationMenuFunction(
        text: String,
        imageName: String,
        destination: AppRoute
    ) -> MenuFunction {
        MenuFunction.navigation(NavigationMenuFunction(
            text: text,
            imageName: imageName,
            destination: destination
        ))
    }
    
    static func shareMenuFunction(url: URL) -> MenuFunction {
        MenuFunction.shareUrl(ShareMenuFunction(url: url))
    }
    
    static func shareImageFunction(image: Image) -> MenuFunction {
        MenuFunction.shareImage(ShareImageFunction(image: image))
    }
}

/// MenuFunction to open a ShareLink
struct ShareMenuFunction: Identifiable {
    var id: String { url.absoluteString }
    
    let url: URL
}

struct ShareImageFunction: Identifiable {
    let id: String
    let image: Image
    
    init(image: Image) {
        self.image = image
        self.id = UUID().uuidString
    }
}

/// MenuFunction to perform a generic menu action
struct StandardMenuFunction: Identifiable {
    var id: String { text }
    
    let text: String
    let imageName: String
    var role: MenuFunctionRole?
    let enabled: Bool
    let callback: () -> Void
}

struct NavigationMenuFunction: Identifiable {
    var id: String { text }
    
    let text: String
    let imageName: String
    let destination: AppRoute
}
