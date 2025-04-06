//
//  CommentSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 25/08/2024.
//

import SwiftUI

struct CommentSettingsView: View {
    @Setting(\.comment_compact) var compactComments
    @Setting(\.comment_gestures_tapToCollapse) var tapCommentsToCollapse
    @Setting(\.comment_maxDepth) var maxCommentDepth
    @Setting(\.comment_jumpButton) var jumpButton

    var body: some View {
        Form {
            Section("Size") {
                HStack {
                    sizePickerItem("Large", isOn: false)
                    sizePickerItem("Compact", isOn: true)
                }
            }
            Section {
                NavigationLink(.settings(.interactionBar(.comment))) {
                    SettingsInteractionBarSummaryView(configuration: InteractionBarTracker.main.commentInteractionBar)
                }
                NavigationLink("Swipe Actions", destination: .settings(.swipeActions(.comment)))
            }
            Section {
                NavigationLink(
                    "Jump Button",
                    value: .init(localized: jumpButton.label),
                    fallbackValue: "",
                    systemImage: Icons.jumpButtonCircle,
                    destination: .settings(.commentJumpButton)
                )
                NavigationLink(
                    "Maximum Depth",
                    value: String(maxCommentDepth),
                    fallbackValue: "",
                    systemImage: Icons.commentDepth,
                    destination: .settings(.commentMaximumDepth)
                )
            }
            Section {
                Toggle("Tap to Collapse", systemImage: Icons.collapseComment, isOn: $tapCommentsToCollapse)
            }
        }
        .labelStyle(.conditional)
        .navigationTitle("Comments")
    }
    
    var sizePickerCommentPreviewDepths: [CGFloat] {
        [0, 1, 2, 1, 2, 3, 2, 1, 2, 2]
    }
    
    @ViewBuilder
    func sizePickerItem(_ titleKey: LocalizedStringResource, isOn: Bool) -> some View {
        DevicePickerItem(titleKey, item: isOn, selected: $compactComments, scale: 1.2) {
            VStack(spacing: 3) {
                ForEach(Array(sizePickerCommentPreviewDepths.enumerated()), id: \.offset) { _, depth in
                    RoundedRectangle(cornerRadius: 2)
                        .frame(height: isOn ? 10 : 15)
                        .padding(.leading, depth * 4)
                }
            }
            .padding(.top, 4)
        }
    }
}
