//
//  MarkdownFooterLinkView.swift
//  Mlem
//
//  Created by Sjmarf on 2024-11-10.
//

import MlemMiddleware
import SwiftUI

struct FooterLinkView: View {
    @Environment(Palette.self) var palette
    
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
        .foregroundStyle(palette.secondary)
        .padding(Constants.main.standardSpacing)
        .background(palette.tertiaryGroupedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
        .paletteBorder(cornerRadius: Constants.main.standardSpacing)
        .contentShape(.contextMenuPreview, .rect(cornerRadius: Constants.main.standardSpacing))
    }
}
