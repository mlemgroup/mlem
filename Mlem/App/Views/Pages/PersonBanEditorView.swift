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
    
    let person: any Person
    let community: (any Community)?
    
    @State var banFromInstance: Bool
    @State var isPermanent: Bool = true
    @State var days: Int = 1
    @State var reason: String = ""
    
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
    
    var body: some View {
        CollapsibleSheetView(presentationSelection: $presentationSelection, canDismiss: reason.isEmpty) {
            NavigationStack {
                Form {
                    scopeSection
                    reasonSection
                    Section {
                        Toggle("Permanent", isOn: $isPermanent)
                            .tint(.red)
                    }
                    durationSection
                }
                .navigationTitle("Ban \(person.name)")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
    
    @ViewBuilder
    var scopeSection: some View {
        Section {
            if let selectedTarget, let community, let instance = appState.firstSession.instance {
                Menu {
                    Picker("Ban Target", selection: $banFromInstance) {
                        Label(instance).tag(true)
                        Label(community).tag(false)
                    }
                } label: {
                    HStack {
                        CircleCroppedImageView(selectedTarget, frame: 24)
                            .id(selectedTarget.actorId)
                        Text(selectedTarget.name)
                        Spacer()
                        Image(systemName: Icons.dropDown)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.empty)
            }
        } header: {
            Text("Ban from...")
                .textCase(nil)
        }
    }
    
    @ViewBuilder
    var reasonSection: some View {
        if let selectedTarget {
            Section {
                TextField("Reason (Optional)", text: $reason, axis: .vertical)
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
                        .now.advanced(by: Double(60 * 60 * 24 * days))
                    },
                    set: { newValue in
                        days = Int(round(newValue.timeIntervalSince(.now) / (60 * 60 * 24)))
                    }
                ),
                in: Date.now.advanced(by: Double(60 * 60 * 24))...,
                displayedComponents: [.date]
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
}

struct BanFormButtonStyle: ButtonStyle {
    let selected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.callout)
            .foregroundStyle(selected ? .white : .primary)
            .padding(.vertical, 4)
            .frame(maxWidth: 150)
            .background(selected ? .blue : Color(uiColor: .systemGroupedBackground), in: .rect(cornerRadius: 6))
    }
}
