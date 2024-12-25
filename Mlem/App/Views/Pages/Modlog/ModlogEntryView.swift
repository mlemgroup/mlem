//
//  ModlogEntryView.swift
//  Mlem
//
//  Created by Sam Marfleet on 2024-12-25.
//

import MlemMiddleware
import SwiftUI

struct ModlogEntryView: View {
    @Environment(Palette.self) var palette
    
    let entry: ModlogEntry
    
    var body: some View {
        VStack {
            HStack {
                FullyQualifiedLinkView(
                    entity: entry.moderator,
                    labelStyle: .medium,
                    showAvatar: false,
                    showInstance: false
                )
                Text("removed a post")
                    .foregroundStyle(.secondary)
                    .font(.footnote)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(Constants.main.standardSpacing)
        .background(palette.secondaryGroupedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
        .paletteBorder(cornerRadius: Constants.main.standardSpacing)
        .environment(\.communityContext, entry.type.community)
    }
}
