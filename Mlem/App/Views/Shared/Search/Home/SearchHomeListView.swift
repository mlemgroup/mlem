//
//  SearchHomeListView.swift
//  Mlem
//
//  Created by Sjmarf on 2026-04-23.
//

import SwiftUI

struct SearchHomeListView<Content: View>: View {
    var content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack {
            Group(subviews: content) { subviews in
                ForEach(Array(subviews.enumerated()), id: \.element.id) { index, subview in
                    subview
                    if index != subviews.count - 1 {
                        Divider()
                            .padding(.leading, 50)
                    }
                }
            }
        }
        .padding(10)
        .padding(.trailing, 5)
        .labelStyle(SearchHomeLabelStyle())
        .background(.themedSecondaryGroupedBackground, in: .rect(cornerRadius: 25))
        .paletteBorder(cornerRadius: 25)
    }
}
