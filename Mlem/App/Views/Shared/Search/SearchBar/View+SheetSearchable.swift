//
//  View+sheetSearchable.swift
//  Mlem
//
//  Created by Sjmarf on 2025-08-22.
//

import SwiftUI

private struct SheetSearchableViewModifier: ViewModifier {
    @Environment(NavigationLayer.self) var navigation
    
    let closeButtonLabel: LocalizedStringResource
    
    @Binding var query: String
    @FocusState var focused: Bool
    
    func body(content: Content) -> some View {
        Group {
            if #available(iOS 26, *) {
                ios26Body(content: content)
            } else {
                ios18Body(content: content)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(String(localized: closeButtonLabel)) {
                    navigation.dismissSheet()
                }
            }
        }
        .onAppear {
            focused = true
        }
    }
    
    func ios18Body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 0) {
                        SearchBar("Search", text: $query, isEditing: .constant(true))
                            .isInitialFirstResponder(true)
                            .focused($focused)
                            .autocorrectionDisabled()
                    }
                }
            }
    }
    
    func ios26Body(content: Content) -> some View {
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
            }
    }
}

extension View {
    func sheetSearchable(
        closeButtonLabel: LocalizedStringResource = "Cancel",
        query: Binding<String>
    ) -> some View {
        modifier(SheetSearchableViewModifier(closeButtonLabel: closeButtonLabel, query: query))
    }
}
