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
    @Environment(\.self) var environment

    let actions: [any Actions.Action]

    @State var popupAnchorModel: PopupAnchorModel = .init()

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                content
                    .padding(16)
            }
        }
        .presentationBackground(.themedGroupedBackground)
        .presentationDragIndicator(.hidden)
        .presentationBackgroundInteraction(.enabled)
    }

    var content: some View {
        VStack(spacing: 0) {
            ForEach(Array(actions.enumerated()), id: \.offset, content: actionRow) 
        }
        .background(.themedSecondaryGroupedBackground, in: .rect(cornerRadius: 25))
        .labelStyle(ActionSheetLabelStyle())
        .buttonStyle(ActionSheetButtonStyle())
    }

    @ViewBuilder
    func actionRow(_ index: Int, _ action: any Actions.Action) -> some View {
        let label = action.createLabel(environment: environment)
        if label.visibility != .hidden {
            if ![actions.startIndex, actions.endIndex-1].contains(index) {
                Divider()
                    .padding(.horizontal, 15)
                ActionSheetButton(action: action, label: label)
                    .popupAnchor(model: popupAnchorModel)
            }
        }
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
