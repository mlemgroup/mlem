//
//  Button+Extensions.swift
//  Actions
//
//  Created by Sjmarf on 2025-11-12.
//

import SwiftUI

public extension Button {
    // Remeber to handle ActionLabel visibility when you use this
    init(
        _ label: ActionLabel,
        callback: @escaping () -> Void
    ) where Label == SwiftUI.Label<Text, Image> {
        self.init(role: label.isDestructive ? .destructive : nil, action: callback) {
            Label(label)
        }
    }
}
