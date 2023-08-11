//
//  BarBackgroundColor.swift
//  Mlem
//
//  Created by fer0n on 11.08.23.
//

import SwiftUI

struct BarBackgroundColorModifier: ViewModifier {
    @AppStorage("showSolidBarColor") var showSolidBarColor: Bool = false

    func body(content: Content) -> some View {
        if showSolidBarColor {
            content
                .toolbarBackground(Color.systemBackground, for: .navigationBar)
        } else {
            content
        }
    }
}

extension View {
    func barBackgroundColor() -> some View {
        self.modifier(BarBackgroundColorModifier())
    }
}
