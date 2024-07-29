//
//  LoginTotpView.swift
//  Mlem
//
//  Created by Sjmarf on 13/05/2024.
//

import MlemMiddleware
import SwiftUI

struct LoginTotpView: View {
    @Environment(AppState.self) var appState
    @Environment(NavigationLayer.self) var navigation
    
    let client: ApiClient
    let username: String
    let password: String
    
    @State var totpToken: String = ""
    @State var authenticating: Bool = false
    @State var incorrect: Bool = false
    
    @FocusState private var focused: Bool
    
    let fontSize: CGFloat = 40
    let characterSpacing: CGFloat = 30
    let characterPadding: CGFloat = 8
    
    var body: some View {
        VStack {
            Image(systemName: "person.badge.key.fill")
                .symbolRenderingMode(.hierarchical)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 50)
                .foregroundStyle(.blue)
            Text("Two-Factor Authentication")
                .font(.title)
                .bold()
                .multilineTextAlignment(.center)
            codeInput
                .padding(.bottom, 5)
            if incorrect, totpToken.count == 0 {
                Text("Authentication code is incorrect.")
                    .foregroundStyle(.red)
            }
            openInAppButton
            if authenticating {
                ProgressView()
                    .controlSize(.large)
                    .tint(.secondary)
                    .padding(.top)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal)
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
    }
    
    @ViewBuilder
    var codeInput: some View {
        ZStack {
            TextField(String(""), text: Binding(
                get: { totpToken },
                set: { newValue in
                    let trimmedValue = String(newValue.prefix(6))
                    totpToken = trimmedValue
                    if trimmedValue.count == 6, !authenticating {
                        focused = false
                        attemptToLogin()
                    }
                }
            ))
            .kerning(characterSpacing)
            .font(.system(size: fontSize))
            .monospaced()
            .focused($focused)
            .offset(x: characterPadding * 2)
            .keyboardType(.numberPad)
            .textContentType(.oneTimeCode)
            .disabled(authenticating)
        }
        .frame(width: fontSize * 0.615 * 6 + characterSpacing * 5 + characterPadding * 4)
        .padding(.vertical, 5)
        .background {
            HStack(spacing: characterSpacing - characterPadding * 2) {
                ForEach(0 ..< 6, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(uiColor: .secondarySystemGroupedBackground))
                }
            }
            .padding(.horizontal, characterPadding)
        }
        .onAppear { focused = true }
    }
    
    @ViewBuilder
    var openInAppButton: some View {
        let authAppUrl = URL(string: "totp://")!
        Button("Open Authenticator App...") {
            UIApplication.shared.open(authAppUrl)
        }
    }
    
    func attemptToLogin() {
        authenticating = true
        Task {
            do {
                let user = try await AccountsTracker.main.login(
                    client: client,
                    username: username,
                    password: password,
                    totpToken: totpToken
                )
                appState.changeAccount(to: user)
                if navigation.isTopSheet {
                    navigation.dismissSheet()
                }
            } catch {
                Task { @MainActor in
                    authenticating = false
                    totpToken = ""
                    focused = true
                    incorrect = true
                }
            }
        }
    }
}
