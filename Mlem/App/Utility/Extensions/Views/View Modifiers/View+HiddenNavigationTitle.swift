//
//  View+HiddenNavigationTitle.swift
//  Mlem
//
//  Created by Sjmarf on 2025-03-18.
//

import SwiftUI

extension View {
    @ViewBuilder
    func hiddenNavigationTitle(_ title: LocalizedStringResource) -> some View {
        hiddenNavigationTitle(String(localized: title))
    }
    
    @_disfavoredOverload
    @ViewBuilder
    func hiddenNavigationTitle(_ title: String) -> some View {
        self
            .navigationTitle(title)
            .toolbar(removing: .title)
    }
}
