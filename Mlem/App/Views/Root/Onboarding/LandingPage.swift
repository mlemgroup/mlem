//
//  LandingPage.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-28.
//

import Foundation
import MlemMiddleware
import SwiftUI

struct LandingPage: View {
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss
    
    enum FocusedField {
        case instance, username, password
    }
    
    enum InstanceValidationProgress {
        case debouncing, waiting, failure, success
    }
    
    @FocusState private var focusedField: FocusedField?
    
    @State var isSubmitting: Bool = false
    @State var instance: String = ""
    @State var username: String = ""
    @State var password: String = ""
    
    @State var instanceValidity: InstanceValidationProgress = .debouncing
    
    var body: some View {
        NavigationStack { instancePage() }
            .presentationBackground(Color(uiColor: .systemGroupedBackground))
    }
    
    @ViewBuilder
    func instancePage() -> some View {
        VStack {
            Image(systemName: "globe")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 50)
                .foregroundStyle(.blue)
            Text("Sign In to Lemmy")
                .font(.title)
                .bold()
            Text("Enter your instance's domain name below.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.bottom, 5)
            Spacer()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink("Next") { credentialsPage() }
                    .disabled(instanceValidity != .success)
            }
        }
        .interactiveDismissDisabled(!instance.isEmpty)
    }
    
    @ViewBuilder
    func credentialsPage() -> some View {
        VStack {
            // Text("Hello world")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemGroupedBackground))
    }

//    func tryToAddAccount() async {
//        print("Will start the account addition process")
//
//        // There should always be a match, but we return if there isn't just to be safe
//        guard let match = instance.firstMatch(of: /^(?:https?:\/\/)?(?:www\.)?(?:[\.\s]*)([^\/\?]+?)(?:[\.\s]*$|\/)/) else {
//            return
//        }
//        let sanitizedLink = String(match.1)
//
//        print("Sanitized link: \(sanitizedLink)")
//
//        do {
//            let instanceUrl = try await getCorrectURLtoEndpoint(baseInstanceAddress: sanitizedLink)
//            print("Found correct endpoint: \(instanceUrl)")
//            guard !instanceUrl.path().contains("v1") else {
//                // If the link is to a v1 instance, stop and show an error
//                // displayIncompatibleVersionAlert()
//                print("INCOMPATIBLE")
//                return
//            }
//
//            let unauthenticatedApiClient = try ApiClient.getApiClient(for: instanceUrl, with: nil)
//
//            let response = try await unauthenticatedApiClient.login(
//                username: username,
//                password: password,
//                totpToken: nil // twoFactorCode.isEmpty ? nil : twoFactorCode
//            )
//
//            guard let token = response.jwt else {
//                return
//            }
//
//            let authenticatedApiClient = try ApiClient.getApiClient(for: instanceUrl, with: token)
//
//            let newAccount = try await authenticatedApiClient.loadUser()
//

    // MARK: Save the account's credentials into the keychain

//
//            AppConstants.keychain["\(newAccount.id)_accessToken"] = response.jwt
//            AccountsTracker.main.addAccount(account: newAccount)
//
//            appState.changeUser(to: newAccount)
    ////
    ////            if !onboarding {
    ////                dismiss()
    ////            }
//        } catch {
//            print(error)
//            // handle(error)
//        }
//    }
}

// MARK: Logic

enum EndpointDiscoveryError: Error {
    case couldNotFindAnyCorrectEndpoints
}
