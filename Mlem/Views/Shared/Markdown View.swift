//
//  Markdown View.swift
//  Mlem
//
//  Created by David Bureš on 18.05.2023.
//

import SwiftUI
import MarkdownUI

extension Theme
{
    static let mlem = Theme()
        .blockquote { label in
            label.body
                .markdownTextStyle {
                    ForegroundColor(.secondary)
                }
        }
}

struct MarkdownView: View {
    
    @State var text: String
    
    var body: some View {
        Markdown(text)
            .markdownTheme(.gitHub)
    }
}
