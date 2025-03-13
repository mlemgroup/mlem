//
//  View+NavigtionStackPreview.swift
//  Mlem
//
//  Created by Sjmarf on 2025-03-13.
//

import SwiftUI

#if DEBUG
    // This can be used in previews to show a back button in the corner
    private struct NavigationStackPreviewModifier: ViewModifier {
        let backButtonLabel: String
    
        func body(content: Content) -> some View {
            NavigationStack(path: .constant([1])) {
                Color.clear // If EmptyView() is used here, the back button isn't labelled correctly
                    .navigationTitle(backButtonLabel)
                    .navigationDestination(for: Int.self) { _ in content }
            }
        }
    }

    extension View {
        func previewNavigationStack(backButtonLabel: LocalizedStringResource = "Back") -> some View {
            modifier(NavigationStackPreviewModifier(backButtonLabel: .init(localized: backButtonLabel)))
        }
    }
#endif
