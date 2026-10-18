//
//  SearchHomeGridView.swift
//  Mlem
//
//  Created by Sjmarf on 2026-10-18.
//

import SwiftUI

struct SearchHomeGridView<Content: View>: View {
    var content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 200), spacing: 16)], spacing: 16) {
            Group(subviews: content) { subviews in
                ForEach(subviews) { subview in
                    subview
                        .lineLimit(1)
                        .frame(maxWidth: .infinity)
                        .padding(16)
                        .background(.themedSecondaryGroupedBackground, in: .rect(cornerRadius: 16))
                        .paletteBorder(cornerRadius: 16)
                }
            }
        }
        .labelStyle(SearchHomeLabelStyle())
    }
}
