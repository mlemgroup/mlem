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
    @FocusState var focused: Bool
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    HStack(spacing: 0) {
                        SearchBar("Search", text: $query, isEditing: .constant(true))
                            .isInitialFirstResponder(true)
                            .focused($focused)
                            .autocorrectionDisabled()
                    }
                    .padding(-10)
                }
                CloseButtonToolbarItem {
                    navigation.dismissSheet()
                }
            }
    }
}

extension View {
    func withSheetSearch(query: Binding<String>) -> some View {
        modifier(SearchSheetViewModifier(query: query))
    }
}
