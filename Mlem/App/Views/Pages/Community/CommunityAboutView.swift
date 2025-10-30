//
//  CommunityView.swift
//  Mlem
//
//  Created by Sjmarf on 30/07/2024.
//

import LemmyMarkdownUI
import MlemMiddleware
import SwiftUI
import Theming

struct CommunityAboutView: View {
    @Environment(AppState.self) var appState
    @Environment(\.palette) var palette

    let community: any Community

    var body: some View {
        VStack(spacing: Constants.main.standardSpacing) {
            if let banner = community.banner {
                MediaView.largeImage(url: banner, shouldBlur: false)
            }
            if let description = community.description {
                VStack(alignment: .trailing) {
                    if canEditDescription {
                        Button("Edit", icon: .general.edit) {

                        }
                        .font(.title)
                        .labelStyle(.iconOnly)
                        .symbolVariant(.circle.fill)
                        .foregroundStyle(.themedPrimary, .themedTertiaryGroupedBackground)
                    }
                    Markdown(description, configuration: .default(palette: palette))
                }
                .padding(Constants.main.standardSpacing)
                .background(.themedSecondaryGroupedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
                .paletteBorder(cornerRadius: Constants.main.standardSpacing)
            }
        }
        .padding([.horizontal, .bottom], Constants.main.standardSpacing)
    }

    var canEditDescription: Bool {
        guard let firstPerson = appState.firstPerson else { return false }
        return firstPerson.isAdmin || firstPerson.moderates(community: community)
    }
}
