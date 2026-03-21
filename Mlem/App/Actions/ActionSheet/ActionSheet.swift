//
//  ActionSheet.swift
//  Mlem
//
//  Created by Sjmarf on 2025-11-12.
//

import Actions
import MlemMiddleware
import SwiftUI

struct ActionSheetSection {
    let actions: [any Actions.Action]
}

struct ActionSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.self) var environment
    @Environment(NavigationLayer.self) var navigation

    let sections: [ActionSheetSection]

    @State var popupAnchorModel: PopupAnchorModel = .init()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                content
                    .padding(16)
                Button("Customize", icon: .general.edit) {
                    navigation.replace(.settings(.contextMenu(.inboxNotification)))
                }
                .font(.footnote)
                .padding(.horizontal, 32)
                .padding(.top, -5)
            }
        }
        .presentationBackground(.themedGroupedBackground)
        .presentationDragIndicator(.hidden)
        .presentationBackgroundInteraction(.enabled)
    }

    var content: some View {
        ForEach(Array(sections.enumerated()), id: \.offset) { _, section in
            let frames = frames(for: section.actions)
            if !frames.isEmpty {
                VStack(spacing: 0) {
                    ForEach(Array(frames.enumerated()), id: \.offset) { index, frame in
                        actionRow(frame, showDivider: ![frames.startIndex, frames.endIndex].contains(index))
                            .compositingGroup()
                    }
                }
                .background(.themedSecondaryGroupedBackground, in: .rect(cornerRadius: 25))
            }
        }
        .labelStyle(ActionSheetLabelStyle())
        .buttonStyle(ActionSheetButtonStyle())
        .onChange(of: popupAnchorModel.outcome) { outcome in
            if outcome == .confirmed, !navigation.rootChangePending { dismiss() }
        }
    }

    private func frames(for actions: [any Actions.Action]) -> [ActionFrame] {
        actions.compactMap {
            let label = $0.createLabel(environment: environment)
            if label.visibility == .hidden { return nil }
            return .init(action: $0, label: label)
        }
    }

    @ViewBuilder
    private func actionRow(_ frame: ActionFrame, showDivider: Bool) -> some View {
        if showDivider {
            Divider()
                .padding(.horizontal, 15)
        }
        ActionSheetButton(action: frame.action, label: frame.label)
            .popupAnchor(model: popupAnchorModel)
    }
}

private struct ActionSheetButton: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.self) var environment
    @Environment(NavigationLayer.self) var navigation
    @Environment(PopupAnchorModel.self) var popupAnchorModel

    let action: any Actions.Action

    // Lable passed separately for performance reasons
    let label: ActionLabel

    var body: some View {
        Button(label) {
            action.execute(environment: environment)
            if !navigation.rootChangePending, popupAnchorModel.data == nil {
                dismiss()
            }
        }
        .disabled(label.visibility == .disabled)
    }
}

private struct ActionFrame {
    let action: any Actions.Action
    let label: ActionLabel
}

private struct ActionSheetButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(configuration.role == .destructive ? .themedWarning : .themedPrimary)
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
