//
//  AccountEmailSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 13/10/2024.
//

import SwiftUI

struct AccountEmailSettingsView: View {
    @Environment(Palette.self) var palette
    
    @State var email: String = ""
    @FocusState var isFocused
    @State var isUpdating: Bool = false
    
    init() {
        guard let session = AppState.main.firstSession as? UserSession else {
            assertionFailure()
            return
        }
        guard let person = session.person else { return }
        _email = .init(wrappedValue: person.email ?? "")
    }
    
    var body: some View {
        Form {
            Section {
                TextField("Email", text: $email)
                    .focused($isFocused)
                    .onAppear {
                        isFocused = true
                    }
            }
            Section {
                Button {
                    Task { @MainActor in
                        isUpdating = true
                        guard let person = (AppState.main.firstSession as? UserSession)?.person else { return }
                        do {
                            try await person.updateSettings(email: email)
                        } catch {
                            handleError(error)
                            email = person.email ?? ""
                        }
                        isUpdating = false
                    }
                } label: {
                    HStack {
                        Text("Save")
                        if isUpdating {
                            ProgressView()
                        }
                    }
                    .foregroundStyle(palette.selectedInteractionBarItem)
                    .tint(palette.selectedInteractionBarItem)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(palette.accent)
                    .contentShape(.rect)
                }
                .listRowInsets(.init())
            }
        }
        .disabled(isUpdating)
    }
}
