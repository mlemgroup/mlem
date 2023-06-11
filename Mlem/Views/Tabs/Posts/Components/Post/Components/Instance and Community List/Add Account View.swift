//
//  Add Saved Instance View.swift
//  Mlem
//
//  Created by David Bureš on 05.05.2023.
//

import SwiftUI
import SwiftyJSON

struct ErrorAlert {
    let title: String
    let message: String
}

extension ErrorAlert {
    static var unexpected: Self {
        .init(
            title: "Something went wrong",
            message: "Sorry, something unexpected happened. Please try again"
        )
    }
}

enum UserIDRetrievalError: Error {
    case couldNotFetchUserInformation
}

struct AddSavedInstanceView: View
{
    @EnvironmentObject var communityTracker: SavedAccountTracker
    @EnvironmentObject var appState: AppState
    
    @Binding var isShowingSheet: Bool
    
    @State private var instanceLink: String = ""
    @State private var usernameOrEmail: String = ""
    @State private var password: String = ""
    
    @State private var token: String = ""
    
    @State private var isShowingEndpointDiscoverySpinner: Bool = false
    @State private var hasSuccessfulyConnectedToEndpoint: Bool = false
    @State private var errorOccuredWhileConnectingToEndpoint: Bool = false
    @State private var errorText: String = ""
    
    @State private var errorAlert: ErrorAlert?
    
    @FocusState var isFocused
    
    var body: some View
    {
        VStack(alignment: .leading, spacing: 0)
        {
            if isShowingEndpointDiscoverySpinner
            {
                if !errorOccuredWhileConnectingToEndpoint
                {
                    if !hasSuccessfulyConnectedToEndpoint
                    {
                        VStack(alignment: .center)
                        {
                            HStack(alignment: .center, spacing: 10)
                            {
                                ProgressView()
                                Text("Connecting to \(instanceLink)")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(uiColor: .secondarySystemBackground))
                    }
                    else
                    {
                        VStack(alignment: .center)
                        {
                            HStack(alignment: .center, spacing: 10)
                            {
                                Image(systemName: "checkmark.shield.fill")
                                Text("Logged in to \(instanceLink) as \(usernameOrEmail)")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.cyan)
                        .foregroundColor(.black)
                    }
                }
                else
                {
                    VStack(alignment: .center)
                    {
                        HStack(alignment: .center, spacing: 10)
                        {
                            Image(systemName: "xmark.circle.fill")
                            Text(errorText)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.pink)
                    .foregroundColor(.black)
                }
            }
            
            Form
            {
                Section("Homepage")
                {
                    TextField("Homepage:", text: $instanceLink, prompt: Text("lemmy.ml"))
                        .autocorrectionDisabled()
                        .focused($isFocused)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .onAppear
                    {
                        isFocused = true
                    }
                }
                
                Section("Credentials")
                {
                    HStack
                    {
                        Text("Username")
                        Spacer()
                        TextField("Username", text: $usernameOrEmail, prompt: Text("Salmoon"))
                            .autocorrectionDisabled()
                            .keyboardType(.default)
                            .textInputAutocapitalization(.never)
                    }
                    
                    HStack
                    {
                        Text("Password")
                        Spacer()
                        SecureField("Password", text: $password, prompt: Text("VeryStrongPassword"))
                            .submitLabel(.go)
                    }
                }
                
                Button
                {
                    Task
                    {
                        await tryToAddAccount()
                    }
                } label: {
                    Text("Log In")
                }
                .disabled(instanceLink.isEmpty || usernameOrEmail.isEmpty || password.isEmpty)
            }
            .disabled(isShowingEndpointDiscoverySpinner)
        }
        .alert(using: $errorAlert) { content in
            Alert(title: Text(content.title), message: Text(content.message))
        }
    }
    
    func tryToAddAccount() async {
        print("Will start the account addition process")
        
        withAnimation {
            isShowingEndpointDiscoverySpinner = true
        }
        
        let sanitizedLink = instanceLink
            .replacingOccurrences(of: "https://", with: "")
            .replacingOccurrences(of: "http://", with: "")
            .replacingOccurrences(of: "www.", with: "")
            .lowercased()
        
        print("Sanitized link: \(sanitizedLink)")
        
        do {
            let instanceURL = try await getCorrectURLtoEndpoint(baseInstanceAddress: sanitizedLink)
            print("Found correct endpoint: \(instanceURL)")
            
            guard !instanceURL.absoluteString.contains("v1") else {
                // If the link is to a v1 instance, stop and show an error
                displayIncompatibleVersionAlert()
                return
            }
            
            let loginRequest = LoginRequest(
                instanceURL: instanceURL,
                username: usernameOrEmail,
                password: password
            )
            
            let response = try await APIClient().perform(request: loginRequest)
            
            hasSuccessfulyConnectedToEndpoint = true
            print("Successfully got the token")
            print("Obtained token: \(response.jwt)")
            let newAccount = SavedAccount(
                id: try await getUserID(authToken: response.jwt, instanceURL: instanceURL),
                instanceLink: instanceURL,
                accessToken: response.jwt,
                username: usernameOrEmail
            )
            
            // MARK: - Save the account's credentials into the keychain
            
            AppConstants.keychain["\(newAccount.id)_accessToken"] = response.jwt
            communityTracker.savedAccounts.append(newAccount)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                isShowingSheet = false
            }
        } catch {
            handle(error)
        }
    }
    
    private func getUserID(authToken: String, instanceURL: URL) async throws -> Int {
        do {
            let request = try GetPersonDetailsRequest(
                accessToken: authToken,
                instanceURL: instanceURL,
                username: usernameOrEmail
            )
            return try await APIClient()
                .perform(request: request)
                .personView
                .person
                .id
        } catch {
            throw UserIDRetrievalError.couldNotFetchUserInformation
        }
    }
            
    private func handle(_ error: Error) {
                let message: String
                switch error {
                case EndpointDiscoveryError.couldNotFindAnyCorrectEndpoints:
                    message = "Could not connect to \(instanceLink)"
                case UserIDRetrievalError.couldNotFetchUserInformation:
                    message = "Mlem couldn't fetch you account's information.\nFile a bug report."
                case APIClientError.encoding:
                    // TODO: we should add better validation at the UI layer as encoding failures can be caught
                    // at an earlier stage
                    message = "Please check your username and password"
                case APIClientError.networking:
                    message = "Please check your internet connection and try again"
                case APIClientError.response(let errorResponse, _):
                    message = errorResponse.error
                default:
                    // unhandled error encountered...
                    message = "Something went wrong"
                    assertionFailure("add error handling for this case...")
                }
                
                displayError(message)
    }
            
    private func displayError(_ message: String) {
        errorText = message
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            errorOccuredWhileConnectingToEndpoint = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    isShowingEndpointDiscoverySpinner = false
                    errorOccuredWhileConnectingToEndpoint = false
                }
            }
        }
    }
    
    private func displayIncompatibleVersionAlert() {
        withAnimation {
            isShowingEndpointDiscoverySpinner = false
            errorAlert = .init(
                title: "Unsupported Lemmy Version",
                message: "\(instanceLink) uses an outdated version of Lemmy that Mlem doesn't support.\nContact \(instanceLink) developers for more information."
            )
        }
    }
}
