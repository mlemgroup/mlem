//
//  SearchResultsView.swift
//  Mlem
//
//  Created by Sjmarf on 27/06/2024.
//

import MlemMiddleware
import SwiftUI

struct SearchResultsView<Item: Searchable, Content: View>: View {
    @ViewBuilder let content: (Item) -> Content
    let results: [Item]
    let dividerPadding: CGFloat
    
    init(
        results: [Item],
        dividerPadding: Bool = true,
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self.results = results
        self.dividerPadding = dividerPadding ? 71 : 0
        self.content = content
    }
    
    var body: some View {
        ForEach(results) { item in
            content(item)
            PaletteDivider()
                .padding(.leading, dividerPadding)
        }
    }
}
