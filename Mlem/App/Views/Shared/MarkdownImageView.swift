//
//  MarkdownImageView.swift
//  Mlem
//
//  Created by Sjmarf on 30/05/2024.
//

import LemmyMarkdownUI
import SwiftUI

struct MarkdownImageView: View {
    @Environment(Palette.self) var palette
    
    let image: InlineImage
    
    var body: some View {
        Image(systemName: "photo")
            .imageScale(.large)
            .foregroundStyle(palette.secondary)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(palette.secondaryBackground)
            )
    }
}
