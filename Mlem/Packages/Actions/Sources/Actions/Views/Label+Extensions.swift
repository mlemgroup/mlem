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
    init(_ appearance: ActionAppearance) {
        self.init(appearance.title, icon: appearance.icon)
    }
}
