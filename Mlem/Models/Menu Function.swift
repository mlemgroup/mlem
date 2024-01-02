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
        }
    }
    
    case standard(StandardMenuFunction)
    case shareUrl(ShareMenuFunction)
    case shareImage(ShareImageFunction)
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
    let destructiveActionPrompt: String?
    let enabled: Bool
    let callback: () -> Void
}
