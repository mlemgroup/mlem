//
//  View+withSheetSearch.swift
//  Mlem
//
//  Created by Sjmarf on 2025-08-22.
//

import ComponentViews
import SwiftUI

private struct SearchSheetViewModifier: ViewModifier {
    @Environment(NavigationLayer.self) var navigation
    
    @Binding var query: String
    @FocusState var focused

    func body(content: Content) -> some View {
        content
            .toolbar {
                CloseButtonToolbarItem {
                    navigation.dismissSheet()
                }
            }
            .safeAreaBar(edge: .bottom) {
                TextField("Search", text: $query)
                    .focused($focused)
                    .padding(16)
                    .glassEffect()
                    .padding([.horizontal, .bottom], 16)
            }
    }
}

extension View {
    func withSheetSearch(query: Binding<String>) -> some View {
        modifier(SearchSheetViewModifier(query: query))
    }
}
