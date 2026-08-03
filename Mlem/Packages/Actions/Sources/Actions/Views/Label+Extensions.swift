//
//  File.swift
//  Actions
//
//  Created by Sjmarf on 2025-10-13.
//

import Icons
import SwiftUI

public extension Label where Title == Text, Icon == Image {
    @inlinable
    init(_ appearance: ActionAppearance, describing type: ActionLabelType) {
        self.init(appearance.label(describing: type))
    }

    @inlinable
    init(_ label: ActionLabel) {
        self.init(label.title, icon: label.icon)
    }
}
