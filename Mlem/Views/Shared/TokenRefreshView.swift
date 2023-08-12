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
    
    enum FocusedField: Hashable {
        case password
        case onetimecode
    }
    
    @EnvironmentObject var appState: AppState
    
    @Environment(\.dismiss) var dismiss
    
    let account: SavedAccount
    let refreshedAccount: (SavedAccount) -> Void
    
    @State private var password = ""
    @State private var twoFactorCode = ""
    @State private var viewState: ViewState = .initial
    @State private var showing2FAAlert = false
    
    @FocusState private var selectedField: FocusedField?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .center, spacing: 5) {
                    header
                    Spacer()
                    informationText
                }
                .padding()
                Spacer(minLength: 15)
                Grid(alignment: .trailing, horizontalSpacing: 0, verticalSpacing: 15) {
                    Divider()
                    passwordField
                        .dynamicTypeSize(.small ... .xxxLarge)
                    Divider()
                    oneTimeCodeView
                        .dynamicTypeSize(.small ... .xxxLarge)
                }
                .disabled(shouldDisableControls)
            }
            .edgesIgnoringSafeArea(.horizontal)
            .navigationBarTitleDisplayMode(.inline)
            .interactiveDismissDisabled()
            .navigationBarColor()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    cancelButton
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    submitButton
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var header: some View {
        Group {
            switch viewState {
            case .refreshing:
                ProgressView()
                    .controlSize(.large)
                    .frame(height: 60)
            case .success:
                Image(systemName: "checkmark.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 60)
                    .foregroundColor(.green)
                    .padding()
            default:
                Text("Your session has expired")
                    .font(.title)
                    .bold()
                    .padding()
                    .multilineTextAlignment(.center)
                    .dynamicTypeSize(.small ... .accessibility1)
            }
        }
    }
    
    @ViewBuilder
    private var informationText: some View {
        switch viewState {
        case .incorrectLogin:
            Text("The password you entered was incorrect")
                .font(.footnote)
                .foregroundColor(.red)
        case .initial:
            Text("Please enter the password for")
                .font(.body)
                .dynamicTypeSize(.small ... .xxxLarge)
            Text("\(account.username)@\(account.instanceLink.host ?? "")" )
                .font(.subheadline)
                .dynamicTypeSize(.small ... .xxxLarge)
        case .refreshing:
            Text("Logging In...")
        case .success:
            Text("Login Succesful")
        }
    }
    
    @ViewBuilder
    private var passwordField: some View {
            GridRow {
                Text("Password")
                    .foregroundColor(.secondary)
                    .accessibilityHidden(true)
                    .padding(.horizontal)
                SecureField("", text: $password)
                    .focused($selectedField, equals: FocusedField.password)
                    .textContentType(.password)
                    .submitLabel(.continue)
                    .dynamicTypeSize(.small ... .accessibility2)
                    .disabled(shouldDisableControls)
                    .onSubmit {
                        updateViewState(.refreshing)
                        Task {
                            await refreshTokenFlow()
                        }
                    }
            }
            .onTapGesture {
                selectedField = .password
            }
    }
    
    @ViewBuilder
    private var oneTimeCodeView: some View {
        if showing2FAAlert {
            Group {
                GridRow {
                    Text("Code")
                        .foregroundColor(.secondary)
                        .accessibilityHidden(true)
                        .padding(.horizontal)
                    SecureField("000000", text: $twoFactorCode)
                        .focused($selectedField, equals: FocusedField.onetimecode)
                        .textContentType(.oneTimeCode)
                        .submitLabel(.go)
                        .onSubmit {
                            refreshTokenUsing2FA()
                        }
                }
                .onTapGesture {
                    selectedField = .onetimecode
                }
                Divider()
            }

        }
        
    }
    
    private var cancelButton: some View {
        Button("Cancel", role: .destructive) {
            dismiss()
        }
        .disabled(shouldDisableControls)
    }
    
    private var submitButton: some View {
        Button("Submit") {
            updateViewState(.refreshing)
            Task {
                await refreshTokenFlow()
            }
        }
        .disabled(shouldDisableControls)
    }
    
    // MARK: - Private methods
    
    private func refreshTokenFlow() async {
        do {
            let token = try await refreshToken(with: password)
            updateViewState(.success)
            await didReceive(token)
        } catch {
            HapticManager.shared.play(haptic: .failure, priority: .high)
            
            if case let APIClientError.response(apiError, _) = error,
               apiError.isIncorrectLogin {
                updateViewState(.incorrectLogin)
                selectedField = .password
                return
            }
            
            if case let APIClientError.response(apiError, _) = error,
               apiError.requires2FA {
                showing2FAAlert = true
                selectedField = .onetimecode
                return
            }
            
            updateViewState(.initial)
        }
    }
    
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
        HapticManager.shared.play(haptic: .success, priority: .high)
        try? await Task.sleep(for: .seconds(0.5))
        
        await MainActor.run {
            refreshedAccount(.init(from: account, accessToken: newToken))
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

struct TokenRefreshViewPreview: PreviewProvider {
    
    static let account = SavedAccount(id: 1,
                                      instanceLink: URL(string: "https://lemmy.world")!,
                                      accessToken: "dfas",
                                      username: "kronusdark")
    
    static var previews: some View {
        TokenRefreshView(account: account) { _ in
            print("Refreshed")
        }
    }
    
}
