//
//  BanUserView.swift
//  Mlem
//
//  Created by Sjmarf on 26/01/2024.
//

import Dependencies
import SwiftUI

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
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.notifier) var notifier
    
    @Environment(\.dismiss) var dismiss
    
    let user: UserModel
    let community: CommunityModel? // if nil, instance ban; otherwise community ban
    let shouldBan: Bool
    
    @State var reason: String = ""
    @State var days: Int = 1
    @State var isPermanent: Bool = true
    @State var removeContent: Bool = false
    @State var isWaiting: Bool = false
    
    enum FocusedField {
        case reason, days
    }
    
    @FocusState var focusedField: FocusedField?
    
    var expires: Int? {
        isPermanent ? nil : Date.getEpochDate(daysFromNow: days)
    }
    
    var verb: String { shouldBan ? "ban" : "unban" }
    
    var body: some View {
        form
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
                    .disabled(isWaiting)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if isWaiting {
                        ProgressView()
                    } else {
                        Button("Confirm", systemImage: Icons.send, action: confirm)
                    }
                }
            }
            .navigationTitle("\(verb.capitalized) \(user.displayName)")
            .navigationBarTitleDisplayMode(.inline)
            .allowsHitTesting(!isWaiting)
            .opacity(isWaiting ? 0.5 : 1)
            .interactiveDismissDisabled(isWaiting)
    }
    
    var form: some View {
        Form {
            if let community {
                communitySection(for: community)
            }
            
            reasonSection
            
            if shouldBan {
                durationSections()
                
                removeContentSection()
            }
        }
    }
    
    // MARK: Form Sections
    
    @ViewBuilder
    func communitySection(for community: CommunityModel) -> some View {
        Section("\(verb.capitalized)ning From") {
            CommunityLabelView(community: community, serverInstanceLocation: .bottom)
        }
    }
    
    @ViewBuilder
    var reasonSection: some View {
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
            if shouldBan {
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
    func durationSections() -> some View {
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
                TextField("", value: Binding(
                    get: { days },
                    set: { newValue in
                        days = newValue > 1 ? newValue : 0
                    }
                ), format: .number)
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: .days)
            }
            DatePicker(
                "Expiration Date:",
                selection: Binding(
                    get: {
                        .now.advanced(by: .days(Double(days)))
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
    }
    
    @ViewBuilder
    func removeContentSection() -> some View {
        Section {
            Toggle("Remove Content", isOn: $removeContent)
                .tint(.red)
        } footer: {
            if community == nil {
                let posts = user.postCount ?? 0
                let comments = user.commentCount ?? 0
                Text("Remove all \(posts) posts and \(comments) comments created by this user.")
            }
        }
    }
    
    // MARK: Components
    
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
    
    // MARK: Logic
    
    private func confirm() {
        if let community {
            communityBan(from: community)
        } else {
            instanceBan()
        }
    }
    
    private func instanceBan() {
        isWaiting = true
        Task {
            let reason = reason.isEmpty ? nil : reason
            var user = user
            await user.toggleBan(
                expires: expires,
                reason: reason,
                removeData: removeContent
            )
            DispatchQueue.main.async {
                isWaiting = false
            }
            
            await handleResult(user.banned)
        }
    }
    
    private func communityBan(from community: CommunityModel) {
        isWaiting = true
        Task {
            let updatedBannedStatus = await community.banUser(
                userId: user.userId,
                ban: shouldBan,
                removeData: removeContent,
                reason: reason.isEmpty ? nil : reason,
                expires: expires
            )
            DispatchQueue.main.async {
                isWaiting = false
            }
            
            await handleResult(updatedBannedStatus)
        }
    }
    
    private func handleResult(_ result: Bool) async {
        if result == shouldBan {
            await notifier.add(.success("\(verb.capitalized)"))
            DispatchQueue.main.async {
                dismiss()
            }
        } else {
            await notifier.add(.failure("Failed to \(verb) user"))
        }
    }
}

#Preview {
    BanUserView(user: .mock(), community: .mock(), shouldBan: true)
}
