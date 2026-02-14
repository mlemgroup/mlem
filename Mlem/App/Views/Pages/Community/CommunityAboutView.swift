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
    @Environment(NavigationLayer.self) var navigation
    @Environment(\.palette) var palette

    let community: any DeprecatedCommunity

    var body: some View {
        VStack(spacing: Constants.main.standardSpacing) {
            if let banner = community.banner {
                MediaView.largeImage(url: banner, shouldBlur: false)
            }
            if let description = community.description {
                descriptionView(description)
            } else if canEditDescription {
                noDescriptionView
            }
        }
        .padding([.horizontal, .bottom], Constants.main.standardSpacing)
    }

    @ViewBuilder
    func descriptionView(_ description: String) -> some View {
        VStack(alignment: .trailing) {
            if canEditDescription {
                HStack {
                    Text("Description")
                    .font(.callout)
                    Spacer()
                    Button("Edit") {
                        edit()
                    }
                    .font(.footnote)
                    .buttonStyle(.bordered)
                }
                .foregroundStyle(.secondary)
                .fontWeight(.semibold)
                .padding(.horizontal, Constants.main.standardSpacing)
                Divider()
            }
            Markdown(description, configuration: .default(palette: palette))
            .padding(.horizontal, Constants.main.standardSpacing)
        }
        .padding(.vertical, Constants.main.standardSpacing)
        .background(.themedSecondaryGroupedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
        .paletteBorder(cornerRadius: Constants.main.standardSpacing)
    }

    @ViewBuilder
    var noDescriptionView: some View {
        VStack(spacing: 20) {
            Image(systemName: "note.text")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50)
                .foregroundStyle(.tertiary)
            Button("Add description") {
                edit()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.vertical, 20)
    }

    var canEditDescription: Bool {
        guard appState.firstApi.supports(.editCommunityDescription, defaultValue: false) else { return false }
        guard let firstPerson = appState.firstPerson else { return false }
        return (firstPerson.isAdmin.value ?? false) || (firstPerson.moderates?(.community(community)) ?? false)
    }

    func edit() {
        if let community = community as? any Community2Providing {
            navigation.openSheet(.editCommunity(community.community2))
        }
    }
}
