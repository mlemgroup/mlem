//
//  View - View - NavigationBar Color.swift
//  Mlem
//
//  Created by fer0n on 11.08.23.
//

import SwiftUI

struct NavigationBarColorModifier: ViewModifier {
    @AppStorage("hasTranslucentInsets") var hasTranslucentInsets: Bool = true
    
    let visibility: Visibility
    
    func body(content: Content) -> some View {
        if hasTranslucentInsets {
            content
                .toolbarBackground(.bar, for: .navigationBar)
                .toolbarBackground(visibility, for: .navigationBar)
        } else {
            content
                .toolbarBackground(Color.systemBackground, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

extension View {
    func navigationBarColor(visibility: Visibility = .automatic) -> some View {
        self.modifier(NavigationBarColorModifier(visibility: visibility))
    }
}
