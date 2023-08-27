//
//  SearchTokenSuggestionView.swift
//  Mlem
//
//  Created by Sjmarf on 27/08/2023.
//

import SwiftUI

struct SearchTokenSuggestionView<Icon: View>: View {
    
    var title: String
    var trailing: String?
    var highlight: String
    
    var icon: Icon
    
    init(
        title: String,
        highlight: String,
        trailing: String? = nil,
        @ViewBuilder _ icon: () -> Icon
    ) {
        self.title = title
        self.highlight = highlight
        self.trailing = trailing
        self.icon = icon()
    }

    var body: some View {
        VStack {
            Button {} label: {
                HStack {
                    Text("Add filter:")
                        .foregroundStyle(.secondary)
                    icon
                    HighlightedResultText(title, highlight: highlight)
                    Spacer()
                    if let trailing = trailing {
                        Text(trailing)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 15)
            Divider()
        }
    }
}
