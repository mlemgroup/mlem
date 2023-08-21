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
}

enum Field: Hashable {
    case homepageField
    case twoFactorField
}

// swiftlint:disable type_body_length
struct AddSavedInstanceView: View {
    
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
    
    @EnvironmentObject var communityTracker: SavedAccountTracker
    @EnvironmentObject var appState: AppState
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.openURL) private var openURL

    @State private var enteredInstance: String = ""
    @State private var username = ""
    @State private var password = ""
    @State private var twoFactorCode = ""
    @State private var viewState: ViewState = .initial
    
    @State private var showing2FAAlert = false
    @State private var errorMessage = ""
    
    @State private var errorAlert: ErrorAlert?
    @FocusState private var focusedField: FocusedField?
    
    let onboarding: Bool
    let givenInstance: String? // if present, will override manual instance entry
    @Binding var currentAccount: SavedAccount?
    
    var instance: String { givenInstance ?? enteredInstance }
    
    init(onboarding: Bool,
         currentAccount: Binding<SavedAccount?>,
         givenInstance: String? = nil) {
        self.onboarding = onboarding
        self._currentAccount = currentAccount
        self.givenInstance = givenInstance
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    title
                    headerSection
                }
                Grid(alignment: .trailing,
                     horizontalSpacing: 0,
                     verticalSpacing: 15) {
                    formSection
                }.disabled(viewState == .loading)
                footerView
            }
            .transaction { transaction in
                transaction.disablesAnimations = true
            }
        }
        .alert(using: $errorAlert) { content in
            Alert(title: Text(content.title), message: Text(content.message))
        }
    }
    
    var isReadyToSubmit: Bool {
        return (password.isNotEmpty && username.isNotEmpty && instance.isNotEmpty)
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
                    TextField("", text: $username)
                        .textContentType(.username)
                        .focused($focusedField, equals: .username)
                        .autocorrectionDisabled()
                        .keyboardType(.default)
                        .textInputAutocapitalization(.never)
                        .onSubmit {
                            focusedField = .password
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
    var title: some View {        
        ZStack {
            Text("Sign In")
                .bold()
            
            HStack {
                if !onboarding {
                    Button(role: .destructive) {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
                
                Spacer()
                
                Button {
                    Task {
                        await tryToAddAccount()
                    }
                } label: {
                    Text("Log In")
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
                Image(systemName: "checkmark.circle")
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
    
    @ViewBuilder
    var footerView: some View {
        Text("What is Lemmy?")
            .font(.footnote)
            .foregroundColor(.blue)
            .accessibilityAddTraits(.isLink)
            .padding()
            .onTapGesture {
                openURL(URL(string: "https://join-lemmy.org")!)
            }
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
                username: username,
                password: password,
                totpToken: twoFactorCode.isEmpty ? nil : twoFactorCode
            )
            
            withAnimation {
                viewState = .success
            }
            
            let newAccount = SavedAccount(
                id: try await getUserID(authToken: response.jwt, instanceURL: instanceURL),
                instanceLink: instanceURL,
                accessToken: response.jwt,
                username: username
            )
            
            // MARK: - Save the account's credentials into the keychain
            
            AppConstants.keychain["\(newAccount.id)_accessToken"] = response.jwt
            communityTracker.addAccount(account: newAccount)
            
            dismiss()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                currentAccount = newAccount
                
                // appState is not present on onboarding screen
                if !onboarding {
                    appState.setActiveAccount(newAccount)
                }
            }
        } catch {
            handle(error)
        }
    }
    
    private func getUserID(authToken: String, instanceURL: URL) async throws -> Int {
        // create a session to use for this request, since we're in the process of creating the account...
        let session = APISession(token: authToken, URL: instanceURL)
        do {
            return try await apiClient.getPersonDetails(session: session, username: username)
                .personView
                .person
                .id
        } catch {
            print("getUserId Error info: \(error)")
            throw UserIDRetrievalError.couldNotFetchUserInformation
        }
    }
    
    private func handle(_ error: Error) {
        let message: String
        switch error {
        case EndpointDiscoveryError.couldNotFindAnyCorrectEndpoints:
            message = "Could not connect to \(instance)"
        case UserIDRetrievalError.couldNotFetchUserInformation:
            message = "Mlem couldn't fetch you account's information.\nFile a bug report."
        case APIClientError.encoding:
            // TODO: we should add better validation
            //  at the UI layer as encoding failures can be caught
            //  at an earlier stage
            message = "Please check your username and password"
        case APIClientError.networking:
            message = "Please check your internet connection and try again"
        case APIClientError.response(let errorResponse, _) where errorResponse.requires2FA:
            message = ""
            
            withAnimation {
                viewState = .onetimecode
            }
            
            return
        case APIClientError.response(let errorResponse, _) where errorResponse.isIncorrectLogin:
            message = "Please check your username and password"
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
        AddSavedInstanceView(
            onboarding: true,
            currentAccount: .constant(.mock())
        )
    }
}
// swiftlint:enable file_length
