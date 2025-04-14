//
//  File.swift
//  Icons
//
//  Created by Sjmarf on 2025-04-14.
//

import SwiftUI

public extension Picker where Label == SwiftUI.Label<Text, Image> {
    nonisolated init(
        _ titleKey: LocalizedStringKey,
        icon: Icon,
        selection: Binding<SelectionValue>,
        @ViewBuilder content: () -> Content
    ) {
        self.init(titleKey, systemImage: icon.computeImageName(), selection: selection, content: content)
    }
}
