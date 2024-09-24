//
//  ReportComposerView.swift
//  Mlem
//
//  Created by Sjmarf on 11/08/2024.
//

import LemmyMarkdownUI
import MlemMiddleware
import SwiftUI

struct ReportComposerView: View {
    @Environment(AppState.self) var appState
    @Environment(Palette.self) var palette
    @Environment(\.dismiss) var dismiss
    
    let target: any ReportableProviding
    
    @State var reason: String = ""
    @FocusState var reasonFocused: Bool
    @State var community: (any Community)?
    @State var presentationSelection: PresentationDetent = .large
    
    init(target: any ReportableProviding, community: AnyCommunity?) {
        self.target = target
        
        if let community {
            self._community = .init(wrappedValue: community.wrappedValue as? any Community)
        } else if let community = (target as? any Interactable2Providing)?.community {
            self._community = .init(wrappedValue: community)
        } else {
            self._community = .init(wrappedValue: nil)
        }
    }

    var body: some View {
        CollapsibleSheetView(presentationSelection: $presentationSelection, canDismiss: reason.isEmpty) {
            NavigationStack {
                Form {
                    TextField("Reason (Optional)", text: $reason, axis: .vertical)
                        .focused($reasonFocused)
                    suggestions
                    if let community {
                        ruleList(community)
                    }
                    if let instance = appState.firstSession.instance {
                        ruleList(instance)
                    }
                }
                .scrollDismissesKeyboard(.interactively)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") { dismiss() }
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
            .onAppear { reasonFocused = true }
        }
    }
    
    @ViewBuilder
    var suggestions: some View {
        Section {
            HStack(spacing: 12) {
                ForEach([
                    LocalizedStringResource("Spam"),
                    LocalizedStringResource("Troll"),
                    LocalizedStringResource("Abuse")
                ], id: \.key) { item in
                    Text(item)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(palette.secondaryGroupedBackground, in: .rect(cornerRadius: 10))
                        .contentShape(.rect)
                        .onTapGesture {
                            var item = item
                            // TODO: Set this to instance/community language?
                            item.locale = .init(languageCode: .english)
                            reason = String(localized: item)
                        }
                }
            }
            .listRowBackground(Color.clear)
            .listRowInsets(.init())
        }
    }
    
    @ViewBuilder
    func ruleList(_ profilable: any Profile2Providing) -> some View {
        let rules = [BlockNode](profilable.description ?? "").rules()
        if rules.count >= 1 {
            Section {
                ForEach(Array(rules.enumerated()), id: \.offset) { index, blocks in
                    HStack(spacing: 12) {
                        Image(systemName: "\(index + 1).circle.fill")
                            .foregroundStyle(palette.secondary)
                            .fontWeight(.semibold)
                        Markdown(blocks, configuration: .default)
                            .frame(maxWidth: .infinity)
                    }
                    .contentShape(.rect)
                    .onTapGesture {
                        switch blocks.first {
                        case let .paragraph(inlines: inlines), .heading(level: _, inlines: let inlines):
                            let text = inlines.stringLiteral
                            if text.count < 100 {
                                reason = "\(profilable.name) rule #\(index + 1): \"\(text)\""
                                return
                            }
                        default:
                            break
                        }
                        reason = "\(profilable.name) rule #\(index + 1)"
                    }
                }
            } header: {
                HStack {
                    CircleCroppedImageView(profilable, frame: 22)
                    Text("\(profilable.name) rules:")
                        .foregroundStyle(palette.secondary)
                        .textCase(nil)
                }
            }
        }
    }
    
    func send() async {
        do {
            try await target.report(reason: reason)
            HapticManager.main.play(haptic: .success, priority: .low)
            dismiss()
        } catch {
            handleError(error)
        }
    }
}
