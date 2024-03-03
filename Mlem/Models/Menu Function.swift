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
        case let .group(groupMenuFunction):
            return groupMenuFunction.id
        case .divider:
            return UUID().uuidString
        }
    }
    
    case divider // not a menu function per se, but adds a divider to the menu
    case standard(StandardMenuFunction)
    case shareUrl(ShareMenuFunction)
    case shareImage(ShareImageFunction)
    case navigation(NavigationMenuFunction)
    /// - Parameter titleKey: User-facing title label for menu.
    /// - Parameter children: Menu items for this child menu.
    /// - Note: Destructive confirmation is not supported at this time.
    case group(GroupMenuFunction)
}

struct MenuFunctionPopup {
    struct Action {
        var text: String
        var callback: () -> Void
    }
    
    let prompt: String?
    let actions: [Action]
}

enum MenuFunctionActionType {
    case standard(callback: () -> Void)
    case popup(MenuFunctionPopup)
}

enum MenuFunctionDestructiveCondition {
    case never, always, whenTrue, whenFalse
}

// some convenience initializers because MenuFunction.standard(StandardMenuFunction...) is ugly
extension MenuFunction {
    static func standardMenuFunction(
        text: String,
        imageName: String,
        isDestructive: Bool = false,
        enabled: Bool = true,
        callback: @escaping () -> Void
    ) -> MenuFunction {
        MenuFunction.standard(StandardMenuFunction(
            text: text,
            imageName: imageName,
            isDestructive: isDestructive,
            role: .standard(callback: callback),
            enabled: enabled
        ))
    }
    
    static func standardMenuFunction(
        text: String,
        imageName: String,
        confirmationPrompt: String,
        enabled: Bool = true,
        callback: @escaping () -> Void
    ) -> MenuFunction {
        MenuFunction.standard(StandardMenuFunction(
            text: text,
            imageName: imageName,
            isDestructive: true,
            role: .popup(.init(prompt: confirmationPrompt, actions: [.init(text: "Yes", callback: callback)])),
            enabled: enabled
        ))
    }
    
    static func standardMenuFunction(
        text: String,
        imageName: String,
        isDestructive: Bool = false,
        enabled: Bool = true,
        prompt: String,
        actions: [MenuFunctionPopup.Action]
    ) -> MenuFunction {
        MenuFunction.standard(StandardMenuFunction(
            text: text,
            imageName: imageName,
            isDestructive: isDestructive,
            role: .popup(.init(prompt: prompt, actions: actions)),
            enabled: enabled
        ))
    }
    
    static func groupMenuFunction(
        text: String,
        imageName: String,
        children: [MenuFunction]
    ) -> MenuFunction {
        MenuFunction.group(GroupMenuFunction(
            text: text,
            imageName: imageName,
            children: children
        ))
    }
    
    // swiftlint:disable:next function_parameter_count
    static func toggleableMenuFunction(
        toggle: Bool,
        trueText: String,
        trueImageName: String,
        falseText: String,
        falseImageName: String,
        isDestructive: MenuFunctionDestructiveCondition = .never,
        enabled: Bool = true,
        callback: @escaping () -> Void
    ) -> MenuFunction {
        if toggle {
            return standardMenuFunction(
                text: trueText,
                imageName: trueImageName,
                isDestructive: isDestructive == .whenTrue || isDestructive == .always,
                enabled: enabled,
                callback: callback
            )
        } else {
            return standardMenuFunction(
                text: falseText,
                imageName: falseImageName,
                isDestructive: isDestructive == .whenFalse || isDestructive == .always,
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
    let isDestructive: Bool
    var role: MenuFunctionActionType
    let enabled: Bool
}

struct GroupMenuFunction: Identifiable {
    var id: String { text }
    let text: String
    let imageName: String
    var children: [MenuFunction]
}

struct NavigationMenuFunction: Identifiable {
    var id: String { text }
    
    let text: String
    let imageName: String
    let destination: AppRoute
}
