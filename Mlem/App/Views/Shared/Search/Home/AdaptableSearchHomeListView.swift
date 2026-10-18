//
//  AdaptableSearchHomeListView.swift
//  Mlem
//
//  Created by Sjmarf on 2026-10-18.
//

import SwiftUI

struct AdaptableSearchHomeListView<Content: View>: View {
    var content: Content

    @State private var width: CGFloat = 0

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        Group {
            if width > 500 {
                SearchHomeGridView { content }
            } else {
                SearchHomeListView { content }
            }
        }
        .frame(maxWidth: .infinity)
        .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { width = $0 }
    }
}
