//
//  LoginCredentialsView.swift
//  Mlem
//
//  Created by Sjmarf on 11/05/2024.
//

import MlemMiddleware
import SwiftUI
import Theming

struct LoginCredentialsView: View {
    @Environment(NavigationLayer.self) var navigation
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss
    @Environment(\.isRootView) var isRootView

    @State var instance: (any InstanceStubProviding)?
    let account: UserAccount?
    
    @State var upgradeState: LoadingState = .idle
    
    @State var usernameOrEmail: String
    @State var password: String = ""
    
    @State var authenticating: Bool = false
    @State private var failureReason: FailureReason?
    
    enum FocusedField { case usernameOrEmail, password }
    @FocusState private var focused: FocusedField?
    
    var showUsernameField: Bool { account == nil }
    
    init(instance: any InstanceStubProviding) {
        self.instance = instance
        self.account = nil
        self._usernameOrEmail = .init(wrappedValue: "")
    }
    
    init(account: UserAccount) {
        self.instance = nil
        self.account = account
        self._usernameOrEmail = .init(wrappedValue: account.name)
    }
    
    var body: some View {
        content
            .frame(maxWidth: .infinity)
            .themedGroupedBackground()
            .interactiveDismissDisabled((!usernameOrEmail.isEmpty && showUsernameField) || !password.isEmpty)
            .toolbar {
                if navigation.isInsideSheet, isRootView {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                        .disabled(authenticating)
                    }
                }
            }
            .task {
                guard upgradeState == .idle else { return }
                upgradeState = .loading
                do {
                    if let instance, !(instance is any Instance3Providing) {
                        self.instance = try await instance.upgradeLocal()
                    }
                    upgradeState = .done
                } catch {
                    upgradeState = .idle
                    handleError(error)
                }
            }
    }
    
    @ViewBuilder
    var content: some View {
        ScrollView {
            VStack {
                if let instance {
                    instanceHeader(instance)
                } else if let account {
                    reauthHeader(account)
                        .padding(.bottom, 15)
                }
                textFields
                nextButton
                    .padding(.top, 5)
                if let failureReason {
                    Text(failureReason.label)
                        .foregroundStyle(.red)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
        }
        .scrollBounceBehavior(.basedOnSize)
    }
    
    @ViewBuilder
    func instanceHeader(_ instance: any InstanceStubProviding) -> some View {
        CircleCroppedImageView(url: instance.avatar_, frame: 50, fallback: .instanceAvatar)
        Text(instance.displayName_ ?? instance.host)
            .font(.title)
            .bold()
    }
    
    @ViewBuilder
    func reauthHeader(_ account: UserAccount) -> some View {
        VStack {
            CircleCroppedImageView(account, frame: 50)
            Text(account.fullName ?? "Sign In")
                .font(.title)
                .bold()
                .padding(.bottom, 5)
            Text("Your session has expired. Enter your password to authenticate a new session.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    @ViewBuilder
    var textFields: some View {
        Grid(
            alignment: .trailing,
            horizontalSpacing: 15,
            verticalSpacing: 0
        ) {
            if showUsernameField {
                GridRow {
                    Text("Username")
                        .padding([.leading, .vertical])
                    TextField("Username", text: $usernameOrEmail, prompt: Text(verbatim: ""))
                        .focused($focused, equals: .usernameOrEmail)
                        .onSubmit { focused = .password }
                        .padding(.trailing)
                }
                Divider()
            }
            GridRow {
                Text("Password")
                    .padding([.leading, .vertical])
                SecureField("Password", text: $password, prompt: Text(verbatim: ""))
                    .focused($focused, equals: .password)
                    .padding(.trailing)
                    .onSubmit(attemptToLogin)
                    .submitLabel(.go)
            }
        }
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.themedSecondaryGroupedBackground)
        )
        .paletteBorder(cornerRadius: 16)
        .onAppear { focused = showUsernameField ? .usernameOrEmail : .password }
        .onChange(of: usernameOrEmail) { failureReason = nil }
        .onChange(of: password) { failureReason = nil }
    }
    
    @ViewBuilder
    var nextButton: some View {
        Button(action: attemptToLogin) {
            Text(authenticating ? "Authenticating..." : "Sign In")
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .transaction { $0.animation = .none }
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.roundedRectangle(radius: 16))
        .disabled(usernameOrEmail.isEmpty || password.isEmpty || authenticating)
    }
    
    func attemptToLogin() {
        guard !usernameOrEmail.isEmpty, !password.isEmpty else { return }
        if let client = (instance as? any Instance)?.guestApi ?? account?.api.asGuest() {
            authenticating = true
            Task {
                do {
                    let user = try await AccountsTracker.main.logIn(
                        client: client,
                        usernameOrEmail: usernameOrEmail,
                        password: password
                    )
                    appState.changeAccount(to: user)
                    if navigation.isTopSheet {
                        navigation.dismissSheet()
                    }
                } catch {
                    switch error {
                    case let ApiClientError.response(response, _) where response.error == "missing_totp_token":
                        navigation.push(.logIn(.totp(client: client, usernameOrEmail: usernameOrEmail, password: password)))
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            authenticating = false
                        }
                    case ApiClientError.invalidSession:
                        failureReason = .incorrectPassword
                    default:
                        handleError(error, silent: true)
                        failureReason = .other
                    }
                    Task { @MainActor in
                        authenticating = false
                    }
                }
            }
        }
    }
}

private enum FailureReason {
    case incorrectPassword
    case other
    
    var label: String {
        switch self {
        case .incorrectPassword:
            "Username or password is incorrect."
        case .other:
            "Something went wrong."
        }
    }
}
