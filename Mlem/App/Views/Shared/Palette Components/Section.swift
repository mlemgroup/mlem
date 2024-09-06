//
//  Section.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-08-30.
//

import Foundation
import SwiftUI

struct Section<Parent: View, Content: View, Footer: View>: View {
    @Environment(Palette.self) var palette

    @ViewBuilder let header: () -> Parent
    @ViewBuilder let content: () -> Content
    @ViewBuilder let footer: () -> Footer

    init(
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder header: @escaping () -> Parent = { EmptyView() },
        @ViewBuilder footer: @escaping () -> Footer = { EmptyView() }
    ) {
        self.header = header
        self.content = content
        self.footer = footer
    }

    init(
        _ header: LocalizedStringResource,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder footer: @escaping () -> Footer = { EmptyView() }
    ) where Parent == Text {
        self.header = { Text(header) }
        self.content = content
        self.footer = footer
    }
    
    @_disfavoredOverload
    init(
        _ header: String,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder footer: @escaping () -> Footer = { EmptyView() }
    ) where Parent == Text {
        self.header = { Text(header) }
        self.content = content
        self.footer = footer
    }

    var body: some View {
        SwiftUI.Section {
            content()
        } header: {
            header().foregroundStyle(palette.secondary)
        } footer: {
            footer().foregroundStyle(palette.secondary)
        }
    }
}
