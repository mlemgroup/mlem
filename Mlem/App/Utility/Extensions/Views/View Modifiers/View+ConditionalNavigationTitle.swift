//
//  View+onditionalNavigationTitle.swift
//  Mlem
//
//  Created by Sjmarf on 2025-03-30.
//

import SwiftUI

private struct ConditionalNavigationTitle: ViewModifier {
    let title: String
    
    @State private var isAtTop: Bool = true

    func body(content: Content) -> some View {
        content
            .isAtTopSubscriber(isAtTop: $isAtTop)
            // Unfortunately `.toolbar(removing: )` doesn't work with a condition :(
            .navigationTitle(isAtTop ? "" : title)
    }
}

extension View {
    func conditionalNavigationTitle(_ title: LocalizedStringResource) -> some View {
        modifier(ConditionalNavigationTitle(title: .init(localized: title)))
    }
    
    @_disfavoredOverload
    func conditionalNavigationTitle(_ title: String) -> some View {
        modifier(ConditionalNavigationTitle(title: title))
    }
}
