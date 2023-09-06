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

// some convenience initializers
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
    
    // this is a special one--if it exists, then we make a ShareLink instead of a regular menu button
    let shareURL: URL?
    
    let callback: () -> Void
    
    init(
        text: String,
        imageName: String,
        destructiveActionPrompt: String?,
        enabled: Bool,
        shareURL: URL? = nil,
        callback: @escaping () -> Void
    ) {
        self.text = text
        self.imageName = imageName
        self.destructiveActionPrompt = destructiveActionPrompt
        self.enabled = enabled
        self.shareURL = shareURL
        self.callback = callback
    }
}
