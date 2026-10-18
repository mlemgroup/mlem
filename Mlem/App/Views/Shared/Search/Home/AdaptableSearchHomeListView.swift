//
//  AdaptableSearchHomeListView.swift
//  Mlem
//
//  Created by Sjmarf on 2026-10-18.
//

import SwiftUI

struct AdaptableSearchHomeListView<Content: View>: View {
    var content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        GeometryReader { geometry in
            if geometry.size.width > 500 {
                SearchHomeGridView { content }
            } else {
                SearchHomeListView { content }
            }
        }
    }
}
