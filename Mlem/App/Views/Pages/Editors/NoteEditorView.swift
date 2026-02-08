//
//  NoteEditorView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-12-14.
//

import ComponentViews
import Haptics
import MlemMiddleware
import SwiftUI

struct NoteEditorView: View {
    @Environment(HapticManager.self) var hapticManager
    @Environment(\.dismiss) var dismiss
    
    let person: Person
    
    @State var note: String
    @FocusState var textFieldFocused: Bool
    @State var presentationSelection: PresentationDetent = .large

    init(person: Person) {
        self.person = person
        self.note = person.note ?? ""
    }

    var body: some View {
        CollapsibleSheetView(presentationSelection: $presentationSelection, canDismiss: note.isEmpty) {
            NavigationStack {
                Form {
                    TextField("Note", text: $note, axis: .vertical)
                        .focused($textFieldFocused)
                }
                .scrollDismissesKeyboard(.interactively)
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Edit Note")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        CloseButtonView(ios18Label: .cancel)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Save", icon: .general.success) {
                            Task { await send() }
                        }
                        .glassProminentButtonStyle()
                    }
                }
            }
            .onAppear { textFieldFocused = true }
        }
    }
    
    func send() async {
        person.updateNote(content: note.isEmpty ? nil : note)
        hapticManager.play(haptic: .success, tier: .low)
        dismiss()
    }
}
