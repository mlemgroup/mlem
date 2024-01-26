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
