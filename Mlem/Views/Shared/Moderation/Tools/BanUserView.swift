//
//  BanUserView.swift
//  Mlem
//
//  Created by Sjmarf on 26/01/2024.
//

import Dependencies
import SwiftUI

struct BanUserView: View {
    @Dependency(\.siteInformation) var siteInformation
    @Dependency(\.hapticManager) var hapticManager
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.notifier) var notifier
    
    @Environment(\.dismiss) var dismiss
    
    enum ContentRemovalType: CaseIterable {
        case keep, remove, purge
        
        var label: String {
            switch self {
            case .keep:
                "Keep"
            case .remove:
                "Remove"
            case .purge:
                "Purge"
            }
        }
        
        var systemImage: String {
            switch self {
            case .keep:
                "checkmark.square"
            case .remove:
                Icons.remove
            case .purge:
                Icons.purge
            }
        }
        
        var description: String {
            switch self {
            case .keep:
                "Keep all posts and comments made by this user."
            case .remove:
                "Remove all posts and comments created by this user. They can be restored later."
            case .purge:
                // swiftlint:disable:next line_length
                "Permanently remove all of this user's posts, comments, attachments and account data from the database. This cannot be undone."
            }
        }
    }
    
    let user: UserModel
    let community: CommunityModel? // if nil, instance ban; otherwise community ban
    let shouldBan: Bool
    let postTracker: StandardPostTracker? // if present, will update with new banned status
    
    @State var reason: String = ""
    @State var days: Int = 1
    @State var isPermanent: Bool = true
    @State var contentRemovalType: ContentRemovalType = .keep
    @State var isWaiting: Bool = false
    
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
            
            ReasonView(reason: $reason, focusedField: $focusedField, showReason: shouldBan)
            
            if shouldBan {
                durationSections()
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
    func durationSections() -> some View {
        Section {
            Toggle(
                "Permanent",
                isOn: Binding(
                    get: { isPermanent },
                    set: { newValue in
                        isPermanent = newValue
                        if !newValue && contentRemovalType == .purge {
                            contentRemovalType = .remove
                        }
                    }
                )
            )
            .tint(.red)
        }
        if siteInformation.isAdmin && isPermanent {
            removeContentPickerSection()
        } else {
            banDurationSection()
            removeContentSection()
        }
    }
    
    @ViewBuilder
    func banDurationSection() -> some View {
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
            Toggle(
                "Remove Content",
                isOn: Binding(
                    get: { contentRemovalType != .keep },
                    set: { contentRemovalType = $0 ? .remove : .keep}
                )
            )
            .tint(.red)
        } footer: {
            if community == nil {
                let posts = user.postCount ?? 0
                let comments = user.commentCount ?? 0
                Text("Remove all \(posts) posts and \(comments) comments created by this user. They can be restored later if needed.")
            }
        }
    }
    
    @ViewBuilder
    func removeContentPickerSection() -> some View {
        Section {
            ForEach(ContentRemovalType.allCases, id: \.self) { type in
                Button { contentRemovalType = type } label: {
                    HStack {
                        Label {
                            Text(type.label)
                        } icon: {
                            Image(systemName: type.systemImage)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Checkbox(isOn: contentRemovalType == type)
                            .tint(type == .purge ? .red : .blue)
                        
                    }
                    .foregroundStyle(.primary)
                    .contentShape(Rectangle())
                }
                .buttonStyle(EmptyButtonStyle())
            }
            .tint(.red)
            .pickerStyle(.inline)
        } header: {
            Text("User Content")
        } footer: {
            Text(contentRemovalType.description)
                .foregroundStyle(contentRemovalType == .purge ? .red : .secondary)
        }
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
    BanUserView(user: .mock(), community: .mock(), shouldBan: true, postTracker: nil)
}
