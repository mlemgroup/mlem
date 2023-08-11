//
//  View - View - NavigationBar Color.swift
//  Mlem
//
//  Created by fer0n on 11.08.23.
//

import SwiftUI

struct NavigationBarColorModifier: ViewModifier {
    @AppStorage("showSolidBarColor") var showSolidBarColor: Bool = false

    func body(content: Content) -> some View {
        if showSolidBarColor {
            content
                .toolbarBackground(Color.systemBackground, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
        } else {
            content
        }
    }
}

extension View {
    func navigationBarColor() -> some View {
        self.modifier(NavigationBarColorModifier())
    }
}
