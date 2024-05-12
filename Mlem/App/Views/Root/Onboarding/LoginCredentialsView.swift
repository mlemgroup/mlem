//
//  LoginCredentialsView.swift
//  Mlem
//
//  Created by Sjmarf on 11/05/2024.
//

import MlemMiddleware
import SwiftUI

struct LoginCredentialsView: View {
    enum FocusedField {
        case username, password
    }
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.isFirstPage) var isFirstPage
    @Environment(NavigationLayer.self) var navigation
    @Environment(AppState.self) var appState
    
    let instance: (any Instance)?
    let userStub: UserStub?
    
    @State var username: String
    @State var password: String = ""
    
    @State var authenticating: Bool = false
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
                Group {
                    if showUsernameField {
                        AvatarView(instance, type: .instance)
                    } else {
                        AvatarView(userStub)
                    }
                }
                .frame(height: 50)
                Text((showUsernameField ? instance?.displayName : userStub?.fullName) ?? "Sign In")
                    .font(.title)
                    .bold()
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
        .frame(maxWidth: .infinity)
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
            Text(authenticating ? "Authenticating..." : "Next")
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
                    let unauthenticatedApi = ApiClient.getApiClient(for: url, with: nil)
                    let response = try await unauthenticatedApi.login(
                        username: username,
                        password: password,
                        totpToken: nil
                    )
                    guard let token = response.jwt else {
                        DispatchQueue.main.async {
                            authenticating = false
                        }
                        return
                    }

                    let authenticatedApiClient = ApiClient.getApiClient(for: url, with: token)
                    
                    // Check if account exists already
                    if let user = AccountsTracker.main.savedAccounts.first(where: { $0.api === authenticatedApiClient }) {
                        user.updateToken(token)
                        appState.changeUser(to: user)
                    } else {
                        let user = try await authenticatedApiClient.loadUser()
                        AccountsTracker.main.addAccount(account: user)
                        appState.changeUser(to: user)
                    }
                    DispatchQueue.main.async {
                        navigation.dismissSheet()
                    }
                } catch {
                    DispatchQueue.main.async {
                        authenticating = false
                    }
                }
            }
        }
    }
}
