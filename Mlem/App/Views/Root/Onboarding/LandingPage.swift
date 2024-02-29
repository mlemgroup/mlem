//
//  LandingPage.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-28.
//

import Dependencies
import Foundation
import SwiftUI

struct LandingPage: View {
    @State var instance: String = ""
    @State var username: String = ""
    @State var password: String = ""
    
    var body: some View {
        Form {
            TextField("Instance", text: $instance)
            TextField("Username", text: $username)
            TextField("Password", text: $password)
            Button("Submit") {
                Task {
                    await tryToAddAccount()
                }
            }
        }
        .autocorrectionDisabled()
        .textInputAutocapitalization(.never)
    }
    
    func tryToAddAccount() async {
        print("Will start the account addition process")
        
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
                // displayIncompatibleVersionAlert()
                print("INCOMPATIBLE")
                return
            }
            
            let apiClient = ApiClient(baseUrl: instanceURL)
            
            print("ATTEMPTING LOGIN")
            let response = try await apiClient.login(
                username: username,
                password: password,
                totpToken: nil // twoFactorCode.isEmpty ? nil : twoFactorCode
            )
            
            print("GOT RESPONSE WITH TOKEN \(response.jwt)")
            
            let user = try await apiClient.loadPerson(username: username)
            print(user.id)
//            let newAccount = UserStub(from: user)
            ////            let newAccount = SavedAccount(
            ////                id: user.id,
            ////                instanceLink: instanceURL,
            ////                accessToken: response.jwt,
            ////                username: username,
            ////                avatarUrl: user.avatarUrl
            ////            )
//
//            // MARK: - Save the account's credentials into the keychain
//
//            AppConstants.keychain["\(newAccount.id)_accessToken"] = response.jwt
//            accountsTracker.addAccount(account: newAccount)
//
//            setFlow(.account(newAccount))
//
//            if !onboarding {
//                dismiss()
//            }
        } catch {
            print(error)
            // handle(error)
        }
    }
}

// MARK: Logic

enum EndpointDiscoveryError: Error {
    case couldNotFindAnyCorrectEndpoints
}

func getCorrectURLtoEndpoint(baseInstanceAddress: String) async throws -> URL {
    var validAddress: URL?
    
    #if targetEnvironment(simulator)
        let possibleInstanceAddresses = [
            URL(string: "https://\(baseInstanceAddress)/api/v3/user"),
            URL(string: "https://\(baseInstanceAddress)/api/v2/user"),
            URL(string: "https://\(baseInstanceAddress)/api/v1/user"),
            URL(string: "http://\(baseInstanceAddress)/api/v3/user"),
            URL(string: "http://\(baseInstanceAddress)/api/v2/user"),
            URL(string: "http://\(baseInstanceAddress)/api/v1/user")
        ]
        .compactMap { $0 }
    #else
        let possibleInstanceAddresses = [
            URL(string: "https://\(baseInstanceAddress)/api/v3/user"),
            URL(string: "https://\(baseInstanceAddress)/api/v2/user"),
            URL(string: "https://\(baseInstanceAddress)/api/v1/user")
        ]
        .compactMap { $0 }
    #endif
    
    for address in possibleInstanceAddresses {
        if await checkIfEndpointExists(at: address) {
            print("\(address) is valid")
            validAddress = address.deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            break
        } else {
            print("\(address) is invalid")
            continue
        }
    }
    
    if let validAddress {
        return validAddress
    }
    
    throw EndpointDiscoveryError.couldNotFindAnyCorrectEndpoints
}

func checkIfEndpointExists(at url: URL) async -> Bool {
    var request = URLRequest(url: url)
    
    request.httpMethod = "GET"
    
    do {
        let (_, response) = try await AppConstants.urlSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            return false
        }
        
        return httpResponse.statusCode == 400
    } catch {
        return false
    }
}
