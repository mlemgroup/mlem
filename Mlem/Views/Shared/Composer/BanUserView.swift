//
//  BanUserView.swift
//  Mlem
//
//  Created by Sjmarf on 26/01/2024.
//

import SwiftUI
import Dependencies

private struct BanFormButton: ButtonStyle {
    
    let selected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.callout)
            .foregroundStyle(selected ? .white : .primary)
            .padding(.vertical, 4)
            .frame(maxWidth: 150)
            .background {
                RoundedRectangle(cornerRadius: 6)
                    .fill(selected ? .blue : Color(uiColor: .systemGroupedBackground))
            }
    }
}

struct BanUserView: View {
    @Dependency(\.siteInformation) var siteInformation
    @Dependency(\.hapticManager) var hapticManager
    @Environment(\.dismiss) var dismiss
    
    let editModel: BanUserEditorModel
    
    @State var reason: String = ""
    @State var days: Int = 1
    @State var isPermanent: Bool = true
    @State var removeContent: Bool = false
    
    enum FocusedField {
        case reason, days
    }
    
    @FocusState var focusedField: FocusedField?
    
    var body: some View {
        Form {
            Section("Reason") {
                TextField("Optional", text: $reason, axis: .vertical)
                    .lineLimit(8)
                    .focused($focusedField, equals: .reason)
                    .overlay(alignment: .trailing) {
                        if reason.isNotEmpty, focusedField != .reason {
                            Button("Clear", systemImage: "xmark.circle.fill") { reason = "" }
                                .foregroundStyle(.secondary.opacity(0.8))
                                .labelStyle(.iconOnly)
                        }
                    }
                HStack {
                    if reason == "Rule #" {
                        ForEach(1..<9) { value in
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
            Section {
                Toggle("Permanent", isOn: $isPermanent)
                    .tint(.red)
            }
            Section("Ban Duration") {
                HStack {
                    Text("Days:")
                        .onTapGesture {
                            focusedField = .days
                        }
                    TextField("", value: $days, format: .number)
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: .days)
                }
                DatePicker(
                    "Expiration Date:",
                    selection: Binding(
                        get: {
                            return .now.advanced(by: .days(Double(days)))
                        },
                        set: { newValue in
                            days = Int(newValue.timeIntervalSince(.now) / (60 * 60 * 24))
                        }
                    ),
                    in: Date.now.advanced(by: .days(1))...,
                    displayedComponents: [.date]
                )
                HStack {
                    daysPresetButton("1d", value: 1)
                    daysPresetButton("3d", value: 3)
                    daysPresetButton("7d", value: 7)
                    daysPresetButton("30d", value: 30)
                    daysPresetButton("60d", value: 60)
                    daysPresetButton("90d", value: 90)
                    daysPresetButton("1y", value: 365)
                }
                .padding(.horizontal, -8)
            }
            .opacity(isPermanent ? 0.5 : 1)
            .disabled(isPermanent)
            
            Section {
                Toggle("Remove Content", isOn: $removeContent)
                    .tint(.red)
            } footer: {
                Text("Remove \(editModel.user.postCount ?? 0) posts and \(editModel.user.commentCount ?? 0) comments created by this user.")
            }
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                HStack {
                    Spacer()
                    Button("Done") { focusedField = nil }
                }
            }
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
                .tint(.red)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Confirm", systemImage: Icons.send) {
                    
                }
            }
        }
        .navigationTitle("Ban \(editModel.user.displayName)")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    func reasonPresetButton(_ label: String) -> some View {
        Button(label) {
            reason = reason == label ? "" : label
            hapticManager.play(haptic: .gentleInfo, priority: .low)
        }
        .buttonStyle(BanFormButton(selected: reason == label))
    }
    
    @ViewBuilder
    func daysPresetButton(_ label: String, value: Int) -> some View {
        Button(label) {
            days = value
            hapticManager.play(haptic: .gentleInfo, priority: .low)
        }
        .buttonStyle(BanFormButton(selected: days == value && !isPermanent))
    }
}

#Preview {
    BanUserView(editModel: .init(user: .mock()))
}
