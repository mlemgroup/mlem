//
//  ActionSheet.swift
//  Mlem
//
//  Created by Sjmarf on 2025-11-12.
//

import Actions
import MlemMiddleware
import SwiftUI

struct ActionSheet: View {
    let actions: [any Actions.Action]

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                content
                    .padding(16)
            }
        }
        .presentationBackground(.themedGroupedBackground)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
        .presentationBackgroundInteraction(.enabled)
    }

    var content: some View {
        VStack(spacing: 0) {
            ForEach(Array(actions.enumerated()), id: \.offset) { index, action in
                if ![actions.startIndex, actions.endIndex-1].contains(index) {
                    Divider()
                        .padding(.horizontal, 15)
                }
                ActionButtonWithVisibilityControl(action)
            }
        }
        .background(.themedSecondaryGroupedBackground, in: .rect(cornerRadius: 25))
        .labelStyle(ActionSheetLabelStyle())
        .buttonStyle(.plain)
    }
}

private struct ActionSheetLabelStyle: LabelStyle {
    @ScaledMetric(relativeTo: .body) var rowHeight = 40

    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.title
            Spacer()
            configuration.icon
                .font(.title2)
        }
        .padding(.horizontal, 25)
        .frame(height: rowHeight)
        .padding(.vertical, 8)
        .contentShape(.rect)
    }
}
