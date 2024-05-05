//
//  ReasonView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27.
//

import Dependencies
import SwiftUI

enum FocusedField {
    case reason, days
}

struct ReasonView: View {
    @Dependency(\.hapticManager) var hapticManager
    
    @Binding var reason: String
    var focusedField: FocusState<FocusedField?>.Binding
    let showReason: Bool
    
    var body: some View {
        Section("Reason") {
            TextField("Optional", text: $reason, axis: .vertical)
                .lineLimit(8)
                .focused(focusedField, equals: .reason)
                .overlay(alignment: .trailing) {
                    if reason.isNotEmpty, focusedField.wrappedValue != .reason {
                        Button("Clear", systemImage: "xmark.circle.fill") { reason = "" }
                            .foregroundStyle(.secondary.opacity(0.8))
                            .labelStyle(.iconOnly)
                    }
                }
            if showReason {
                HStack {
                    if reason == "Rule #" {
                        ForEach(1 ..< 9) { value in
                            Button(String(value)) {
                                reason = "Rule \(value)"
                                hapticManager.play(haptic: .gentleInfo, priority: .low)
                            }
                            .buttonStyle(BanFormButton(selected: false))
                        }
                    } else {
                        Button("Rule #") {
                            reason = "Rule #"
                            hapticManager.play(haptic: .gentleInfo, priority: .low)
                        }
                        .buttonStyle(BanFormButton(selected: reason.hasPrefix("Rule")))
                        reasonPresetButton("Spam")
                        reasonPresetButton("Troll")
                        reasonPresetButton("Abuse")
                    }
                }
                .padding(.horizontal, -8)
            }
        }
    }
    
    @ViewBuilder
    func reasonPresetButton(_ label: String) -> some View {
        Button(label) {
            reason = reason == label ? "" : label
            hapticManager.play(haptic: .gentleInfo, priority: .low)
        }
        .buttonStyle(BanFormButton(selected: reason == label))
    }
}
