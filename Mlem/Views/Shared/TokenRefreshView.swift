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
                }
                .padding()
                Spacer(minLength: 15)
                Grid(alignment: .trailing, verticalSpacing: 15) {
                    Divider()
                    passwordField.padding(.horizontal)
                    Divider()
                    oneTimeCodeView.padding(.horizontal)
                }
            }
            .edgesIgnoringSafeArea(.horizontal)
            .navigationBarTitleDisplayMode(.inline)
            .interactiveDismissDisabled()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    cancelButton
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
            case .success:
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .foregroundColor(.green)
            default:
                informationText
            }
        }
    }
    
    @ViewBuilder
    private var informationText: some View {
        switch viewState {
        case .initial, .incorrectLogin:
            
            Text("Your session has expired")
                .font(.title)
                .bold()
                .padding()
                .multilineTextAlignment(.center)
                .dynamicTypeSize(.small ... .accessibility1)
            Text("Please enter the password for")
                .font(.body)
            Text("\(account.username)@\(account.instanceLink.host ?? "")" )
                .font(.subheadline)
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
                SecureField("", text: $password)
                    .focused($selectedField, equals: FocusedField.password)
                    .textContentType(.password)
                    .submitLabel(.continue)
                    .dynamicTypeSize(.small ... .accessibility2)
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
                    }
            }
        GridRow {
            if viewState == .incorrectLogin {
                Text("The password you entered was incorrect")
                    .font(.footnote)
                    .foregroundColor(.red)
            }
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
                    SecureField("Enter one-time code", text: $twoFactorCode)
                        .focused($selectedField, equals: FocusedField.onetimecode)
                        .textContentType(.oneTimeCode)
                        .submitLabel(.go)
                        .onSubmit {
                            refreshTokenUsing2FA()
                        }
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
        HapticManager.shared.success()
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
