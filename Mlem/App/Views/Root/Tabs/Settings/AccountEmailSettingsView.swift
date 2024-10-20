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
        guard let person = AppState.main.firstPerson else { return }
        _email = .init(wrappedValue: person.email ?? "")
    }
    
    var showToolbarOptions: Bool {
        email != appState.firstPerson?.email
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
                        email = appState.firstPerson?.email ?? ""
                    }
                    .disabled(isSubmitting)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if isSubmitting {
                        ProgressView()
                    } else {
                        Button("Save") {
                            Task { @MainActor in
                                await submit()
                            }
                        }
                    }
                }
            }
        }
    }
    
    @MainActor
    func submit() async {
        isSubmitting = true
        do {
            try await appState.firstPerson?.updateSettings(email: email)
        } catch {
            handleError(error)
            email = appState.firstPerson?.email ?? ""
        }
        isSubmitting = false
    }
}
