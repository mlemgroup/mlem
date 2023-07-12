// 
//  TokenRefreshView.swift
//  Mlem
//
//  Created by mormaer on 10/07/2023.
//  
//

import SwiftUI

struct TokenRefreshView: View {
    
    enum ViewState {
        case initial
        case refreshing
        case success
        case incorrectLogin
    }
    
    @EnvironmentObject var appState: AppState
    
    @Environment(\.dismiss) var dismiss
    
    let account: SavedAccount
    let refreshedAccount: (SavedAccount) -> Void
    
    @State private var password = ""
    @State private var twoFactorCode = ""
    @State private var viewState: ViewState = .initial
    @State private var showing2FAAlert = false
    
    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                header
                informationText
                passwordField
            }
            
            Spacer()
            cancelButton
        }
        .alert("2FA Required", isPresented: $showing2FAAlert) {
            SecureField("Enter 2FA Token", text: $twoFactorCode)
            Button("OK", action: refreshTokenUsing2FA)
        }
        .multilineTextAlignment(.center)
        .padding()
        .interactiveDismissDisabled()
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var header: some View {
        switch viewState {
        case .initial, .incorrectLogin:
            Image(systemName: "exclamationmark.triangle")
                .resizable()
                .foregroundColor(.red)
                .frame(width: 100, height: 100)
                .padding(.vertical, 50)
        case .refreshing:
            ProgressView()
                .controlSize(.large)
                .frame(width: 100, height: 100)
                .padding(.vertical, 50)
        case .success:
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .foregroundColor(.green)
                .frame(width: 100, height: 100)
                .padding(.vertical, 50)
        }
    }
    
    private var informationText: some View {
        let text: String
        
        switch viewState {
        case .initial, .incorrectLogin:
            text = """
        Your current session has expired, you will need to log in to continue.\n
        Please enter the password for\n\(account.username)@\(account.instanceLink.host() ?? "")
        """
        case .refreshing:
            text = "Setting up your new session..."
        case .success:
            text = "New session created"
        }
        
        // using an ideal height below so that it can expand further if needed
        // but won't collapse for the shorter phrases to keep things a bit less... jiggly
        
        return Text(text)
            .font(.body)
            .padding(.bottom, 16)
            .frame(idealHeight: 150)
    }
    
    @ViewBuilder
    private var passwordField: some View {
        VStack {
            SecureField("Password", text: $password)
                .textContentType(.password)
                .submitLabel(.continue)
                .textFieldStyle(.roundedBorder)
                .disabled(shouldDisableControls)
                .onSubmit {
                    updateViewState(.refreshing)
                    Task {
                        do {
                            let token = try await refreshToken(with: password)
                            updateViewState(.success)
                            await didReceive(token)
                        } catch {
                            AppConstants.hapticManager.notificationOccurred(.error)
                            
                            if case let APIClientError.response(apiError, _) = error,
                               apiError.isIncorrectLogin {
                                updateViewState(.incorrectLogin)
                                return
                            }
                            
                            if case let APIClientError.response(apiError, _) = error,
                               apiError.requires2FA {
                                showing2FAAlert = true
                                return
                            }
                            
                            updateViewState(.initial)
                        }
                    }
                }
        }
        
        if viewState == .incorrectLogin {
            Text("The password you entered was incorrect")
                .font(.footnote)
                .foregroundColor(.red)
        }
    }
    
    private var cancelButton: some View {
        Button("Cancel") {
            dismiss()
        }
        .disabled(shouldDisableControls)
    }
    
    // MARK: - Private methods
    
    private func refreshToken(with newPassword: String, twoFactorToken: String? = nil) async throws -> String {
        let request = LoginRequest(
            instanceURL: account.instanceLink,
            username: account.username,
            password: password,
            totpToken: twoFactorToken
        )
        
        return try await APIClient().perform(request: request).jwt
    }
    
    private func refreshTokenUsing2FA() {
        updateViewState(.refreshing)
        Task {
            do {
                let token = try await refreshToken(with: password, twoFactorToken: twoFactorCode)
                updateViewState(.success)
                await didReceive(token)
            } catch {
                updateViewState(.initial)
            }
        }
    }
    
    private func didReceive(_ newToken: String) async {
        // small artifical delay so the user sees confirmation of success
        AppConstants.hapticManager.notificationOccurred(.success)
        try? await Task.sleep(for: .seconds(0.5))
        
        await MainActor.run {
            refreshedAccount(
                .init(
                    id: account.id,
                    instanceLink: account.instanceLink,
                    accessToken: newToken,
                    username: account.username
                )
            )
            dismiss()
        }
    }
    
    private func updateViewState(_ newValue: ViewState) {
        withAnimation {
            viewState = newValue
        }
    }
    
    private var shouldDisableControls: Bool {
        switch viewState {
        case .refreshing, .success:
            // disable the password field and cancel buttons while calls are in-flight
            return true
        case .initial, .incorrectLogin:
            return false
        }
    }
}
