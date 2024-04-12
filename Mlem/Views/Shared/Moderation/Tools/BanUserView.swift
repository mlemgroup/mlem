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
    
    @EnvironmentObject var unreadTracker: UnreadTracker
    
    @Environment(\.dismiss) var dismiss
    
    let user: UserModel
    let communityContext: CommunityModel?
    let bannedFromCommunity: Bool
    let shouldBan: Bool
    let userRemovalWalker: UserRemovalWalker
    let callback: (() -> Void)?
    
    @State var banFromInstance: Bool
    
    @State var reason: String = ""
    @State var days: Int = 1
    @State var isPermanent: Bool = true
    @State var removeContent: Bool = false
    @State var isWaiting: Bool = false
    
    @FocusState var focusedField: FocusedField?
    
    init(
        user: UserModel,
        communityContext: CommunityModel?,
        bannedFromCommunity: Bool = false,
        shouldBan: Bool,
        userRemovalWalker: UserRemovalWalker,
        callback: (() -> Void)? = nil
    ) {
        self.user = user
        self.communityContext = communityContext
        self.bannedFromCommunity = bannedFromCommunity
        self.shouldBan = shouldBan
        self.userRemovalWalker = userRemovalWalker
        self.callback = callback
        
        @Dependency(\.siteInformation) var siteInformation
        
        // by default, ban from instance if admin and user isn't already instance banned. If admin but also moderates the community, default to community ban
        var instanceBan: Bool = siteInformation.isAdmin && shouldBan != user.banned
        if siteInformation.isAdmin,
           let communityId = communityContext?.communityId,
           siteInformation.moderatedCommunities.contains(communityId) {
            instanceBan = false
        }
        
        _banFromInstance = .init(
            wrappedValue: instanceBan
        )
    }
    
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
            scopeSection()
            
            ReasonView(reason: $reason, focusedField: $focusedField, showReason: shouldBan)
            
            if shouldBan {
                durationSections()
            }
        }
    }
    
    // MARK: Form Sections
    
    @ViewBuilder
    func scopeSection() -> some View {
        if !siteInformation.isAdmin || (bannedFromCommunity != user.banned && !banFromInstance) {
            if let communityContext {
                Section("\(verb.capitalized)ning From") {
                    CommunityLabelView(community: communityContext, serverInstanceLocation: .bottom)
                        .padding(.vertical, 1)
                }
            }
        } else if let instance = siteInformation.instance {
            if let communityContext, bannedFromCommunity == user.banned {
                Section("\(verb.capitalized) From") {
                    Menu {
                        Picker("Test", selection: $banFromInstance) {
                            Button {} label: {
                                Text("Instance")
                                if let name = siteInformation.instance?.name {
                                    Text(name)
                                }
                            }.tag(true)
                            Button {} label: {
                                Text("Community")
                                if let name = communityContext.fullyQualifiedName {
                                    Text(name)
                                }
                            }.tag(false)
                        }.pickerStyle(.inline)
                    } label: {
                        HStack {
                            if banFromInstance {
                                InstanceLabelView(instance: instance)
                            } else {
                                CommunityLabelView(community: communityContext, serverInstanceLocation: .bottom)
                            }
                            Spacer()
                            Image(systemName: "chevron.down")
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .padding(.vertical, 1)
                }
            } else {
                Section("\(verb.capitalized)ning From") {
                    InstanceLabelView(instance: instance)
                        .padding(.vertical, 1)
                }
            }
        }
    }
    
    @ViewBuilder
    func durationSections() -> some View {
        Section {
            Toggle("Permanent", isOn: $isPermanent)
                .tint(.red)
        }
        banDurationSection()
        removeContentSection()
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
                        days = Int(round(newValue.timeIntervalSince(.now) / (60 * 60 * 24)))
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
            if communityContext == nil {
                let posts = user.postCount ?? 0
                let comments = user.commentCount ?? 0
                Text("Remove all \(posts) posts and \(comments) comments created by this user. They can be restored later if needed.")
            }
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
    BanUserView(
        user: .mock(),
        communityContext: .mock(),
        shouldBan: true,
        userRemovalWalker: .init()
    )
}
