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
    
    init(
        results: [Item],
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self.results = results
        self.content = content
    }
    
    var body: some View {
        ForEach(results) { item in
            content(item)
                .paletteBorder(cornerRadius: Constants.main.standardSpacing)
                .padding(.horizontal, Constants.main.standardSpacing)
                .padding(.bottom, Constants.main.halfSpacing)
        }
    }
}
