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
    @State var width: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    HStack(spacing: 0) {
                        SearchBar("Search", text: $query, isEditing: .constant(true))
                            .isInitialFirstResponder(true)
                            .autocorrectionDisabled()
                    }
                    // This weird padding setup is necessary.
                    // Adding simple padding causes the bubble to
                    // be a different width than the search bar
                    // content.
                    .padding(.horizontal, 5)
                    .frame(width: width)
                    .padding(.vertical, -10)
                    .padding(.horizontal, -15)
                }
                CloseButtonToolbarItem {
                    navigation.dismissSheet()
                }
            }
            .background {
                GeometryReader { proxy in
                    Color.clear
                        .onAppear { width = proxy.size.width }
                        .onChange(of: proxy.size.width) { width = $1 }
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
