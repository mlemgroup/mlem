//
//  ReportEditorView.swift
//  Mlem
//
//  Created by Sjmarf on 11/08/2024.
//

import ComponentViews
import Haptics
import MlemMiddleware
import SwiftUI

struct ReportEditorView: View {
    @Environment(AppState.self) var appState
    @Environment(HapticManager.self) var hapticManager
    @Environment(\.dismiss) var dismiss
    
    let target: any ReportableProviding
    
    @State var community: (any ValueProviding<(Community)>)?
    @State var reason: String = ""
    @FocusState var reasonFocused: Bool
    @State var presentationSelection: PresentationDetent = .large
    
    init(target: any ReportableProviding, community: Community?) {
        self.target = target
        
        if let community {
            self._community = .init(wrappedValue: RealizedValue(community))
        } else if let community = (target as? any InteractableProviding)?.community {
            self._community = .init(wrappedValue: community)
        } else {
            self._community = .init(wrappedValue: nil)
        }
    }

    var body: some View {
        CollapsibleSheetView(presentationSelection: $presentationSelection, canDismiss: reason.isEmpty) {
            NavigationStack {
                Form {
                    TextField("Reason", text: $reason, axis: .vertical)
                        .focused($reasonFocused)
                    Section {
                        ReasonShortcutView(reason: $reason)
                    }
                    // ExpectedView causes rendering issues here
                    if let community = community?.value {
                        RulesListView(model: community, reason: $reason)
                    }
                    if let instance = appState.firstSession.instance {
                        RulesListView(model: instance, reason: $reason)
                    }
                }
                .scrollDismissesKeyboard(.interactively)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        CloseButtonView(ios18Label: .cancel)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Send", icon: .lemmy.send) {
                            Task {
                                await send()
                            }
                        }
                        .glassProminentButtonStyle()
                        .disabled(reason.isEmpty)
                    }
                }
            }
            .onAppear { reasonFocused = true }
        }
    }
    
    func send() async {
        do {
            try await target.report(reason: reason)
            hapticManager.play(haptic: .success, tier: .low)
            dismiss()
        } catch {
            handleError(error)
        }
    }
}
