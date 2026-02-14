//
//  AccountEmailSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 13/10/2024.
//

import SwiftUI

import MlemMiddleware

struct AccountEmailSettingsView: View {
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss
    
    @State var email: String = ""
    @State var isSubmitting: Bool = false
    @FocusState var isFocused
    
    init() {
        guard let person = AppState.main.firstPerson else { return }
        _email = .init(wrappedValue: person.email.value as? String ?? "")
    }
    
    var showToolbarOptions: Bool {
        email != appState.firstPerson?.email.value
    }
    
    var body: some View {
        Form {
            TextField("Email", text: $email)
                .focused($isFocused)
                .onAppear {
                    isFocused = true
                }
        }
        .navigationBarBackButtonHidden(showToolbarOptions)
        .disabled(isSubmitting)
        .toolbar {
            if showToolbarOptions {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        email = appState.firstPerson?.email as? String ?? ""
                    }
                    .disabled(isSubmitting)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if isSubmitting {
                        ProgressView()
                    } else if let updateSettings = appState.firstPerson?.updateSettings {
                        Button("Save") {
                            Task { @MainActor in
                                await submit(updateSettings: updateSettings)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @MainActor
    func submit(updateSettings: (Person.ProfileSettings) async throws -> Void) async {
        isSubmitting = true
        do {
            try await updateSettings(.init(email: email))
        } catch {
            handleError(error)
            email = appState.firstPerson?.email as? String ?? ""
        }
        isSubmitting = false
    }
}
