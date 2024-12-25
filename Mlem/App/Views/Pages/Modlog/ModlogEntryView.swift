//
//  ModlogEntryView.swift
//  Mlem
//
//  Created by Sjmarf on 2024-12-25.
//

import MlemMiddleware
import SwiftUI

struct ModlogEntryView: View {
    @Environment(Palette.self) var palette
    
    let entry: ModlogEntry
    var targetCommunity: (any Community)?
    
    var body: some View {
        VStack(alignment: .leading) {
            if let moderator = entry.moderator {
                HStack(spacing: Constants.main.standardSpacing) {
                    CircleCroppedImageView(moderator, frame: Constants.main.mediumAvatarSize)
                    let labelText = moderator.nameTextView(
                        showFlairs: true,
                        showInstance: true,
                        communityContext: targetCommunity ?? entry.type.community,
                        font: .footnote
                    )
                    Text("\(labelText) removed a post")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .imageScale(.small)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Constants.main.standardSpacing)
        .background(palette.secondaryGroupedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
        .paletteBorder(cornerRadius: Constants.main.standardSpacing)
        .environment(\.communityContext, entry.type.community)
    }
}
