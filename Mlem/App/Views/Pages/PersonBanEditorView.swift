//
//  PersonBanEditorView.swift
//  Mlem
//
//  Created by Sjmarf on 2024-11-11.
//

import LemmyMarkdownUI
import MlemMiddleware
import SwiftUI

struct PersonBanEditorView: View {
    enum FocusedField: Hashable {
        case reason, days
    }
    
    @Environment(AppState.self) var appState
    @Environment(NavigationLayer.self) var navigation
    @Environment(Palette.self) var palette
    @Environment(\.dismiss) var dismiss
    
    let person: any Person
    let community: (any Community)?
    var shouldBan: Bool = true
    
    @State var banFromInstance: Bool
    @State var isPermanent: Bool = true
    @State var expiryDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now
    @State var reason: String = ""
    @State var removeContent: Bool = false
    
    @FocusState var focusedField: FocusedField?
    @State var presentationSelection: PresentationDetent = .large
    
    var selectedTarget: (any Profile2Providing)? {
        if banFromInstance {
            appState.firstSession.instance
        } else {
            community
        }
    }
    
    init(person: any Person, community: (any Community)?) {
        self.person = person
        self.community = community
        self._banFromInstance = .init(wrappedValue: AppState.main.firstApi.isAdmin)
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
                    reasonSection
                    Section {
                        Toggle("Permanent", isOn: $isPermanent)
                            .tint(palette.warning)
                    }
                    durationSection
                    Section {
                        Toggle("Remove Content", isOn: $removeContent)
                            .tint(palette.warning)
                    }
                }
                .navigationTitle(shouldBan ? "Ban \(person.name)" : "Unban \(person.name)")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Send", systemImage: Icons.send) {
                            Task {
                                await send()
                            }
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    var scopeSection: some View {
        Section {
            if let selectedTarget, let instance = appState.firstSession.instance {
                if let community, appState.firstApi.isAdmin {
                    Menu {
                        Picker("Ban Target", selection: $banFromInstance) {
                            Label(instance).tag(true)
                            Label(community).tag(false)
                        }
                    } label: {
                        HStack {
                            targetLabel
                            Spacer()
                            Image(systemName: Icons.dropDown)
                                .fontWeight(.semibold)
                                .foregroundStyle(palette.secondary)
                        }
                    }
                    .buttonStyle(.empty)
                } else {
                    targetLabel
                }
            }
        } header: {
            Text(shouldBan ? "Ban from..." : "Unban from...")
                .textCase(nil)
        }
    }
    
    @ViewBuilder
    var targetLabel: some View {
        if let selectedTarget {
            HStack {
                CircleCroppedImageView(selectedTarget, frame: 24)
                    .id(selectedTarget.actorId)
                Text(selectedTarget.name)
            }
        }
    }
    
    @ViewBuilder
    var reasonSection: some View {
        if let selectedTarget {
            Section {
                TextField("Reason", text: $reason, axis: .vertical)
                    .focused($focusedField, equals: .reason)
                if ![BlockNode](selectedTarget.description ?? "").rules().isEmpty {
                    Button("\(selectedTarget.name) rules...", systemImage: "book.pages") {
                        navigation.openSheet(.rulesList(selectedTarget, callback: {
                            reason = $0
                        }))
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    var durationSection: some View {
        Section("Ban Duration") {
            HStack {
                Text("Days:")
                    .onTapGesture {
                        focusedField = .days
                    }
                TextField("", value: Binding(
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
            HapticManager.main.play(haptic: .gentleInfo, priority: .low)
        }
        .buttonStyle(BanFormButtonStyle(selected: days == value && !isPermanent))
    }
    
    var dateFormatter: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.maximumUnitCount = 1
        return formatter
    }
    
    func send() async {
        do {
            if banFromInstance {
                try await person.banFromInstance(
                    removeContent: removeContent,
                    reason: reason,
                    expires: isPermanent ? nil : expiryDate
                )
            } else if let community {
                try await person.ban(
                    from: community,
                    removeContent: removeContent,
                    reason: reason,
                    expires: isPermanent ? nil : expiryDate
                )
            }
            dismiss()
        } catch {
            handleError(error)
        }
    }
}

private struct BanFormButtonStyle: ButtonStyle {
    @Environment(Palette.self) var palette
    
    let selected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.callout)
            .foregroundStyle(selected ? palette.selectedInteractionBarItem : palette.primary)
            .padding(.vertical, 4)
            .frame(maxWidth: 150)
            .background(selected ? palette.accent : palette.groupedBackground, in: .rect(cornerRadius: 6))
    }
}
