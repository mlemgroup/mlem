//
//  Button+Extensions.swift
//  Actions
//
//  Created by Sjmarf on 2025-11-12.
//

import SwiftUI

public extension Button {
    // Remember to handle ActionAppearance visibility when you use this
    init(
        _ appearance: ActionAppearance,
        describing type: ActionLabelType,
        callback: @escaping () -> Void
    ) where Label == SwiftUI.Label<Text, Image> {
        self.init(role: appearance.isDestructive ? .destructive : nil, action: callback) {
            Label(appearance, describing: type)
        }
    }
}
