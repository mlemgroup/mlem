//
//  CommentSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 25/08/2024.
//

import SwiftUI

struct CommentSettingsView: View {
    @Environment(Palette.self) var palette
    
    @Setting(\.compactComments) var compactComments
    @Setting(\.tapCommentsToCollapse) var tapCommentsToCollapse
    @Setting(\.maxCommentDepth) var maxCommentDepth
    
    var body: some View {
        Form {
            Section {
                Toggle("Compact Comments", systemImage: Icons.compactComments, isOn: $compactComments)
                Toggle("Tap to Collapse", systemImage: Icons.collapseComment, isOn: $tapCommentsToCollapse)
            }
            Section {
                NavigationLink(
                    "Customize Interaction Bar",
                    systemImage: Icons.interactionBar,
                    destination: .settings(.commentInteractionBar)
                )
            }
            maxDepthSection
        }
        .labelStyle(ConditionalIconLabelStyle())
        .navigationTitle("Comments")
    }
    
    @ViewBuilder
    var maxDepthSection: some View {
        Section {
            HStack {
                Label("Maximum Comment Depth", systemImage: Icons.commentDepth)
                Spacer()
                Text(String(maxCommentDepth))
                    .foregroundStyle(palette.secondary)
                    .monospaced()
            }
            Slider(
                value: .init(
                    get: { Double(maxCommentDepth) },
                    set: { maxCommentDepth = Int($0) }
                ),
                in: 1.0 ... 12.0,
                step: 1
            )
        } footer: {
            Text("The number of child comments that are shown in a chain before the \"More Replies\" button is shown.")
        }
    }
}
