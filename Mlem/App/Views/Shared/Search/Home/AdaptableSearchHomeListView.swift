//
//  AdaptableSearchHomeListView.swift
//  Mlem
//
//  Created by Sjmarf on 2026-10-18.
//

import SwiftUI

struct AdaptableSearchHomeListView<Content: View>: View {
    let isGrid: Bool
    var content: Content

    init(isGrid: Bool, @ViewBuilder content: () -> Content) {
        self.isGrid = isGrid
        self.content = content()
    }

    var body: some View {
        Group {
            if isGrid {
                SearchHomeGridView { content }
            } else {
                SearchHomeListView { content }
            }
        }
        .frame(maxWidth: .infinity)
    }
}
