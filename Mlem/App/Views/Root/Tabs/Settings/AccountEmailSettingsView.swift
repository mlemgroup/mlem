//
//  AccountEmailSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 13/10/2024.
//

import SwiftUI

struct AccountEmailSettingsView: View {
    @Environment(AppState.self) var appState
    @Environment(Palette.self) var palette
    @Environment(\.dismiss) var dismiss
    
    @State var email: String = ""
    @State var isSubmitting: Bool = false
    @FocusState var isFocused
    
    init() {
        guard let session = AppState.main.firstSession as? UserSession else {
            assertionFailure()
            return
        }
        guard let person = session.person else { return }
        _email = .init(wrappedValue: person.email ?? "")
    }
    
    var showToolbarOptions: Bool {
        email != (appState.firstSession as? UserSession)?.person?.email
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
                        if let session = AppState.main.firstSession as? UserSession {
                            email = session.person?.email ?? ""
                        }
                    }
                    .disabled(isSubmitting)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if isSubmitting {
                        ProgressView()
                    } else {
                        Button("Save") {
                            submit()
                        }
                    }
                }
            }
        }
    }
    
    func submit() {
        Task { @MainActor in
            isSubmitting = true
            guard let person = (AppState.main.firstSession as? UserSession)?.person else { return }
            do {
                try await person.updateSettings(email: email)
            } catch {
                handleError(error)
                email = person.email ?? ""
            }
            isSubmitting = false
        }
    }
}
