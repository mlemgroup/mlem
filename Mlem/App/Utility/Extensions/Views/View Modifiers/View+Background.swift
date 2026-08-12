//
//  View+Background.swift
//  Mlem
//
//  Created by Sjmarf on 2025-04-01.
//

import SwiftUI
import Theming

extension View {
    func themedGroupedBackground() -> some View {
        containerBackground(.themedGroupedBackground, for: .navigation)
    }
}
