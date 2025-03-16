//
//  SharingLinksSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-03-09.
//

import SwiftUI

struct SharingLinksSettingsView: View {
    @Setting(\.linkSharingMode) var linkSharingMode
    @Setting(\.showSettingsIcons) var showSettingsIcons

    var body: some View {
        Form {
            SettingsHeaderView(
                title: "Share Links",
                // swiftlint:disable:next line_length
                description: "In the Fediverse, many different links can point to the same piece of content. Choose which site to use when sharing content.",
                systemImage: Icons.share
            )
            .tint(.themedColorfulAccent(3))
            
            pickerItemView(
                mode: .myInstance,
                title: "My Instance",
                description: "Share links using the instance you are currently connected to.",
                systemImage: Icons.instance
            )
            
            pickerItemView(
                mode: .originalInstance,
                title: "Original Instance",
                description: "Share links using the instance that the content originated from.",
                systemImage: "signature"
            )

            pickerItemView(
                mode: .lemmyverse,
                title: "Universal Link",
                description: "Share links using \("https://lemmyverse.link"). When someone opens the link, they can choose which instance to use.",
                systemImage: "globe"
            )
            pickerItemView(
                mode: .askEveryTime,
                title: "Ask Every Time",
                description: "Every time I share a link, show a popup asking which instance to use.",
                systemImage: "questionmark.circle"
            )
        }
        .contentMargins(.top, 16)
        .labelStyle(.conditional)
        .animation(.easeInOut(duration: 0.1), value: linkSharingMode)
    }
    
    @ViewBuilder
    func pickerItemView(
        mode: LinkSharingMode,
        title: LocalizedStringResource,
        description: LocalizedStringResource,
        systemImage: String
    ) -> some View {
        HStack(alignment: .top) {
            if showSettingsIcons {
                Image(systemName: systemImage)
                    .foregroundStyle(.themedAccent)
                    .frame(width: 30)
                    .padding(.top, 2)
            }
            VStack(alignment: .leading) {
                Text(title)
                Text(description)
                    .font(.footnote)
                    .foregroundStyle(.themedSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Checkbox(isOn: linkSharingMode == mode)
        }
        .contentShape(.rect)
        .onTapGesture {
            linkSharingMode = mode
        }
        .listRowInsets(.init(top: 10, leading: showSettingsIcons ? 10 : 16, bottom: 10, trailing: 16))
    }
}

enum LinkSharingMode: String, Codable, CaseIterable {
    case myInstance, originalInstance, lemmyverse, askEveryTime
}
