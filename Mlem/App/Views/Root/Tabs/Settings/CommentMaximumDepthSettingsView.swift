//
//  CommentMaximumDepthSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-21.
//

import SwiftUI

struct CommentMaximumDepthSettingsView: View {
    @Setting(\.comment_maxDepth) var maxCommentDepth
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Label("Maximum Comment Depth", icon: .settings.commentDepth)
                    Spacer()
                    Text(String(maxCommentDepth))
                        .foregroundStyle(.themedSecondary)
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
                Text("The number of child comments that can appear in a chain before the \"More Replies\" button is shown.")
            }
        }
        .navigationTitle("Maximum Depth")
                .labelStyle(.conditional)
        .toggleStyle(.conditional)
    }
}
