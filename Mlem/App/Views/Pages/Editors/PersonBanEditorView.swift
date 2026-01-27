//
//  PersonBanEditorView.swift
//  Mlem
//
//  Created by Sjmarf on 2024-11-11.
//

import ComponentViews
import Haptics
import LemmyMarkdownUI
import MlemMiddleware
import SwiftUI

struct PersonBanEditorView: View {
    enum FocusedField: Hashable {
        case reason, days
    }
    
    @Environment(AppState.self) var appState
    @Environment(HapticManager.self) var hapticManager
    @Environment(NavigationLayer.self) var navigation
    @Environment(\.dismiss) var dismiss
    
    let person: any DeprecatedPerson
    let community: (any Community)?
    var isBannedFromCommunity: Bool
    var shouldBan: Bool = true
    
    @State var targetInstance: Bool
    @State var isPermanent: Bool = true
    @State var expiryDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now
    @State var reason: String = ""
    @State var removeContent: Bool = false
    
    @FocusState var focusedField: FocusedField?
    @State var presentationSelection: PresentationDetent = .large
    
    var selectedTarget: (any Profile2Providing)? {
        if targetInstance {
            appState.firstSession.instance
        } else {
            community
        }
    }
    
    init(
        person: any DeprecatedPerson,
        community: (any Community)?,
        isBannedFromCommunity: Bool,
        shouldBan: Bool
    ) {
        self.person = person
        self.community = community
        self.isBannedFromCommunity = isBannedFromCommunity
        self.shouldBan = shouldBan
        
        let isCommunityModerator: Bool
        if let community {
            isCommunityModerator = (AppState.main.firstSession as? UserSession)?.person?.moderates(community: community) ?? false
        } else {
            isCommunityModerator = false
        }
        self._targetInstance = .init(
            wrappedValue: !(isCommunityModerator || person.bannedFromInstance == shouldBan) || isBannedFromCommunity == shouldBan
        )
    }
    
    var days: Int {
        get {
            Calendar.current.dateComponents(
                [.day],
                from: .now,
                // This prevents the number of days ticking down if you leave the sheet open for more than a minute
                to: expiryDate.addingTimeInterval(60 * 60)
            ).day ?? 0
        }
        nonmutating set {
            expiryDate = Calendar.current.date(byAdding: .day, value: newValue, to: .now) ?? .now
        }
    }
    
    var body: some View {
        CollapsibleSheetView(presentationSelection: $presentationSelection, canDismiss: reason.isEmpty) {
            NavigationStack {
                Form {
                    scopeSection
                    if appState.firstApi.supports(.unbanWithReason, defaultValue: true) || shouldBan {
                        reasonSection
                    }
                    if shouldBan {
                        durationSection
                        removeContentSection
                    }
                }
                .navigationTitle(shouldBan ? "Ban \(person.name)" : "Unban \(person.name)")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        CloseButtonView(ios18Label: .cancel)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Send", icon: .lemmy.send) {
                            Task { await send() }
                        }
                        .glassProminentButtonStyle()
                    }
                }
            }
        }
    }
    
    var scopeSectionTitle: LocalizedStringResource {
        if community != nil, appState.firstApi.isAdmin {
            shouldBan ? "Ban from..." : "Unban from..."
        } else {
            shouldBan ? "Banning from..." : "Unbanning from..."
        }
    }
    
    @ViewBuilder
    var scopeSection: some View {
        Section {
            if let instance = appState.firstSession.instance {
                if let community, appState.firstApi.isAdmin, isBannedFromCommunity == person.bannedFromInstance {
                    Menu {
                        Picker("Ban Target", selection: $targetInstance) {
                            Label(instance).tag(true)
                            Label(community).tag(false)
                        }
                    } label: {
                        HStack {
                            targetLabel
                            Spacer()
                            Image(icon: .general.dropDown)
                                .fontWeight(.semibold)
                                .foregroundStyle(.themedSecondary)
                        }
                    }
                    .buttonStyle(.empty)
                } else {
                    targetLabel
                }
            }
        } header: {
            Text(scopeSectionTitle)
                .textCase(nil)
        }
    }
    
    @ViewBuilder
    var targetLabel: some View {
        if let selectedTarget {
            HStack {
                CircleCroppedImageView(selectedTarget, frame: 24)
                Text(selectedTarget.name)
            }
        }
    }
    
    @ViewBuilder
    var reasonSection: some View {
        if let selectedTarget {
            Group {
                Section {
                    TextField("Reason", text: $reason, axis: .vertical)
                        .focused($focusedField, equals: .reason)
                }
                Section {
                    ReasonShortcutView(reason: $reason, rulesTarget: selectedTarget)
                }
                .listSectionSpacing(10)
            }
        }
    }
    
    @ViewBuilder
    var durationSection: some View {
        Section {
            Toggle("Permanent", isOn: $isPermanent)
                .tint(.themedWarning)
        }
        .listSectionSpacing(60)
        Section("Ban Duration") {
            HStack {
                Text("Days:")
                    .onTapGesture {
                        focusedField = .days
                    }
                TextField(String(""), value: Binding(
                    get: { days },
                    set: { days = $0 }
                ), format: .number)
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: .days)
            }
            DatePicker(
                "Expires:",
                selection: $expiryDate,
                in: Date.now...,
                displayedComponents: [.date, .hourAndMinute]
            )
            HStack {
                daysPresetButton(.init(day: 1), value: 1)
                daysPresetButton(.init(day: 3), value: 3)
                daysPresetButton(.init(day: 7), value: 7)
                daysPresetButton(.init(day: 30), value: 30)
                daysPresetButton(.init(day: 60), value: 60)
                daysPresetButton(.init(day: 90), value: 90)
                daysPresetButton(.init(year: 1), value: 365)
            }
            .padding(.horizontal, -8)
        }
        .opacity(isPermanent ? 0.5 : 1)
        .disabled(isPermanent)
    }
    
    @ViewBuilder
    func daysPresetButton(_ date: DateComponents, value: Int) -> some View {
        Button(dateFormatter.string(for: date) ?? "") {
            days = value
            hapticManager.play(haptic: .gentleInfo, tier: .low)
        }
        .buttonStyle(BanFormButtonStyle(selected: days == value && !isPermanent))
    }
    
    @ViewBuilder
    var removeContentSection: some View {
        Section {
            Toggle("Remove Content", isOn: $removeContent)
                .tint(.themedWarning)
        }
    }
}

private struct BanFormButtonStyle: ButtonStyle {
    let selected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.callout)
            .foregroundStyle(selected ? .themedContrastingLabel : .themedPrimary)
            .padding(.vertical, 4)
            .frame(maxWidth: 150)
            .background(selected ? .themedAccent : .themedGroupedBackground, in: .rect(cornerRadius: 6))
    }
}
