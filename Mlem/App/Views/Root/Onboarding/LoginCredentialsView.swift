//
//  LoginCredentialsView.swift
//  Mlem
//
//  Created by Sjmarf on 11/05/2024.
//

import MlemMiddleware
import SwiftUI

struct LoginCredentialsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.isFirstPage) var isFirstPage
    @Environment(NavigationLayer.self) var navigation
    @Environment(AppState.self) var appState
    
    let instance: (any Instance)?
    let userStub: UserStub?
    
    @State var username: String
    @State var password: String = ""
    
    @State var authenticating: Bool = false
    
    enum FocusedField { case username, password }
    @FocusState private var focused: FocusedField?
    
    var showUsernameField: Bool { userStub == nil }
    
    init(instance: any Instance) {
        self.instance = instance
        self.userStub = nil
        self._username = .init(wrappedValue: "")
    }
    
    init(userStub: UserStub) {
        self.instance = nil
        self.userStub = userStub
        self._username = .init(wrappedValue: userStub.name)
    }
    
    var body: some View {
        content
            .frame(maxWidth: .infinity)
            .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
            .toolbar {
                if navigation.isInsideSheet, isFirstPage {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
            }
    }
    
    @ViewBuilder
    var content: some View {
        ScrollView {
            VStack {
                if let instance {
                    instanceHeader(instance)
                } else if let userStub {
                    reauthHeader(userStub)
                        .padding(.bottom, 15)
                }
                textFields
                nextButton
                    .padding(.top, 5)
                Text("")
                    .foregroundStyle(.red)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
        }
        .scrollBounceBehavior(.basedOnSize)
    }
    
    @ViewBuilder
    func instanceHeader(_ instance: any Instance) -> some View {
        AvatarView(instance)
            .frame(height: 50)
        Text(instance.displayName)
            .font(.title)
            .bold()
    }
    
    @ViewBuilder
    func reauthHeader(_ userStub: UserStub) -> some View {
        VStack {
            AvatarView(userStub)
                .frame(height: 50)
            Text(userStub.fullName ?? "Sign In")
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
                    TextField("Username", text: $username, prompt: Text(""))
                        .focused($focused, equals: .username)
                        .onSubmit { focused = .password }
                        .padding(.trailing)
                }
                Divider()
            }
            GridRow {
                Text("Password")
                    .padding([.leading, .vertical])
                SecureField("Password", text: $password, prompt: Text(""))
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
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        )
        .onAppear { focused = showUsernameField ? .username : .password }
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
        .disabled(username.isEmpty || password.isEmpty || authenticating)
    }
    
    func attemptToLogin() {
        guard !username.isEmpty, !password.isEmpty else { return }
        if let domain = instance?.host ?? userStub?.host, let url = URL(string: "https://\(domain)") {
            authenticating = true
            Task {
                do {
                    let user = try await AccountsTracker.main.login(url: url, username: username, password: password)
                    appState.changeUser(to: user)
                    if navigation.isTopSheet {
                        navigation.dismissSheet()
                    }
                } catch {
                    print("ERROR", error)
                    switch error {
                    case let ApiClientError.response(response, _) where response.error == "missing_totp_token":
                        navigation.push(.login(.totp(url: url, username: username, password: password)))
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            authenticating = false
                        }
                    default:
                        DispatchQueue.main.async {
                            authenticating = false
                        }
                    }
                }
            }
        }
    }
}
