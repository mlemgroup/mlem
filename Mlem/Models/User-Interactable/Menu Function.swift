//
//  Menu Functions.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-30.
//

import Foundation

enum MenuFunction: Identifiable {
    var id: String {
        switch self {
        case let .standard(standardMenuFunction):
            return standardMenuFunction.id
        case let .share(shareMenuFunction):
            return shareMenuFunction.id
        }
    }
    
    case standard(StandardMenuFunction)
    case share(ShareMenuFunction)
}

// some convenience initializers because MenuFunction.standard(StandardMenuFunction...) is ugly
extension MenuFunction {
    static func standardMenuFunction(
        text: String,
        imageName: String,
        destructiveActionPrompt: String?,
        enabled: Bool,
        callback: @escaping () -> Void
    ) -> MenuFunction {
        MenuFunction.standard(StandardMenuFunction(
            text: text,
            imageName: imageName,
            destructiveActionPrompt: destructiveActionPrompt,
            enabled: enabled,
            callback: callback
        ))
    }
    
    static func shareMenuFunction(url: URL) -> MenuFunction {
        MenuFunction.share(ShareMenuFunction(url: url))
    }
}

struct ShareMenuFunction: Identifiable {
    var id: String { url.description }
    
    let url: URL
}

/// All the info needed to populate a menu
struct StandardMenuFunction: Identifiable {
    var id: String { text }
    
    let text: String
    let imageName: String
    let destructiveActionPrompt: String?
    let enabled: Bool
    let callback: () -> Void
}
