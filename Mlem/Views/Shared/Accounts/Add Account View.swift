//
//  Add Saved Instance View.swift
//  Mlem
//
//  Created by David Bureš on 05.05.2023.
//

import Dependencies
import SwiftUI

// swiftlint:disable file_length
enum UserIDRetrievalError: Error {
    case couldNotFetchUserInformation
    case instanceIsPrivate
}

enum Field: Hashable {
    case homepageField
    case twoFactorField
}

/// Enumeration of the possible types of login that this view can handle
enum LoginType {
    /// case for onboarding. Takes an optional instance string
    case onboarding(String?)
    /// case for signing in to an existing account
    case authenticating
    /// case for reauthenticating an existing account. Takes required instance and username strings
    case reauthenticating(String, String)
}

/// Enumeration of the possible ways this view can be displayed, used to determine whether to display actions as a header or in the nav bar
enum LoginDisplayMode {
    case sheet, nav
}

// swiftlint:disable type_body_length
struct AddSavedInstanceView: View {
    @Dependency(\.accountsTracker) var accountsTracker
    @Dependency(\.apiClient) var apiClient
    
    enum ViewState {
        case initial
        case loading
        case success
        case onetimecode
        case incorrectLogin
        case error
    }
    
    enum FocusedField: Hashable {
        case instance
        case username
        case password
        case onetimecode
    }
    
