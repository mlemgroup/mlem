//
//  SignUpUsernameView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-05-24.
//

import MlemMiddleware
import SwiftUI

struct SignUpUsernameView: View {
    enum ValidityWarningDisplayCondition { case immediate, onSubmit, never }
    
    let instance: Instance3
    
    @State var username: String = ""
    @State var submissionAttempted: Bool = false
    @FocusState var focused: Bool
    
    @State var usernameValidityTask: Task<Void, Never>?
    @State var usernameValidity: UsernameValidity?
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Choose a Username")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 50)
                Text("This cannot be changed later.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                VStack(spacing: 16) {
                    textFieldView
                    nextButtonView
                }
                validityWarningView
            }
            .padding(.horizontal, 16)
        }
        .frame(maxHeight: .infinity)
        .background(.themedGroupedBackground)
    }
    
    @ViewBuilder
    var textFieldView: some View {
        HStack(spacing: 0) {
            Text(verbatim: "@")
                .foregroundStyle(.secondary)
            TextField("Username", text: $username, prompt: Text(verbatim: ""))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .focused($focused)
                .onAppear {
                    focused = true
                }
        }
        .padding()
        .background(.themedSecondaryGroupedBackground, in: .rect(cornerRadius: 16))
        .task(id: username) {
            usernameValidityTask?.cancel()
            usernameValidityTask = Task {
                submissionAttempted = false
                do {
                    usernameValidity = try await instance.usernameIsValidForNewAccount(username)
                } catch {
                    handleError(error)
                }
            }
            _ = await usernameValidityTask?.value
        }
    }
    
    @ViewBuilder
    var nextButtonView: some View {
        Button(action: submit) {
            Text("Next")
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.roundedRectangle(radius: 16))
        // IMO it's less jarring to only disable the button once they try to tap on it - otherwise the user would see the button flicker as they type out their username
        .disabled(submissionAttempted && usernameValidity != .available)
    }

    @ViewBuilder
    var validityWarningView: some View {
        Text(validityWarningText)
            .font(.footnote)
            .foregroundStyle(submissionAttempted ? .red : .secondary)
            .lineLimit(3, reservesSpace: true)
    }
    
    var validityWarningText: String {
        guard let usernameValidity else { return "" }
        
        let shouldDisplay: Bool
        switch validityWarningDisplayCondition() {
        case .immediate:
            shouldDisplay = true
        case .onSubmit:
            shouldDisplay = submissionAttempted
        case .never:
            shouldDisplay = false
        }
        
        if shouldDisplay {
            return String(localized: usernameValidity.label)
        } else {
            return ""
        }
    }
    
    func validityWarningDisplayCondition() -> ValidityWarningDisplayCondition {
        switch usernameValidity {
        case .available: .never
        case .taken: .immediate
        case .invalid(.tooShort): .onSubmit
        case .invalid(.tooLong): .immediate
        case .invalid(.containsInvalidCharacters): .immediate
        case .invalid(.other): .immediate
        case nil: .never
        }
    }
    
    func submit() {
        Task {
            // Await the task to ensure we have the most up-to-date result
            _ = await usernameValidityTask?.value
            submissionAttempted = true
            guard usernameValidity == .available else { return }
        }
    }
}
