//
//  SignUpView+EmailConfirmationView.swift
//  Mlem
//
//  Created by Sjmarf on 07/09/2024.
//

import MlemMiddleware
import SwiftUI

extension SignUpView {
    struct EmailConfirmationView: View {
        @Environment(NavigationLayer.self) var navigation
        @Environment(Palette.self) var palette
        @Environment(\.scenePhase) var scenePhase
        
        private var timer = Timer.publish(every: 5, tolerance: 0.5, on: .main, in: .common)
            .autoconnect()
        
        let api: ApiClient
        let email: String
        let username: String
        let password: String
        
        init(api: ApiClient, email: String, username: String, password: String) {
            self.api = api
            self.email = email
            self.username = username
            self.password = password
        }
        
        var body: some View {
            VStack(spacing: Constants.main.doubleSpacing) {
                Image(systemName: Icons.email)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 100)
                    .foregroundStyle(palette.accent)
                    .padding(.bottom)
                Text("We sent an email to \(email) to verify your email address and activate your account.")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("Click on the link in the email to continue.")
                ProgressView()
                    .tint(palette.secondary)
                    .controlSize(.large)
            }
            .multilineTextAlignment(.center)
            .padding()
            .onDisappear {
                timer.upstream.connect().cancel()
            }
            .onReceive(timer) { _ in
                Task { await attemptToLogIn() }
            }
        }
        
        func attemptToLogIn() async {
            do {
                let response = try await api.logIn(
                    username: username,
                    password: password,
                    totpToken: nil
                )
                guard let token = response.jwt else { return }
                let account = try await AccountsTracker.main.logIn(username: username, url: api.baseUrl, token: token)
                navigation.dismissSheet()
                AppState.main.changeAccount(to: account)
            } catch let ApiClientError.response(response, _) where response.emailNotVerified || response.registrationApplicationIsPending {
                // no-op
            } catch {
                handleError(error)
            }
        }
    }
}