    @EnvironmentObject var appState: AppState
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.openURL) private var openURL
    @Environment(\.setAppFlow) private var setFlow

    @State private var enteredInstance: String = ""
    @State private var enteredUsername = ""
    @State private var password = ""
    @State private var twoFactorCode = ""
    @State private var viewState: ViewState = .initial
    
    @State private var showing2FAAlert = false
    @State private var errorMessage = ""
    
    @State private var errorAlert: ErrorAlert?
    @FocusState private var focusedField: FocusedField?
    
    let loginType: LoginType
    let displayMode: LoginDisplayMode
    
    // convenience for computed vars
    let givenInstance: String?
    let givenUsername: String?
    
    var instance: String { givenInstance ?? enteredInstance }
    var username: String { givenUsername ?? enteredUsername }
    var badCredentialsMessage: String {
        if case .onboarding = loginType {
            // swiftlint:disable line_length
            "Please check your username and password. If you signed up with an email, make sure you've activated your account from the confirmation email."
            // swiftlint:enable line_length
        } else {
            "Please check your username and password"
        }
    }
    
    var registrationError = "Please verify your email and try again."
    
    init(loginType: LoginType, displayMode: LoginDisplayMode) {
        self.loginType = loginType
        self.displayMode = displayMode
        
        // initialize convenience vars
        switch loginType {
        case let .onboarding(instance):
            self.givenInstance = instance
            self.givenUsername = nil
        case let .reauthenticating(instance, username):
            self.givenInstance = instance
            self.givenUsername = username
        default:
            self.givenInstance = nil
            self.givenUsername = nil
        }
    }
    
    var body: some View {
        ScrollView {
            VStack {
                if displayMode == .sheet {
                    sheetTitle
                }
                headerSection
            }
            Grid(
                alignment: .trailing,
                horizontalSpacing: 0,
                verticalSpacing: 15
            ) {
                formSection
            }.disabled(viewState == .loading)
        }
        .transaction { transaction in
            transaction.disablesAnimations = true
        }
        .alert(using: $errorAlert) { content in
            Alert(title: Text(content.title), message: Text(content.message))
        }
        .toolbar {
            if displayMode == .nav {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task(priority: .userInitiated) {
                            await tryToAddAccount()
                        }
                    } label: {
                        Text("Submit")
                    }.disabled(!isReadyToSubmit)
                }
            }
        }
        .navigationTitle(Text(displayMode == .nav ? "Sign In" : ""))
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var isReadyToSubmit: Bool {
        (password.isNotEmpty && username.isNotEmpty && instance.isNotEmpty)
            && (viewState != .loading || viewState != .success)
    }
    
    @ViewBuilder
    var formSection: some View {
        Group {
            switch viewState {
            case .initial, .incorrectLogin, .error:
                Divider()
                GridRow {
                    Text("Instance")
                        .foregroundColor(.secondary)
                    if let givenInstance {
                        Text(givenInstance)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.secondary)
                            .onAppear {
                                focusedField = .username
                            }
                    } else {
                        TextField("lemmy.ml", text: $enteredInstance)
                            .textContentType(.URL)
                            .autocorrectionDisabled()
                            .focused($focusedField, equals: .instance)
                            .keyboardType(.URL)
                            .textInputAutocapitalization(.never)
                            .onAppear {
                                focusedField = .instance
                            }
                            .onSubmit {
                                focusedField = .username
                            }
                    }
                }
                .padding(.horizontal)
                .onTapGesture {
                    focusedField = .instance
                }
                Divider()
                GridRow {
                    Text("Username")
                        .foregroundColor(.secondary)
                    if let givenUsername {
                        Text(givenUsername)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.secondary)
                            .onAppear {
                                focusedField = .password
                            }
                    } else {
                        TextField("", text: $enteredUsername)
                            .textContentType(.username)
                            .focused($focusedField, equals: .username)
                            .autocorrectionDisabled()
                            .keyboardType(.default)
                            .textInputAutocapitalization(.never)
                            .onSubmit {
                                focusedField = .password
                            }
                    }
                }
                .padding(.horizontal)
                .onTapGesture {
                    focusedField = .username
                }
                Divider()
                GridRow {
                    Text("Password")
                        .foregroundColor(.secondary)
                    SecureField("", text: $password)
                        .focused($focusedField, equals: .password)
                        .textContentType(.password)
                        .submitLabel(.go)
                        .onSubmit {
                            if isReadyToSubmit {
                                Task {
                                    await tryToAddAccount()
                                }
                            }
                        }
                }
                .padding(.horizontal)
                .onTapGesture {
                    focusedField = .password
                }
                Divider()
            case .onetimecode:
                Divider()
                GridRow {
                    // Maybe Replace this with the multi-textbox thing
                    // at some point
                    Text("Code")
                        .foregroundColor(.secondary)
                    SecureField("Code", text: $twoFactorCode, prompt: Text("000000"))
                        .focused($focusedField, equals: .onetimecode)
                        .textContentType(.oneTimeCode)
                        .submitLabel(.go)
                        .onAppear {
                            focusedField = .onetimecode
                        }
                }
                .padding(.horizontal)
                .onTapGesture {
                    focusedField = .onetimecode
                }
                Divider()
            case .success:
                Spacer()
            default:
                ProgressView()
            }
        }
    }
    
    @ViewBuilder
    var sheetTitle: some View {
        ZStack {
            Text("Sign In")
                .bold()
            
            HStack {
                Button("Cancel", role: .destructive) {
                    dismiss()
                }
//                Button(role: .destructive) {
//                    dismiss()
//                } label: {
//                    Text("Cancel")
//                }
                
                Spacer()
                
                Button {
                    Task {
                        await tryToAddAccount()
                    }
                } label: {
                    Text("Submit")
                }
                .disabled(!isReadyToSubmit)
            }
        }
        .padding()
    }
    
    @ViewBuilder
    var headerSection: some View {
        Group {
            switch viewState {
            case .initial:
                LogoView()
            case .error:
                Text(errorMessage)
            case .onetimecode:
                Text("Enter one-time code")
            case .loading:
                Text("Logging In")
            case .success:
                Spacer()
                Image(systemName: Icons.successCircle)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 120)
                    .foregroundColor(.green)
                    .accessibilityLabel("Logged In")
            default:
                Text("Unhandled Shit 🙈")
            }
        }
        .font(.subheadline)
        .bold()
        .padding()
        .multilineTextAlignment(.center)
        .dynamicTypeSize(.small ... .accessibility1)
    }
    
    func tryToAddAccount() async {
        print("Will start the account addition process")
        
        withAnimation {
            viewState = .loading
        }
        
        // There should always be a match, but we return if there isn't just to be safe
        guard let match = instance.firstMatch(of: /^(?:https?:\/\/)?(?:www\.)?(?:[\.\s]*)([^\/\?]+?)(?:[\.\s]*$|\/)/) else {
            return
        }
        let sanitizedLink = String(match.1)
        
        print("Sanitized link: \(sanitizedLink)")
        
        do {
            let instanceURL = try await getCorrectURLtoEndpoint(baseInstanceAddress: sanitizedLink)
            print("Found correct endpoint: \(instanceURL)")
            guard !instanceURL.path().contains("v1") else {
                // If the link is to a v1 instance, stop and show an error
                displayIncompatibleVersionAlert()
                return
            }
            
            let response = try await apiClient.login(
                instanceURL: instanceURL,
                username: enteredUsername,
                password: password,
                totpToken: twoFactorCode.isEmpty ? nil : twoFactorCode
            )
            
            withAnimation {
                viewState = .success
            }
            
            let user = try await loadUser(authToken: response.jwt, instanceURL: instanceURL)
            let newAccount = SavedAccount(
                id: user.id,
                instanceLink: instanceURL,
                accessToken: response.jwt,
                username: enteredUsername,
                avatarUrl: user.avatarUrl
            )
            
            // MARK: - Save the account's credentials into the keychain
            
            AppConstants.keychain["\(newAccount.id)_accessToken"] = response.jwt
            switch loginType {
            case .authenticating, .onboarding:
                accountsTracker.addAccount(account: newAccount)
            case .reauthenticating:
                accountsTracker.update(with: newAccount)
            }
            
            setFlow(.account(newAccount))
            
            if displayMode == .sheet {
                dismiss()
            }
        } catch {
            handle(error)
        }
    }
    
    private func loadUser(authToken: String, instanceURL: URL) async throws -> APIPerson {
        // create a session to use for this request, since we're in the process of creating the account...
        let session = APISession.authenticated(instanceURL, authToken)
        do {
            return try await apiClient.getPersonDetails(session: session, username: enteredUsername)
                .personView
                .person
        } catch {
            print("getUserId Error info: \(error)")
            switch error {
            case let APIClientError.response(errorResponse, _) where errorResponse.instanceIsPrivate:
                throw UserIDRetrievalError.instanceIsPrivate
            default:
                throw UserIDRetrievalError.couldNotFetchUserInformation
            }
        }
    }
    
    private func handle(_ error: Error) {
        let message: String
        switch error {
        case EndpointDiscoveryError.couldNotFindAnyCorrectEndpoints:
            message = "Could not connect to \(instance)"
        case UserIDRetrievalError.couldNotFetchUserInformation:
            message = "Mlem couldn't fetch you account's information.\nFile a bug report."
        case UserIDRetrievalError.instanceIsPrivate:
            message = "\(instance) is a private instance."
        case APIClientError.encoding:
            // TODO: we should add better validation
            //  at the UI layer as encoding failures can be caught
            //  at an earlier stage
            message = badCredentialsMessage
        case APIClientError.networking:
            message = "Please check your internet connection and try again"
        case let APIClientError.response(errorResponse, _) where errorResponse.requires2FA:
            message = ""
            
            withAnimation {
                viewState = .onetimecode
            }
            
            return
        case let APIClientError.response(errorResponse, _) where errorResponse.isIncorrectLogin:
            message = badCredentialsMessage
        case APIClientError.invalidLogin:
            message = badCredentialsMessage
            
        case let APIClientError.response(errorResponse, _) where errorResponse.emailNotVerified:
            message = registrationError
            
        case let APIClientError.response(errorResponse, _) where errorResponse.userRegistrationPending:
            message = registrationError
            
        default:
            // unhandled error encountered...
            message = "Something went wrong"
            assertionFailure("add error handling for this case...")
        }
        
        displayError(message)
    }
    
    private func displayError(_ message: String) {
        errorMessage = message
        withAnimation {
            viewState = .error
        }
    }
    
    private func displayIncompatibleVersionAlert() {
        withAnimation {
            showing2FAAlert = false
            errorAlert = .init(
                title: "Unsupported Lemmy Version",
                message: """
                \(instance) uses an outdated version of Lemmy that Mlem doesn't support. \
                Contact \(instance) developers for more information.
                """
            )
        }
    }
}

// swiftlint:enable type_body_length

struct AddSavedInstanceView_Previews: PreviewProvider {
    static var previews: some View {
        AddSavedInstanceView(loginType: .onboarding(nil), displayMode: .nav)
    }
}

// swiftlint:enable file_length
