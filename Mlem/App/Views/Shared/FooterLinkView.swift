//
//  MarkdownFooterLinkView.swift
//  Mlem
//
//  Created by Sjmarf on 2024-11-10.
//

import MlemMiddleware
import SwiftUI

struct FooterLinkView: View {
    let title: String
    let subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.subheadline)
                .fontWeight(.semibold)
                .multilineTextAlignment(.leading)
                .lineLimit(2)

            if let subtitle {
                Text(subtitle)
                    .font(.footnote)
                    .lineLimit(1)
            }
        }
        .foregroundStyle(.themedSecondary)
        .padding(Constants.main.standardSpacing)
        .background(.themedTertiaryGroupedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
        .paletteBorder(cornerRadius: Constants.main.standardSpacing)
        .contentShape(.contextMenuPreview, .rect(cornerRadius: Constants.main.standardSpacing))
    }
}
