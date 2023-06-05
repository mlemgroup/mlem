//
//  Add Saved Instance View.swift
//  Mlem
//
//  Created by David Bureš on 05.05.2023.
//

import SwiftUI
import SwiftyJSON

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
    }

    func tryToAddAccount() async
    {
        print("Will start the account addition process")

        withAnimation
        {
            isShowingEndpointDiscoverySpinner = true
        }

        do
        {
            let sanitizedLink: String = instanceLink.replacingOccurrences(of: "https://", with: "").replacingOccurrences(of: "http://", with: "").replacingOccurrences(of: "www.", with: "")
            
            print("Sanitized link: \(sanitizedLink)")
            
            let instanceURL = try await getCorrectURLtoEndpoint(baseInstanceAddress: sanitizedLink)
            print("Found correct endpoint: \(instanceURL)")

            if instanceURL.absoluteString.contains("v1")
            { /// If the link is to a v1 instance, stop and show an error
                
                withAnimation {
                    isShowingEndpointDiscoverySpinner.toggle()
                }
                
                appState.alertTitle = "Unsupported Lemmy Version"
                appState.alertMessage = "\(instanceLink) uses an outdated version of Lemmy that Mlem doesn't support.\nContanct \(instanceLink) developers for more information."
                appState.isShowingAlert.toggle()
                                
                return
            }
            else
            {
                do
                {
                    let loginRequestResponse = try await sendPostCommand(appState: appState, baseURL: instanceURL, endpoint: "user/login", arguments: ["username_or_email": "\(usernameOrEmail)", "password": "\(password)"])
                    if loginRequestResponse.contains("jwt")
                    {
                        hasSuccessfulyConnectedToEndpoint = true
                        
                        print("Successfully got the token")
                        
                        let parsedResponse: JSON = try! parseJSON(from: loginRequestResponse)
                        
                        token = parsedResponse["jwt"].stringValue
                        
                        print("Obtained token: \(token)")
                        
                        let newAccount = SavedAccount(instanceLink: instanceURL, accessToken: token, username: usernameOrEmail)
                        
                        // MARK: - Save the account's credentials into the keychain
                        
                        AppConstants.keychain["\(newAccount.id)_accessToken"] = token
                        
                        communityTracker.savedAccounts.append(newAccount)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2)
                        {
                            isShowingSheet = false
                        }
                    }
                    else
                    {
                        print("Error occured: \(loginRequestResponse)")
                        
                        errorText = "Invalid credentials"
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1)
                        {
                            errorOccuredWhileConnectingToEndpoint = true
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2)
                            {
                                withAnimation
                                {
                                    isShowingEndpointDiscoverySpinner = false
                                    errorOccuredWhileConnectingToEndpoint = false
                                }
                            }
                        }
                    }
                }
                catch let loginRequestError
                {
                    print("Failed while sending login command: \(loginRequestError)")
                    
                    errorText = "Could not connect to \(instanceLink)"
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1)
                    {
                        errorOccuredWhileConnectingToEndpoint = true
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2)
                        {
                            withAnimation
                            {
                                isShowingEndpointDiscoverySpinner = false
                                errorOccuredWhileConnectingToEndpoint = false
                            }
                        }
                    }
                }
            }
            
        }
        catch let endpointDiscoveryError
        {
            print("Failed while trying to get correct URL to endpoint: \(endpointDiscoveryError)")

            errorText = "Could not connect to \(instanceLink)"

            DispatchQueue.main.asyncAfter(deadline: .now() + 1)
            {
                errorOccuredWhileConnectingToEndpoint = true

                DispatchQueue.main.asyncAfter(deadline: .now() + 2)
                {
                    withAnimation
                    {
                        isShowingEndpointDiscoverySpinner = false
                        errorOccuredWhileConnectingToEndpoint = false
                    }
                }
            }
        }
    }
}
