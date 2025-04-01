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
        Group {
            if #available(iOS 18.0, *) {
                containerBackground(.themedGroupedBackground, for: .navigation)
            } else {
                background(ThemedColor.themedGroupedBackground, in: Rectangle())
            }
        }
    }
}
