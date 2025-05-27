//
//  OnboardingUsernameView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-05-24.
//

import ComponentViews
import MlemMiddleware
import SwiftUI

struct OnboardingUsernameView: View {
    let instance: Instance3
    let back: () -> Void
    
    @State var username: String = ""
    @FocusState var focused: Bool
    
    @State var usernameValidity: UsernameValidity?
    
    var body: some View {
        VStack {
            Text("Choose a Username")
                .font(.title)
                .fontWeight(.bold)
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
        .frame(minHeight: 0, maxHeight: .infinity) // Min height is needed here otherwise the keyboard padding doesn't work properly
        .keyboardAwarePadding(removePaddingOnDismiss: false)
        .overlay(alignment: .topLeading) {
            Button("Back", icon: .general.backward) {
                focused = false
                back()
            }
            .fontWeight(.semibold)
            .imageScale(.large)
            .labelStyle(.iconOnly)
            .padding()
        }
        .frame(maxHeight: .infinity)
    }
    
    @ViewBuilder
    var textFieldView: some View {
        HStack(spacing: 0) {
            Text(verbatim: "@")
                .foregroundStyle(.secondary)
            TextField("Username", text: $username, prompt: Text(verbatim: ""))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .submitLabel(.done)
                .onSubmit {}
                .focused($focused)
                .onAppear {
                    focused = true
                }
        }
        .padding()
        .background(.themedSecondaryGroupedBackground, in: .rect(cornerRadius: 16))
        .task(id: username) {
            do {
                usernameValidity = nil
                if !username.isEmpty {
                    try await Task.sleep(for: .seconds(0.5))
                }
                usernameValidity = try await instance.usernameIsValidForNewAccount(username)
            } catch ApiClientError.cancelled {
                // no-op
            } catch {
                handleError(error)
            }
        }
    }
    
    @ViewBuilder
    var nextButtonView: some View {
        Button(action: submit) {
            Text("Next")
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .opacity(usernameValidity == nil ? 0 : 1)
                .overlay {
                    if usernameValidity == nil {
                        ProgressView()
                            .tint(.themedSecondary)
                    }
                }
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.roundedRectangle(radius: 16))
        .disabled(usernameValidity != .available)
    }

    @ViewBuilder
    var validityWarningView: some View {
        Text(validityWarningText)
            .font(.footnote)
            .foregroundStyle(.secondary)
            .lineLimit(3, reservesSpace: true)
    }
    
    var validityWarningText: String {
        guard let usernameValidity else { return "" }
        if usernameValidity != .available {
            return String(localized: usernameValidity.label)
        } else {
            return ""
        }
    }
    
    func submit() {
        Task {
            guard usernameValidity == .available else { return }
        }
    }
}
