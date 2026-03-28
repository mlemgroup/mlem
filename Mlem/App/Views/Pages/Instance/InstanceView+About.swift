//
//  InstanceView+About.swift
//  Mlem
//
//  Created by Sjmarf on 2025-08-11.
//

import LemmyMarkdownUI
import MlemMiddleware
import SwiftUI

extension InstanceView {
    @ViewBuilder
    var aboutTab: some View {
        VStack(spacing: Constants.main.standardSpacing) {
            if let shortDescription = instance.shortDescription {
                markdownBox(shortDescription)
            }
            if let description = instance.description {
                markdownBox(description)
            }
        }
        .padding([.horizontal, .bottom], Constants.main.standardSpacing)
    }
    
    private func markdownBox(_ text: String) -> some View {
        Markdown(text, configuration: .default(palette: palette))
            .padding(Constants.main.standardSpacing)
            .background(.themedSecondaryGroupedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
            .paletteBorder(cornerRadius: Constants.main.standardSpacing)
    }
}
