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
    @Setting(\.maxCommentDepth) var maxCommentDepth
    
    var body: some View {
        Form {
            Section {
                Toggle("Compact Comments", isOn: $compactComments)
            }
            Section {
                NavigationLink(
                    "Customize Interaction Bar",
                    systemImage: "square.and.line.vertical.and.square.fill",
                    destination: .settings(.commentInteractionBar)
                )
            }
            maxDepthSection
        }
        .navigationTitle("Comments")
    }
    
    @ViewBuilder
    var maxDepthSection: some View {
        Section {
            HStack {
                Text("Maximum Comment Depth")
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
